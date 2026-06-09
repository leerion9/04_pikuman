# lib/features/result

## 역할
레벨 클리어 후 보여주는 결과 화면.
클리어 확인 메시지, 해당 레벨에 등장한 단어 전체 목록과 뜻 풀이, Home/Next Level 버튼을 표시합니다.

## 포함 파일
| 파일 | 설명 |
|------|------|
| `bindings/result_binding.dart` | ResultController 주입 바인딩 |
| `controllers/result_controller.dart` | 단어 목록 로드, 홈/다음 레벨 이동 (Phase 6 구현) |
| `presentation/result_page.dart` | 결과 화면 UI |

## 화면 구성
- 상단: "Level N 클리어!" 메시지
- 중앙: 이번 레벨에 등장한 단어 목록 + 각 단어 뜻 풀이
- 하단: Home 버튼 / Next Level 버튼 + 배너 광고
