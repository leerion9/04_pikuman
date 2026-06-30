// 메인 화면 파일 - 캐릭터, 현재 레벨, Play/갤러리 버튼을 표시하는 화면
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import '../../../core/services/settings_service.dart';
import '../../../core/widgets/banner_ad_widget.dart';

/// 메인 화면
///
/// 구성 요소:
/// - pikuMAN 캐릭터 이미지
/// - "현재 레벨 : N" 표시
/// - Play 버튼 (게임 화면 이동)
/// - 갤러리 버튼 (클리어 퍼즐 모음)
/// - 설정 버튼 (상단 우측)
/// - 하단 배너 광고
class MainPage extends StatelessWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<MainController>();
    final settings = Get.find<SettingsService>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      // 설정 버튼 (상단 우측)
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.brown),
            tooltip: '설정',
            onPressed: controller.onSettingsPressed,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // pikuMAN 캐릭터 이미지
                    _CharacterImage(),
                    const SizedBox(height: 32),
                    // 앱 이름
                    const Text(
                      'pikuman4',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE53935),
                        letterSpacing: 1,
                      ),
                    ),
                    const Text(
                      ': nonogram',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.brown,
                      ),
                    ),
                    const SizedBox(height: 40),
                    // 현재 레벨 표시
                    Obx(
                      () => _LevelBadge(level: settings.currentLevel.value),
                    ),
                    const SizedBox(height: 32),
                    // Play 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: controller.onPlayPressed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE53935),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                        ),
                        child: const Text(
                          'PLAY',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // 갤러리 버튼
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: controller.onGalleryPressed,
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          color: Color(0xFFE53935),
                        ),
                        label: const Text(
                          '갤러리',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFFE53935),
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFE53935),
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      // 하단 배너 광고
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}

/// pikuMAN 캐릭터 이미지 (없으면 기본 이모지)
class _CharacterImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/ch1.png',
      height: 180,
      errorBuilder: (_, __, ___) => const Text(
        '👾',
        style: TextStyle(fontSize: 120),
      ),
    );
  }
}

/// 현재 레벨 번호를 강조 표시하는 뱃지 위젯
class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: const Color(0xFFE53935), width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        '현재 레벨 : $level',
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xFFE53935),
        ),
      ),
    );
  }
}
