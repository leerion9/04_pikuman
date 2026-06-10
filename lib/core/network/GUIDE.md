# core/network/ 폴더 안내

서버와의 HTTP 통신을 담당하는 코드 모음입니다.
(Phase 1에서 구현 예정. ⚠️ 서버 환경 확정 후 진행)

## 파일 목록 (구현 예정)

| 파일 | 역할 |
|------|------|
| `puzzle_api_service.dart` | 서버에서 퍼즐 목록·JSON 데이터 다운로드 |

## ⚠️ 주의사항

서버 환경(정적 파일 방식 vs REST API 방식)이 확정되어야 구현 방향이 결정됩니다.
- **정적 파일 방식**: `/puzzles/list.json`, `/puzzles/051.json` URL로 직접 GET
- **REST API 방식**: `GET /api/puzzles?from=51` 동적 응답
