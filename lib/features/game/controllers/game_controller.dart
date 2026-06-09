// 게임 플레이 화면의 모든 상태와 로직을 담당하는 컨트롤러입니다.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/services.dart';

import '../../../app/routes/app_pages.dart';
import '../../../core/engine/puzzle_generator.dart';
import '../../../core/engine/puzzle_model.dart';
import '../../../core/services/ad_service.dart';
import '../../../core/services/audio_service.dart';
import '../../../core/services/data_service.dart';
import '../../../core/services/level_progress_service.dart';
import '../../../core/services/save_service.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/services/wordbook_service.dart';
import '../models/game_enums.dart';

/// 게임 플레이 컨트롤러.
///
/// 주요 역할:
///  - 레벨 번호 시드로 PuzzleBoard 생성
///  - 칸 선택·음절 입력·자동 다음 빈칸 이동 처리
///  - 경과 타이머 (앱 백그라운드 시 일시 정지)
///  - 유저 힌트 (판당 2회 제한, 선택 칸 오픈 or 랜덤 빈 칸 오픈)
///  - 세이브/로드 (음절 입력·타이머·힌트 횟수를 SharedPreferences에 저장)
///  - 레벨 클리어 감지 → 저장 초기화 + 레벨 진행 업데이트 + 결과 화면 이동
class GameController extends GetxController with WidgetsBindingObserver {
  GameController(this._data, this._save, this._progress, this._wordbook);

  final DataService _data;
  final SaveService _save;
  final LevelProgressService _progress;
  final WordbookService _wordbook;

  /// 판당 유저 힌트 최대 사용 횟수
  static const int _maxHints = 2;

  // ─── 퍼즐 상태 ───────────────────────────────────────────
  late PuzzleBoard _puzzle;
  late int _level;
  late Set<(int, int)> _hintPositions; // 퍼즐 힌트 타일 좌표 집합

  // ─── 반응형 상태 ─────────────────────────────────────────
  /// 사용자 입력 맵: 키="row,col", 값=입력 음절
  final _userInputs = <String, String>{}.obs;

  /// 현재 선택된 칸 (null 이면 선택 없음)
  final selectedPos = Rxn<(int, int)>();

  /// 현재 활성 단어 인덱스 (placedWords 기준, null 이면 없음)
  final currentWordIndex = RxnInt();

  /// 경과 시간 (초)
  final elapsedSeconds = 0.obs;

  /// 레벨 클리어 여부
  final isLevelComplete = false.obs;

  /// 유저가 이번 판에 사용한 힌트 횟수
  final hintsUsed = 0.obs;

  /// 음절 팔레트 (반응형).
  ///
  /// 아직 칸에 배치되지 않은 음절 목록입니다.
  /// 힌트 타일(미리 오픈된 칸)은 처음부터 포함하지 않습니다.
  /// 음절이 칸에 입력되면 팔레트에서 제거되고, 단어 초기화 시 다시 추가됩니다.
  final palette = <String>[].obs;

  /// 정답으로 확정된 단어의 인덱스 목록 (반응형).
  ///
  /// 단어의 모든 빈 칸이 채워지고 모두 정답인 경우에만 추가됩니다.
  /// 단어가 초기화되면 제거됩니다.
  final _judgedWords = <int>[].obs;

  /// 모든 칸이 채워졌지만 오답인 단어 인덱스 (반응형).
  ///
  /// 마지막 음절 입력 직후 즉시 오답 표시·취소 가능하도록 별도 추적합니다.
  final _wrongWords = <int>[].obs;

  Timer? _timer;

  /// 결과 화면 이동 중복 방지
  bool _navigatedToResult = false;

  // ─── 공개 게터 ───────────────────────────────────────────
  PuzzleBoard get puzzle => _puzzle;
  int get level => _level;

  /// 이번 판에 남은 힌트 사용 횟수
  int get remainingHints => _maxHints - hintsUsed.value;

  /// 현재 활성화된 단어 (없으면 null)
  PlacedWord? get currentWord {
    final idx = currentWordIndex.value;
    if (idx == null || idx >= _puzzle.placedWords.length) return null;
    return _puzzle.placedWords[idx];
  }

  /// 경과 시간을 "MM:SS" 형식으로 반환합니다.
  String get formattedTime {
    final m = elapsedSeconds.value ~/ 60;
    final s = elapsedSeconds.value % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ─── 생명주기 ────────────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    _level = Get.arguments as int? ?? 1;
    _initPuzzle();
    _loadSavedState();
    _syncPaletteAfterLoad(); // 저장된 상태 반영: 이미 정답이 입력된 칸의 음절 제거
    _startTimer();
    ever(isLevelComplete, _handleLevelComplete);
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        if (!isLevelComplete.value) _startTimer();
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.detached:
        _timer?.cancel();
        _saveState(); // 백그라운드 진입 시 즉시 저장
    }
  }

  // ─── 초기화 ──────────────────────────────────────────────
  void _initPuzzle() {
    _puzzle = PuzzleGenerator.generate(
      level: _level,
      wordPool: _data.wordPool,
      designs: _data.levelDesigns,
    );
    _hintPositions = {
      for (final h in _puzzle.hintTiles) (h.row, h.col),
    };
    _buildPalette();
  }

  /// 빈 칸(힌트 타일 제외)의 정답 음절 목록을 셔플하여 팔레트를 초기화합니다.
  ///
  /// 힌트 타일은 이미 정답이 표시되므로 팔레트에 포함하지 않습니다.
  /// 교차점 칸은 두 단어에 걸쳐 있지만 물리적으로 하나의 칸이므로
  /// 좌표 Set으로 중복을 방지하여 정확히 1번만 추가합니다.
  void _buildPalette() {
    final syllables = <String>[];
    final addedPositions = <(int, int)>{}; // 이미 추가된 칸 좌표 (교차점 중복 방지)
    for (final pw in _puzzle.placedWords) {
      for (int i = 0; i < pw.length; i++) {
        final (r, c) = pw.positions[i];
        if (_isHint(r, c)) continue; // 힌트 타일은 이미 오픈됨 → 팔레트 불필요
        if (addedPositions.contains((r, c))) continue; // 교차점 중복 추가 방지
        addedPositions.add((r, c));
        syllables.add(pw.word.word[i]);
      }
    }
    syllables.shuffle(Random(_level + 999));
    palette.assignAll(syllables);
  }

  /// 저장된 상태 로드 후 팔레트와 _judgedWords를 동기화합니다.
  ///
  /// - 이미 입력된 칸의 음절은 팔레트에서 제거합니다 (정답/오답 무관).
  /// - 교차점 중복 제거를 방지하기 위해 좌표 Set으로 처리된 칸을 추적합니다.
  /// - 완전히 채워지고 모두 정답인 단어는 _judgedWords에 추가합니다.
  void _syncPaletteAfterLoad() {
    // 입력된 모든 음절을 팔레트에서 제거 (교차점은 한 번만 처리)
    final removedPositions = <(int, int)>{};
    for (final pw in _puzzle.placedWords) {
      for (int i = 0; i < pw.length; i++) {
        final (r, c) = pw.positions[i];
        if (_isHint(r, c)) continue;
        if (removedPositions.contains((r, c))) continue; // 교차점 중복 방지
        final input = _userInputs['$r,$c'];
        if (input != null) {
          removedPositions.add((r, c));
          palette.remove(input);
        }
      }
    }
    // 완성된 단어를 정답/오답 목록에 등록
    for (int i = 0; i < _puzzle.placedWords.length; i++) {
      final pw = _puzzle.placedWords[i];
      if (!_isWordInputFull(pw)) continue;
      if (_isWordComplete(pw)) {
        _judgedWords.add(i);
      } else {
        _wrongWords.add(i);
      }
    }
  }

  // ─── 세이브/로드 ─────────────────────────────────────────
  /// 이전에 저장된 게임 진행 상태를 복원합니다.
  /// 저장 데이터가 없거나 다른 레벨의 데이터면 무시합니다.
  void _loadSavedState() {
    final saved = _save.load(_level);
    if (saved == null) return;

    elapsedSeconds.value = saved['elapsed'] as int;
    hintsUsed.value = saved['hintsUsed'] as int;

    final inputs = saved['inputs'] as Map<String, String>;
    _userInputs.addAll(inputs);
  }

  /// 현재 게임 진행 상태를 로컬에 저장합니다.
  Future<void> _saveState() async {
    await _save.save(
      level: _level,
      elapsedSeconds: elapsedSeconds.value,
      hintsUsed: hintsUsed.value,
      inputs: Map<String, String>.from(_userInputs),
    );
  }

  // ─── 타이머 ──────────────────────────────────────────────
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => elapsedSeconds.value++,
    );
  }

  // ─── 칸 선택 ─────────────────────────────────────────────
  /// [row], [col] 칸을 선택합니다.
  ///
  /// 칸 상태에 따른 동작:
  ///  - 정답 확정 칸(correct): 수정 불가. 교차점에서 미완성 단어가 있으면 그 단어로 전환.
  ///  - 입력된 칸(filled/incorrect): 해당 칸 하나만 팔레트로 반환 후 그 칸 선택.
  ///  - 빈 칸(empty/activeWord): 기존 선택 로직 (가로 우선, 교차점 방향 전환).
  void onCellTap(int row, int col) {
    if (isLevelComplete.value) return;
    if (_puzzle.grid[row][col].isEmpty) return;

    final pos = (row, col);
    final wordsHere = _puzzle.placedWords
        .where((w) => w.positions.contains(pos))
        .toList();
    if (wordsHere.isEmpty) return;

    // ── 정답 확정 칸: 수정 불가 (교차점은 미완성 단어 방향 전환만) ──
    if (_isCellLocked(row, col)) {
      final incompleteWords = wordsHere
          .where((w) => !_judgedWords.contains(_puzzle.placedWords.indexOf(w)))
          .toList();
      if (incompleteWords.isEmpty) return;
      final horiz = incompleteWords
          .where((w) => w.direction == Direction.across)
          .firstOrNull;
      currentWordIndex.value =
          _puzzle.placedWords.indexOf(horiz ?? incompleteWords.first);
      selectedPos.value = pos;
      _audio.playCellSelectSound();
      return;
    }

    // ── 입력된 칸: 탭하면 해당 칸만 팔레트로 반환 (선택 칸 재탭 포함) ──
    if (_hasInput(row, col) && !_isHint(row, col)) {
      _clearSingleCell(row, col);
      final validWords = wordsHere
          .where((w) => !_judgedWords.contains(_puzzle.placedWords.indexOf(w)))
          .toList();
      if (validWords.isNotEmpty) {
        final horiz = validWords
            .where((w) => w.direction == Direction.across)
            .firstOrNull;
        currentWordIndex.value =
            _puzzle.placedWords.indexOf(horiz ?? validWords.first);
      }
      selectedPos.value = pos;
      _audio.playCellSelectSound();
      return;
    }

    // ── 빈 칸: 선택 로직 ───────────────────────────────────
    final validWords = wordsHere
        .where((w) => !_judgedWords.contains(_puzzle.placedWords.indexOf(w)))
        .toList();
    if (validWords.isEmpty) return;

    if (selectedPos.value == pos && validWords.length > 1) {
      // 교차점 재선택 → 미완성 단어 중 방향 전환
      final curDir = currentWord?.direction;
      final toggled = validWords.firstWhere(
        (w) => w.direction != curDir,
        orElse: () => validWords.first,
      );
      currentWordIndex.value = _puzzle.placedWords.indexOf(toggled);
    } else {
      // 새 칸 선택: 가로 단어 우선
      final horiz = validWords
          .where((w) => w.direction == Direction.across)
          .firstOrNull;
      currentWordIndex.value =
          _puzzle.placedWords.indexOf(horiz ?? validWords.first);
    }
    selectedPos.value = pos;
    _audio.playCellSelectSound();
  }

  // ─── 음절 입력 ───────────────────────────────────────────

  /// [row],[col]에 음절을 새로 넣을 수 있는지 확인합니다 (UI·애니메이션 가드).
  bool canAcceptSyllableAt(int row, int col) {
    if (isLevelComplete.value) return false;
    if (_isHint(row, col)) return false;
    if (_isCellLocked(row, col)) return false;
    if (_hasInput(row, col)) return false;
    return true;
  }

  /// 팔레트에서 [syllable] 을 선택해 현재 칸에 입력합니다.
  ///
  /// 동작 규칙:
  ///  - 정답 확정된 단어의 칸은 수정 불가 → 무시합니다.
  ///  - 단어의 모든 빈 칸이 채워진 후에 정답 여부를 판별합니다.
  ///  - 정답 확정 시 → 다음 미완성 단어로 커서 자동 이동.
  ///  - 오답 시 → 현재 위치 유지 (사용자가 개별 타일 탭으로 수정).
  ///
  /// 입력이 적용되면 true, 무시되면 false를 반환합니다.
  bool onSyllableTap(String syllable) {
    final pos = selectedPos.value;
    if (pos == null || isLevelComplete.value) return false;
    if (_isHint(pos.$1, pos.$2)) return false;

    // 정답 확정된 단어의 칸은 수정 불가
    final isInJudgedWord = _puzzle.placedWords.any((w) =>
        _judgedWords.contains(_puzzle.placedWords.indexOf(w)) &&
        w.positions.contains(pos));
    if (isInJudgedWord) return false;

    // 이미 입력된 칸에는 덮어쓰지 않음 (오답 단어 마지막 음절 등 → 팔레트 소모 방지)
    if (_hasInput(pos.$1, pos.$2)) return false;

    _userInputs['${pos.$1},${pos.$2}'] = syllable;
    palette.remove(syllable); // 입력된 음절은 팔레트에서 즉시 제거

    // 이 칸이 속한 모든 단어에 대해 완성 여부 확인 후 정답/오답 판별
    final wordsAtPos = _puzzle.placedWords
        .where((w) => w.positions.contains(pos))
        .toList();

    bool anyWordCompleted = false;
    bool anyWrongAnswer = false;

    for (final word in wordsAtPos) {
      final wordIdx = _puzzle.placedWords.indexOf(word);
      if (_judgedWords.contains(wordIdx)) continue; // 이미 확정된 단어 건너뜀
      if (!_isWordInputFull(word)) continue; // 아직 미완성 단어 건너뜀

      if (_isWordComplete(word)) {
        _wrongWords.remove(wordIdx);
        if (!_judgedWords.contains(wordIdx)) {
          _judgedWords.add(wordIdx);
        }
        anyWordCompleted = true;
      } else {
        if (!_wrongWords.contains(wordIdx)) {
          _wrongWords.add(wordIdx);
        }
        anyWrongAnswer = true;
      }
    }

    // 효과음·이동 처리
    if (anyWrongAnswer) {
      _audio.playWrongAnswerSound();
      _vibrate();
      // 오답 시 현재 위치 유지 (사용자가 타일 탭으로 개별 수정)
    } else if (anyWordCompleted) {
      _audio.playWordCompleteSound();
      _moveToNextIncompleteWord(); // 정답 확정 후 다음 미완성 단어로 커서 이동
    } else {
      _autoMove(pos); // 미완성: 같은 단어의 다음 빈칸으로 이동
    }

    _saveState();
    _checkLevelComplete();
    return true;
  }

  /// [word] 의 모든 비-힌트 칸에 입력값이 있는지 확인합니다 (정답 여부 무관).
  bool _isWordInputFull(PlacedWord word) {
    for (int i = 0; i < word.length; i++) {
      final (r, c) = word.positions[i];
      if (_isHint(r, c)) continue;
      if (!_hasInput(r, c)) return false;
    }
    return true;
  }

  /// [row], [col] 칸 하나의 입력만 초기화하고 팔레트로 돌려보냅니다.
  ///
  /// 정답 확정 단어에 속한 칸은 초기화하지 않습니다.
  void _clearSingleCell(int row, int col) {
    if (_isHint(row, col)) return;
    if (_isCellLocked(row, col)) return;

    final input = _userInputs['$row,$col'];
    if (input != null) {
      palette.add(input);
      _userInputs.remove('$row,$col');
      _invalidateWordsAt(row, col);
      _saveState();
    }
  }

  /// [row],[col] 칸이 속한 단어 중 오답·정답 확정 상태를 해제합니다.
  void _invalidateWordsAt(int row, int col) {
    final pos = (row, col);
    for (int i = 0; i < _puzzle.placedWords.length; i++) {
      if (_puzzle.placedWords[i].positions.contains(pos)) {
        _wrongWords.remove(i);
        _judgedWords.remove(i);
      }
    }
  }

  /// 정답으로 확정된 단어에만 속한 칸이면 수정·취소 불가입니다.
  bool _isCellLocked(int row, int col) {
    final pos = (row, col);
    final wordsHere = _puzzle.placedWords
        .where((w) => w.positions.contains(pos))
        .toList();
    if (wordsHere.isEmpty) return false;
    return wordsHere.every(
      (w) => _judgedWords.contains(_puzzle.placedWords.indexOf(w)),
    );
  }

  /// [row],[col] 칸이 현재 선택(커서) 위치인지 여부 (테두리 표시용).
  bool isSelected(int row, int col) => selectedPos.value == (row, col);

  /// 정답 확정 후, 아직 완성되지 않은 다음 단어의 첫 번째 빈칸으로 커서를 이동합니다.
  ///
  /// 가로(across) 단어를 세로(down) 단어보다 우선합니다.
  void _moveToNextIncompleteWord() {
    final incompleteWords = <PlacedWord>[];
    // 가로 단어 먼저
    for (int i = 0; i < _puzzle.placedWords.length; i++) {
      if (_judgedWords.contains(i)) continue;
      if (_puzzle.placedWords[i].direction == Direction.across) {
        incompleteWords.add(_puzzle.placedWords[i]);
      }
    }
    // 세로 단어
    for (int i = 0; i < _puzzle.placedWords.length; i++) {
      if (_judgedWords.contains(i)) continue;
      if (_puzzle.placedWords[i].direction == Direction.down) {
        incompleteWords.add(_puzzle.placedWords[i]);
      }
    }
    if (incompleteWords.isEmpty) return; // 모든 단어 완성

    final nextWord = incompleteWords.first;
    currentWordIndex.value = _puzzle.placedWords.indexOf(nextWord);
    // 첫 번째 빈칸으로 이동 (힌트·이미 입력된 칸 제외)
    for (int i = 0; i < nextWord.length; i++) {
      final (r, c) = nextWord.positions[i];
      if (!_isHint(r, c) && !_hasInput(r, c)) {
        selectedPos.value = (r, c);
        return;
      }
    }
    // 빈 칸이 없으면 첫 칸으로 (모든 칸이 힌트로 채워진 경우)
    selectedPos.value = nextWord.positions.first;
  }

  /// 입력 후 현재 단어에서 다음 빈 칸으로 커서를 자동 이동합니다.
  void _autoMove((int, int) from) {
    final cw = currentWord;
    if (cw == null) return;
    final idx = cw.positions.indexOf(from);
    if (idx == -1) return;

    for (int i = idx + 1; i < cw.length; i++) {
      final next = cw.positions[i];
      if (!_isHint(next.$1, next.$2) && !_hasInput(next.$1, next.$2)) {
        selectedPos.value = next;
        return;
      }
    }
    // 현재 단어에 남은 빈 칸 없음 → 위치 유지
  }

  // ─── 힌트 기능 ───────────────────────────────────────────
  /// 힌트 버튼을 눌렀을 때 호출됩니다.
  ///
  /// 동작 규칙:
  ///  - 남은 힌트가 0이면 아무것도 하지 않습니다.
  ///  - 비어 있는 칸이 선택된 상태 → 해당 칸을 정답으로 오픈합니다.
  ///  - 선택 없음 또는 이미 채워진 칸 선택 → 아직 비어 있는 칸 중 하나를 랜덤 선택 후 오픈합니다.
  void onHintTap() {
    if (isLevelComplete.value) return;
    if (remainingHints <= 0) return;

    final pos = selectedPos.value;
    // 선택된 칸이 비어 있는 경우 → 그 칸을 오픈
    if (pos != null &&
        !_isHint(pos.$1, pos.$2) &&
        !_hasInput(pos.$1, pos.$2)) {
      _revealCell(pos.$1, pos.$2);
      return;
    }

    // 그 외 → 비어 있는 칸 중 랜덤 선택
    _revealRandomEmptyCell();
  }

  /// [row],[col] 칸을 정답 음절로 채우고, 팔레트에서 해당 음절을 제거하며,
  /// 힌트 사용 횟수를 1 증가시킵니다. 힌트로 단어가 완성되면 _judgedWords에 추가합니다.
  void _revealCell(int row, int col) {
    final correctSyllable = _puzzle.grid[row][col];
    _userInputs['$row,$col'] = correctSyllable;
    palette.remove(correctSyllable);
    hintsUsed.value++;

    // 이 칸이 속한 단어들이 힌트로 완성됐는지 확인
    final pos = (row, col);
    for (int i = 0; i < _puzzle.placedWords.length; i++) {
      final pw = _puzzle.placedWords[i];
      if (!pw.positions.contains(pos)) continue;
      if (_judgedWords.contains(i)) continue;
      if (!_isWordInputFull(pw)) continue;
      if (_isWordComplete(pw)) {
        _wrongWords.remove(i);
        _judgedWords.add(i);
      } else {
        _wrongWords.add(i);
      }
    }

    _saveState();
    _checkLevelComplete();
  }

  /// 아직 비어 있는 칸(퍼즐 힌트·정답이 아닌) 중 하나를 랜덤 선택해 오픈합니다.
  void _revealRandomEmptyCell() {
    final emptyCells = <(int, int)>[];
    for (final pw in _puzzle.placedWords) {
      for (int i = 0; i < pw.length; i++) {
        final (r, c) = pw.positions[i];
        if (!_isHint(r, c) && !_hasInput(r, c)) {
          emptyCells.add((r, c));
        }
      }
    }
    if (emptyCells.isEmpty) return;

    final chosen = emptyCells[Random().nextInt(emptyCells.length)];
    _revealCell(chosen.$1, chosen.$2);
    selectedPos.value = chosen; // 오픈된 칸으로 커서 이동
  }

  // ─── 레벨 클리어 감지 ────────────────────────────────────
  /// 모든 단어가 정답으로 확정됐는지 확인합니다.
  ///
  /// [_judgedWords]에 모든 단어 인덱스가 포함된 경우 레벨 클리어로 처리합니다.
  void _checkLevelComplete() {
    if (_judgedWords.length >= _puzzle.placedWords.length) {
      isLevelComplete.value = true;
      _timer?.cancel();
    }
  }

  /// 레벨 클리어 시 처리합니다.
  /// 단어 저장 → 게임 상태 삭제 → 레벨 진행 업데이트 → 결과 화면으로 이동.
  void _handleLevelComplete(bool complete) {
    if (!complete || _navigatedToResult) return;
    _navigatedToResult = true;

    _audio.playLevelClearSound();
    _tryShowInterstitial();

    Future.delayed(const Duration(milliseconds: 500), () async {
      if (isClosed) return;

      final wordEntries = _puzzle.placedWords
          .map((pw) => WordEntry(word: pw.word.word, meaning: pw.word.meaning))
          .toList();
      await _wordbook.saveLevel(_level, wordEntries);
      if (isClosed) return;

      await _save.clear();
      if (isClosed) return;

      await _progress.setCurrentLevel(_level + 1);
      if (isClosed) return;

      Get.offNamed(
        AppRoutes.result,
        arguments: {
          'level': _level,
          'elapsed': elapsedSeconds.value,
          'words': _puzzle.placedWords,
        },
      );
    });
  }

  // ─── 칸 상태 조회 (그리드 위젯에서 사용) ─────────────────
  /// [row], [col] 칸의 시각적 표시 상태를 반환합니다.
  ///
  /// 정답 판별은 단어 전체가 채워진 후에만 이루어집니다.
  /// 입력됐지만 단어가 아직 미완성인 경우 [CellDisplayState.filled]를 반환합니다.
  CellDisplayState cellState(int row, int col) {
    if (_puzzle.grid[row][col].isEmpty) return CellDisplayState.inactive;
    if (_isHint(row, col)) return CellDisplayState.hint;

    final input = _userInputs['$row,$col'];
    if (input != null) {
      final wordsHere = _puzzle.placedWords
          .where((w) => w.positions.contains((row, col)))
          .toList();

      // 오답 확정(전체 채움·오답) 단어 → 빨간색
      if (wordsHere.any(
        (w) => _wrongWords.contains(_puzzle.placedWords.indexOf(w)),
      )) {
        return CellDisplayState.incorrect;
      }

      // 정답 확정 단어에만 속한 칸 → 파란색
      if (wordsHere.every(
        (w) => _judgedWords.contains(_puzzle.placedWords.indexOf(w)),
      )) {
        return CellDisplayState.correct;
      }

      // 입력됐지만 단어 미완성 또는 판별 전
      return CellDisplayState.filled;
    }

    return CellDisplayState.empty;
  }

  /// [row], [col] 칸에 표시할 글자를 반환합니다.
  /// 퍼즐 힌트 칸이면 정답 글자, 그 외엔 사용자 입력값 (없으면 null).
  String? displayLetter(int row, int col) {
    if (_isHint(row, col)) return _puzzle.grid[row][col];
    return _userInputs['$row,$col'];
  }

  bool _isHint(int row, int col) => _hintPositions.contains((row, col));
  bool _hasInput(int row, int col) => _userInputs.containsKey('$row,$col');

  /// [word] 의 모든 칸이 정답으로 채워졌는지 확인합니다 (힌트 칸 포함).
  bool _isWordComplete(PlacedWord word) {
    for (int i = 0; i < word.length; i++) {
      final (r, c) = word.positions[i];
      if (_isHint(r, c)) continue;
      if (_userInputs['$r,$c'] != word.word.word[i]) return false;
    }
    return true;
  }

  // ─── 사운드·진동·광고 헬퍼 ──────────────────────────────
  /// AudioService 를 반환합니다 (항상 등록되어 있음).
  AudioService get _audio => Get.find<AudioService>();

  /// 진동 설정이 켜져 있으면 햅틱 피드백을 발생시킵니다.
  void _vibrate() {
    try {
      if (Get.find<SettingsService>().vibrationEnabled) {
        HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }

  /// 10레벨마다 전면 광고를 표시합니다.
  void _tryShowInterstitial() {
    try {
      Get.find<AdService>().showInterstitialEvery10Levels(_level);
    } catch (_) {}
  }

  void goBack() => Get.back();
}
