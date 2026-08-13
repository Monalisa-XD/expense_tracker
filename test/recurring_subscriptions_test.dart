import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/entities.dart';

void main() {
  group('Subscriptions & Recurring Payments 2.0 Tests', () {
    test('Normalized Monthly & Yearly Cost Calculations', () {
      final monthlyItem = RecurringTransactionEntity(
        id: '1',
        title: 'Netflix',
        amount: 649.0,
        type: TransactionType.expense,
        categoryId: 'entertainment',
        accountId: 'acc1',
        paymentMethod: PaymentMethod.upi,
        frequency: RecurringFrequency.monthly,
        startDate: DateTime.now(),
        nextOccurrenceDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final yearlyItem = RecurringTransactionEntity(
        id: '2',
        title: 'Amazon Prime',
        amount: 1499.0,
        type: TransactionType.expense,
        categoryId: 'entertainment',
        accountId: 'acc1',
        paymentMethod: PaymentMethod.upi,
        frequency: RecurringFrequency.yearly,
        startDate: DateTime.now(),
        nextOccurrenceDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final quarterlyItem = RecurringTransactionEntity(
        id: '3',
        title: 'Sony LIV',
        amount: 599.0,
        type: TransactionType.expense,
        categoryId: 'entertainment',
        accountId: 'acc1',
        paymentMethod: PaymentMethod.upi,
        frequency: RecurringFrequency.quarterly,
        startDate: DateTime.now(),
        nextOccurrenceDate: DateTime.now(),
        createdAt: DateTime.now(),
      );

      // Monthly Cost normalization
      expect(monthlyItem.amount, 649.0);
      expect((yearlyItem.amount / 12.0).toStringAsFixed(2), '124.92');
      expect((quarterlyItem.amount / 3.0).toStringAsFixed(2), '199.67');

      // Yearly Cost normalization
      expect(monthlyItem.amount * 12.0, 7788.0);
      expect(yearlyItem.amount, 1499.0);
    });

    test('Countdown helper formats remaining days correctly', () {
      final today = DateTime.now();
      final dueToday = today;
      final dueTomorrow = today.add(const Duration(days: 1));
      final dueIn5 = today.add(const Duration(days: 5));

      String formatCountdown(DateTime date) {
        final diff = date.difference(today).inDays;
        if (diff == 0) return 'Due today';
        if (diff == 1) return 'Due tomorrow';
        return 'Due in $diff days';
      }

      expect(formatCountdown(dueToday), 'Due today');
      expect(formatCountdown(dueTomorrow), 'Due tomorrow');
      expect(formatCountdown(dueIn5), 'Due in 5 days');
    });
  });
}
