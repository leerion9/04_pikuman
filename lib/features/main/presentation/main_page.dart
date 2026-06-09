// 메인 화면 UI: 현재 레벨 표시, Play/단어장 버튼, 하단 배너 광고를 제공합니다.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../controllers/main_controller.dart';

/// 메인 화면: 캐릭터, 현재 레벨, Play·단어장·설정 진입
class MainPage extends GetView<MainController> {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(context),
            Expanded(child: _buildCenter(context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'pikuman3 : word puzzle',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFF6B2B),
                ),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Get.toNamed(AppRoutes.settings),
          ),
        ],
      ),
    );
  }

  Widget _buildCenter(BuildContext context) {
    // 화면이 작을 경우 스크롤 가능하게, 충분히 크면 가운데 정렬
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildCharacterImage(context),
                  const SizedBox(height: 24),
                  _buildLevelAndButtons(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCharacterImage(BuildContext context) {
    final imageHeight = MediaQuery.of(context).size.height * 0.35;
    return Image.asset(
      'assets/images/pikuman_back.png',
      fit: BoxFit.contain,
      height: imageHeight,
      errorBuilder: (_, __, ___) => SizedBox(height: imageHeight),
    );
  }

  Widget _buildLevelAndButtons() {
    return Obx(() {
      final level = controller.currentLevel.value;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.orange.shade300),
            ),
            child: Text(
              '현재 레벨 : $level',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF333333),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: controller.goToGame,
                icon: const Icon(Icons.play_arrow, size: 20),
                label: const Text('PLAY'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 28, vertical: 12),
                  textStyle: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton.icon(
                onPressed: controller.goToWordbook,
                icon: const Icon(Icons.menu_book_outlined, size: 20),
                label: const Text('단어장'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 12),
                  side: const BorderSide(color: Color(0xFFFF6B2B)),
                  foregroundColor: const Color(0xFFFF6B2B),
                  textStyle: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      );
    });
  }
}
