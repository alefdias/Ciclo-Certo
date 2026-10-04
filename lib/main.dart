import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app/app.dart';
import 'core/providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Inicializa localização em português para formatação de datas e horas
  await initializeDateFormatting('pt_BR', null);

  // Inicializa container Riverpod
  final container = ProviderContainer();

  // Inicializa notificações
  final notificationService = container.read(notificationServiceProvider);
  await notificationService.initialize();


  // Inicia a sincronização de notificações
  container.read(notificationSyncProvider);

  runApp(
    UncontrolledProviderScope(container: container, child: const VelixMedApp()),
  );
}
