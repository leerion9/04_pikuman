# core/services

앱 전역에서 사용하는 서비스(저장, 광고 등)를 두는 폴더입니다.

## 파일

- `level_progress_service.dart` - 다음에 플레이할 레벨(1~101) 저장·조회 (SharedPreferences)
- `settings_service.dart` - BGM·효과음·진동 on/off 저장·조회 (SharedPreferences)
- `ad_service.dart` - AdMob 배너 preload·캐시, 전면 광고 로드·노출 (10레벨마다, 실패 시 백오프 재시도)
- `route_sync_service.dart` - 현재 라우트 동기화 (하단 배너 표시 여부)
