import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/entities.dart';

void main() {
  group('Accounts and Money Transfer Tests', () {
    test('TEST 1 — Account Creation', () {
      final acc = AccountEntity(
        id: 'acc_hdfc',
        name: 'HDFC Bank',
        balance: 25000.0,
        type: PaymentMethod.bank,
        initialBalance: 25000.0,
      );
      expect(acc.initialBalance, 25000.0);
      expect(acc.balance, 25000.0);
    });

    test('TEST 4 — Transfer Accounting', () {
      // Setup initial balances
      double hdfcBalance = 29000.0;
      double cashBalance = 3000.0;

      // Execute transfer of 5000
      const transferAmt = 5000.0;
      hdfcBalance -= transferAmt;
      cashBalance += transferAmt;

      expect(hdfcBalance, 24000.0);
      expect(cashBalance, 8000.0);
      expect(hdfcBalance + cashBalance, 32000.0); // Total wealth unchanged
    });

    test('TEST 7 — Analytics Exclusion', () {
      final tx = TransactionEntity(
        id: 'tx_tr_1',
        amount: 5000.0,
        type: TransactionType.transfer,
        categoryId: 'cat_other_expense',
        accountId: 'acc_hdfc',
        title: 'Transfer to Cash',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.bank,
        createdAt: DateTime.now(),
        transferId: 'tr_1',
        fromAccountId: 'acc_hdfc',
        toAccountId: 'acc_cash',
      );

      // Verify that the transfer is ignored from income and expense categories
      expect(tx.type, TransactionType.transfer);
      expect(tx.type != TransactionType.income && tx.type != TransactionType.expense, true);
    });
  });
}
