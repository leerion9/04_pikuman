// 광고 서비스: 배너·전면 광고를 중앙에서 preload·캐시·재시도합니다.

import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Size;
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// AdMob 배너·전면 광고 로드·캐시·표시를 담당하는 서비스.
///
/// - 배너: 앱 시작·스플래시에서 미리 로드, [AppBannerScaffold]에서 1개만 표시
/// - 전면: 앱 시작 시 preload, 실패 시 지수 백오프 재시도
class AdService extends GetxService {
  // ─── 광고 단위 ID ─────────────────────────────────────────
  /// 배너 광고 ID (pikuman3 메인 배너)
  static const String bannerAdUnitId =
      'ca-app-pub-2850426593033777/1590139214';

  /// 전면 광고 ID (pikuman3)
  static const String interstitialAdUnitId =
      'ca-app-pub-2850426593033777/2135418759';

  /// 재시도 대기 시간(초): 5 → 15 → 30 → 60 (이후 60초 고정)
  static const List<int> _retryDelaysSec = [5, 15, 30, 60];

  /// 배너·전면 각각 최대 재시도 횟수 (무한 루프 방지)
  static const int _maxRetries = 5;

  /// 화면 너비를 알기 전 preload에 쓰는 기본 폭(px, 세로 모드 일반 폰)
  static const int _defaultBannerWidthPx = 390;

  // ─── 배너 상태 ─────────────────────────────────────────────
  BannerAd? _bannerAd;
  AdSize? _bannerSize;
  bool _isBannerLoading = false;
  int _bannerRetryCount = 0;
  Timer? _bannerRetryTimer;
  int _lastBannerWidthPx = _defaultBannerWidthPx;

  /// 배너 로드 완료 여부 (UI 갱신용)
  final bannerReady = false.obs;

  /// 배너 슬롯 높이(px). 로드 전에도 고정값으로 레이아웃 유지.
  final bannerSlotHeight = 50.0.obs;

  // ─── 전면 광고 상태 ────────────────────────────────────────
  InterstitialAd? _interstitialAd;
  bool _isInterstitialLoading = false;
  int _interstitialRetryCount = 0;
  Timer? _interstitialRetryTimer;

  void _log(String msg) {
    if (kDebugMode) debugPrint('[AdService] $msg');
  }

  // ─── 초기화 ────────────────────────────────────────────────
  /// 앱 시작 시 전면·배너 preload를 시작합니다.
  Future<void> init() async {
    if (kIsWeb) return;
    await loadInterstitial();
    // 일반 폰 폭으로 먼저 preload (스플래시에서 실제 폭으로 보정 가능)
    unawaited(preloadBanner(_defaultBannerWidthPx));
  }

  @override
  void onClose() {
    _bannerRetryTimer?.cancel();
    _interstitialRetryTimer?.cancel();
    _bannerAd?.dispose();
    _bannerAd = null;
    _interstitialAd?.dispose();
    _interstitialAd = null;
    super.onClose();
  }

  // ─── 배너 ──────────────────────────────────────────────────

  /// 로드 완료된 배너 인스턴스 (없으면 null)
  BannerAd? get bannerAd => bannerReady.value ? _bannerAd : null;

  /// [widthPx] 화면 너비 기준으로 배너를 preload합니다.
  ///
  /// 이미 로드 중이거나 동일 폭으로 준비된 배너가 있으면 중복 요청하지 않습니다.
  Future<void> preloadBanner(int widthPx) async {
    if (kIsWeb) return;
    if (widthPx <= 0) widthPx = _defaultBannerWidthPx;
    _lastBannerWidthPx = widthPx;

    if (_isBannerLoading) return;
    if (bannerReady.value && _bannerAd != null) return;

    _isBannerLoading = true;
    _bannerRetryTimer?.cancel();

    try {
      final size = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        widthPx,
      );
      if (size == null) {
        _log('배너 AdSize 계산 실패 (width=$widthPx)');
        _isBannerLoading = false;
        _scheduleBannerRetry();
        return;
      }

      _bannerSize = size;
      bannerSlotHeight.value = size.height.toDouble();

      await _bannerAd?.dispose();
      _bannerAd = null;
      bannerReady.value = false;

      final ad = BannerAd(
        adUnitId: bannerAdUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _isBannerLoading = false;
            _bannerRetryCount = 0;
            bannerReady.value = true;
            _log('배너 로드 완료 (${size.width}x${size.height})');
          },
          onAdFailedToLoad: (ad, error) {
            ad.dispose();
            if (_bannerAd == ad) {
              _bannerAd = null;
              bannerReady.value = false;
            }
            _isBannerLoading = false;
            _log('배너 로드 실패: $error');
            _scheduleBannerRetry();
          },
        ),
      );

      _bannerAd = ad;
      await ad.load();
    } catch (e) {
      _isBannerLoading = false;
      _log('배너 preload 예외: $e');
      _scheduleBannerRetry();
    }
  }

  void _scheduleBannerRetry() {
    if (_bannerRetryCount >= _maxRetries) {
      _log('배너 재시도 상한 도달 ($_maxRetries회)');
      return;
    }
    final delaySec =
        _retryDelaysSec[min(_bannerRetryCount, _retryDelaysSec.length - 1)];
    _bannerRetryCount++;
    _bannerRetryTimer?.cancel();
    _bannerRetryTimer = Timer(Duration(seconds: delaySec), () {
      if (!bannerReady.value && !_isBannerLoading) {
        unawaited(preloadBanner(_lastBannerWidthPx));
      }
    });
    _log('배너 $delaySec초 후 재시도 ($_bannerRetryCount/$_maxRetries)');
  }

  /// 배너 슬롯 크기 (고정 레이아웃용)
  Size get bannerSlotSize => Size(
        _bannerSize?.width.toDouble() ?? _lastBannerWidthPx.toDouble(),
        bannerSlotHeight.value,
      );

  // ─── 전면 광고 ─────────────────────────────────────────────

  Future<void> loadInterstitial() async {
    if (kIsWeb) return;
    if (_isInterstitialLoading) return;
    if (_interstitialAd != null) return;

    _isInterstitialLoading = true;
    _interstitialRetryTimer?.cancel();

    await InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (InterstitialAd ad) {
          _isInterstitialLoading = false;
          _interstitialRetryCount = 0;
          _interstitialAd = ad;
          _setFullScreenCallback(ad);
          _log('전면 광고 로드 완료');
        },
        onAdFailedToLoad: (LoadAdError error) {
          _isInterstitialLoading = false;
          _interstitialAd = null;
          _log('전면 광고 로드 실패: $error');
          _scheduleInterstitialRetry();
        },
      ),
    );
  }

  void _scheduleInterstitialRetry() {
    if (_interstitialRetryCount >= _maxRetries) {
      _log('전면 재시도 상한 도달 ($_maxRetries회)');
      return;
    }
    final delaySec = _retryDelaysSec[
        min(_interstitialRetryCount, _retryDelaysSec.length - 1)];
    _interstitialRetryCount++;
    _interstitialRetryTimer?.cancel();
    _interstitialRetryTimer = Timer(Duration(seconds: delaySec), () {
      if (_interstitialAd == null && !_isInterstitialLoading) {
        unawaited(loadInterstitial());
      }
    });
    _log('전면 $delaySec초 후 재시도 ($_interstitialRetryCount/$_maxRetries)');
  }

  void _setFullScreenCallback(InterstitialAd ad) {
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        ad.dispose();
        _interstitialAd = null;
        unawaited(loadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        ad.dispose();
        _interstitialAd = null;
        _log('전면 광고 표시 실패: $error');
        unawaited(loadInterstitial());
      },
    );
  }

  /// 10레벨마다 전면 광고를 표시합니다.
  void showInterstitialEvery10Levels(int clearedLevel) {
    if (kIsWeb) return;
    if (clearedLevel <= 0 || clearedLevel % 10 != 0) return;
    if (_interstitialAd == null) return;
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
