# features/ 폴더 안내

앱의 각 화면(기능) 단위로 분리된 코드 모음입니다.
각 기능 폴더는 `bindings/`, `controllers/`, `presentation/` 구조를 따릅니다.

## 화면 목록

| 폴더 | 화면 | 구현 단계 |
|------|------|---------|
| `splash/` | 스플래시 화면 1·2 (로고 + 신규 레벨 다운로드) | Phase 3 |
| `main/` | 메인 화면 (캐릭터 + 레벨 선택) | Phase 3 |
| `game/` | 게임 플레이 화면 (노노그램 그리드) | Phase 4 |
| `result/` | 게임 결과 화면 (클리어 + 소요 시간) | Phase 5 |
| `gallery/` | 갤러리 화면 (클리어한 퍼즐 썸네일 모음) | Phase 5 |
| `settings/` | 설정 화면 (사운드·진동·오류 표시 설정) | Phase 6 |

## 각 폴더 내부 구조

```
[화면명]/
├── bindings/       # GetX 의존성 주입 (컨트롤러 등록)
├── controllers/    # 화면 로직 (GetxController)
└── presentation/   # UI 위젯 (Page, Widget 파일)
```
