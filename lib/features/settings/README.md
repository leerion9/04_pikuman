# settings (설정) 기능

설정 화면을 담당하는 기능 폴더입니다.

## 구성

- `presentation/settings_page.dart` - 설정 화면 UI (BGM·효과음·진동 스위치)
- `controllers/settings_controller.dart` - 토글 값 서비스와 동기화
- `bindings/settings_binding.dart` - SettingsController 주입

## 설정 항목

- **배경음악**: on/off (추후 BGM 재생 시 적용)
- **효과음**: on/off (틀린 매칭 등 효과음 적용)
- **진동(햅틱)**: on/off (틀린 매칭 시 HapticFeedback 적용)

값은 SettingsService를 통해 SharedPreferences에 저장됩니다.
