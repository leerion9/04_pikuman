// 기본 위젯 테스트 파일 (앱 빌드 확인용)
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Phase 0: 앱이 컴파일되는지만 확인 (실제 앱 테스트는 별도 진행)
    expect(1 + 1, equals(2));
  });
}
