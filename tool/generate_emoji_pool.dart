import 'dart:convert';
import 'dart:io';

class EmojiPoolEntry {
  EmojiPoolEntry({
    required this.emoji,
    required this.name,
    required this.alias,
    required this.group,
    required this.subgroup,
    required this.codepoints,
  });

  final String emoji;
  final String name;
  final String alias;
  final String group;
  final String subgroup;
  final List<String> codepoints; // hex strings

  Map<String, Object?> toJson() => {
        'emoji': emoji,
        'name': name,
        'alias': alias,
        'group': group,
        'subgroup': subgroup,
        'codepoints': codepoints,
      };
}

/// Generates:
/// - lib/core/constants/tile_emojis.dart (Dart const pool + helper)
/// - assets/emoji/emoji_pool.json (metadata for search)
///
/// Source: unicode.org emoji-test.txt (UTS #51) v16.0
///
/// Filtering rules (per product spec):
/// - Only groups: Objects, Symbols, Travel & Places, Activity
/// - Only fully-qualified entries (ensures emoji presentation; includes VS16 when needed)
/// - Exclude ZWJ sequences that include gender variants and/or skin tone modifiers
Future<void> main(List<String> args) async {
  final inputPath = args.isNotEmpty ? args.first : 'tool/unicode/emoji-test.txt';
  final inputFile = File(inputPath);
  if (!inputFile.existsSync()) {
    stderr.writeln('Input file not found: $inputPath');
    exitCode = 2;
    return;
  }

  const allowedGroups = <String>{
    'Objects',
    'Symbols',
    'Travel & Places',
    'Activity',
  };

  final lines = inputFile.readAsLinesSync();
  String? currentGroup;
  String? currentSubgroup;

  final entries = <EmojiPoolEntry>[];
  final usedAliases = <String, int>{};

  for (final raw in lines) {
    final line = raw.trimRight();
    if (line.isEmpty) continue;

    if (line.startsWith('# group:')) {
      currentGroup = line.substring('# group:'.length).trim();
      continue;
    }
    if (line.startsWith('# subgroup:')) {
      currentSubgroup = line.substring('# subgroup:'.length).trim();
      continue;
    }
    if (line.startsWith('#')) continue;

    if (currentGroup == null ||
        currentSubgroup == null ||
        !allowedGroups.contains(currentGroup)) {
      continue;
    }

    // Example:
    // 1F600                                      ; fully-qualified     # 😀 E1.0 grinning face
    final semicolon = line.indexOf(';');
    if (semicolon < 0) continue;
    final afterSemicolon = line.substring(semicolon + 1).trimLeft();
    if (!afterSemicolon.startsWith('fully-qualified')) continue;

    final hash = line.indexOf('#');
    if (hash < 0) continue;
    final afterHash = line.substring(hash + 1).trimLeft();
    if (afterHash.isEmpty) continue;

    // afterHash begins with the rendered emoji, then version token, then name.
    // Example: "😀 E1.0 grinning face"
    final parts = afterHash.split(RegExp(r'\s+'));
    if (parts.length < 3) continue;
    final emoji = parts[0];
    final name = parts.sublist(2).join(' ').trim();
    if (name.isEmpty) continue;

    final codepointField = line.substring(0, semicolon).trim();
    final codepoints =
        codepointField.split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();

    if (_shouldExcludeByZwGenderOrSkinTone(codepoints)) {
      continue;
    }

    final baseAlias = _toAlias(name);
    final alias = _dedupeAlias(baseAlias, usedAliases);

    entries.add(
      EmojiPoolEntry(
        emoji: emoji,
        name: name,
        alias: alias,
        group: currentGroup,
        subgroup: currentSubgroup,
        codepoints: codepoints,
      ),
    );
  }

  // Output JSON (metadata for search and tooling)
  final jsonOutDir = Directory('assets/emoji');
  if (!jsonOutDir.existsSync()) jsonOutDir.createSync(recursive: true);
  final jsonOutFile = File('assets/emoji/emoji_pool.json');
  jsonOutFile.writeAsStringSync(
    const JsonEncoder.withIndent('  ').convert({
      'source': {
        'file': inputPath,
        'unicode_emoji_version': '16.0',
      },
      'filters': {
        'groups': allowedGroups.toList()..sort(),
        'status': 'fully-qualified',
        'exclude_zwj_gender_or_skin_tone': true,
      },
      'count': entries.length,
      'items': entries.map((e) => e.toJson()).toList(),
    }),
  );

  // Output Dart constants used by the app.
  final dartOutDir = Directory('lib/core/constants');
  if (!dartOutDir.existsSync()) dartOutDir.createSync(recursive: true);

  final dartOutFile = File('lib/core/constants/tile_emojis.dart');
  dartOutFile.writeAsStringSync(_renderDart(entries));

  stdout.writeln('Generated ${entries.length} emojis.');
  stdout.writeln(' - ${jsonOutFile.path}');
  stdout.writeln(' - ${dartOutFile.path}');
}

bool _shouldExcludeByZwGenderOrSkinTone(List<String> codepoints) {
  // Only exclude when ZWJ exists AND (gender variation OR skin tone modifier exists).
  // ZWJ: 200D
  // Skin tones: 1F3FB..1F3FF
  // Gender signs: 2640, 2642 (with or without FE0F)
  final hasZwj = codepoints.any((cp) => cp.toUpperCase() == '200D');
  if (!hasZwj) return false;

  final hasSkinTone = codepoints.any((cp) {
    final v = int.tryParse(cp, radix: 16);
    if (v == null) return false;
    return v >= 0x1F3FB && v <= 0x1F3FF;
  });

  final hasGenderSign = codepoints.any((cp) {
    final u = cp.toUpperCase();
    return u == '2640' || u == '2642';
  });

  return hasSkinTone || hasGenderSign;
}

String _toAlias(String name) {
  var s = name.toLowerCase();
  s = s.replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  s = s.replaceAll(RegExp(r'_+'), '_');
  s = s.replaceAll(RegExp(r'^_+|_+$'), '');
  if (s.isEmpty) return 'emoji';
  return s;
}

String _dedupeAlias(String base, Map<String, int> usedAliases) {
  final prev = usedAliases[base];
  if (prev == null) {
    usedAliases[base] = 1;
    return base;
  }
  final next = prev + 1;
  usedAliases[base] = next;
  return '${base}_$next';
}

String _dartStringLiteral(String s) {
  final escaped = s
      .replaceAll(r'\', r'\\')
      .replaceAll("'", r"\'")
      .replaceAll('\n', r'\n')
      .replaceAll('\r', r'\r');
  return "'$escaped'";
}

String _renderDart(List<EmojiPoolEntry> entries) {
  final b = StringBuffer();
  b.writeln('// GENERATED FILE - DO NOT EDIT BY HAND');
  b.writeln('//');
  b.writeln('// Generated from unicode.org emoji-test.txt (UTS #51) v16.0');
  b.writeln('// Filters: Objects, Symbols, Travel & Places, Activity');
  b.writeln('//         fully-qualified only');
  b.writeln('//         exclude ZWJ gender/skin tone variations');
  b.writeln('//');
  b.writeln('// Regenerate: dart run tool/generate_emoji_pool.dart');
  b.writeln();
  b.writeln('class EmojiPoolItem {');
  b.writeln('  const EmojiPoolItem({');
  b.writeln('    required this.emoji,');
  b.writeln('    required this.name,');
  b.writeln('    required this.alias,');
  b.writeln('    required this.group,');
  b.writeln('    required this.subgroup,');
  b.writeln('  });');
  b.writeln();
  b.writeln('  final String emoji;');
  b.writeln('  final String name;');
  b.writeln('  final String alias;');
  b.writeln('  final String group;');
  b.writeln('  final String subgroup;');
  b.writeln('}');
  b.writeln();
  b.writeln('/// 이모지 풀(메타 포함). 검색/필터 용도.');
  b.writeln('const List<EmojiPoolItem> kEmojiPool = [');
  for (final e in entries) {
    b.writeln(
      '  EmojiPoolItem(emoji: ${_dartStringLiteral(e.emoji)}, name: ${_dartStringLiteral(e.name)}, alias: ${_dartStringLiteral(e.alias)}, group: ${_dartStringLiteral(e.group)}, subgroup: ${_dartStringLiteral(e.subgroup)}),',
    );
  }
  b.writeln('];');
  b.writeln();
  b.writeln('/// 게임 타일 표시에 바로 쓰는 이모지 목록.');
  b.writeln('const List<String> kTileEmojis = [');
  for (final e in entries) {
    b.writeln('  ${_dartStringLiteral(e.emoji)},');
  }
  b.writeln('];');
  b.writeln();
  b.writeln('/// typeId(1부터 시작)에 해당하는 이모지를 반환합니다.');
  b.writeln('String emojiForType(int typeId) {');
  b.writeln("  if (kTileEmojis.isEmpty) return '?';");
  b.writeln('  final index = (typeId - 1) % kTileEmojis.length;');
  b.writeln('  return kTileEmojis[index];');
  b.writeln('}');
  b.writeln();
  return b.toString();
}

