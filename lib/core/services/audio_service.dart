// 오디오 서비스 - BGM과 효과음 재생을 관리하는 파일
import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';
import 'settings_service.dart';

/// 게임 내 모든 오디오를 중앙에서 관리하는 전역 서비스
///
/// BGM 플레이어와 효과음 플레이어를 별도로 운영합니다.
/// 사운드 재생 전 SettingsService를 확인하여 설정에 따라 재생 여부를 결정합니다.
///
/// BGM 파일     : assets/sounds/bgm.mp3 (루프 재생)
/// 효과음 파일  : assets/sounds/ 폴더의 wav/mp3 파일
class AudioService extends GetxService {
  late final AudioPlayer _bgmPlayer;
  late final AudioPlayer _sfxPlayer;

  SettingsService get _settings => Get.find<SettingsService>();

  /// 오디오 플레이어를 초기화합니다
  Future<AudioService> init() async {
    _bgmPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();
    return this;
  }

  // ──────────────────────────────────────────
  // BGM (배경음악)
  // ──────────────────────────────────────────

  /// BGM 재생을 시작합니다 (루프 반복)
  ///
  /// 설정에서 음악이 OFF면 재생하지 않습니다.
  Future<void> playBgm() async {
    if (!_settings.isMusicOn.value) return;
    await _bgmPlayer.setReleaseMode(ReleaseMode.loop);
    await _bgmPlayer.play(AssetSource('sounds/bgm.mp3'));
  }

  /// BGM을 일시 정지합니다 (앱 백그라운드 진입 시 호출)
  Future<void> pauseBgm() async {
    await _bgmPlayer.pause();
  }

  /// 일시 정지된 BGM을 재개합니다
  Future<void> resumeBgm() async {
    if (!_settings.isMusicOn.value) return;
    await _bgmPlayer.resume();
  }

  /// BGM을 완전히 멈춥니다
  Future<void> stopBgm() async {
    await _bgmPlayer.stop();
  }

  /// 음악 설정 변경 시 BGM을 즉시 반영합니다
  Future<void> applyMusicSetting() async {
    if (_settings.isMusicOn.value) {
      await playBgm();
    } else {
      await stopBgm();
    }
  }

  // ──────────────────────────────────────────
  // 효과음 (SFX)
  // ──────────────────────────────────────────

  /// 칸 채우기 효과음을 재생합니다
  void playCellFill() {
    if (!_settings.isSoundOn.value) return;
    _sfxPlayer.play(AssetSource('sounds/cell_select.wav'));
  }

  /// X 표시(빈칸 확정) 효과음을 재생합니다
  void playCellMark() {
    if (!_settings.isSoundOn.value) return;
    _sfxPlayer.play(AssetSource('sounds/tile_delete.wav'));
  }

  /// 오류 입력 효과음을 재생합니다 (Easy 모드에서 잘못 채운 칸)
  void playCellError() {
    if (!_settings.isSoundOn.value) return;
    _sfxPlayer.play(AssetSource('sounds/tile_incorrect.wav'));
  }

  /// 레벨 클리어 효과음을 재생합니다
  void playClear() {
    if (!_settings.isSoundOn.value) return;
    _sfxPlayer.play(AssetSource('sounds/level_clear.mp3'));
  }

  @override
  void onClose() {
    _bgmPlayer.dispose();
    _sfxPlayer.dispose();
    super.onClose();
  }
}
