import '../../core/theme/entities.dart';
import '../../core/services/local_storage_service.dart';
import 'usecases.dart';
import 'datasources.dart';

class MockAuthRepository implements AuthRepository {
  final LocalStorageService _localStorageService;
  UserEntity? _currentUser;

  MockAuthRepository(this._localStorageService);

  @override
  Future<UserEntity?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserEntity(
      id: 'usr_monalisa',
      name: 'Monalisa',
      email: email,
    );
    await _localStorageService.setToken('mock_jwt_token_xyz123');
    return _currentUser;
  }

  @override
  Future<UserEntity?> register(String name, String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _currentUser = UserEntity(
      id: 'usr_monalisa',
      name: name,
      email: email,
    );
    await _localStorageService.setToken('mock_jwt_token_xyz123');
    return _currentUser;
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
    await _localStorageService.clearAuth();
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final token = _localStorageService.getToken();
    if (token != null) {
      _currentUser = UserEntity(
        id: 'usr_monalisa',
        name: 'Monalisa',
        email: 'monalisa@example.com',
      );
      return _currentUser;
    }
    return null;
  }
}

class MockTransactionRepository implements TransactionRepository {
  final TransactionDataSource _dataSource;
  MockTransactionRepository(this._dataSource);

  @override
  Future<List<TransactionEntity>> getTransactions() => _dataSource.getTransactions();
  @override
  Future<void> addTransaction(TransactionEntity tx) => _dataSource.addTransaction(tx);
  @override
  Future<void> updateTransaction(TransactionEntity tx) => _dataSource.updateTransaction(tx);
  @override
  Future<void> deleteTransaction(String id) => _dataSource.deleteTransaction(id);
}

class MockBudgetRepository implements BudgetRepository {
  final BudgetDataSource _dataSource;
  MockBudgetRepository(this._dataSource);

  @override
  Future<List<BudgetEntity>> getBudgets() => _dataSource.getBudgets();
  @override
  Future<void> addBudget(BudgetEntity b) => _dataSource.addBudget(b);
  @override
  Future<void> updateBudget(BudgetEntity b) => _dataSource.updateBudget(b);
  @override
  Future<void> deleteBudget(String id) => _dataSource.deleteBudget(id);
}

class MockAccountRepository implements AccountRepository {
  final AccountDataSource _dataSource;
  MockAccountRepository(this._dataSource);

  @override
  Future<List<AccountEntity>> getAccounts() => _dataSource.getAccounts();
  @override
  Future<void> addAccount(AccountEntity a) => _dataSource.addAccount(a);
  @override
  Future<void> updateAccount(AccountEntity a) => _dataSource.updateAccount(a);
  @override
  Future<void> deleteAccount(String id) => _dataSource.deleteAccount(id);
}

class MockCategoryRepository implements CategoryRepository {
  final CategoryDataSource _dataSource;
  MockCategoryRepository(this._dataSource);

  @override
  Future<List<CategoryEntity>> getCategories() => _dataSource.getCategories();
  @override
  Future<void> addCategory(CategoryEntity c) => _dataSource.addCategory(c);
  @override
  Future<void> updateCategory(CategoryEntity c) => _dataSource.updateCategory(c);
  @override
  Future<void> deleteCategory(String id) => _dataSource.deleteCategory(id);
}

class MockRecurringRepository implements RecurringRepository {
  final RecurringDataSource _dataSource;
  MockRecurringRepository(this._dataSource);

  @override
  Future<List<RecurringTransactionEntity>> getRecurringTransactions() => _dataSource.getRecurringTransactions();

  @override
  Future<RecurringTransactionEntity?> getRecurringById(String id) async {
    final list = await _dataSource.getRecurringTransactions();
    final idx = list.indexWhere((e) => e.id == id);
    if (idx != -1) return list[idx];
    return null;
  }

  @override
  Future<void> createRecurringTransaction(RecurringTransactionEntity rec) => _dataSource.createRecurringTransaction(rec);

  @override
  Future<void> updateRecurringTransaction(RecurringTransactionEntity rec) => _dataSource.updateRecurringTransaction(rec);

  @override
  Future<void> deleteRecurringTransaction(String id) => _dataSource.deleteRecurringTransaction(id);
}

class MockNotificationRepository implements NotificationRepository {
  final NotificationDataSource _dataSource;
  MockNotificationRepository(this._dataSource);

  @override
  Future<List<NotificationEntity>> getNotifications() => _dataSource.getNotifications();

  @override
  Future<void> createNotification(NotificationEntity notification) => _dataSource.createNotification(notification);

  @override
  Future<void> markNotificationRead(String id) => _dataSource.markNotificationRead(id);

  @override
  Future<void> markAllNotificationsRead() => _dataSource.markAllNotificationsRead();

  @override
  Future<void> deleteNotification(String id) => _dataSource.deleteNotification(id);

  @override
  Future<void> clearReadNotifications() => _dataSource.clearReadNotifications();

  @override
  Future<NotificationSettingsEntity> getNotificationSettings() => _dataSource.getNotificationSettings();

  @override
  Future<void> updateNotificationSettings(NotificationSettingsEntity settings) => _dataSource.updateNotificationSettings(settings);
}
