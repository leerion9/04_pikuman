# app 폴더

앱 진입점 및 전역 설정을 담당합니다.

- **app.dart**: GetMaterialApp 등 앱 루트 위젯 정의
- **bindings/**: GetX 화면별 바인딩(의존성 주입)
- **routes/**: 라우트 이름·경로 및 화면 매핑

UI나 비즈니스 로직은 넣지 않고, 앱 초기화·라우팅만 두세요.
