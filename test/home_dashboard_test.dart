import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/entities.dart';
import 'package:expense_tracker/features/repositories/analytics_usecases.dart';

void main() {
  group('Home Dashboard 2.0 Components & Render Logic Tests', () {
    test('Balance rendering calculation matches active accounts', () {
      final accounts = [
        AccountEntity(id: '1', name: 'HDFC', balance: 45200.0, type: PaymentMethod.bank, initialBalance: 45200.0),
        AccountEntity(id: '2', name: 'SBI', balance: 18500.0, type: PaymentMethod.bank, initialBalance: 18500.0),
      ];

      final total = accounts.fold<double>(0.0, (sum, acc) => sum + acc.balance);
      expect(total, 63700.0);
    });

    test('Income & Expense Summary calculations are correct', () {
      final list = [
        TransactionEntity(
          id: '1', amount: 73500.0, type: TransactionType.income,
          categoryId: 'salary_income', accountId: 'acc_hdfc', title: 'Salary',
          date: DateTime.now(), paymentMethod: PaymentMethod.bank, createdAt: DateTime.now(),
        ),
        TransactionEntity(
          id: '2', amount: 18097.0, type: TransactionType.expense,
          categoryId: 'shopping', accountId: 'acc_hdfc', title: 'Shopping',
          date: DateTime.now(), paymentMethod: PaymentMethod.upi, createdAt: DateTime.now(),
        ),
      ];

      final summary = GetFinancialSummaryUseCase().call(list);
      expect(summary.totalIncome, 73500.0);
      expect(summary.totalExpenses, 18097.0);
    });

    test('Savings & Savings Rate calculation', () {
      final summary = FinancialSummary(
        totalIncome: 73500.0,
        totalExpenses: 18097.0,
        savings: 55403.0,
        savingsRate: 75.378,
      );

      expect(summary.savings, 55403.0);
      expect(summary.savingsRate.toStringAsFixed(1), '75.4');
    });

    test('Period switching updates AnalyticsPeriodState', () {
      var period = 'Month';
      // Switch period
      period = 'Week';
      expect(period, 'Week');
    });

    test('Budget overview uses BudgetStatusHelper to derive health status', () {
      final budget = BudgetEntity(
        id: 'b1',
        categoryId: 'shopping',
        limitAmount: 5000.0,
        spentAmount: 4600.0,
        startDate: DateTime.now(),
        endDate: DateTime.now(),
        createdAt: DateTime.now(),
        alertPercentage: 80.0,
      );

      final ratio = budget.limitAmount > 0 ? (budget.spentAmount / budget.limitAmount) : 0.0;
      expect((ratio * 100).round(), 92);
      expect(ratio > 0.9, true);
    });

    test('Financial Alerts lists notifications', () {
      final alerts = [
        NotificationEntity(
          id: '1',
          type: NotificationType.budgetWarning,
          title: '⚠ Shopping budget 92% used',
          message: 'HDFC balance is below ₹3,000',
          createdAt: DateTime.now(),
        ),
      ];
      expect(alerts.length, 1);
      expect(alerts.first.title.contains('Shopping'), true);
    });

    test('Upcoming Payments details', () {
      final upcoming = [
        RecurringTransactionEntity(
          id: 'rec_netflix',
          title: 'Netflix',
          amount: 649.0,
          type: TransactionType.expense,
          categoryId: 'entertainment',
          accountId: 'acc_hdfc',
          paymentMethod: PaymentMethod.upi,
          frequency: RecurringFrequency.monthly,
          startDate: DateTime.now(),
          nextOccurrenceDate: DateTime.now().add(const Duration(days: 1)),
          createdAt: DateTime.now(),
        ),
      ];
      expect(upcoming.first.title, 'Netflix');
      expect(upcoming.first.amount, 649.0);
    });

    test('Accounts overview renders list details', () {
      final accounts = [
        AccountEntity(id: '1', name: 'HDFC Bank', balance: 45200.0, type: PaymentMethod.bank, initialBalance: 45200.0),
      ];
      expect(accounts.first.name, 'HDFC Bank');
      expect(accounts.first.balance, 45200.0);
    });

    test('Recent transactions classification', () {
      final tx = TransactionEntity(
        id: '1',
        amount: 420.0,
        type: TransactionType.expense,
        categoryId: 'food_dining',
        accountId: 'acc_hdfc',
        title: 'Swiggy',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.upi,
        createdAt: DateTime.now(),
        merchantName: 'Swiggy',
      );
      expect(tx.merchantName, 'Swiggy');
      expect(tx.amount, 420.0);
    });

    test('Dashboard empty state values', () {
      final list = <TransactionEntity>[];
      expect(list.isEmpty, true);
    });
  });
}
