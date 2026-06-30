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

### Phase 0: 프로젝트 기반 설정 ✅ 완료
- [x] 기존 pikuman3 코드 정리 (pikuman4에 맞게 전면 교체)
- [x] pubspec.yaml 패키지 업데이트 (sqflite, http 추가, 불필요 패키지 제거)
- [x] 전체 폴더 구조 재생성 (gallery 추가, engine 재설계)
- [x] assets/data/puzzles/ 폴더 구성
- [x] 각 폴더 GUIDE.md 작성
- [x] flutter analyze: 오류 없음 확인

### Phase 1: 데이터 레이어 구축 ✅ 완료
- [x] SQLite DB 구조 설계 및 헬퍼 구현 (puzzles, progress, cleared 테이블)
- [x] 번들 JSON 로더 구현 (assets/data/puzzles/)
- [x] 서버 API 통신 stub (⚠️ 미결 1 확인 후 실제 구현)
- [x] PuzzleRepository: 번들+SQLite 통합 데이터 접근

### Phase 2: 네모로직 엔진 구현 ✅ 완료
- [x] `nonogram_model.dart`: 퍼즐 데이터 모델 + 플레이어 진행 상태 모델 (JSON ↔ Dart)
- [x] `clue_calculator.dart`: 이진 배열 → 행·열 클루 계산
- [x] `puzzle_validator.dart`: 클루 기반 정답 검증 + Easy 모드 셀 단위 검증

### Phase 3: 화면 뼈대 + 네비게이션 ✅ 완료
- [x] GetX 라우팅 설정 (app_pages.dart)
- [x] 스플래시 1 (하늘색 + interpage 로고)
- [x] 스플래시 2 (빨간 배경 + 캐릭터 + 로딩 + 서버 신규 레벨 체크)
- [x] 메인 화면 (캐릭터 + 레벨 표시 + Play/갤러리 버튼)

### Phase 4: 게임 플레이 화면 ✅ 완료
- [x] NonogramGridWidget: 터치/드래그 인터랙티브 격자
- [x] RowClueWidget / ColClueWidget: 행·열 클루 (완성 행/열 흐리게)
- [x] 채우기/X표시 모드 + 드래그 연속 입력
- [x] 경과 타이머 (백그라운드 자동 일시정지)
- [x] 진행 상태 SQLite 저장·불러오기 (이어하기)
- [x] Easy 모드: 오류 즉시 표시

### Phase 5: 결과·갤러리 화면 ✅ 완료
- [x] 결과 화면: 클리어 메시지 + 썸네일 + 소요 시간 + Home/Next 버튼
- [x] 갤러리 화면: 클리어 퍼즐 3열 그리드 + 상세 팝업

### Phase 6: 설정·사운드·광고 ✅ 완료
- [x] SettingsService: SharedPreferences 기반 설정 저장
- [x] AudioService: BGM 루프 재생 + 효과음 4종
- [x] AdService: AdMob 전면 광고 (테스트 ID, 10레벨마다)
- [x] BannerAdWidget: AdMob 배너 광고 (테스트 ID)
- [x] 설정 화면: 토글 4종 + 인앱 리뷰 버튼

### Phase 7: 어드민 도구 ✅ 완료
- [x] Flutter Windows 데스크톱 앱 (`admin/` 폴더 별도 프로젝트)
- [x] 이미지 → 노노그램 그리드 자동 변환 (임계값 슬라이더)
- [x] 수동 셀 편집 (클릭/드래그)
- [x] 클루 자동 계산 (Phase 2 엔진 재사용)
- [x] 플레이 테스트 화면 (직접 풀어보며 검증)
- [x] JSON 저장 (puzzle_XXX.json 형식)

### Phase 8: 완성도 & 출시 준비 (예정)

---

## 진행 상황

> 마지막 업데이트: 2026-06-30 (게임 앱 전체 화면 구현 완료)

### 완료된 작업
- pikuman4 기획 논의 및 전체 방향 확정
- `.cursorrules` 및 `README.md` pikuman4 기준으로 전면 재작성
- GitHub 저장소 연결: https://github.com/leerion9/04_pikuman
- **Phase 0 완료**: pikuman3 코드 전면 교체, 노노그램 기반 폴더 구조 재구성

### Phase 0 작업 내용 (2026-06-10)
- pikuman3 lib/ 코드 전체 삭제 후 노노그램 구조로 재생성
- pubspec.yaml: sqflite, http 패키지 추가
- 폴더 구조: core/(database, engine, network, services, widgets) + features/(splash, main, game, result, gallery, settings) 생성
- 각 폴더 GUIDE.md 작성, 모든 화면 stub 파일 생성, assets/data/puzzles/ 폴더 생성

### Phase 2 작업 내용 (2026-06-10)
- `nonogram_model.dart`: NonogramPuzzle, GridSize, CellState, GameProgress 모델
- `clue_calculator.dart`: 이진 배열 → 행·열 클루 계산, 클루 비교
- `puzzle_validator.dart`: 클루 기반 정답 검증, Easy 모드 셀 검증, 행·열 완성 확인

### Phase 7 작업 내용 (2026-06-10)
- `admin/` 폴더에 Flutter Windows 데스크톱 프로젝트 생성
- 이미지 이진화(`image_binarizer.dart`), 홈·에디터·플레이테스트 화면 구현
- `flutter analyze`: No issues found

### 어드민 도구 실행 환경 준비 (2026-06-11)
- Windows 개발자 모드 활성화 완료
- Visual Studio (C++를 사용한 데스크톱 개발 워크로드) 설치 완료
- 퍼즐 소재: **Google Noto Emoji / Twemoji PNG** 활용하기로 결정
  - 저작권 무료(상업적 사용 가능), 소재 다양, 인식하기 쉬운 장점
  - 단색·굵은 윤곽선 이모지가 이진화 품질에 유리

### 어드민 도구 실행 성공 (2026-06-15)
- Flutter 3.35.1 → **3.44.2** 업그레이드 (VS 2026 지원 버전)
- VS 2026 + Flutter 3.44.2 조합으로 `flutter run -d windows` 정상 빌드·실행 확인
- `admin.exe` Windows 앱 정상 구동 확인
- 릴리즈 빌드 후 바탕화면 바로가기 생성 (`pikuman4 어드민.lnk`)
  - exe 경로: `admin/build/windows/x64/runner/Release/admin.exe`
  - ⚠️ 코드 수정 후에는 반드시 아래 명령어로 재빌드해야 바로가기에 반영됨
    ```
    cd c:\cursor\04_pikuman4\admin
    flutter build windows --release
    ```

### 어드민 도구 기능 개선 (2026-06-18)
- **그리드 크기 프리셋 추가**: 5×5, 12×12 추가 (기존 10×10, 15×15, 20×20, 25×25, 15×20, 20×15)
- **기존 퍼즐 편집 버그 수정**:
  - 목록에서 퍼즐 선택 시 GetX 컨트롤러 교체 순서 수정 → 그리드 데이터 정상 로드
  - 저장 시 원본 레벨 ID 추적 → 레벨 번호 변경 시 원본 파일 자동 삭제 후 새 파일 저장
  - 저장 후 홈 목록 즉시 자동 갱신 (프로그램 재시작 불필요)
- **원본 이미지 함께 저장**: 퍼즐 저장 시 원본 이미지(puzzle_XXX.png 등)도 같은 폴더에 저장
- **기존 퍼즐 불러올 때 이미지 자동 로드**: 이미지가 함께 저장된 퍼즐은 불러올 때 자동으로 이미지 복원 → 임계값 슬라이더 즉시 사용 가능

### 개발 순서 변경 결정
퍼즐 생성 검증 우선을 위해 아래 순서로 진행합니다:
**Phase 0(완료) → Phase 2(노노그램 엔진) → Phase 7(어드민 도구) → Phase 1·3·4·5·6·8(게임 앱)**

### Phase 1·3·4·5·6 작업 내용 (2026-06-30)

#### Phase 1 — 데이터 레이어
| 파일 | 내용 |
|---|---|
| `core/database/database_helper.dart` | SQLite 초기화, puzzles·progress·cleared 테이블 생성 |
| `core/database/puzzle_dao.dart` | 서버 다운로드 퍼즐 CRUD (ID 51~) |
| `core/database/progress_dao.dart` | 게임 진행 상태 저장·불러오기 (이어하기) |
| `core/database/cleared_dao.dart` | 클리어 기록 저장·조회 (갤러리용) |
| `core/data/bundle_loader.dart` | assets/data/puzzles/ JSON 파일 로더 |
| `core/data/puzzle_repository.dart` | 번들+SQLite 통합 접근, 다음 레벨 ID 조회 |
| `core/network/puzzle_api_service.dart` | 서버 통신 stub (미결 1 확정 후 구현 예정) |

#### Phase 3 — 스플래시·메인 화면
- `splash_controller.dart`: 2단계 스플래시(Splash1→Splash2) + 앱 초기화 순서 관리
- `splash_page.dart`: 하늘색(interpage 로고) → 빨간(캐릭터+로딩 메시지) AnimatedSwitcher
- `main_controller.dart`: 현재 레벨 표시, Play/갤러리/설정 버튼 이벤트
- `main_page.dart`: 캐릭터 이미지 + 레벨 뱃지 + 버튼 + 배너 광고

#### Phase 4 — 게임 플레이 화면
- `game_controller.dart`: 타이머(백그라운드 자동 일시정지), 셀 채우기/X표시, Easy 모드 오류 즉시 표시, SQLite 이어하기, 10레벨마다 전면 광고
- `widgets/nonogram_grid_widget.dart`: 터치 탭·길게누르기·드래그 연속입력, 5칸 굵은 경계선
- `widgets/clue_widget.dart`: 행·열 클루 표시, 완성된 행/열 흐리게+취소선

#### Phase 5 — 결과·갤러리 화면
- `result_controller.dart` + `result_page.dart`: 클리어 애니메이션, 썸네일(Base64/URL), 소요 시간, Home/Next Level 버튼
- `gallery_controller.dart` + `gallery_page.dart`: 3열 썸네일 그리드, 탭 시 제목·시간 상세 팝업

#### Phase 6 — 서비스·설정 화면
- `settings_service.dart`: SharedPreferences 기반, 반응형 Rx 상태값(isMusicOn 등)
- `audio_service.dart`: BGM 루프 재생 + 효과음 4종(채우기/X표시/오류/클리어)
- `ad_service.dart`: AdMob 전면 광고 (테스트 ID, 로드 후 자동 예비 로드)
- `banner_ad_widget.dart`: AdMob 배너 광고 StatefulWidget
- `settings_page.dart`: 토글 4종(음악/효과음/진동/Easy모드) + 인앱 리뷰 버튼

#### 기타
- `AndroidManifest.xml`: 앱 이름 → "pikuman4 : nonogram", AdMob 테스트 App ID 설정
- `pubspec.yaml`: `path: ^1.9.0` 추가 (sqflite DB 경로용)
- `tool/` 구 pikuman3 파일 삭제 (analyze_hint_limits.dart, verify_level_design.dart)
- **flutter analyze**: No issues found

### 다음 할 일
- **퍼즐 생성**: 어드민 도구로 이모지 PNG → 레벨 1~50 퍼즐 JSON 제작 후 `assets/data/puzzles/`에 배치
- **실기기 테스트**: `flutter run` 으로 실제 디바이스에서 전체 흐름 확인
- **Phase 8**: 앱 아이콘·스플래시 이미지 교체, AdMob 실제 ID 교체, 스토어 출시 준비

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
