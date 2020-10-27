import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_segment/flutter_segment.dart';

import 'analytics_route_observer.dart';

/// Analytical information are collected only if [ENABLE_ANALYTICS] is true
/// It will be true if the app is in release mode.
const ENABLE_ANALYTICS = true;
//Todo (bibin): uncomment this after QA testing.
// const ENABLE_ANALYTICS = bool.fromEnvironment('dart.vm.product');

/// Class that collects and send analytical information to "Firebase" and "Segment"
class Analytics {
  static final Analytics instance = Analytics._internal();

  /// List contains whitelisted routes/screen names
  List _ignoredRoutes = [];

  Analytics._internal();

  /// An instance of Firebase Analytics API
  FirebaseAnalytics firebaseAnalytics;

  /// An instance of custom route observer created for analytics
  AnalyticsRouteObserver observer;

  /// true if the user is logged in to the app.
  bool _loggedIn = false;

  /// Initialises the instances created.
  /// Enables/disables "Analytics" based on [ENABLE_ANALYTICS].
  /// Sets the device-token to [Segment].
  void init({String deviceToken}) {
    firebaseAnalytics = FirebaseAnalytics();
    observer = AnalyticsRouteObserver(onNewRoute: _newRouteHandler);

    //Enable or disable the analytics on this device.
    firebaseAnalytics.setAnalyticsCollectionEnabled(ENABLE_ANALYTICS);
    ENABLE_ANALYTICS ? Segment.enable() : Segment.disable();

    if (deviceToken != null) _setSegmentDeviceToken(deviceToken);
  }

  /// Captures analytical information on route changes.
  void _newRouteHandler(PageRoute route) {
    this.setCurrentScreen(
      screenName: route.settings.name,
      properties: route.settings.arguments ?? {},
    );
  }

  /// Used to capture information when app is opened.
  void logAppOpened() async {
    await firebaseAnalytics?.logAppOpen();
    if (_loggedIn) await Segment.track(eventName: 'Application Opened');
  }

  /// Used to capture information when app goes to background.
  void logAppBackgrounded() async {
    if (_loggedIn) await Segment.track(eventName: 'Application Backgrounded');
  }

  /// Used to capture information when app is crashed.
  void logAppCrashed() async {
    if (_loggedIn) await Segment.track(eventName: 'Application Crashed');
  }

  /// Used to capture information about current screen in use.
  void setCurrentScreen({
    @required String screenName,
    Map<String, dynamic> properties = const {},
  }) async {
    if (screenName == null || _ignoredRoutes.contains(screenName)) return;

    await firebaseAnalytics?.setCurrentScreen(screenName: screenName);

    if (_loggedIn)
      await Segment.screen(
        screenName: screenName,
        properties: properties,
      );
  }

  /// Used to capture information when user log in.
  Future logLoginEvent(int userId) async {
    _loggedIn = true;

    _setFirebaseUserId(userId.toString());

    await firebaseAnalytics?.logLogin();
    // TODO: add traits if needed such as user-name, email, etc.
    await Segment.identify(
      userId: userId.toString(),
    );
  }

  /// Used to capture information when user log out.
  void logLogoutEvent() async {
    await firebaseAnalytics?.logEvent(name: 'logout');

    _loggedIn = false;
  }

  /// Sets the device-token to "Segment".
  void _setSegmentDeviceToken(String deviceToken) async =>
      await Segment.setContext({
        'device': {'token': deviceToken},
      });

  /// Sets the device-token to "Firebase".
  Future _setFirebaseUserId(String userId) async =>
      await firebaseAnalytics?.setUserId(userId);

  /// Used to capture analytical information and send to "Firebase"
  Future logToFirebase({
    @required String name,
    Map<String, dynamic> params,
  }) async =>
      await firebaseAnalytics?.logEvent(
        name: name,
        parameters: params,
      );

  /// Sets routes/screens which need to be whitelisted for analytics.
  void setIgnoredRoutes(List routes) {
    _ignoredRoutes = routes;
  }
}
