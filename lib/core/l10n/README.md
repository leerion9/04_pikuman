# core/l10n

다국어(로컬라이제이션) 리소스를 두는 폴더입니다.

## 구성

- `app_translations.dart` - GetX Translations: 영(en)·한(ko)·스페인어(es)·일본어(ja) 문자열 맵
- UI에서는 `'키'.tr` 또는 `'키'.trParams({'param': '값'})` 로 사용

## 지원 언어

- **en** (English, 기본)
- **ko** (한국어)
- **es** (Español)
- **ja** (日本語)

언어 변경은 설정 화면 > 언어에서 선택하며, 선택 값은 저장되어 재실행 시 유지됩니다.
