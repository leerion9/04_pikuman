# pikuman4 Admin Tool

**노노그램 퍼즐 생성·검증·저장용 Windows 데스크톱 앱**

---

## 기능 요약

| 기능 | 설명 |
|------|------|
| 이미지 → 퍼즐 변환 | jpg/png 이미지를 노노그램 그리드로 자동 변환 |
| 임계값 조정 | 슬라이더로 흑백 변환 기준값 실시간 조정 |
| 흑백 반전 | 배경이 어두운 이미지 대응 |
| 수동 셀 편집 | 클릭/드래그로 셀 직접 채우기/지우기 |
| 클루 자동 계산 | 그리드 변경 시 행·열 클루 자동 재계산 |
| 플레이 테스트 | 생성한 퍼즐을 직접 풀어보며 유효성 검증 |
| JSON 저장 | puzzle_001.json 형식으로 저장 |

---

## 실행 방법

### 1. Windows 개발자 모드 활성화 (최초 1회)

Flutter Windows 빌드에는 심볼릭 링크 권한이 필요합니다.

1. 설정 앱 열기 → **개인 정보 및 보안** → **개발자용**
2. **개발자 모드** 켜기

또는 PowerShell에서:
```
start ms-settings:developers
```

### 2. 빌드 및 실행

```powershell
cd c:\cursor\04_pikuman4\admin
flutter run -d windows
```

또는 Release 빌드:
```powershell
flutter build windows
# 실행 파일: build\windows\x64\runner\Release\pikuman4_admin.exe
```

---

## 화면 구성

### 홈 화면
- 저장된 퍼즐 카드 목록 (그리드 형태)
- 우하단 **"새 퍼즐 만들기"** 버튼
- 상단 출력 폴더 경로 표시 및 변경
- 카드 우클릭 → 삭제

### 에디터 화면
**왼쪽 패널:**
- 이미지 선택 버튼 + 미리보기
- 그리드 크기 선택 (10×10 / 15×15 / 20×20 / 25×25 등)
- 이진화 임계값 슬라이더
- 흑백 반전 버튼
- 채움 비율 표시 (적정: 20%~60%)
- 퍼즐 제목·레벨 번호 입력

**오른쪽 패널:**
- 클루 숫자 + 편집 가능한 그리드
- 클릭/드래그: 셀 채우기/지우기

**상단 버튼:**
- **플레이 테스트** — 직접 풀어보기
- **저장** — JSON 파일 저장

### 플레이 테스트 화면
- 실제 게임처럼 퍼즐 풀기
- 모드 전환: 채우기 ↔ X표시
- 클리어 시 "유효한 퍼즐" 확인 메시지

---

## 출력 폴더

기본 출력 폴더: 앱 실행 위치의 `output/` 폴더

저장된 JSON을 게임 앱의 번들 퍼즐로 사용하려면:
```
output/puzzle_001.json
  ↓ 복사
c:\cursor\04_pikuman4\assets\data\puzzles\puzzle_001.json
```

---

## 폴더 구조

```
lib/
├── main.dart
├── app/
│   ├── app.dart
│   └── routes/app_pages.dart
├── core/
│   ├── engine/              # 노노그램 엔진 (게임 앱과 동일)
│   └── image/
│       └── image_binarizer.dart  # 이미지 → 이진 그리드 변환
└── features/
    ├── home/                # 홈 화면 (퍼즐 목록)
    ├── editor/              # 에디터 화면 (핵심 기능)
    └── play_test/           # 플레이 테스트 화면
```
