// 게임 결과 화면 파일 - 레벨 클리어 확인, 완성된 그림, 소요 시간을 표시하는 화면
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/result_controller.dart';
import '../../../core/widgets/banner_ad_widget.dart';

/// 게임 결과 화면
///
/// 구성:
/// - "Level N 클리어!" 메시지 + 축하 아이콘
/// - 완성된 퍼즐 이미지 (thumbnail이 있으면 표시)
/// - 소요 시간
/// - Home 버튼 / Next Level 버튼
/// - 하단 배너 광고
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ResultController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8E1),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    // 클리어 아이콘
                    const _ClearIcon(),
                    const SizedBox(height: 16),
                    // 클리어 메시지
                    Text(
                      'Level ${controller.puzzleId} 클리어!',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFE53935),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '"${controller.title}"',
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.brown,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 28),
                    // 완성 이미지 (thumbnail이 있으면 표시, 없으면 기본 박스)
                    _ThumbnailView(thumbnail: controller.thumbnail),
                    const SizedBox(height: 28),
                    // 소요 시간
                    _TimerRow(timerText: controller.timerText),
                    const SizedBox(height: 40),
                    // 버튼 영역
                    _ButtonRow(controller: controller),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
            // 하단 배너 광고
            const BannerAdWidget(),
          ],
        ),
      ),
    );
  }
}

/// 클리어 체크 아이콘 (애니메이션)
class _ClearIcon extends StatelessWidget {
  const _ClearIcon();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      curve: Curves.elasticOut,
      builder: (_, value, child) =>
          Transform.scale(scale: value, child: child),
      child: Container(
        width: 80,
        height: 80,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFE53935),
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 48),
      ),
    );
  }
}

/// 퍼즐 완성 이미지 뷰 (Base64 또는 URL 지원)
class _ThumbnailView extends StatelessWidget {
  const _ThumbnailView({required this.thumbnail});
  final String? thumbnail;

  @override
  Widget build(BuildContext context) {
    const size = 200.0;

    if (thumbnail != null && thumbnail!.startsWith('data:image')) {
      // Base64 인코딩 이미지
      try {
        final base64Str = thumbnail!.split(',').last;
        final bytes = base64Decode(base64Str);
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
        );
      } catch (_) {}
    }

    if (thumbnail != null && thumbnail!.startsWith('http')) {
      // URL 이미지
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          thumbnail!,
          width: size,
          height: size,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => _defaultBox(size),
        ),
      );
    }

    return _defaultBox(size);
  }

  /// 이미지가 없을 때 표시하는 기본 박스
  Widget _defaultBox(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 64, color: Colors.grey),
      ),
    );
  }
}

/// 소요 시간 표시 행
class _TimerRow extends StatelessWidget {
  const _TimerRow({required this.timerText});
  final String timerText;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.timer_outlined, color: Colors.brown, size: 22),
        const SizedBox(width: 8),
        Text(
          '클리어 시간: $timerText',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.brown,
          ),
        ),
      ],
    );
  }
}

/// Home / Next Level 버튼 영역
class _ButtonRow extends StatelessWidget {
  const _ButtonRow({required this.controller});
  final ResultController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Home 버튼
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.onHomePressed,
            icon: const Icon(Icons.home_outlined, color: Color(0xFFE53935)),
            label: const Text(
              '홈',
              style: TextStyle(color: Color(0xFFE53935), fontSize: 16),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFFE53935)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Next Level 버튼
        Expanded(
          child: Obx(
            () => ElevatedButton.icon(
              onPressed: controller.hasNextLevel.value
                  ? controller.onNextLevelPressed
                  : controller.onHomePressed,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                controller.hasNextLevel.value ? '다음 레벨' : '홈으로',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE53935),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
