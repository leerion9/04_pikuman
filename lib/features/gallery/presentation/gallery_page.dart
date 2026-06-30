// 갤러리 화면 파일 - 클리어한 퍼즐의 완성 그림 썸네일 모음 화면
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/gallery_controller.dart';
import '../../../core/widgets/banner_ad_widget.dart';

/// 갤러리 화면
///
/// 구성:
/// - 클리어한 퍼즐 썸네일을 3열 그리드로 표시
/// - 썸네일 탭 시 제목·소요 시간 팝업 표시
/// - 하단 배너 광고
class GalleryPage extends StatelessWidget {
  const GalleryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<GalleryController>();

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      appBar: AppBar(
        title: const Text(
          '갤러리',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: const Color(0xFFE53935),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.clearedList.isEmpty) {
          return const _EmptyGallery();
        }
        return _GalleryGrid(controller: controller);
      }),
      bottomNavigationBar: const BannerAdWidget(),
    );
  }
}

/// 클리어한 퍼즐이 없을 때 표시하는 빈 화면
class _EmptyGallery extends StatelessWidget {
  const _EmptyGallery();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.photo_library_outlined, size: 72, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            '아직 클리어한 퍼즐이 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            '퍼즐을 풀어서 갤러리를 채워보세요!',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade400),
          ),
        ],
      ),
    );
  }
}

/// 클리어한 퍼즐 썸네일 그리드
class _GalleryGrid extends StatelessWidget {
  const _GalleryGrid({required this.controller});
  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: controller.clearedList.length,
      itemBuilder: (_, index) {
        final info = controller.clearedList[index];
        return _ThumbnailCard(
          info: info,
          controller: controller,
        );
      },
    );
  }
}

/// 썸네일 카드 (탭하면 상세 팝업)
class _ThumbnailCard extends StatelessWidget {
  const _ThumbnailCard({required this.info, required this.controller});
  final ClearedPuzzleInfo info;
  final GalleryController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetail(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Stack(
            children: [
              // 썸네일 이미지 or 기본 박스
              Positioned.fill(child: _ThumbnailImage(thumbnail: info.thumbnail)),
              // 레벨 번호 오버레이 (좌상단)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE53935),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${info.id}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 퍼즐 상세 정보 팝업을 표시합니다
  void _showDetail(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 썸네일
            SizedBox(
              width: 140,
              height: 140,
              child: _ThumbnailImage(thumbnail: info.thumbnail),
            ),
            const SizedBox(height: 16),
            // 레벨 번호
            Text(
              'Level ${info.id}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: Color(0xFFE53935),
              ),
            ),
            const SizedBox(height: 4),
            // 퍼즐 제목
            Text(
              '"${info.title}"',
              style: const TextStyle(fontSize: 16, color: Colors.brown),
            ),
            const SizedBox(height: 12),
            // 클리어 시간
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, size: 18, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  controller.formatTime(info.elapsedSeconds),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}

/// 썸네일 이미지 (Base64/URL/기본 박스)
class _ThumbnailImage extends StatelessWidget {
  const _ThumbnailImage({required this.thumbnail});
  final String? thumbnail;

  @override
  Widget build(BuildContext context) {
    if (thumbnail != null && thumbnail!.startsWith('data:image')) {
      try {
        final bytes = base64Decode(thumbnail!.split(',').last);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {}
    }
    if (thumbnail != null && thumbnail!.startsWith('http')) {
      return Image.network(
        thumbnail!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _defaultBox(),
      );
    }
    return _defaultBox();
  }

  Widget _defaultBox() {
    return Container(
      color: Colors.grey.shade200,
      child: const Center(
        child: Icon(Icons.grid_on, color: Colors.grey),
      ),
    );
  }
}
