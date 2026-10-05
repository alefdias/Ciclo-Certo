import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../app/theme/app_colors.dart';
import '../core/providers.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/dashboard/home_screen.dart';
import '../features/history/history_screen.dart';
import '../features/medications/add_medication_screen.dart';
import '../features/medications/medications_screen.dart';
import '../features/settings/settings_screen.dart';
import '../features/settings/privacy_lock_screen.dart';
import '../features/settings/partner_sync_screen.dart';
import '../features/stock/stock_screen.dart';
import '../features/diary/diary_screen.dart';
import '../features/auth/login_screen.dart';
import '../features/auth/role_selection_screen.dart';
import '../features/chat/zap_ciclo_screen.dart';
import '../services/user_profile_service.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/login',
  routes: [
    ShellRoute(
      builder: (context, state, child) {
        return _AppScaffoldShell(child: child);
      },
      routes: [
        GoRoute(
          path: '/',
          pageBuilder:
              (context, state) => const NoTransitionPage(child: HomeScreen()),
        ),
        GoRoute(
          path: '/medications',
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: MedicationsScreen()),
        ),
        GoRoute(
          path: '/calendar',
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: CalendarScreen()),
        ),
        GoRoute(
          path: '/diary',
          pageBuilder:
              (context, state) => const NoTransitionPage(child: DiaryScreen()),
        ),
        GoRoute(
          path: '/history',
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: HistoryScreen()),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder:
              (context, state) =>
                  const NoTransitionPage(child: SettingsScreen()),
        ),
      ],
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/role-selection',
      builder: (context, state) => const RoleSelectionScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/stock',
      builder: (context, state) => const StockScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/add-medication',
      redirect: (context, state) async {
        final role = await UserProfileService.instance.getUserRole();
        if (role == UserRole.partner) {
          return '/medications';
        }
        return null;
      },
      builder: (context, state) => const AddMedicationScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/partner-sync',
      builder: (context, state) => const PartnerSyncScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/privacy-lock',
      builder: (context, state) => const PrivacyLockScreen(),
    ),
    GoRoute(
      parentNavigatorKey: _rootNavigatorKey,
      path: '/zapciclo',
      builder: (context, state) => const ZapCicloScreen(),
    ),
  ],
);

class _AppScaffoldShell extends ConsumerWidget {
  const _AppScaffoldShell({required this.child});
  final Widget child;

  int _calculateSelectedIndex(BuildContext context, bool isPartner) {
    final String location = GoRouterState.of(context).uri.path;
    if (isPartner) {
      if (location.startsWith('/diary')) return 1;
      if (location.startsWith('/calendar')) return 2;
      if (location.startsWith('/settings')) return 3;
      return 0;
    } else {
      if (location.startsWith('/medications')) return 1;
      if (location.startsWith('/calendar')) return 2;
      if (location.startsWith('/diary')) return 3;
      if (location.startsWith('/history')) return 4;
      if (location.startsWith('/settings')) return 5;
      return 0;
    }
  }

  void _onItemTapped(int index, BuildContext context, bool isPartner) {
    if (isPartner) {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/diary');
          break;
        case 2:
          context.go('/calendar');
          break;
        case 3:
          context.go('/settings');
          break;
      }
    } else {
      switch (index) {
        case 0:
          context.go('/');
          break;
        case 1:
          context.go('/medications');
          break;
        case 2:
          context.go('/calendar');
          break;
        case 3:
          context.go('/diary');
          break;
        case 4:
          context.go('/history');
          break;
        case 5:
          context.go('/settings');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPartner = ref.watch(isPartnerModeProvider);
    final selectedIndex = _calculateSelectedIndex(context, isPartner);

    final destinations =
        isPartner
            ? const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Início',
              ),
              NavigationDestination(
                icon: Icon(Icons.favorite_outline_rounded),
                selectedIcon: Icon(Icons.favorite_rounded),
                label: 'Diário dela',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'Calendário',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_rounded),
                selectedIcon: Icon(Icons.tune_rounded),
                label: 'Ajustes',
              ),
            ]
            : const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home_rounded),
                label: 'Início',
              ),
              NavigationDestination(
                icon: Icon(Icons.medication_outlined),
                selectedIcon: Icon(Icons.medication_rounded),
                label: 'Métodos',
              ),
              NavigationDestination(
                icon: Icon(Icons.calendar_today_outlined),
                selectedIcon: Icon(Icons.calendar_month_rounded),
                label: 'Calendário',
              ),
              NavigationDestination(
                icon: Icon(Icons.book_outlined),
                selectedIcon: Icon(Icons.book_rounded),
                label: 'Diário',
              ),
              NavigationDestination(
                icon: Icon(Icons.history_rounded),
                selectedIcon: Icon(Icons.history_toggle_off_rounded),
                label: 'Histórico',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_rounded),
                selectedIcon: Icon(Icons.tune_rounded),
                label: 'Ajustes',
              ),
            ];

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected:
              (idx) => _onItemTapped(idx, context, isPartner),
          destinations: destinations,
        ),
      ),
    );
  }
}
