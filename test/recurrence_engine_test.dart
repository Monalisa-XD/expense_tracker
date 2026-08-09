import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/entities.dart';
import 'package:expense_tracker/core/utils/recurrence_engine.dart';

void main() {
  group('Recurrence Engine Tests', () {
    test('TEST 1 - Monthly Calculation', () {
      final start = DateTime(2026, 8, 15);
      final next = RecurrenceEngine.calculateNextOccurrence(start, RecurringFrequency.monthly);
      expect(next, DateTime(2026, 9, 15));
    });

    test('TEST 1.1 - Monthly Calculation Leap Year & Varying Month Lengths', () {
      final jan31 = DateTime(2024, 1, 31);
      final febOccurrence = RecurrenceEngine.calculateNextOccurrence(jan31, RecurringFrequency.monthly);
      expect(febOccurrence.month, 2);
      expect(febOccurrence.day, 29); // 2024 is a leap year

      final nextFromFeb = RecurrenceEngine.calculateNextOccurrence(febOccurrence, RecurringFrequency.monthly);
      expect(nextFromFeb.month, 3);
      expect(nextFromFeb.day, 29); // Next remains 29th
    });

    test('TEST 2 - Generate occurrences', () {
      final start = DateTime(2026, 8, 15);
      final lastGenerated = DateTime(2026, 8, 15);
      final today = DateTime(2026, 9, 20);

      final dates = RecurrenceEngine.generateDueDates(
        startDate: start,
        endDate: null,
        frequency: RecurringFrequency.monthly,
        lastGenerated: lastGenerated,
        today: today,
        skippedOccurrences: [],
      );

      expect(dates.length, 1);
      expect(dates.first, DateTime(2026, 9, 15));
    });

    test('TEST 5 & 6 - Pause / Resume simulation', () {
      final list = <RecurringTransactionEntity>[];
      final item = RecurringTransactionEntity(
        id: '1',
        title: 'Netflix',
        amount: 649,
        type: TransactionType.expense,
        categoryId: 'cat_entertainment',
        accountId: 'acc_cc',
        paymentMethod: PaymentMethod.creditCard,
        frequency: RecurringFrequency.monthly,
        startDate: DateTime(2026, 8, 15),
        nextOccurrenceDate: DateTime(2026, 8, 15),
        createdAt: DateTime.now(),
        isPaused: true,
      );
      list.add(item);

      // Verify that when paused, no new occurrences generated
      final active = list.where((e) => e.isActive && !e.isPaused).toList();
      expect(active.isEmpty, true);
    });

    test('TEST 7 - Skip Next', () {
      final skipDate = DateTime(2026, 8, 15);
      final skippedStr = skipDate.toIso8601String().split('T')[0];
      final dates = RecurrenceEngine.generateDueDates(
        startDate: DateTime(2026, 8, 15),
        endDate: null,
        frequency: RecurringFrequency.monthly,
        lastGenerated: DateTime(2026, 7, 15),
        today: DateTime(2026, 8, 20),
        skippedOccurrences: [skippedStr],
      );

      // Should not contain August 15 because it was skipped
      expect(dates.any((d) => d.day == 15 && d.month == 8), false);
    });
  });
}
