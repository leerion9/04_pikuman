// 단어장 화면: 클리어한 레벨의 단어와 뜻을 최신 레벨 순서로 표시합니다.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wordbook_controller.dart';
import '../../../core/services/wordbook_service.dart';

/// 단어장 화면.
///
/// 클리어한 레벨을 최신순(내림차순)으로 보여줍니다.
/// 레벨 헤더 아래에 해당 레벨의 단어 목록과 뜻을 나열합니다.
class WordbookPage extends GetView<WordbookController> {
  const WordbookPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFF6B2B),
        foregroundColor: Colors.white,
        title: const Text(
          '단어장',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: controller.goBack,
        ),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isEmpty) {
          return const _EmptyView();
        }
        return ListView.builder(
          itemCount: controller.entries.length,
          itemBuilder: (_, i) => _LevelSection(entry: controller.entries[i]),
        );
      }),
    );
  }
}

/// 클리어한 레벨이 없을 때 표시하는 안내 화면
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            '아직 클리어한 레벨이 없습니다.',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// 레벨 헤더 + 단어 목록을 묶은 섹션 위젯
class _LevelSection extends StatelessWidget {
  const _LevelSection({required this.entry});

  final WordbookEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLevelHeader(),
        ...entry.words.asMap().entries.map(
              (e) => _WordTile(index: e.key + 1, wordEntry: e.value),
            ),
        const SizedBox(height: 8),
      ],
    );
  }

  /// 레벨 번호를 강조하는 헤더 바
  Widget _buildLevelHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFFF6B2B).withAlpha(220),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Text(
        'Level ${entry.level}',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 15,
        ),
      ),
    );
  }
}

/// 단어 하나를 표시하는 타일
class _WordTile extends StatelessWidget {
  const _WordTile({required this.index, required this.wordEntry});

  final int index;
  final WordEntry wordEntry;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: Colors.orange.shade100,
          child: Text(
            '$index',
            style: const TextStyle(
              color: Color(0xFFFF6B2B),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          wordEntry.word,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: wordEntry.meaning.isNotEmpty
            ? Text(
                wordEntry.meaning,
                style: const TextStyle(color: Colors.black54, fontSize: 13),
              )
            : null,
      ),
    );
  }
}
