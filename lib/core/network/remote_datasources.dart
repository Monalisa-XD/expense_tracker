import '../../core/theme/entities.dart';

abstract class TransactionRemoteDataSource {
  Future<List<TransactionEntity>> fetchTransactions();
  Future<TransactionEntity> createTransaction(TransactionEntity transaction);
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);
  Future<void> deleteTransaction(String id);
}

class MockTransactionRemoteDataSource implements TransactionRemoteDataSource {
  final List<TransactionEntity> _mockDatabase = [];

  @override
  Future<List<TransactionEntity>> fetchTransactions() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _mockDatabase;
  }

  @override
  Future<TransactionEntity> createTransaction(TransactionEntity transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockDatabase.insert(0, transaction);
    return transaction;
  }

  @override
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockDatabase.indexWhere((t) => t.id == transaction.id);
    if (idx != -1) {
      _mockDatabase[idx] = transaction;
    }
    return transaction;
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockDatabase.removeWhere((t) => t.id == id);
  }
}

abstract class AccountRemoteDataSource {
  Future<List<AccountEntity>> fetchAccounts();
  Future<AccountEntity> createAccount(AccountEntity account);
  Future<AccountEntity> updateAccount(AccountEntity account);
  Future<void> deleteAccount(String id);
}

class MockAccountRemoteDataSource implements AccountRemoteDataSource {
  final List<AccountEntity> _mockDatabase = [];

  @override
  Future<List<AccountEntity>> fetchAccounts() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _mockDatabase;
  }

  @override
  Future<AccountEntity> createAccount(AccountEntity account) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockDatabase.add(account);
    return account;
  }

  @override
  Future<AccountEntity> updateAccount(AccountEntity account) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockDatabase.indexWhere((a) => a.id == account.id);
    if (idx != -1) {
      _mockDatabase[idx] = account;
    }
    return account;
  }

  @override
  Future<void> deleteAccount(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockDatabase.removeWhere((a) => a.id == id);
  }
}

abstract class BudgetRemoteDataSource {
  Future<List<BudgetEntity>> fetchBudgets();
  Future<BudgetEntity> createBudget(BudgetEntity budget);
  Future<BudgetEntity> updateBudget(BudgetEntity budget);
  Future<void> deleteBudget(String id);
}

class MockBudgetRemoteDataSource implements BudgetRemoteDataSource {
  final List<BudgetEntity> _mockDatabase = [];

  @override
  Future<List<BudgetEntity>> fetchBudgets() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockDatabase;
  }

  @override
  Future<BudgetEntity> createBudget(BudgetEntity budget) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockDatabase.add(budget);
    return budget;
  }

  @override
  Future<BudgetEntity> updateBudget(BudgetEntity budget) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final idx = _mockDatabase.indexWhere((b) => b.id == budget.id);
    if (idx != -1) {
      _mockDatabase[idx] = budget;
    }
    return budget;
  }

  @override
  Future<void> deleteBudget(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mockDatabase.removeWhere((b) => b.id == id);
  }
}

abstract class RecurringRemoteDataSource {
  Future<List<RecurringTransactionEntity>> fetchRecurringTransactions();
  Future<RecurringTransactionEntity> createRecurringTransaction(RecurringTransactionEntity rec);
  Future<RecurringTransactionEntity> updateRecurringTransaction(RecurringTransactionEntity rec);
  Future<void> deleteRecurringTransaction(String id);
}

class MockRecurringRemoteDataSource implements MockRecurringRemoteDataSourceWrapper {
  final List<RecurringTransactionEntity> _mockDatabase = [];

  @override
  Future<List<RecurringTransactionEntity>> fetchRecurringTransactions() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return _mockDatabase;
  }

  @override
  Future<RecurringTransactionEntity> createRecurringTransaction(RecurringTransactionEntity rec) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mockDatabase.add(rec);
    return rec;
  }

  @override
  Future<RecurringTransactionEntity> updateRecurringTransaction(RecurringTransactionEntity rec) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final idx = _mockDatabase.indexWhere((r) => r.id == rec.id);
    if (idx != -1) {
      _mockDatabase[idx] = rec;
    }
    return rec;
  }

  @override
  Future<void> deleteRecurringTransaction(String id) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockDatabase.removeWhere((r) => r.id == id);
  }
}

abstract class MockRecurringRemoteDataSourceWrapper implements RecurringRemoteDataSource {}

abstract class NotificationRemoteDataSource {
  Future<List<NotificationEntity>> fetchNotifications();
  Future<NotificationEntity> createNotification(NotificationEntity notification);
  Future<void> markNotificationRead(String id);
  Future<void> markAllNotificationsRead();
  Future<void> deleteNotification(String id);
}

class MockNotificationRemoteDataSource implements NotificationRemoteDataSource {
  final List<NotificationEntity> _mockDatabase = [];

  @override
  Future<List<NotificationEntity>> fetchNotifications() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mockDatabase;
  }

  @override
  Future<NotificationEntity> createNotification(NotificationEntity notification) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _mockDatabase.add(notification);
    return notification;
  }

  @override
  Future<void> markNotificationRead(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final idx = _mockDatabase.indexWhere((n) => n.id == id);
    if (idx != -1) {
      _mockDatabase[idx] = _mockDatabase[idx].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllNotificationsRead() async {
    await Future.delayed(const Duration(milliseconds: 150));
    for (int i = 0; i < _mockDatabase.length; i++) {
      _mockDatabase[i] = _mockDatabase[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mockDatabase.removeWhere((n) => n.id == id);
  }
}
