import 'package:memecloud/core/noti_init.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// 0 <= progress <= 100
Future<void> sendProgressNoti({
  required int id,
  required String title,
  required int progress,
}) async {
  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    '$progress%',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'download_channel',
        'Downloads',
        channelDescription: 'Download progress notifications',
        showProgress: true,
        maxProgress: 100,
        progress: progress,
        onlyAlertOnce: true,
        playSound: false,
        priority: Priority.defaultPriority,
        importance: Importance.defaultImportance,
      ),
    ),
  );
}

Future<void> sendCompleteNoti({
  required int id,
  required String title,
  String body = 'Download completed',
}) async {
  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        'download_channel',
        'Downloads',
        channelDescription: 'Download progress notifications',
        priority: Priority.high,
        importance: Importance.high,
        playSound: true,
      ),
    ),
  );
}

Future<void> sendErrorNoti({
  required int id,
  required String title,
  required dynamic error,
}) async {
  await flutterLocalNotificationsPlugin.show(
    id,
    title,
    'Download failed: $error',
    NotificationDetails(
      android: AndroidNotificationDetails(
        'download_channel',
        'Downloads',
        channelDescription: 'Download progress notifications',
        priority: Priority.high,
        importance: Importance.high,
        playSound: true,
      ),
    ),
  );
}

Future<void> cancelNoti(int id) async {
  await flutterLocalNotificationsPlugin.cancel(id);
}
