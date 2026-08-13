import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/entities.dart';
import 'package:expense_tracker/core/utils/financial_alert_engine.dart';

void main() {
  group('Financial Alert Engine Tests', () {
    test('Budget alert triggered at 80%', () {
      final List<BudgetEntity> budgets = [
        BudgetEntity(
          id: 'b1',
          categoryId: 'cat_shopping',
          limitAmount: 5000.0,
          spentAmount: 4000.0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          alertPercentage: 80.0,
        ),
      ];

      final alerts = FinancialAlertEngine.checkBudgetAlerts(
        budgets: budgets,
        existing: [],
        enabled: true,
      );

      expect(alerts.length, 1);
      expect(alerts.first.type, NotificationType.budgetWarning);
      expect(alerts.first.priority, NotificationPriority.normal);
    });

    test('Budget alert triggered at 90%', () {
      final List<BudgetEntity> budgets = [
        BudgetEntity(
          id: 'b1',
          categoryId: 'cat_shopping',
          limitAmount: 5000.0,
          spentAmount: 4500.0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          alertPercentage: 80.0,
        ),
      ];

      final alerts = FinancialAlertEngine.checkBudgetAlerts(
        budgets: budgets,
        existing: [],
        enabled: true,
      );

      expect(alerts.length, 2); // triggers warning (80%) + critical (90%)
      expect(alerts.any((a) => a.type == NotificationType.budgetCritical), true);
    });

    test('Budget alert duplicate prevention test', () {
      final List<BudgetEntity> budgets = [
        BudgetEntity(
          id: 'b1',
          categoryId: 'cat_shopping',
          limitAmount: 5000.0,
          spentAmount: 4500.0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          alertPercentage: 80.0,
        ),
      ];

      final initialAlerts = FinancialAlertEngine.checkBudgetAlerts(
        budgets: budgets,
        existing: [],
        enabled: true,
      );

      // Run check again passing the previous alerts as existing
      final finalAlerts = FinancialAlertEngine.checkBudgetAlerts(
        budgets: budgets,
        existing: initialAlerts,
        enabled: true,
      );

      expect(finalAlerts.length, 0); // No duplicates generated
    });

    test('Low Balance Alert triggers and respects recovery transition', () {
      final accounts = [
        AccountEntity(
          id: 'acc1',
          name: 'HDFC',
          balance: 2500.0,
          type: PaymentMethod.bank,
          initialBalance: 5000.0,
        ),
      ];

      final alerts = FinancialAlertEngine.checkLowBalanceAlerts(
        accounts: accounts,
        existing: [],
        threshold: 3000.0,
        enabled: true,
      );

      expect(alerts.length, 1);
      expect(alerts.first.type, NotificationType.lowBalance);
    });
  });
}
