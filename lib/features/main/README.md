# main (메인/홈) 기능

메인(홈) 화면을 담당하는 기능 폴더입니다.

## 구성

- `presentation/main_page.dart` - 메인 화면 UI (현재 레벨 표시, 플레이·설정)
- `controllers/main_controller.dart` - 현재 레벨 로드, 게임 진입 처리
- `bindings/main_binding.dart` - MainController 주입

## 흐름

- 스플래시 종료 후 이 화면으로 이동
- 저장된 "다음 플레이 레벨"을 표시하고, 플레이 버튼으로 게임 화면 진입
- 게임에서 홈 버튼 시 이 화면으로 복귀
