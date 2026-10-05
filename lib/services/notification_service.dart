import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/providers.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  factory NotificationService() => instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    final LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    final InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Lógica ao clicar na notificação
      },
    );
  }

  /// Exibe uma notificação imediata (ex: quando parceira toma o remédio)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails
    androidDetails = AndroidNotificationDetails(
      'partner_updates_channel',
      'Avisos da Parceira',
      channelDescription:
          'Notificações em tempo real sobre medicamentos e bem-estar da parceira',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(id, title, body, details);
  }

  Future<void> scheduleDoseNotification(DoseItem dose) async {
    final now = DateTime.now();
    if (dose.occurrence.scheduledAt.isBefore(now)) return;
    if (dose.isDone) return;

    final id = dose.occurrence.hashCode.abs();

    // Converte DateTime local para TZDateTime
    final scheduledDate = tz.TZDateTime.from(
      dose.occurrence.scheduledAt,
      tz.local,
    );

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'dose_channel',
          'Lembretes de Doses',
          channelDescription:
              'Canal de notificações para lembrar de tomar medicamentos',
          importance: Importance.max,
          priority: Priority.high,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      'Hora do medicamento!',
      'É hora de tomar ${dose.medication.displayName}.',
      scheduledDate,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.dateAndTime,
    );
  }

  Future<void> cancelDoseNotification(DoseItem dose) async {
    final id = dose.occurrence.hashCode.abs();
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> syncNotifications(List<DoseItem> upcomingDoses) async {
    await cancelAll();
    for (final dose in upcomingDoses) {
      if (dose.occurrence.scheduledAt.isAfter(DateTime.now()) && !dose.isDone) {
        await scheduleDoseNotification(dose);
      }
    }
  }
}
