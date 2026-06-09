# lib/core/data

## 역할
CSV 파일에서 단어 목록과 레벨 설계 데이터를 읽어오는 데이터 로더 모음.

## 포함 파일 (Phase 1 구현 예정)
| 파일 | 설명 |
|------|------|
| `word_model.dart` | 단어 데이터 모델 (word, meaning) |
| `word_loader.dart` | `assets/data/word_pool.csv` 파싱 및 단어 리스트 반환 |
| `level_design_model.dart` | 레벨 설계 모델 (level, word_count, hint_count) |
| `level_design_loader.dart` | `assets/data/level_design.csv` 파싱 및 레벨 설계 리스트 반환 |

## 데이터 파일 경로
- `assets/data/word_pool.csv` — 단어 풀 (word, meaning, 총 10,489개)
- `assets/data/level_design.csv` — 레벨별 난이도 (level, word_count, hint_count, 101행)
