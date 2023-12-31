import 'dart:io';
import 'dart:math';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:goipvc/models/myipvc/lesson.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;

import '../providers/settings_provider.dart';

class Notifications {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid
      = AndroidInitializationSettings("@drawable/ic_stat_logo");
    const DarwinInitializationSettings initializationSettingsDarwin
      = DarwinInitializationSettings(
        onDidReceiveLocalNotification: null
      );
    const LinuxInitializationSettings initializationSettingsLinux
      = LinuxInitializationSettings(defaultActionName: "Open notification");

    await _notificationsPlugin.initialize(
      const InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
        macOS: initializationSettingsDarwin,
        linux: initializationSettingsLinux
      )
    );
  }

  static Future<void> scheduleLessonWarningNotification
      (String name, DateTime startDate, int minsBefore, String room) async {
    // Scheduled notifications are not implemented in these platforms
    if(Platform.isLinux || Platform.isWindows) {
      return;
    }

    const AndroidNotificationDetails androidNotificationDetails
      = AndroidNotificationDetails(
        "lessonAlert",
        "Aviso de aula",
        channelDescription: "Avisar x minutos antes de uma aula começar",
        importance: Importance.max,
        priority: Priority.max
      );

    const NotificationDetails notificationDetails
      = NotificationDetails(android: androidNotificationDetails);

    DateTime notificationTime = startDate.subtract(Duration(minutes: minsBefore));

    var scheduledDate = tz.TZDateTime.from(
        notificationTime, tz.getLocation("Europe/Lisbon")
    );

    await _notificationsPlugin.zonedSchedule(
      Random().nextInt(2147483647),
      name,
      "Começa em ${SettingsNotifier.getLessonAlertString(minsBefore)} na sala $room",
      scheduledDate,
      notificationDetails,
      matchDateTimeComponents: DateTimeComponents.time,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime
    );
  }

  static Future<void> discardLessonWarningNotifications() async {
    // Scheduled notifications are not implemented in these platforms
    if(Platform.isLinux || Platform.isWindows) {
      return;
    }

    for(var notification in await _notificationsPlugin.pendingNotificationRequests()){
      _notificationsPlugin.cancel(notification.id);
    }
  }

  static Future<void> parseSchedule(List<MyIPVCLesson> schedule) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int? lessonAlert = prefs.getInt("lessonAlert");

    if(lessonAlert == 0 || lessonAlert == null) {
      return;
    }

    for(var lesson in schedule) {
      if(["#ff0000", "#f4b7b7", "#f0a0a0", "#f0a0a0", "#7f5555"]
          .contains(lesson.corValor)){
        continue;
      }

      DateTime lessonDate = DateTime.parse(lesson.dataHoraIni);

      bool lessonIsInTheNext24hours =
          lessonDate.difference(DateTime.now()).inSeconds > lessonAlert * 60
          && lessonDate.difference(DateTime.now()).inHours < 24;

      if (lessonIsInTheNext24hours) {
        await Notifications.scheduleLessonWarningNotification(
            "${lesson.sigla} - ${lesson.horNomeTurno}",
            lessonDate,
            lessonAlert,
            lesson.sala
        );
      }
    }
  }
}