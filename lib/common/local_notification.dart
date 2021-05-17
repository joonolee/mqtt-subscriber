import 'package:fimber/fimber.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  static final String _kChannelId = 'your channel id';
  static final String _kChannelName = 'your channel name';
  static final String _kChannelDesc = 'your channel description';
  static final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  static String _selectedPayload;

  /// 초기화: main 에서 호출해야 함
  static Future<void> init() async {
    await _iosRequestPermissions();
    // 노티피케이션을 클릭해서 실행한 경우 앱 실행할 때 payload 를 받아옴
    final NotificationAppLaunchDetails appLaunchDetails =
        await _plugin.getNotificationAppLaunchDetails();
    if (appLaunchDetails?.didNotificationLaunchApp ?? false) {
      _selectedPayload = appLaunchDetails.payload;
      Fimber.d('LocalNotification LaunchApp Payload : $_selectedPayload');
    }
    final InitializationSettings initSettings = InitializationSettings(
      android: AndroidInitializationSettings('app_icon'),
      iOS: IOSInitializationSettings(),
      macOS: MacOSInitializationSettings(),
    );
    // 플러그인 초기화
    await _plugin.initialize(initSettings, onSelectNotification: (String payload) async {
      _selectedPayload = payload;
      // 앱 실행 중 뜬 노티피케이션을 클릭한 경우의 payload 를 받아옴
      Fimber.d('LocalNotification Running Payload : $payload');
    });
    Fimber.d('LocalNotification 초기화 완료');
  }

  /// 로컬 노티피케이션을 보여줌
  static Future<void> show({
    @required String title,
    @required String body,
    String payload,
  }) async {
    /// TODO(hein): channel definition (for android)
    /// 안드로이드 채널 설정
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _kChannelName,
      _kChannelDesc,
      importance: Importance.max,
      priority: Priority.high,
    );
    final NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);
    await _plugin.show(
      0, // id
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// iOS 권한 요청
  static Future<void> _iosRequestPermissions() async {
    await _plugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          sound: true,
          badge: false,
        );
  }
}
