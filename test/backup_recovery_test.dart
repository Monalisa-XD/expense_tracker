import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expense_tracker/core/theme/entities.dart';
import 'package:expense_tracker/features/backup/domain/backup_usecases.dart';

void main() {
  group('Data Backup, Export, Import & Recovery Unit Tests', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();

      // Seed mock data
      final transactions = [
        TransactionEntity(
          id: 'tx1',
          amount: 420.0,
          type: TransactionType.expense,
          categoryId: 'food_dining',
          accountId: 'acc1',
          title: 'Swiggy',
          date: DateTime.now(),
          paymentMethod: PaymentMethod.upi,
          createdAt: DateTime.now(),
        ),
      ];

      final accounts = [
        AccountEntity(id: 'acc1', name: 'HDFC', balance: 5000.0, type: PaymentMethod.bank, initialBalance: 5000.0),
      ];

      final budgets = [
        BudgetEntity(
          id: 'b1',
          categoryId: 'food_dining',
          limitAmount: 1000.0,
          spentAmount: 420.0,
          startDate: DateTime.now(),
          endDate: DateTime.now(),
          createdAt: DateTime.now(),
          alertPercentage: 80.0,
        ),
      ];

      final recurring = [
        RecurringTransactionEntity(
          id: 'r1',
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
        ),
      ];

      final notifications = [
        NotificationEntity(
          id: 'n1',
          type: NotificationType.lowBalance,
          title: 'Low Balance',
          message: 'HDFC balance is low',
          createdAt: DateTime.now(),
        ),
      ];

      await prefs.setString('persist_transactions', jsonEncode(transactions.map((e) => e.toMap()).toList()));
      await prefs.setString('persist_accounts', jsonEncode(accounts.map((e) => e.toMap()).toList()));
      await prefs.setString('persist_budgets', jsonEncode(budgets.map((e) => e.toMap()).toList()));
      await prefs.setString('persist_recurring_transactions', jsonEncode(recurring.map((e) => e.toMap()).toList()));
      await prefs.setString('persist_notifications', jsonEncode(notifications.map((e) => e.toMap()).toList()));
      await prefs.setStringList('favorite_merchants', ['swiggy']);
    });

    test('Export Data Usecase produces structured JSON string', () {
      final export = ExportDataUseCase(prefs).call();
      final decoded = jsonDecode(export);

      expect(decoded['backupVersion'], 1);
      expect(decoded['data']['transactions'].length, 1);
      expect(decoded['data']['accounts'].length, 1);
      expect(decoded['data']['budgets'].length, 1);
      expect(decoded['data']['recurringTransactions'].length, 1);
      expect(decoded['data']['notifications'].length, 1);
      expect(decoded['data']['favoriteMerchants'].first, 'swiggy');
    });

    test('Validate Backup rejects invalid json and structure', () {
      final validator = ValidateBackupUseCase();

      // Corrupted JSON
      final res1 = validator.call('{corrupted');
      expect(res1.isValid, false);

      // Missing version
      final res2 = validator.call('{"data": {}}');
      expect(res2.isValid, false);

      // Missing required collections
      final res3 = validator.call('{"backupVersion": 1, "data": {}}');
      expect(res3.isValid, false);
      expect(res3.errorMessage!.contains('Missing required list'), true);
    });

    test('Validate Backup accepts valid structure', () {
      final rawStr = ExportDataUseCase(prefs).call();
      final res = ValidateBackupUseCase().call(rawStr);
      expect(res.isValid, true);
    });

    test('Validate Backup rejects unsupported versions', () {
      final validator = ValidateBackupUseCase();
      final res = validator.call('{"backupVersion": 99, "data": {}}');
      expect(res.isValid, false);
    });

    test('Restore Backup completely overrides current data', () async {
      final export = ExportDataUseCase(prefs).call();

      // Mutate current storage data
      await prefs.setString('persist_transactions', jsonEncode([]));
      await prefs.setString('persist_accounts', jsonEncode([]));

      final backupData = jsonDecode(export);
      await RestoreBackupUseCase(prefs).call(backupData);

      final restoredTxs = jsonDecode(prefs.getString('persist_transactions')!);
      expect(restoredTxs.length, 1);
      expect(restoredTxs[0]['id'], 'tx1');
    });

    test('Restore atomic failure rolls back data safely', () async {
      final export = ExportDataUseCase(prefs).call();

      final backupData = jsonDecode(export);
      // Corrupt backup data transactions list elements to trigger parse failure
      backupData['data']['transactions'] = [{'id': 'tx2'}]; // Missing required fields throws map errors

      expect(
        () => RestoreBackupUseCase(prefs).call(backupData),
        throwsA(isA<TypeError>()),
      );

      // Confirm current data remains intact (rollback worked)
      final txs = jsonDecode(prefs.getString('persist_transactions')!);
      expect(txs.length, 1);
      expect(txs[0]['id'], 'tx1');
    });

    test('Merge Backup avoids duplicating existing entries by ID', () async {
      final export = ExportDataUseCase(prefs).call();
      final backupData = jsonDecode(export);

      // Merge backup into current (identical IDs)
      await MergeBackupUseCase(prefs).call(backupData);

      final txs = jsonDecode(prefs.getString('persist_transactions')!);
      expect(txs.length, 1); // Remains 1, duplicate prevented

      final accs = jsonDecode(prefs.getString('persist_accounts')!);
      expect(accs.length, 1);
    });
  });
}
