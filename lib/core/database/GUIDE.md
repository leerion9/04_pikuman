# core/database/ 폴더 안내

SQLite 로컬 데이터베이스를 관리하는 코드 모음입니다.
(Phase 1에서 구현 예정)

## 파일 목록 (구현 예정)

| 파일 | 역할 |
|------|------|
| `database_helper.dart` | DB 초기화, 테이블 생성, 버전 관리 |
| `puzzle_dao.dart` | puzzles 테이블 CRUD (퍼즐 데이터 저장·조회) |
| `progress_dao.dart` | progress 테이블 CRUD (플레이 진행 상태 저장·조회) |
| `cleared_dao.dart` | cleared 테이블 CRUD (클리어 기록 저장·조회) |

## DB 테이블 구조

- **puzzles**: 서버에서 다운로드한 퍼즐 JSON 데이터
- **progress**: 플레이 중인 퍼즐의 칸 입력 상태
- **cleared**: 클리어한 레벨 번호, 소요 시간 기록
