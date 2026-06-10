// 홈 화면 컨트롤러 - 저장된 퍼즐 목록 조회 및 관리 로직
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import '../../../core/engine/nonogram_model.dart';
import '../../editor/controllers/editor_controller.dart';
import '../../../app/routes/app_pages.dart';

/// 홈 화면의 상태와 비즈니스 로직을 관리합니다.
///
/// - 출력 폴더(output 폴더)에서 저장된 퍼즐 JSON 파일을 읽어 목록으로 표시
/// - 새 퍼즐 만들기, 기존 퍼즐 열기 기능 제공
class HomeController extends GetxController {
  /// 현재 출력 폴더 경로 (사용자가 변경 가능)
  final outputFolder = ''.obs;

  /// 출력 폴더에서 불러온 퍼즐 목록
  final puzzles = <NonogramPuzzle>[].obs;

  /// 로딩 중 여부
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 기본 출력 폴더: 현재 실행 위치 기준 output/ 폴더
    final defaultFolder = '${Directory.current.path}\\output';
    outputFolder.value = defaultFolder;
    _ensureOutputFolder();
    loadPuzzles();
  }

  /// output 폴더가 없으면 생성합니다.
  void _ensureOutputFolder() {
    final dir = Directory(outputFolder.value);
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
  }

  /// 출력 폴더에서 모든 puzzle_XXX.json 파일을 읽어 목록을 갱신합니다.
  void loadPuzzles() {
    isLoading.value = true;
    try {
      final dir = Directory(outputFolder.value);
      if (!dir.existsSync()) {
        puzzles.clear();
        return;
      }

      final jsonFiles = dir
          .listSync()
          .whereType<File>()
          .where((f) => f.path.endsWith('.json'))
          .toList();

      // 파일명 기준으로 정렬
      jsonFiles.sort((a, b) => a.path.compareTo(b.path));

      final loaded = <NonogramPuzzle>[];
      for (final file in jsonFiles) {
        try {
          final content = file.readAsStringSync();
          loaded.add(NonogramPuzzle.fromJsonString(content));
        } catch (_) {
          // 잘못된 형식의 파일은 무시
        }
      }
      puzzles.assignAll(loaded);
    } finally {
      isLoading.value = false;
    }
  }

  /// 출력 폴더 변경 다이얼로그 열기
  Future<void> changeOutputFolder() async {
    final result = await FilePicker.platform.getDirectoryPath(
      dialogTitle: '퍼즐 저장 폴더 선택',
    );
    if (result != null) {
      outputFolder.value = result;
      _ensureOutputFolder();
      loadPuzzles();
    }
  }

  /// 새 퍼즐 만들기 화면으로 이동합니다.
  void createNewPuzzle() {
    Get.put(EditorController(outputFolder: outputFolder.value), permanent: false);
    Get.toNamed(Routes.editor);
  }

  /// 기존 퍼즐을 열어 편집 화면으로 이동합니다.
  void openPuzzle(NonogramPuzzle puzzle) {
    final controller = EditorController(outputFolder: outputFolder.value);
    controller.loadExistingPuzzle(puzzle);
    Get.put(controller, permanent: false);
    Get.toNamed(Routes.editor);
  }

  /// 퍼즐 파일을 삭제합니다.
  void deletePuzzle(NonogramPuzzle puzzle) {
    final fileName = 'puzzle_${puzzle.id.toString().padLeft(3, '0')}.json';
    final file = File('${outputFolder.value}\\$fileName');
    if (file.existsSync()) {
      file.deleteSync();
    }
    loadPuzzles();
  }
}
