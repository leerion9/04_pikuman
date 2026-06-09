// 설정 화면 UI: 사운드·진동 토글과 앱 평가 버튼을 제공합니다.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/settings_controller.dart';

/// 구글 플레이 스토어 앱 페이지 URL (출시 후 실제 앱 ID로 교체)
const _playStoreUrl =
    'https://play.google.com/store/apps/details?id=com.interpage.pikuman3';

/// 설정 화면: 효과음·BGM·진동 토글 + 앱 평가 버튼
class SettingsPage extends GetView<SettingsController> {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B2B),
        foregroundColor: Colors.white,
        title: const Text(
          '설정',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.back,
        ),
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          children: [
            _sectionTitle('사운드'),
            _switchTile(
              title: '효과음',
              subtitle: '버튼 및 입력 효과음',
              value: controller.sfxEnabled,
              onChanged: controller.setSfx,
            ),
            _switchTile(
              title: '배경 음악',
              subtitle: '게임 중 재생되는 BGM',
              value: controller.musicEnabled,
              onChanged: controller.setMusic,
            ),
            _sectionTitle('진동'),
            _switchTile(
              title: '진동 (햅틱)',
              subtitle: '터치 시 진동 피드백',
              value: controller.vibrationEnabled,
              onChanged: (v) {
                controller.setVibration(v);
                if (v) HapticFeedback.lightImpact();
              },
            ),
            _sectionTitle('평점'),
            _buildRatingTile(),
          ],
        ),
      ),
    );
  }

  /// 섹션 구분 제목
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  /// on/off 토글 리스트 타일
  Widget _switchTile({
    required String title,
    required String subtitle,
    required RxBool value,
    required void Function(bool) onChanged,
  }) {
    return Obx(
      () => SwitchListTile(
        title: Text(title),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        value: value.value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFFFF6B2B),
      ),
    );
  }

  /// 앱 평가 버튼: 인앱 리뷰 API 우선, 실패 시 스토어로 이동
  Widget _buildRatingTile() {
    return ListTile(
      title: const Text('앱 평가하기'),
      subtitle: Row(
        children: List.generate(
          5,
          (_) => Icon(Icons.star, color: Colors.amber.shade500, size: 22),
        ),
      ),
      trailing: const Icon(Icons.open_in_new, size: 18),
      onTap: _requestReview,
    );
  }

  /// 구글 인앱 리뷰 API를 시도하고, 불가능하면 스토어 페이지로 이동합니다.
  Future<void> _requestReview() async {
    HapticFeedback.lightImpact();
    final inAppReview = InAppReview.instance;
    try {
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        // 구글이 UI 표시 여부를 제어하므로, 창이 안 떠도 정상입니다.
        Get.snackbar(
          '앱 평가',
          '',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 5),
          messageText: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '평가 창이 보이지 않을 수 있습니다.',
                style: TextStyle(color: Colors.white70),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _openPlayStore,
                  child: const Text('스토어로 이동'),
                ),
              ),
            ],
          ),
        );
        return;
      }
    } catch (_) {}
    // 인앱 리뷰 불가(미출시·사이드로드 APK 등) 시 스토어로 직접 이동
    await _openPlayStore();
  }

  /// 구글 플레이 스토어 앱 페이지를 외부 브라우저로 엽니다.
  Future<void> _openPlayStore() async {
    final uri = Uri.parse(_playStoreUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Get.snackbar('알림', '스토어를 열 수 없습니다.');
    }
  }
}
