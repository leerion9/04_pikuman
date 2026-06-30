// 스플래시 화면 파일 - 앱 시작 로고와 로딩 화면을 표시하는 파일
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/splash_controller.dart';

/// 스플래시 화면
///
/// 단계 0 (Splash 1): 하늘색 배경 + interpage 회사 로고 (2초)
/// 단계 1 (Splash 2): 빨간 배경 + pikuMAN 캐릭터 + 앱 이름 + 로딩 메시지
class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<SplashController>();
    return Obx(() {
      return AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: controller.phase.value == 0
            ? const _Splash1(key: ValueKey('splash1'))
            : _Splash2(controller: controller, key: const ValueKey('splash2')),
      );
    });
  }
}

/// 스플래시 1: 하늘색 배경 + interpage 로고
class _Splash1 extends StatelessWidget {
  const _Splash1({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF87CEEB),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // interpage 로고 이미지
            _LogoImage(
              path: 'assets/splash/splash_1.png',
              fallbackText: 'interpage',
            ),
            SizedBox(height: 20),
            Text(
              'interpage',
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 스플래시 2: 빨간 배경 + pikuMAN 캐릭터 + 로딩
class _Splash2 extends StatelessWidget {
  const _Splash2({required this.controller, super.key});

  final SplashController controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE53935),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // pikuMAN 캐릭터 이미지
              const _LogoImage(
                path: 'assets/splash/splash_2.png',
                fallbackText: '👾',
                height: 200,
              ),
              const SizedBox(height: 24),
              // 앱 이름
              const Text(
                'pikuman4',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1,
                ),
              ),
              const Text(
                ': nonogram',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              // 로딩 인디케이터
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
              const SizedBox(height: 16),
              // 로딩 상태 메시지
              Obx(
                () => Text(
                  controller.loadingText.value,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 이미지 로드를 시도하고 실패하면 텍스트로 대체하는 헬퍼 위젯
class _LogoImage extends StatelessWidget {
  const _LogoImage({
    required this.path,
    required this.fallbackText,
    this.height = 120,
  });

  final String path;
  final String fallbackText;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      height: height,
      errorBuilder: (_, __, ___) => Text(
        fallbackText,
        style: TextStyle(fontSize: height * 0.5, color: Colors.white),
      ),
    );
  }
}
