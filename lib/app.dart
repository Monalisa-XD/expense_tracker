import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/repositories/providers.dart';
import 'features/security/presentation/app_lock_screen.dart';

class ExpenseTrackerApp extends ConsumerWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    ThemeMode mode = ThemeMode.system;
    if (themeMode == 'light') mode = ThemeMode.light;
    if (themeMode == 'dark') mode = ThemeMode.dark;

    return MaterialApp.router(
      title: 'ExpenseX',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: mode,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return AppLockScreen(child: child ?? const SizedBox());
      },
    );
  }
}
