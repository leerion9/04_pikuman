# lib/core/engine

## 역할
시드 기반 크로스워드 퍼즐을 생성하는 엔진 모음.
레벨 번호를 시드로 사용하여 동일한 레벨은 항상 동일한 퍼즐을 생성합니다.

## 포함 파일 (Phase 2 구현 예정)
| 파일 | 설명 |
|------|------|
| `puzzle_generator.dart` | 시드를 받아 퍼즐 전체를 생성하는 메인 엔진 |
| `word_placer.dart` | Incremental Growth 방식으로 단어를 10×12 판에 배치 |
| `placement_validator.dart` | 옆구리 접촉 금지·평행 배치 금지·헤드/테일 여유 공간 규칙 검증 |
| `hint_selector.dart` | 교차점 우선으로 힌트 타일을 선정 (단어당 최대 2개) |
| `puzzle_model.dart` | 퍼즐 데이터 모델 (배치된 단어 목록, 그리드 상태) |

## 퍼즐 생성 규칙 요약
- 퍼즐 판: 가로 10칸 × 세로 8칸
- 단어: 3~5음절 명사
- 배치: Incremental Growth (첫 단어 배치 → 교차 가능 단어 탐색 → 반복)
- 백트래킹: 500회 초과 시 해당 단어 교체
- 힌트 타일: 교차점 우선, 단어당 최대 2개, 총 개수는 level_design.csv의 hint_count
