import 'package:flutter/material.dart';

import 'router.dart';
import 'theme/app_theme.dart';

class VelixMedApp extends StatelessWidget {
  const VelixMedApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Ciclo Certo :Lembrete',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
