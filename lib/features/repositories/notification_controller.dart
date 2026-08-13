import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/entities.dart';
import '../../core/utils/financial_alert_engine.dart';
import 'providers.dart';
import 'controllers.dart';
import 'account_controller.dart';
import 'recurring_controller.dart';

class NotificationState {
  final List<NotificationEntity> notifications;
  final List<NotificationEntity> unreadNotifications;
  final int unreadCount;
  final NotificationSettingsEntity settings;
  final bool isLoading;
  final String? error;

  NotificationState({
    required this.notifications,
    required this.unreadNotifications,
    required this.unreadCount,
    required this.settings,
    required this.isLoading,
    this.error,
  });

  NotificationState copyWith({
    List<NotificationEntity>? notifications,
    List<NotificationEntity>? unreadNotifications,
    int? unreadCount,
    NotificationSettingsEntity? settings,
    bool? isLoading,
    String? Function()? error,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      unreadNotifications: unreadNotifications ?? this.unreadNotifications,
      unreadCount: unreadCount ?? this.unreadCount,
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

final notificationControllerProvider = StateNotifierProvider<NotificationStateController, NotificationState>((ref) {
  return NotificationStateController(ref);
});

class NotificationStateController extends StateNotifier<NotificationState> {
  final Ref _ref;

  NotificationStateController(this._ref)
      : super(NotificationState(
          notifications: [],
          unreadNotifications: [],
          unreadCount: 0,
          settings: NotificationSettingsEntity(),
          isLoading: true,
        )) {
    load().then((_) => syncFinancialAlerts());

    // Listen to changes reactively
    _ref.listen(transactionControllerProvider, (prev, next) {
      if (next.hasValue) {
        syncFinancialAlerts();
      }
    });
    _ref.listen(accountStateNotifierProvider, (prev, next) {
      if (!next.isLoading) {
        syncFinancialAlerts();
      }
    });
    _ref.listen(budgetControllerProvider, (prev, next) {
      if (next.hasValue) {
        syncFinancialAlerts();
      }
    });
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final getNotifs = _ref.read(getNotificationsUseCaseProvider);
      final getSettings = _ref.read(getNotificationSettingsUseCaseProvider);

      final notifs = await getNotifs();
      final settings = await getSettings();

      // Sort notifications by date descending
      notifs.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      final unread = notifs.where((n) => !n.isRead).toList();

      state = NotificationState(
        notifications: notifs,
        unreadNotifications: unread,
        unreadCount: unread.length,
        settings: settings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => 'Failed to load notifications.');
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _ref.read(markNotificationReadUseCaseProvider)(id);
      await load();
    } catch (e) {
      state = state.copyWith(error: () => 'Failed to update read status.');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      await _ref.read(markAllNotificationsReadUseCaseProvider)();
      await load();
    } catch (e) {
      state = state.copyWith(error: () => 'Failed to mark all as read.');
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _ref.read(deleteNotificationUseCaseProvider)(id);
      await load();
    } catch (e) {
      state = state.copyWith(error: () => 'Failed to delete notification.');
    }
  }

  Future<void> clearReadNotifications() async {
    try {
      await _ref.read(clearReadNotificationsUseCaseProvider)();
      await load();
    } catch (e) {
      state = state.copyWith(error: () => 'Failed to clear read notifications.');
    }
  }

  Future<void> updateSettings(NotificationSettingsEntity settings) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(updateNotificationSettingsUseCaseProvider)(settings);
      await load();
      await syncFinancialAlerts();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => 'Failed to save settings.');
    }
  }

  Future<void> syncFinancialAlerts() async {
    // If master notifications is off, skip generating alerts
    if (!state.settings.masterNotifications) return;

    try {
      final existing = await _ref.read(getNotificationsUseCaseProvider)();
      final createUseCase = _ref.read(createNotificationUseCaseProvider);

      final budgetState = _ref.read(budgetStateProvider);
      final budgets = budgetState.budgets;

      final recurringState = _ref.read(recurringControllerProvider);
      final upcomingRecurring = recurringState.upcomingPayments;

      final accountState = _ref.read(accountStateNotifierProvider);
      final accounts = accountState.accounts;

      final txState = _ref.read(transactionControllerProvider);
      final transactions = txState.value ?? [];

      final List<NotificationEntity> generated = [];

      // 1. Budget Alerts
      generated.addAll(FinancialAlertEngine.checkBudgetAlerts(
        budgets: budgets,
        existing: existing,
        settings: state.settings,
      ));

      // 2. Recurring Alerts
      generated.addAll(FinancialAlertEngine.checkRecurringAlerts(
        upcoming: upcomingRecurring,
        existing: existing,
        accounts: accounts,
        settings: state.settings,
      ));

      // 3. Low Balance Alerts
      generated.addAll(FinancialAlertEngine.checkLowBalanceAlerts(
        accounts: accounts,
        existing: existing,
        settings: state.settings,
      ));

      // 4. Large Expense Alerts
      generated.addAll(FinancialAlertEngine.checkLargeExpenses(
        transactions: transactions,
        existing: existing,
        settings: state.settings,
      ));

      // 5. Unusual Spending Alerts
      generated.addAll(FinancialAlertEngine.checkUnusualSpending(
        transactions: transactions,
        existing: existing,
        settings: state.settings,
      ));

      // 6. Monthly Summary and Insights Alerts
      generated.addAll(FinancialAlertEngine.checkMonthlySummaryAndInsights(
        transactions: transactions,
        existing: existing,
        settings: state.settings,
      ));

      // Create generated notifications
      for (var n in generated) {
        await createUseCase(n);
      }

      if (generated.isNotEmpty) {
        await load();
      }
    } catch (e) {
      // Fail silently in background sync, error is logged or ignored.
    }
  }
}
