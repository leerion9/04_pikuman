// 게임 플레이 컨트롤러 - 노노그램 게임의 상태와 로직을 담당하는 파일
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import '../../../app/routes/app_pages.dart';
import '../../../core/database/cleared_dao.dart';
import '../../../core/database/progress_dao.dart';
import '../../../core/data/puzzle_repository.dart';
import '../../../core/engine/nonogram_model.dart';
import '../../../core/engine/puzzle_validator.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/settings_service.dart';

/// 게임 플레이 화면의 상태와 비즈니스 로직을 관리합니다
///
/// 주요 기능:
/// - 퍼즐 데이터 로드 (이어하기 포함)
/// - 그리드 셀 채우기/X표시 처리 (드래그 포함)
/// - 경과 타이머 관리 (백그라운드 시 자동 일시정지)
/// - Easy 모드: 오류 즉시 표시
/// - 클리어 감지 → 결과 화면 이동
class GameController extends GetxController with WidgetsBindingObserver {
  /// 현재 플레이 중인 퍼즐 데이터 (로드 완료 전 null)
  final puzzle = Rx<NonogramPuzzle?>(null);

  /// 플레이어의 현재 그리드 입력 상태
  final progress = Rx<GameProgress?>(null);

  /// 경과 시간 (초)
  final elapsedSeconds = 0.obs;

  /// 데이터 로딩 중 여부
  final isLoading = true.obs;

  /// 현재 입력 모드 (true=채우기, false=X표시)
  final isFillMode = true.obs;

  /// Easy 모드에서 오류인 셀 좌표 집합 {row * 1000 + col}
  final errorCells = <int>{}.obs;

  Timer? _timer;
  bool _isTimerRunning = false;

  SettingsService get _settings => Get.find<SettingsService>();
  AudioService get _audio => Get.find<AudioService>();

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    // Get.arguments에서 퍼즐 ID 추출
    final args = Get.arguments as Map<String, dynamic>?;
    final puzzleId = args?['puzzleId'] as int? ?? 1;
    _loadPuzzle(puzzleId);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    // 앱 종료/화면 이탈 시 진행 상태 저장
    _saveProgress();
    super.onClose();
  }

  /// 앱 생명주기 변화 감지 (백그라운드 진입 시 타이머 정지)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      _pauseTimer();
      _saveProgress();
    } else if (state == AppLifecycleState.resumed) {
      _resumeTimer();
    }
  }

  // ──────────────────────────────────────────
  // 퍼즐 로드
  // ──────────────────────────────────────────

  /// 퍼즐 데이터와 이어하기 진행 상태를 불러옵니다
  Future<void> _loadPuzzle(int puzzleId) async {
    isLoading.value = true;

    final p = await Get.find<PuzzleRepository>().getPuzzle(puzzleId);
    if (p == null) {
      Get.back();
      Get.snackbar('오류', '퍼즐을 불러올 수 없습니다.');
      return;
    }
    puzzle.value = p;

    // 이어하기 진행 상태 로드 (없으면 새 게임 시작)
    final saved = await ProgressDao.loadProgress(
      puzzleId,
      width: p.width,
      height: p.height,
    );
    progress.value =
        saved ??
        GameProgress.empty(
          puzzleId: puzzleId,
          width: p.width,
          height: p.height,
        );
    elapsedSeconds.value = progress.value!.elapsedSeconds;

    isLoading.value = false;
    _startTimer();
  }

  // ──────────────────────────────────────────
  // 셀 입력 처리
  // ──────────────────────────────────────────

  /// 특정 셀을 탭합니다 (드래그 포함, 현재 모드에 따라 채우기/X표시)
  void tapCell(int row, int col) {
    final p = puzzle.value;
    final prog = progress.value;
    if (p == null || prog == null) return;

    final current = prog.grid[row][col];
    CellState next;

    if (isFillMode.value) {
      next = current == CellState.filled ? CellState.empty : CellState.filled;
    } else {
      next = current == CellState.marked ? CellState.empty : CellState.marked;
    }

    progress.value = prog.updateCell(row, col, next);

    // Easy 모드: 오류 즉시 표시
    _checkEasyModeError(row, col, next, p);

    // 효과음 + 진동
    if (next == CellState.filled) {
      _audio.playCellFill();
    } else if (next == CellState.marked) {
      _audio.playCellMark();
    }
    _vibrate();

    // 클리어 확인
    _checkClear(p);
  }

  /// 입력 모드를 채우기 ↔ X표시로 전환합니다
  void toggleMode() => isFillMode.value = !isFillMode.value;

  // ──────────────────────────────────────────
  // 내부 로직
  // ──────────────────────────────────────────

  /// Easy 모드에서 방금 입력한 셀이 오류인지 확인합니다
  void _checkEasyModeError(int row, int col, CellState state, NonogramPuzzle p) {
    if (!_settings.isEasyMode.value) return;
    final key = row * 1000 + col;

    if (state == CellState.empty) {
      errorCells.remove(key);
    } else if (!PuzzleValidator.isCellCorrect(row, col, state, p.solution)) {
      errorCells.add(key);
      _audio.playCellError();
      _vibrate(heavy: true);
    } else {
      errorCells.remove(key);
    }

    // trigger: errorCells는 Set이므로 직접 refresh
    // ignore: invalid_use_of_protected_member
    errorCells.refresh();
  }

  /// 클리어 여부를 확인하고 클리어면 결과 화면으로 이동합니다
  void _checkClear(NonogramPuzzle p) {
    final prog = progress.value;
    if (prog == null) return;

    if (!PuzzleValidator.isSolvedByClue(prog.grid, p)) return;

    // 클리어 처리
    _pauseTimer();
    _audio.playClear();

    // 클리어 기록 저장 + 진행 상태 삭제
    ClearedDao.saveClear(p.id, elapsedSeconds.value);
    ProgressDao.deleteProgress(p.id);

    // 현재 레벨 → 다음 레벨로 업데이트
    _advanceLevel(p.id);

    // 10레벨 클리어마다 전면 광고
    if (p.id % 10 == 0) {
      Get.find<AdService>().showInterstitialAd();
    }

    // 결과 화면으로 이동 (현재 화면 대체)
    Get.offNamed(
      Routes.result,
      arguments: {
        'puzzleId': p.id,
        'elapsedSeconds': elapsedSeconds.value,
        'title': p.title,
        'thumbnail': p.thumbnail,
      },
    );
  }

  /// 클리어 후 currentLevel을 다음 레벨로 진행시킵니다
  Future<void> _advanceLevel(int clearedId) async {
    final repo = Get.find<PuzzleRepository>();
    final nextId = await repo.getNextId(clearedId);
    if (nextId != null) {
      await Get.find<SettingsService>().setCurrentLevel(nextId);
    }
  }

  /// 현재 진행 상태를 SQLite에 저장합니다
  Future<void> _saveProgress() async {
    final prog = progress.value;
    if (prog == null) return;
    await ProgressDao.saveProgress(
      prog.updateTimer(elapsedSeconds.value),
    );
  }

  // ──────────────────────────────────────────
  // 타이머
  // ──────────────────────────────────────────

  void _startTimer() {
    _isTimerRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_isTimerRunning) elapsedSeconds.value++;
    });
  }

  void _pauseTimer() {
    _isTimerRunning = false;
  }

  void _resumeTimer() {
    if (_timer != null && !_isTimerRunning) {
      _isTimerRunning = true;
    }
  }

  // ──────────────────────────────────────────
  // 편의 메서드
  // ──────────────────────────────────────────

  /// 특정 행이 완성되었는지 (클루 흐리게 표시용)
  bool isRowComplete(int row) {
    final p = puzzle.value;
    final prog = progress.value;
    if (p == null || prog == null) return false;
    return PuzzleValidator.isRowComplete(row, prog.grid, p);
  }

  /// 특정 열이 완성되었는지 (클루 흐리게 표시용)
  bool isColComplete(int col) {
    final p = puzzle.value;
    final prog = progress.value;
    if (p == null || prog == null) return false;
    return PuzzleValidator.isColComplete(col, prog.grid, p);
  }

  /// 특정 셀이 오류 상태인지 (Easy 모드)
  bool isCellError(int row, int col) =>
      errorCells.contains(row * 1000 + col);

  /// 경과 시간을 "분:초" 포맷으로 반환합니다 (예: 3:07)
  String get timerText {
    final m = elapsedSeconds.value ~/ 60;
    final s = elapsedSeconds.value % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }

  /// 진동 피드백 (설정 ON 시만 동작)
  void _vibrate({bool heavy = false}) {
    if (!_settings.isVibrationOn.value) return;
    if (heavy) {
      HapticFeedback.heavyImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }
}
