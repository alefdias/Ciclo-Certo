import 'package:flutter/foundation.dart';
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
    try {
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
    } catch (e) {
      debugPrint('Aviso de fuso horário no NotificationService: $e');
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    const LinuxInitializationSettings initializationSettingsLinux =
        LinuxInitializationSettings(defaultActionName: 'Open notification');
    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
          macOS: initializationSettingsDarwin,
          linux: initializationSettingsLinux,
        );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Ação ao tocar na notificação
      },
    );

    await requestPermissions();
  }

  /// Solicita permissões explicitamente no Android (POST_NOTIFICATIONS e alarmes exatos)
  Future<void> requestPermissions() async {
    final androidImplementation = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidImplementation != null) {
      try {
        await androidImplementation.requestNotificationsPermission();
      } catch (e) {
        debugPrint('Erro ao solicitar permissão de notificações: $e');
      }

      try {
        await androidImplementation.requestExactAlarmsPermission();
      } catch (e) {
        debugPrint('Erro ao solicitar permissão de alarmes exatos: $e');
      }

      // Cria canais de notificação no Android com importância máxima e som
      const AndroidNotificationChannel doseChannel = AndroidNotificationChannel(
        'dose_channel',
        'Lembretes de Doses',
        description: 'Notificações sonoras para lembrar de tomar medicamentos',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      const AndroidNotificationChannel partnerChannel = AndroidNotificationChannel(
        'partner_updates_channel',
        'Avisos da Parceira',
        description: 'Notificações em tempo real sobre medicamentos e ZapCiclo',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      try {
        await androidImplementation.createNotificationChannel(doseChannel);
        await androidImplementation.createNotificationChannel(partnerChannel);
      } catch (e) {
        debugPrint('Erro ao criar canais de notificação: $e');
      }
    }
  }

  /// Exibe uma notificação imediata (ex: ZapCiclo ou parceira tomou remédio)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'partner_updates_channel',
      'Avisos da Parceira',
      channelDescription:
          'Notificações em tempo real sobre medicamentos e bem-estar da parceira',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(id % 2147483647, title, body, details);
  }

  Future<void> scheduleDoseNotification(DoseItem dose) async {
    final now = DateTime.now();
    if (dose.occurrence.scheduledAt.isBefore(now)) return;
    if (dose.isDone) return;

    final id = (dose.occurrence.hashCode.abs()) % 2147483647;

    // Converte DateTime local para TZDateTime
    final scheduledDate = tz.TZDateTime.from(
      dose.occurrence.scheduledAt,
      tz.local,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'dose_channel',
          'Lembretes de Doses',
          channelDescription:
              'Notificações sonoras para lembrar de tomar medicamentos',
          importance: Importance.max,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.reminder,
        );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    final title = 'Hora do remédio! 💊';
    final body =
        'É hora de tomar ${dose.medication.displayName} (${dose.quantityLabel}).';

    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (e) {
      debugPrint('Aviso: Tentando agendamento inexato de dose: $e');
      try {
        await _plugin.zonedSchedule(
          id,
          title,
          body,
          scheduledDate,
          details,
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        );
      } catch (err) {
        debugPrint('Erro ao agendar notificação: $err');
      }
    }
  }

  Future<void> cancelDoseNotification(DoseItem dose) async {
    final id = (dose.occurrence.hashCode.abs()) % 2147483647;
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }

  Future<void> syncNotifications(List<DoseItem> upcomingDoses) async {
    await cancelAll();
    final now = DateTime.now();
    for (final dose in upcomingDoses) {
      if (dose.occurrence.scheduledAt.isAfter(now) && !dose.isDone) {
        await scheduleDoseNotification(dose);
      }
    }
  }
}
