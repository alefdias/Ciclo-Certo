import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../core/providers.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();
  factory NotificationService() => instance;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const AndroidNotificationChannel doseChannel =
      AndroidNotificationChannel(
        'dose_channel',
        'Lembretes de Doses',
        description: 'Notificações sonoras para lembrar de tomar medicamentos',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  static const AndroidNotificationChannel partnerChannel =
      AndroidNotificationChannel(
        'partner_updates_channel',
        'Avisos da Parceira e ZapCiclo',
        description: 'Notificações em tempo real sobre medicamentos e mensagens',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  /// Gera um ID inteiro de 31 bits estável e determinístico a partir de uma chave textual
  static int stableNotificationId(String key) {
    var hash = 5381;
    for (var i = 0; i < key.length; i++) {
      hash = ((hash << 5) + hash) + key.codeUnitAt(i);
    }
    return hash.abs() % 2147483647;
  }

  Future<void> initialize() async {
    tz.initializeTimeZones();
    try {
      final timezoneInfo = await FlutterTimezone.getLocalTimezone();
      final String currentTimeZone = timezoneInfo.identifier;
      tz.setLocalLocation(tz.getLocation(currentTimeZone));
    } catch (e) {
      debugPrint('Aviso ao obter fuso horário no NotificationService: $e');
      try {
        tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));
      } catch (_) {}
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

    // Garante criação imediata dos canais no Android
    final androidImpl = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidImpl != null) {
      try {
        await androidImpl.createNotificationChannel(doseChannel);
        await androidImpl.createNotificationChannel(partnerChannel);
      } catch (e) {
        debugPrint('Erro ao criar canais de notificação no Android: $e');
      }
    }
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

      try {
        await androidImplementation.createNotificationChannel(doseChannel);
        await androidImplementation.createNotificationChannel(partnerChannel);
      } catch (e) {
        debugPrint('Erro ao reassegurar canais de notificação: $e');
      }
    }
  }

  /// Exibe uma notificação imediata (ex: ZapCiclo ou parceira tomou remédio)
  Future<void> showImmediateNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    final safeId = id.abs() % 2147483647;

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'partner_updates_channel',
      'Avisos da Parceira e ZapCiclo',
      channelDescription:
          'Notificações em tempo real sobre medicamentos e mensagens',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      category: AndroidNotificationCategory.message,
      visibility: NotificationVisibility.public,
    );
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _plugin.show(safeId, title, body, details);
  }

  Future<void> scheduleDoseNotification(DoseItem dose) async {
    final now = DateTime.now();
    if (dose.occurrence.scheduledAt.isBefore(now)) return;
    if (dose.isDone) return;

    final id = stableNotificationId(dose.occurrence.key);

    // Constrói o TZDateTime no fuso local pelos componentes exatos (ano, mês, dia, hora, minuto)
    final scheduledDate = tz.TZDateTime(
      tz.local,
      dose.occurrence.scheduledAt.year,
      dose.occurrence.scheduledAt.month,
      dose.occurrence.scheduledAt.day,
      dose.occurrence.scheduledAt.hour,
      dose.occurrence.scheduledAt.minute,
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) return;

    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'dose_channel',
          'Lembretes de Doses',
          channelDescription:
              'Notificações sonoras para lembrar de tomar medicamentos',
          importance: Importance.max,
          priority: Priority.max,
          icon: '@mipmap/ic_launcher',
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.reminder,
          visibility: NotificationVisibility.public,
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
    final id = stableNotificationId(dose.occurrence.key);
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
