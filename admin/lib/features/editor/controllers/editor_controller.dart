// 에디터 화면 컨트롤러 - 이미지 로드, 이진화, 그리드 편집, 저장 로직을 담당하는 파일
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../../core/engine/clue_calculator.dart';
import '../../../core/engine/nonogram_model.dart';
import '../../../core/image/image_binarizer.dart';
import '../../home/controllers/home_controller.dart';
import '../../play_test/controllers/play_test_controller.dart';
import '../../../app/routes/app_pages.dart';

/// 에디터 화면의 상태와 비즈니스 로직을 관리합니다.
///
/// 주요 기능:
/// - 이미지 파일 선택 및 로드
/// - 그리드 크기·임계값 조정 → 이진 그리드 재생성
/// - 셀 수동 토글 (마우스 클릭)
/// - 클루 자동 계산
/// - JSON 파일 저장
class EditorController extends GetxController {
  /// 저장될 출력 폴더 경로
  final String outputFolder;

  EditorController({required this.outputFolder});

  // ── 이미지 관련 ──────────────────────────
  /// 선택한 이미지 파일 경로 (null이면 아직 미선택)
  final imagePath = Rx<String?>(null);

  /// 이미지 파일 바이트 (이진화 재실행 시 재사용)
  Uint8List? _imageBytes;

  // ── 그리드 설정 ──────────────────────────
  /// 그리드 가로 칸 수
  final gridWidth = 10.obs;

  /// 그리드 세로 칸 수
  final gridHeight = 10.obs;

  /// 이진화 임계값 (0~255, 낮을수록 어두운 픽셀만 채움)
  final threshold = 128.0.obs;

  // ── 그리드 데이터 ────────────────────────
  /// 현재 편집 중인 이진 그리드 [행][열] (0=빈칸, 1=채움)
  final grid = <List<int>>[].obs;

  /// 현재 계산된 행 클루
  final rowClues = <List<int>>[].obs;

  /// 현재 계산된 열 클루
  final colClues = <List<int>>[].obs;

  // ── 퍼즐 정보 ────────────────────────────
  /// 퍼즐 제목
  final title = ''.obs;

  /// 퍼즐 레벨 ID (저장 시 파일명에 사용)
  final levelId = 1.obs;

  // ── 상태 ─────────────────────────────────
  /// 기존 퍼즐 편집 시 원본 레벨 ID (레벨 변경 시 원본 파일 삭제에 사용)
  int? _originalLevelId;

  /// 마우스 드래그 시작 시 그릴지(true) 지울지(false)
  bool? _dragFillValue;

  @override
  void onInit() {
    super.onInit();
    _initEmptyGrid();
    _calcNextLevelId();
  }

  /// 비어있는 빈 그리드로 초기화합니다.
  void _initEmptyGrid() {
    grid.assignAll(List.generate(
      gridHeight.value,
      (_) => List.filled(gridWidth.value, 0),
    ));
    _recalcClues();
  }

  /// 출력 폴더에서 다음 레벨 번호를 계산합니다.
  void _calcNextLevelId() {
    final dir = Directory(outputFolder);
    if (!dir.existsSync()) {
      levelId.value = 1;
      return;
    }
    final files = dir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.json'))
        .toList();
    levelId.value = files.length + 1;
  }

  // ──────────────────────────────────────────
  // 기존 퍼즐 편집
  // ──────────────────────────────────────────

  /// 기존 퍼즐을 불러와 편집 상태로 초기화합니다.
  /// 함께 저장된 원본 이미지가 있으면 자동으로 로드하여 임계값 조정도 가능하게 합니다.
  void loadExistingPuzzle(NonogramPuzzle puzzle) {
    // 원본 레벨 ID 기억 (저장 시 레벨이 바뀌면 원본 파일을 삭제하기 위해)
    _originalLevelId = puzzle.id;
    levelId.value = puzzle.id;
    title.value = puzzle.title;
    gridWidth.value = puzzle.gridSize.width;
    gridHeight.value = puzzle.gridSize.height;
    grid.assignAll(
      puzzle.solution.map((row) => List<int>.from(row)).toList(),
    );
    _recalcClues();

    // 함께 저장된 원본 이미지 자동 로드 (있으면 임계값 조정 활성화)
    _loadSavedImage(puzzle.id);
  }

  /// 출력 폴더에서 퍼즐에 해당하는 원본 이미지를 찾아 로드합니다.
  void _loadSavedImage(int id) {
    final base = '$outputFolder\\puzzle_${id.toString().padLeft(3, '0')}';
    for (final ext in ['.png', '.jpg', '.jpeg', '.gif', '.webp']) {
      final imgFile = File('$base$ext');
      if (imgFile.existsSync()) {
        _imageBytes = imgFile.readAsBytesSync();
        imagePath.value = imgFile.path;
        return;
      }
    }
    // 이미지 파일 없으면 초기화
    _imageBytes = null;
    imagePath.value = null;
  }

  // ──────────────────────────────────────────
  // 이미지 로드 & 이진화
  // ──────────────────────────────────────────

  /// 파일 선택 다이얼로그를 열어 이미지를 로드하고 이진화합니다.
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      dialogTitle: '변환할 이미지 선택',
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    imagePath.value = file.path;
    _imageBytes = file.bytes ?? File(file.path!).readAsBytesSync();

    _runBinarize();
  }

  /// 현재 설정(gridWidth, gridHeight, threshold)으로 이미지를 다시 이진화합니다.
  void _runBinarize() {
    if (_imageBytes == null) return;
    try {
      final newGrid = ImageBinarizer.binarizeFromBytes(
        _imageBytes!,
        gridWidth: gridWidth.value,
        gridHeight: gridHeight.value,
        threshold: threshold.value.toInt(),
      );
      grid.assignAll(newGrid);
      _recalcClues();
    } catch (e) {
      Get.snackbar('오류', '이미지 변환 실패: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  /// 임계값 변경 시 재이진화
  void onThresholdChanged(double value) {
    threshold.value = value;
    _runBinarize();
  }

  /// 그리드 크기 변경 시 재이진화 (이미지가 있으면) 또는 빈 그리드 재생성
  void onGridSizeChanged(int w, int h) {
    gridWidth.value = w;
    gridHeight.value = h;
    if (_imageBytes != null) {
      _runBinarize();
    } else {
      _initEmptyGrid();
    }
  }

  /// 흑백 반전 (배경이 검은 이미지 대응)
  void invertGrid() {
    grid.assignAll(ImageBinarizer.invertGrid(List<List<int>>.from(grid)));
    _recalcClues();
  }

  // ──────────────────────────────────────────
  // 수동 셀 편집
  // ──────────────────────────────────────────

  /// 셀을 탭하여 채움/비움 토글합니다.
  void toggleCell(int row, int col) {
    final newGrid = grid.map((r) => List<int>.from(r)).toList();
    newGrid[row][col] = newGrid[row][col] == 0 ? 1 : 0;
    grid.assignAll(newGrid);
    _recalcClues();
  }

  /// 마우스 드래그 시작 (첫 셀에서 채울지 지울지 결정)
  void startDrag(int row, int col) {
    final current = grid[row][col];
    _dragFillValue = current == 0; // 비어 있으면 채우기 모드, 채워져 있으면 지우기 모드
    _applyDrag(row, col);
  }

  /// 마우스 드래그 중 셀 적용
  void applyDrag(int row, int col) => _applyDrag(row, col);

  void _applyDrag(int row, int col) {
    if (_dragFillValue == null) return;
    if (row < 0 || row >= grid.length) return;
    if (col < 0 || col >= grid[0].length) return;

    final newGrid = grid.map((r) => List<int>.from(r)).toList();
    newGrid[row][col] = _dragFillValue! ? 1 : 0;
    grid.assignAll(newGrid);
    _recalcClues();
  }

  /// 마우스 드래그 종료
  void endDrag() => _dragFillValue = null;

  // ──────────────────────────────────────────
  // 클루 계산
  // ──────────────────────────────────────────

  /// 현재 그리드에서 행·열 클루를 다시 계산합니다.
  void _recalcClues() {
    if (grid.isEmpty) return;
    final (:rowClues, :colClues) = ClueCalculator.calculate(
      List<List<int>>.from(grid),
    );
    this.rowClues.assignAll(rowClues);
    this.colClues.assignAll(colClues);
  }

  // ──────────────────────────────────────────
  // 플레이 테스트
  // ──────────────────────────────────────────

  /// 현재 그리드를 기반으로 플레이 테스트 화면으로 이동합니다.
  void goToPlayTest() {
    if (grid.isEmpty) {
      Get.snackbar('알림', '먼저 그리드를 만들어 주세요.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final puzzle = _buildPuzzle();
    Get.put(
      PlayTestController(puzzle: puzzle),
      permanent: false,
    );
    Get.toNamed(Routes.playTest);
  }

  // ──────────────────────────────────────────
  // 저장
  // ──────────────────────────────────────────

  /// 현재 퍼즐을 JSON 파일로 저장합니다.
  ///
  /// - 새 퍼즐: outputFolder/puzzle_XXX.json 생성
  /// - 기존 퍼즐 수정: 레벨 ID가 바뀌었으면 원본 파일 삭제 후 새 파일 생성
  void savePuzzle() {
    if (title.value.trim().isEmpty) {
      Get.snackbar('알림', '퍼즐 제목을 입력해 주세요.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (grid.isEmpty) {
      Get.snackbar('알림', '먼저 그리드를 만들어 주세요.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    final padId = levelId.value.toString().padLeft(3, '0');

    // 기존 퍼즐 편집 중 레벨 ID가 바뀌었으면 원본 JSON·이미지 파일 삭제
    if (_originalLevelId != null && _originalLevelId != levelId.value) {
      final oldPad = _originalLevelId.toString().padLeft(3, '0');
      _deleteFileIfExists('$outputFolder\\puzzle_$oldPad.json');
      for (final ext in ['.png', '.jpg', '.jpeg', '.gif', '.webp']) {
        _deleteFileIfExists('$outputFolder\\puzzle_$oldPad$ext');
      }
    }

    // JSON 저장
    final puzzle = _buildPuzzle();
    final fileName = 'puzzle_$padId.json';
    File('$outputFolder\\$fileName').writeAsStringSync(
      const JsonEncoder.withIndent('  ').convert(puzzle.toJson()),
    );

    // 원본 이미지를 퍼즐 번호에 맞는 파일명으로 함께 저장
    if (_imageBytes != null && imagePath.value != null) {
      final ext = _extensionOf(imagePath.value!);
      File('$outputFolder\\puzzle_$padId$ext').writeAsBytesSync(_imageBytes!);
    }

    // 저장 후 원본 ID를 현재 ID로 업데이트 (연속 수정 시 중복 삭제 방지)
    _originalLevelId = levelId.value;

    // 홈 화면 퍼즐 목록 즉시 갱신 (프로그램 재시작 없이 반영)
    if (Get.isRegistered<HomeController>()) {
      Get.find<HomeController>().loadPuzzles();
    }

    Get.snackbar(
      '저장 완료',
      '$fileName 저장됨 → $outputFolder',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
    );
  }

  /// 현재 상태로 NonogramPuzzle 객체를 생성합니다.
  NonogramPuzzle _buildPuzzle() {
    return NonogramPuzzle(
      id: levelId.value,
      title: title.value.trim(),
      gridSize: GridSize(
        width: gridWidth.value,
        height: gridHeight.value,
      ),
      rowClues: rowClues.toList(),
      colClues: colClues.toList(),
      solution: grid.map((r) => List<int>.from(r)).toList(),
      createdAt: DateTime.now().toIso8601String().substring(0, 10),
    );
  }

  /// 채워진 칸의 비율 (품질 지표 표시용)
  double get filledRatio {
    if (grid.isEmpty) return 0.0;
    return ImageBinarizer.filledRatio(List<List<int>>.from(grid));
  }

  /// 이미지가 로드되어 있는지 여부 (임계값 슬라이더 활성화 여부 판단용)
  bool get hasImage => _imageBytes != null;

  /// 파일 경로에서 확장자를 추출합니다. (예: "cat.png" → ".png")
  String _extensionOf(String path) {
    final dot = path.lastIndexOf('.');
    if (dot == -1) return '.png';
    return path.substring(dot).toLowerCase();
  }

  /// 파일이 존재하면 삭제합니다.
  void _deleteFileIfExists(String path) {
    final f = File(path);
    if (f.existsSync()) f.deleteSync();
  }
}
