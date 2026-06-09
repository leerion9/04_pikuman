// 앱 진입점: Flutter 앱을 시작하고 필수 서비스들을 초기화합니다.

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/services/ad_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/data_service.dart';
import 'core/services/level_progress_service.dart';
import 'core/services/save_service.dart';
import 'core/services/settings_service.dart';
import 'core/services/wordbook_service.dart';

/// 앱 시작 시 한 번 실행되는 진입점.
/// 세로 모드 고정, 광고 SDK 초기화, 서비스 등록을 순서대로 처리합니다.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 앱을 세로 모드로 고정합니다.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // AdMob SDK 초기화 (웹 빌드 제외)
  if (!kIsWeb) {
    await MobileAds.instance.initialize();
    Get.put<AdService>(AdService(), permanent: true);
    await Get.find<AdService>().init();
  }

  // SharedPreferences 인스턴스를 한 번 받아서 서비스에 전달합니다.
  final prefs = await SharedPreferences.getInstance();

  // 설정 서비스 (사운드·진동 설정 저장/불러오기)
  Get.put<SettingsService>(SettingsService(prefs), permanent: true);

  // 레벨 진행 서비스 (현재 레벨 번호 저장/불러오기)
  Get.put<LevelProgressService>(LevelProgressService(prefs), permanent: true);

  // 게임 진행 상태 저장 서비스 (음절 입력·타이머·힌트 횟수)
  Get.put<SaveService>(SaveService(prefs), permanent: true);

  // 단어장 서비스 (클리어한 레벨의 단어·뜻 저장)
  Get.put<WordbookService>(WordbookService(prefs), permanent: true);

  // 오디오 서비스 (BGM·효과음)
  Get.put<AudioService>(AudioService(), permanent: true);

  // 데이터 서비스 (word_pool.csv · level_design.csv — 실제 로드는 SplashPage 에서 수행)
  Get.put<DataService>(DataService(), permanent: true);

  runApp(const App());
}
