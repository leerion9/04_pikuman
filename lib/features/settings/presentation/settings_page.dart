// 설정 화면 파일 - 사운드·진동·오류표시 토글과 평점 버튼을 표시하는 화면
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../../../core/services/settings_service.dart';

/// 설정 화면
///
/// 구성:
/// - 배경음악 ON/OFF 토글
/// - 효과음 ON/OFF 토글
/// - 진동 ON/OFF 토글
/// - 오류 즉시 표시(Easy 모드) ON/OFF 토글
/// - 평점 남기기 버튼 (인앱 리뷰 → 스토어 이동 fallback)
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SettingsController>();
    final settings = Get.find<SettingsService>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── 소리 설정 ──
          _SectionHeader(title: '소리'),
          Obx(
            () => _SettingsTile(
              icon: Icons.music_note_outlined,
              title: '배경음악',
              subtitle: '게임 진행 중 배경음악을 재생합니다',
              value: settings.isMusicOn.value,
              onChanged: (_) => controller.toggleMusic(),
            ),
          ),
          Obx(
            () => _SettingsTile(
              icon: Icons.volume_up_outlined,
              title: '효과음',
              subtitle: '셀 채우기, 클리어 등의 효과음',
              value: settings.isSoundOn.value,
              onChanged: (_) => controller.toggleSound(),
            ),
          ),
          const SizedBox(height: 8),

          // ── 기타 설정 ──
          _SectionHeader(title: '기타'),
          Obx(
            () => _SettingsTile(
              icon: Icons.vibration,
              title: '진동',
              subtitle: '셀 입력 시 햅틱 피드백',
              value: settings.isVibrationOn.value,
              onChanged: (_) => controller.toggleVibration(),
            ),
          ),
          Obx(
            () => _SettingsTile(
              icon: Icons.bug_report_outlined,
              title: 'Easy 모드',
              subtitle: '잘못 채운 칸을 즉시 표시합니다',
              value: settings.isEasyMode.value,
              onChanged: (_) => controller.toggleEasyMode(),
            ),
          ),
          const SizedBox(height: 8),

          // ── 앱 평가 ──
          _SectionHeader(title: '앱 정보'),
          const SizedBox(height: 8),
          _RateButton(onPressed: controller.requestReview),
          const SizedBox(height: 24),

          // 앱 버전 표시
          const Center(
            child: Text(
              'pikuman4 : nonogram  v1.0.0',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

/// 섹션 헤더 (예: "소리", "기타")
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Color(0xFFE53935),
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

/// 토글 스위치가 있는 설정 항목 타일
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        secondary: Icon(icon, color: const Color(0xFFE53935)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        value: value,
        activeThumbColor: const Color(0xFFE53935),
        activeTrackColor: const Color(0xFFFF8A80),
        onChanged: onChanged,
      ),
    );
  }
}

/// 평점 남기기 버튼
class _RateButton extends StatelessWidget {
  const _RateButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: const Icon(Icons.star_outline, color: Colors.amber),
        title: const Text(
          '앱 평가하기',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '구글 플레이스토어에서 리뷰를 남겨주세요!',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: onPressed,
      ),
    );
  }
}
