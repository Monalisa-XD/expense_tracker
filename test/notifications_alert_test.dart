import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/entities.dart';
import 'package:expense_tracker/core/utils/financial_alert_engine.dart';

void main() {
  group('Smart Notifications & Financial Alerts Unit Tests', () {
    late NotificationSettingsEntity settings;

    setUp(() {
      settings = NotificationSettingsEntity(
        masterNotifications: true,
        budgetAlerts: true,
        recurringPaymentAlerts: true,
        lowBalanceAlerts: true,
        largeExpenseAlerts: true,
        weeklySummary: true,
        monthlySummary: true,
        lowBalanceThreshold: 3000.0,
        largeExpenseThreshold: 10000.0,
        budgetWarningThreshold: 90.0,
      );
    });

    test('Budget 50% threshold alert generation', () {
      final List<BudgetEntity> budgets = [
        BudgetEntity(
          id: 'b_shopping',
          categoryId: 'shopping',
          limitAmount: 5000.0,
          spentAmount: 2500.0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          createdAt: DateTime.now(),
          alertPercentage: 80.0,
        ),
      ];

      final alerts = FinancialAlertEngine.checkBudgetAlerts(
        budgets: budgets,
        existing: [],
        settings: settings,
      );

      expect(alerts.any((n) => n.id.contains('50')), true);
    });

    test('Budget 75% threshold alert generation', () {
      final List<BudgetEntity> budgets = [
        BudgetEntity(
          id: 'b_shopping',
          categoryId: 'shopping',
          limitAmount: 5000.0,
          spentAmount: 3750.0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          createdAt: DateTime.now(),
          alertPercentage: 80.0,
        ),
      ];

      final alerts = FinancialAlertEngine.checkBudgetAlerts(
        budgets: budgets,
        existing: [],
        settings: settings,
      );

      expect(alerts.any((n) => n.id.contains('75')), true);
    });

    test('Budget 90% threshold alert generation', () {
      final List<BudgetEntity> budgets = [
        BudgetEntity(
          id: 'b_shopping',
          categoryId: 'shopping',
          limitAmount: 5000.0,
          spentAmount: 4500.0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          createdAt: DateTime.now(),
          alertPercentage: 80.0,
        ),
      ];

      final alerts = FinancialAlertEngine.checkBudgetAlerts(
        budgets: budgets,
        existing: [],
        settings: settings,
      );

      expect(alerts.any((n) => n.id.contains('90')), true);
    });

    test('Budget exceeded alert generation', () {
      final List<BudgetEntity> budgets = [
        BudgetEntity(
          id: 'b_shopping',
          categoryId: 'shopping',
          limitAmount: 5000.0,
          spentAmount: 5400.0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          createdAt: DateTime.now(),
          alertPercentage: 80.0,
        ),
      ];

      final alerts = FinancialAlertEngine.checkBudgetAlerts(
        budgets: budgets,
        existing: [],
        settings: settings,
      );

      expect(alerts.any((n) => n.type == NotificationType.budgetExceeded), true);
    });

    test('Duplicate notification prevention', () {
      final List<BudgetEntity> budgets = [
        BudgetEntity(
          id: 'b_shopping',
          categoryId: 'shopping',
          limitAmount: 5000.0,
          spentAmount: 4500.0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          createdAt: DateTime.now(),
          alertPercentage: 80.0,
        ),
      ];
      final existing = [
        NotificationEntity(
          id: 'budget_b_shopping_2026_08_90',
          type: NotificationType.budgetWarning,
          title: 'Shopping Budget',
          message: 'Shopping budget is 90% used.',
          createdAt: DateTime.now(),
        ),
      ];

      final alerts = FinancialAlertEngine.checkBudgetAlerts(
        budgets: budgets,
        existing: existing,
        settings: settings,
      );

      expect(alerts.any((n) => n.id == 'budget_b_shopping_2026_08_90'), false);
    });

    test('Recurring payment reminders (7 days, 3 days, 1 day, today)', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final List<RecurringTransactionEntity> upcoming = [
        RecurringTransactionEntity(
          id: 'rec_netflix',
          title: 'Netflix',
          amount: 649.0,
          type: TransactionType.expense,
          categoryId: 'entertainment',
          accountId: 'acc_hdfc',
          paymentMethod: PaymentMethod.upi,
          frequency: RecurringFrequency.monthly,
          startDate: today,
          nextOccurrenceDate: today.add(const Duration(days: 1)),
          createdAt: today,
        ),
      ];

      final List<AccountEntity> accounts = [
        AccountEntity(id: 'acc_hdfc', name: 'HDFC Bank', balance: 5000.0, type: PaymentMethod.bank, initialBalance: 5000.0),
      ];

      final alerts = FinancialAlertEngine.checkRecurringAlerts(
        upcoming: upcoming,
        existing: [],
        accounts: accounts,
        settings: settings,
      );

      expect(alerts.any((n) => n.type == NotificationType.recurringPayment && n.message.contains('tomorrow')), true);
    });

    test('Recurring payment failed / Insufficient balance alert', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      final List<RecurringTransactionEntity> upcoming = [
        RecurringTransactionEntity(
          id: 'rec_netflix',
          title: 'Netflix',
          amount: 649.0,
          type: TransactionType.expense,
          categoryId: 'entertainment',
          accountId: 'acc_hdfc',
          paymentMethod: PaymentMethod.upi,
          frequency: RecurringFrequency.monthly,
          startDate: today,
          nextOccurrenceDate: today.add(const Duration(days: 1)),
          createdAt: today,
        ),
      ];

      final List<AccountEntity> accounts = [
        AccountEntity(id: 'acc_hdfc', name: 'HDFC Bank', balance: 400.0, type: PaymentMethod.bank, initialBalance: 400.0),
      ];

      final alerts = FinancialAlertEngine.checkRecurringAlerts(
        upcoming: upcoming,
        existing: [],
        accounts: accounts,
        settings: settings,
      );

      expect(alerts.any((n) => n.type == NotificationType.lowBalance && n.title.contains('Insufficient')), true);
    });

    test('Low account balance alert', () {
      final List<AccountEntity> accounts = [
        AccountEntity(id: 'acc_hdfc', name: 'HDFC Bank', balance: 2100.0, type: PaymentMethod.bank, initialBalance: 5000.0),
      ];

      final alerts = FinancialAlertEngine.checkLowBalanceAlerts(
        accounts: accounts,
        existing: [],
        settings: settings,
      );

      expect(alerts.any((n) => n.type == NotificationType.lowBalance && n.message.contains('below your minimum')), true);
    });

    test('Large expense detection ignores transfers', () {
      final List<TransactionEntity> txs = [
        TransactionEntity(
          id: 'tx_large',
          amount: 15000.0,
          type: TransactionType.expense,
          categoryId: 'shopping',
          accountId: 'acc_hdfc',
          title: 'Amazon',
          date: DateTime.now(),
          paymentMethod: PaymentMethod.upi,
          createdAt: DateTime.now(),
        ),
        TransactionEntity(
          id: 'tx_transfer',
          amount: 25000.0,
          type: TransactionType.transfer,
          categoryId: 'transfer',
          accountId: 'acc_hdfc',
          title: 'HDFC to Cash',
          date: DateTime.now(),
          paymentMethod: PaymentMethod.bank,
          createdAt: DateTime.now(),
        ),
      ];

      final alerts = FinancialAlertEngine.checkLargeExpenses(
        transactions: txs,
        existing: [],
        settings: settings,
      );

      expect(alerts.any((n) => n.relatedEntityId == 'tx_large'), true);
      expect(alerts.any((n) => n.relatedEntityId == 'tx_transfer'), false);
    });

    test('Monthly summary generation and Savings Insights rate comparison', () {
      final now = DateTime.now();

      final List<TransactionEntity> txs = [
        TransactionEntity(
          id: 'tx_inc_1', amount: 73500.0, type: TransactionType.income,
          categoryId: 'salary_income', accountId: 'acc_hdfc', title: 'Salary',
          date: now, paymentMethod: PaymentMethod.bank, createdAt: now,
        ),
        TransactionEntity(
          id: 'tx_exp_1', amount: 18097.0, type: TransactionType.expense,
          categoryId: 'bills_recharge', accountId: 'acc_hdfc', title: 'Amazon',
          date: now, paymentMethod: PaymentMethod.upi, createdAt: now,
        ),
        TransactionEntity(
          id: 'tx_inc_last', amount: 70000.0, type: TransactionType.income,
          categoryId: 'salary_income', accountId: 'acc_hdfc', title: 'Salary',
          date: now.subtract(const Duration(days: 35)), paymentMethod: PaymentMethod.bank, createdAt: now,
        ),
        TransactionEntity(
          id: 'tx_exp_last', amount: 25000.0, type: TransactionType.expense,
          categoryId: 'bills_recharge', accountId: 'acc_hdfc', title: 'Amazon',
          date: now.subtract(const Duration(days: 35)), paymentMethod: PaymentMethod.upi, createdAt: now,
        ),
      ];

      final alerts = FinancialAlertEngine.checkMonthlySummaryAndInsights(
        transactions: txs,
        existing: [],
        settings: settings,
      );

      expect(alerts.any((n) => n.type == NotificationType.monthlySummary), true);
      expect(alerts.any((n) => n.title.contains('Savings Insight')), true);
    });
  });
}
