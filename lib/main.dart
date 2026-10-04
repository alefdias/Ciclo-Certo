import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint('Firebase não inicializado nesta plataforma: $e');
  }

  // Inicializa localização em português para formatação de datas e horas
  await initializeDateFormatting('pt_BR', null);

  // Inicializa container Riverpod
  final container = ProviderContainer();

  // Inicializa notificações
  try {
    final notificationService = container.read(notificationServiceProvider);
    await notificationService.initialize();
    container.read(notificationSyncProvider);
  } catch (e) {
    debugPrint('Notificações não inicializadas nesta plataforma: $e');
  }

  runApp(
    UncontrolledProviderScope(container: container, child: const VelixMedApp()),
  );
}
