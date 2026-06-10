// 이미지 이진화 파일 - 이미지 파일을 노노그램용 이진 그리드(0/1 배열)로 변환하는 파일
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

/// 이미지 파일을 노노그램 이진 그리드로 변환하는 유틸리티 클래스
///
/// 변환 과정:
/// 1. 이미지 파일 로드
/// 2. 지정한 그리드 크기(width × height)로 리사이즈
/// 3. 각 픽셀을 밝기(luminance) 기준으로 0 또는 1로 변환
///    - 밝기 < threshold  → 1 (어두운 픽셀 = 채움 칸)
///    - 밝기 >= threshold → 0 (밝은 픽셀 = 빈 칸)
class ImageBinarizer {
  // 인스턴스 생성 방지
  const ImageBinarizer._();

  /// 이미지 파일 경로를 받아 이진 그리드를 반환합니다.
  ///
  /// [filePath]: 이미지 파일의 절대 경로 (jpg, png 등)
  /// [gridWidth]: 변환할 그리드 가로 칸 수
  /// [gridHeight]: 변환할 그리드 세로 칸 수
  /// [threshold]: 밝기 임계값 0~255 (기본 128. 낮을수록 어두운 픽셀만 채움)
  ///
  /// 반환값: [행][열] 형태의 이진 배열 (0=빈칸, 1=채움)
  ///
  /// 예외: 파일을 열 수 없거나 지원하지 않는 형식이면 예외 발생
  static List<List<int>> binarizeFromFile(
    String filePath, {
    required int gridWidth,
    required int gridHeight,
    int threshold = 128,
  }) {
    // 파일 읽기
    final bytes = File(filePath).readAsBytesSync();
    return binarizeFromBytes(
      bytes,
      gridWidth: gridWidth,
      gridHeight: gridHeight,
      threshold: threshold,
    );
  }

  /// 이미지 바이트 데이터를 받아 이진 그리드를 반환합니다.
  ///
  /// [bytes]: 이미지 파일 바이트 (file_picker로 읽은 데이터)
  /// [gridWidth]: 변환할 그리드 가로 칸 수
  /// [gridHeight]: 변환할 그리드 세로 칸 수
  /// [threshold]: 밝기 임계값 0~255 (기본 128)
  ///
  /// 반환값: [행][열] 형태의 이진 배열
  static List<List<int>> binarizeFromBytes(
    Uint8List bytes, {
    required int gridWidth,
    required int gridHeight,
    int threshold = 128,
  }) {
    // 이미지 디코딩
    final original = img.decodeImage(bytes);
    if (original == null) {
      throw Exception('이미지를 읽을 수 없습니다. 지원 형식: jpg, png, gif, bmp');
    }

    // 그리드 크기로 리사이즈
    final resized = img.copyResize(
      original,
      width: gridWidth,
      height: gridHeight,
      interpolation: img.Interpolation.average, // 평균값 보간 (계단 현상 감소)
    );

    // 각 픽셀을 밝기 기준으로 0/1 변환
    return List.generate(gridHeight, (row) {
      return List.generate(gridWidth, (col) {
        final pixel = resized.getPixel(col, row);

        // 밝기 계산 (0.0 ~ 255.0, 0=검정, 255=흰색)
        final luminance = img.getLuminance(pixel);

        // 임계값보다 어두우면 채움(1), 밝으면 비움(0)
        return luminance < threshold ? 1 : 0;
      });
    });
  }

  /// 이진 그리드를 반전시킵니다 (0↔1).
  ///
  /// 이미지에 따라 배경이 검은색일 수도 있으므로, 반전 버튼 기능에 사용합니다.
  static List<List<int>> invertGrid(List<List<int>> grid) {
    return grid
        .map((row) => row.map((cell) => cell == 0 ? 1 : 0).toList())
        .toList();
  }

  /// 그리드에서 채워진 칸(1)의 개수를 반환합니다.
  /// 퍼즐 품질 확인 시 너무 비어있거나 너무 꽉 찬 퍼즐을 걸러낼 때 사용합니다.
  static int countFilledCells(List<List<int>> grid) {
    var count = 0;
    for (final row in grid) {
      for (final cell in row) {
        if (cell == 1) count++;
      }
    }
    return count;
  }

  /// 채워진 칸의 비율(0.0~1.0)을 반환합니다.
  /// 0.2~0.6 (20%~60%) 범위가 퍼즐로 적합합니다.
  static double filledRatio(List<List<int>> grid) {
    if (grid.isEmpty || grid[0].isEmpty) return 0.0;
    final total = grid.length * grid[0].length;
    return countFilledCells(grid) / total;
  }
}
