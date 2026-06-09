# pikuman4 : nonogram

**네모로직(노노그램, Nonogram) 퍼즐 게임**  
패키지명: `pikuman4_nonogram` | 앱 ID: `com.interpage.pikuman4`  
타겟: 안드로이드 플레이스토어

---

## 프로젝트 개요

| 항목 | 내용 |
|------|------|
| 앱 종류 | 네모로직(네모네모, Nonogram) 퍼즐 게임 |
| 지원 언어 | 한국어 단독 |
| 레벨 구조 | 관리자가 서버에 업로드한 퍼즐을 앱에서 다운로드하여 플레이 |
| 출시 레벨 | 1~50: 앱 번들 내장 / 51~100: 서버 제공 / 101~: 지속 업데이트 |
| 퍼즐 구조 | 행·열 숫자 클루를 보고 격자 칸을 채워 그림 완성 |
| 그리드 크기 | 퍼즐 생성 결과를 보며 결정 예정 (초기 테스트: 10×10) |
| 광고 모델 | 하단 배너 광고 + 10레벨마다 전면 광고 |
| 타겟 플랫폼 | 안드로이드 |

---

## 기술 스택

| 분야 | 기술 |
|------|------|
| 프레임워크 | Flutter (Stable) |
| 언어 | Dart |
| 상태관리·라우팅 | GetX |
| 로컬 저장 (퍼즐·진행) | SQLite (`sqflite` 패키지) |
| 로컬 저장 (설정) | SharedPreferences |
| 서버 통신 | `http` 또는 `dio` 패키지 |
| 광고 | Google AdMob (`google_mobile_ads`) |
| 오디오 | audioplayers |
| 앱 평가 | Google Play In-App Review API + 스토어 이동 fallback |
| 외부 링크 | url_launcher |

---

## 폴더 구조

```
lib/
├── core/
│   ├── database/      # SQLite DB 헬퍼, 퍼즐·진행 DAO
│   ├── engine/        # 네모로직 클루 계산·검증 로직
│   ├── network/       # 서버 API 통신 (퍼즐 다운로드)
│   ├── services/      # 오디오, 광고, 설정 서비스
│   └── widgets/       # 공통 위젯 (배너 광고 등)
└── features/
    ├── splash/        # 스플래시 화면 1, 2 (신규 레벨 체크·다운로드)
    ├── main/          # 메인 화면
    ├── game/          # 게임 플레이 화면
    ├── result/        # 게임 결과 화면
    ├── gallery/       # 클리어한 퍼즐 갤러리 화면
    └── settings/      # 설정 화면

assets/
├── data/
│   └── puzzles/       # 번들 내장 퍼즐 JSON (puzzle_001.json ~ puzzle_050.json)
├── images/            # 앱 아이콘, 로고, 캐릭터 이미지
├── sounds/            # BGM, 효과음 (mp3)
├── splash/            # 스플래시 이미지
└── fonts/             # 폰트
```

---

## 화면 구성 요약

| 화면 | 주요 내용 |
|------|---------|
| 스플래시 1 | 하늘색 배경 + interpage 로고 |
| 스플래시 2 | 빨간 배경 + pikuMAN 캐릭터 + 서버 신규 레벨 체크·다운로드 |
| 메인 | 캐릭터 + "현재 레벨 : N" + Play / 갤러리 버튼 + 하단 배너 |
| 게임 플레이 | Level N 헤더 + 경과 타이머 + 네모로직 그리드 + 행·열 클루 + 하단 배너 |
| 게임 결과 | 레벨 클리어 + 완성 그림 + 소요 시간 + Home / Next Level 버튼 |
| 갤러리 | 클리어한 퍼즐 완성 그림 썸네일 모음. 탭하면 제목·소요 시간 확인 |
| 설정 | music / sound / vibration 토글 + 오류 즉시 표시 토글 + 평점 버튼 |

---

## 레벨 관리 구조

### 퍼즐 생성 흐름 (관리자 PC)
```
이미지 파일 입력
  → 어드민 도구에서 그리드 크기 선택
  → 이미지 이진화(흑백 변환) + 네모로직 클루 생성
  → 직접 플레이하여 품질·유일해 검증
  → 통과 시 서버에 JSON 업로드
```

### 앱에서의 퍼즐 로드 흐름
```
앱 실행
  → 스플래시 2에서 서버에 신규 레벨 목록 조회
  → 로컬에 없는 레벨 JSON 다운로드 → SQLite 저장
  → 오프라인 상태에서도 다운로드된 레벨 플레이 가능
```

### 퍼즐 JSON 구조
```json
{
  "id": 51,
  "title": "고양이",
  "gridSize": { "width": 10, "height": 10 },
  "rowClues": [[2], [1,1], [3], ...],
  "colClues": [[1], [2,1], [4], ...],
  "solution": [[0,1,1,0,...], ...],
  "thumbnail": "data:image/jpeg;base64,...",
  "createdAt": "2026-06-01"
}
```

---

## ⚠️ 개발 전 반드시 확인해야 할 미결 사항

> 해당 개발 단계 시작 전, 아래 항목에 대해 반드시 사용자에게 확인 요청할 것

### 미결 1 — 서버 환경 (네트워크 레이어 개발 전 확인)
- **질문**: 호스팅 서버가 정적 파일 제공만 가능한가, 아니면 PHP/Node.js 등 서버사이드 스크립트 실행이 가능한가?
- **영향**: API 구조 결정
  - 정적 파일 방식: `/puzzles/list.json`, `/puzzles/051.json` 등 URL로 직접 접근
  - REST API 방식: `GET /api/puzzles?from=51` 등 동적 응답

### 미결 2 — 어드민 도구 형태 (어드민 도구 개발 전 확인)
- **질문**: 퍼즐 생성·검증·업로드 도구를 어떤 형태로 만들 것인가?
- **선택지**:
  - Flutter 데스크톱 앱 (Windows/Mac)
  - Python 스크립트 + 간단한 웹 UI
  - 기타

---

## 개발 단계 계획

### Phase 0: 프로젝트 기반 설정 (예정)
- [ ] 기존 pikuman3 코드 정리 (pikuman4에 맞게 전면 교체)
- [ ] pubspec.yaml 패키지 업데이트 (sqflite, http/dio 추가, 불필요 패키지 제거)
- [ ] 앱 ID·이름·테마 색상 변경
- [ ] 전체 폴더 구조 재생성 (gallery 추가, engine 재설계)
- [ ] assets/data/puzzles/ 폴더 구성

### Phase 1: 데이터 레이어 구축 (예정)
- [ ] SQLite DB 구조 설계 및 헬퍼 구현 (puzzles, progress, cleared 테이블)
- [ ] 번들 JSON 로더 구현 (assets/data/puzzles/)
- [ ] 서버 API 통신 구현 (⚠️ 미결 1 확인 후 진행)

### Phase 2: 네모로직 엔진 구현 (예정)
- [ ] 클루(힌트) 계산 로직 (이진 배열 → 행·열 숫자 배열)
- [ ] 퍼즐 검증 로직 (정답 비교)

### Phase 3: 화면 뼈대 + 네비게이션 (예정)
- [ ] GetX 라우팅 설정
- [ ] 스플래시 1, 2 (서버 신규 레벨 체크 포함)
- [ ] 메인 화면

### Phase 4: 게임 플레이 화면 (예정)
- [ ] 네모로직 그리드 위젯
- [ ] 행·열 클루 위젯
- [ ] 채우기/X표시 인터랙션
- [ ] 타이머, 세이브/로드

### Phase 5: 결과·갤러리 화면 (예정)

### Phase 6: 설정·사운드·광고 (예정)

### Phase 7: 어드민 도구 (예정)
- [ ] ⚠️ 미결 2 확인 후 형태 결정
- [ ] 이미지 → 네모로직 변환
- [ ] 플레이 테스트 기능
- [ ] 서버 업로드

### Phase 8: 완성도 & 출시 준비 (예정)

---

## 진행 상황

> 마지막 업데이트: 2026-06-09 (프로젝트 기획 확정)

### 완료된 작업
- pikuman4 기획 논의 및 전체 방향 확정
- `.cursorrules` 및 `README.md` pikuman4 기준으로 전면 재작성
- GitHub 저장소 연결: https://github.com/leerion9/04_pikuman

### 다음 할 일
- **Phase 0 시작 전**: 미결 1 (서버 환경), 미결 2 (어드민 도구 형태) 확인
- Phase 0: 기존 pikuman3 코드를 pikuman4 기준으로 전면 교체

---

## 출시 전 필수 교체 항목

| 항목 | 현재 상태 | 교체 방법 |
|------|----------|----------|
| AdMob App ID | 미설정 | `android/app/src/main/AndroidManifest.xml` |
| AdMob 배너 광고 ID | 미설정 | `lib/core/services/ad_service.dart` |
| AdMob 전면 광고 ID | 미설정 | `lib/core/services/ad_service.dart` |
| 서버 퍼즐 API URL | 미결정 | `lib/core/network/puzzle_api_service.dart` |
| 캐릭터 이미지 | pikuman3 자산 사용 중 | `assets/images/` |
| 앱 아이콘 | pikuman3 자산 사용 중 | `assets/images/app_icon.png` |
| BGM 파일 | pikuman3 자산 사용 중 | `assets/sounds/bgm.mp3` |
