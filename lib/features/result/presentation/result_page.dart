// 게임 결과 화면: 레벨 클리어 정보와 이번 레벨에 등장한 단어·뜻을 표시합니다.

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_pages.dart';
import '../../../core/engine/puzzle_model.dart';

/// 게임 결과 화면.
///
/// Get.arguments 로 전달받는 Map 구조:
///   - 'level'   : int  — 클리어한 레벨 번호
///   - 'elapsed' : int  — 경과 시간(초)
///   - 'words'   : List of PlacedWord — 이번 레벨에 배치된 단어 목록
class ResultPage extends StatelessWidget {
  const ResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args    = Get.arguments as Map<String, dynamic>? ?? {};
    final level   = args['level']   as int?              ?? 1;
    final elapsed = args['elapsed'] as int?              ?? 0;
    final words   = args['words']   as List<PlacedWord>? ?? [];

    final minutes = elapsed ~/ 60;
    final seconds = elapsed % 60;
    final timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(level, timeStr),
            Expanded(child: _buildWordList(words)),
            _buildButtons(level),
          ],
        ),
      ),
    );
  }

  /// 클리어 레벨·경과 시간을 표시하는 상단 헤더
  Widget _buildHeader(int level, String timeStr) {
    return Container(
      color: const Color(0xFFFF6B2B),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        children: [
          const Icon(Icons.emoji_events, color: Colors.white, size: 52),
          const SizedBox(height: 8),
          Text(
            'Level $level 클리어!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.timer, color: Colors.white70, size: 18),
              const SizedBox(width: 4),
              Text(
                '클리어 시간: $timeStr',
                style: const TextStyle(color: Colors.white70, fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 이번 레벨에 등장한 단어와 뜻 목록
  Widget _buildWordList(List<PlacedWord> words) {
    // 중복 단어 제거 (같은 단어가 여러 PlacedWord 로 중복 포함될 수 있음)
    final seen   = <String>{};
    final unique = words.where((pw) => seen.add(pw.word.word)).toList();

    if (unique.isEmpty) {
      return const Center(
        child: Text('단어 정보 없음', style: TextStyle(color: Colors.grey)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: unique.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (_, i) {
        final pw = unique[i];
        return ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: const Color(0xFFFF6B2B),
            child: Text(
              '${i + 1}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
          title: Text(
            pw.word.word,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: pw.word.meaning.isNotEmpty
              ? Text(
                  pw.word.meaning,
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                )
              : null,
        );
      },
    );
  }

  /// 홈으로 / 다음 레벨 버튼
  Widget _buildButtons(int level) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Get.offAllNamed(AppRoutes.main),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                side: const BorderSide(color: Color(0xFFFF6B2B)),
                foregroundColor: const Color(0xFFFF6B2B),
              ),
              child: const Text('홈으로'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () => Get.offNamed(
                AppRoutes.game,
                arguments: level + 1,
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: const Color(0xFFFF6B2B),
                foregroundColor: Colors.white,
              ),
              child: const Text('다음 레벨'),
            ),
          ),
        ],
      ),
    );
  }
}
