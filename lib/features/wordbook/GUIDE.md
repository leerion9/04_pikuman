# lib/features/wordbook

## 역할
지금까지 클리어한 레벨에서 등장한 단어들을 모아 보여주는 단어장 화면.
최신 레벨이 가장 위에 표시되고, 스크롤로 이전 레벨 확인 가능합니다.

## 포함 파일
| 파일 | 설명 |
|------|------|
| `bindings/wordbook_binding.dart` | WordbookController 주입 바인딩 |
| `controllers/wordbook_controller.dart` | 클리어된 레벨 목록 및 단어 데이터 로드 (Phase 6 구현) |
| `presentation/wordbook_page.dart` | 단어장 화면 UI |

## 화면 구성
- 클리어한 레벨 번호별로 그룹화
- 최신 레벨이 가장 위 (내림차순 정렬)
- 각 레벨에서 사용된 단어와 뜻 풀이 표시
- 클리어한 레벨이 없으면 빈 상태 안내 메시지
