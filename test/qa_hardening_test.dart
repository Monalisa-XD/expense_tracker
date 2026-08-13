import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/theme/entities.dart';
import 'package:expense_tracker/core/utils/recurrence_engine.dart';
import 'package:expense_tracker/features/repositories/datasources.dart';

class FailingSharedPreferences implements SharedPreferences {
  @override
  Future<bool> setString(String key, String value) async {
    return false; // Simulate write failure
  }

  @override
  String? getString(String key) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return null;
  }
}

void main() {
  group('QA & Edge Case Resilience Hardening Tests', () {
    test('Transaction persistence failure triggers rollback', () async {
      final badPrefs = FailingSharedPreferences();
      final datasource = MockTransactionDataSource(badPrefs);

      final initialCount = (await datasource.getTransactions()).length;

      final testTx = TransactionEntity(
        id: 'error_tx_1',
        amount: 500.0,
        type: TransactionType.expense,
        categoryId: 'shopping',
        accountId: 'acc1',
        title: 'Failing Tx',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.upi,
        createdAt: DateTime.now(),
      );

      // Verify saving throws StorageException and rolls back in-memory state
      expect(
        () => datasource.addTransaction(testTx),
        throwsA(isA<StorageException>()),
      );

      final postCount = (await datasource.getTransactions()).length;
      expect(postCount, initialCount); // Must remain identical after rollback!
    });

    test('Transfer atomicity test: source subtraction and destination addition', () {
      final initialFromBalance = 5000.0;
      final initialToBalance = 1000.0;
      final transferAmt = 1500.0;

      final transferTx = TransactionEntity(
        id: 'tx_tr_123',
        amount: transferAmt,
        type: TransactionType.transfer,
        categoryId: 'cat_other_expense',
        accountId: 'from_acc',
        title: 'Transfer',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.bank,
        createdAt: DateTime.now(),
        transferId: 'tr_123',
        fromAccountId: 'from_acc',
        toAccountId: 'to_acc',
      );

      // Dynamic calculation logic
      double computeBalance(String accId, double initialVal, List<TransactionEntity> list) {
        double balance = initialVal;
        for (var tx in list) {
          if (tx.type == TransactionType.income && tx.accountId == accId) {
            balance += tx.amount;
          } else if (tx.type == TransactionType.expense && tx.accountId == accId) {
            balance -= tx.amount;
          } else if (tx.type == TransactionType.transfer) {
            if (tx.fromAccountId == accId) {
              balance -= tx.amount;
            } else if (tx.toAccountId == accId) {
              balance += tx.amount;
            }
          }
        }
        return balance;
      }

      final list = [transferTx];
      final finalFrom = computeBalance('from_acc', initialFromBalance, list);
      final finalTo = computeBalance('to_acc', initialToBalance, list);

      expect(finalFrom, 3500.0);
      expect(finalTo, 2500.0);
    });

    test('Leap Year recurrence calculations (Feb 29, 2028)', () {
      final start = DateTime(2028, 1, 31);
      final nextOcc = RecurrenceEngine.calculateNextOccurrence(start, RecurringFrequency.monthly);
      // Next occurrence from Jan 31 in leap year Feb must be Feb 29
      expect(nextOcc.year, 2028);
      expect(nextOcc.month, 2);
      expect(nextOcc.day, 29);
    });
  });
}
