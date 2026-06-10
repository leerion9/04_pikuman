# assets/data/puzzles/ 폴더 안내

앱에 번들로 내장된 노노그램 퍼즐 JSON 파일 모음입니다.
인터넷 없이도 즉시 플레이할 수 있는 레벨 1~50이 여기에 저장됩니다.

## 파일 명명 규칙

- `puzzle_001.json` ~ `puzzle_050.json`
- 3자리 숫자로 맞춤 (001, 002, ... 050)

## JSON 구조 예시

```json
{
  "id": 1,
  "title": "고양이",
  "gridSize": { "width": 10, "height": 10 },
  "rowClues": [[2], [1, 1], [3], ...],
  "colClues": [[1], [2, 1], [4], ...],
  "solution": [[0, 1, 1, 0, ...], ...],
  "thumbnail": "data:image/jpeg;base64,...",
  "createdAt": "2026-06-01"
}
```

## 현재 상태

아직 퍼즐 파일이 없습니다.
Phase 2(노노그램 엔진) + Phase 7(어드민 도구) 완성 후 퍼즐을 생성하여 이 폴더에 추가합니다.
