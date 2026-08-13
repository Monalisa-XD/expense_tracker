import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/entities.dart';
import '../../mock/mock_data.dart';

class StorageException implements Exception {
  final String message;
  const StorageException(this.message);
  @override
  String toString() => 'StorageException: $message';
}

abstract class TransactionDataSource {
  Future<List<TransactionEntity>> getTransactions();
  Future<void> addTransaction(TransactionEntity tx);
  Future<void> updateTransaction(TransactionEntity tx);
  Future<void> deleteTransaction(String id);
}

class MockTransactionDataSource implements TransactionDataSource {
  final SharedPreferences _prefs;
  static const _key = 'persist_transactions';
  final List<TransactionEntity> _list = [];

  MockTransactionDataSource(this._prefs) {
    _init();
  }

  void _init() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _list.addAll(MockData.transactions);
      _saveToStorageSync();
    } else {
      final List decoded = jsonDecode(raw);
      _list.addAll(decoded.map((item) => TransactionEntity.fromMap(item)));
    }
  }

  void _saveToStorageSync() {
    final raw = jsonEncode(_list.map((tx) => tx.toMap()).toList());
    _prefs.setString(_key, raw);
  }

  Future<void> _saveToStorage() async {
    final raw = jsonEncode(_list.map((tx) => tx.toMap()).toList());
    final success = await _prefs.setString(_key, raw);
    if (!success) {
      throw const StorageException('Unable to save transaction. Try Again.');
    }
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async => _list;

  @override
  Future<void> addTransaction(TransactionEntity tx) async {
    _list.insert(0, tx);
    try {
      await _saveToStorage();
    } catch (e) {
      _list.removeAt(0); // Rollback
      rethrow;
    }
  }

  @override
  Future<void> updateTransaction(TransactionEntity tx) async {
    final idx = _list.indexWhere((e) => e.id == tx.id);
    if (idx != -1) {
      final oldTx = _list[idx];
      _list[idx] = tx;
      try {
        await _saveToStorage();
      } catch (e) {
        _list[idx] = oldTx; // Rollback
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final idx = _list.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final removed = _list.removeAt(idx);
      try {
        await _saveToStorage();
      } catch (e) {
        _list.insert(idx, removed); // Rollback
        rethrow;
      }
    }
  }
}

abstract class BudgetDataSource {
  Future<List<BudgetEntity>> getBudgets();
  Future<void> addBudget(BudgetEntity b);
  Future<void> updateBudget(BudgetEntity b);
  Future<void> deleteBudget(String id);
}

class MockBudgetDataSource implements BudgetDataSource {
  final SharedPreferences _prefs;
  static const _key = 'persist_budgets';
  final List<BudgetEntity> _list = [];

  MockBudgetDataSource(this._prefs) {
    _init();
  }

  void _init() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _list.addAll(MockData.budgets);
      _saveToStorageSync();
    } else {
      final List decoded = jsonDecode(raw);
      _list.addAll(decoded.map((item) => BudgetEntity.fromMap(item)));
    }
  }

  void _saveToStorageSync() {
    final raw = jsonEncode(_list.map((b) => b.toMap()).toList());
    _prefs.setString(_key, raw);
  }

  Future<void> _saveToStorage() async {
    final raw = jsonEncode(_list.map((b) => b.toMap()).toList());
    final success = await _prefs.setString(_key, raw);
    if (!success) {
      throw const StorageException('Unable to save budget. Try Again.');
    }
  }

  @override
  Future<List<BudgetEntity>> getBudgets() async => _list;

  @override
  Future<void> addBudget(BudgetEntity b) async {
    _list.add(b);
    try {
      await _saveToStorage();
    } catch (e) {
      _list.removeLast(); // Rollback
      rethrow;
    }
  }

  @override
  Future<void> updateBudget(BudgetEntity b) async {
    final idx = _list.indexWhere((e) => e.id == b.id);
    if (idx != -1) {
      final old = _list[idx];
      _list[idx] = b;
      try {
        await _saveToStorage();
      } catch (e) {
        _list[idx] = old; // Rollback
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    final idx = _list.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final removed = _list.removeAt(idx);
      try {
        await _saveToStorage();
      } catch (e) {
        _list.insert(idx, removed); // Rollback
        rethrow;
      }
    }
  }
}

abstract class CategoryDataSource {
  Future<List<CategoryEntity>> getCategories();
  Future<void> addCategory(CategoryEntity c);
  Future<void> updateCategory(CategoryEntity c);
  Future<void> deleteCategory(String id);
}

class MockCategoryDataSource implements CategoryDataSource {
  final SharedPreferences _prefs;
  static const _key = 'persist_categories';
  final List<CategoryEntity> _list = [];

  MockCategoryDataSource(this._prefs) {
    _init();
  }

  void _init() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _list.addAll(MockData.categories);
      _saveToStorageSync();
    } else {
      final List decoded = jsonDecode(raw);
      _list.addAll(decoded.map((item) => CategoryEntity.fromMap(item)));
    }
  }

  void _saveToStorageSync() {
    final raw = jsonEncode(_list.map((c) => c.toMap()).toList());
    _prefs.setString(_key, raw);
  }

  Future<void> _saveToStorage() async {
    final raw = jsonEncode(_list.map((c) => c.toMap()).toList());
    final success = await _prefs.setString(_key, raw);
    if (!success) {
      throw const StorageException('Unable to save categories. Try Again.');
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories() async => _list;

  @override
  Future<void> addCategory(CategoryEntity c) async {
    _list.add(c);
    try {
      await _saveToStorage();
    } catch (e) {
      _list.removeLast(); // Rollback
      rethrow;
    }
  }

  @override
  Future<void> updateCategory(CategoryEntity c) async {
    final idx = _list.indexWhere((e) => e.id == c.id);
    if (idx != -1) {
      final old = _list[idx];
      _list[idx] = c;
      try {
        await _saveToStorage();
      } catch (e) {
        _list[idx] = old; // Rollback
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    final idx = _list.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final removed = _list.removeAt(idx);
      try {
        await _saveToStorage();
      } catch (e) {
        _list.insert(idx, removed); // Rollback
        rethrow;
      }
    }
  }
}

abstract class AccountDataSource {
  Future<List<AccountEntity>> getAccounts();
  Future<void> addAccount(AccountEntity a);
  Future<void> updateAccount(AccountEntity a);
  Future<void> deleteAccount(String id);
}

class MockAccountDataSource implements AccountDataSource {
  final SharedPreferences _prefs;
  static const _key = 'persist_accounts';
  final List<AccountEntity> _list = [];

  MockAccountDataSource(this._prefs) {
    _init();
  }

  void _init() {
    final raw = _prefs.getString(_key);
    if (raw == null) {
      _list.addAll(MockData.accounts);
      _saveToStorageSync();
    } else {
      final List decoded = jsonDecode(raw);
      _list.addAll(decoded.map((item) => AccountEntity.fromMap(item)));
    }
  }

  void _saveToStorageSync() {
    final raw = jsonEncode(_list.map((a) => a.toMap()).toList());
    _prefs.setString(_key, raw);
  }

  Future<void> _saveToStorage() async {
    final raw = jsonEncode(_list.map((a) => a.toMap()).toList());
    final success = await _prefs.setString(_key, raw);
    if (!success) {
      throw const StorageException('Unable to save accounts. Try Again.');
    }
  }

  @override
  Future<List<AccountEntity>> getAccounts() async => _list;

  @override
  Future<void> addAccount(AccountEntity a) async {
    _list.add(a);
    try {
      await _saveToStorage();
    } catch (e) {
      _list.removeLast(); // Rollback
      rethrow;
    }
  }

  @override
  Future<void> updateAccount(AccountEntity a) async {
    final idx = _list.indexWhere((e) => e.id == a.id);
    if (idx != -1) {
      final old = _list[idx];
      _list[idx] = a;
      try {
        await _saveToStorage();
      } catch (e) {
        _list[idx] = old; // Rollback
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    final idx = _list.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final removed = _list.removeAt(idx);
      try {
        await _saveToStorage();
      } catch (e) {
        _list.insert(idx, removed); // Rollback
        rethrow;
      }
    }
  }
}

abstract class RecurringDataSource {
  Future<List<RecurringTransactionEntity>> getRecurringTransactions();
  Future<void> createRecurringTransaction(RecurringTransactionEntity rec);
  Future<void> updateRecurringTransaction(RecurringTransactionEntity rec);
  Future<void> deleteRecurringTransaction(String id);
}

class MockRecurringDataSource implements RecurringDataSource {
  final SharedPreferences _prefs;
  static const _key = 'persist_recurring_transactions';
  final List<RecurringTransactionEntity> _list = [];

  MockRecurringDataSource(this._prefs) {
    _init();
  }

  void _init() {
    final raw = _prefs.getString(_key);
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      _list.addAll(decoded.map((item) => RecurringTransactionEntity.fromMap(item)));
    }
  }

  void _saveToStorageSync() {
    final raw = jsonEncode(_list.map((r) => r.toMap()).toList());
    _prefs.setString(_key, raw);
  }

  Future<void> _saveToStorage() async {
    final raw = jsonEncode(_list.map((r) => r.toMap()).toList());
    final success = await _prefs.setString(_key, raw);
    if (!success) {
      throw const StorageException('Unable to save recurring transactions. Try Again.');
    }
  }

  @override
  Future<List<RecurringTransactionEntity>> getRecurringTransactions() async => _list;

  @override
  Future<void> createRecurringTransaction(RecurringTransactionEntity rec) async {
    _list.add(rec);
    try {
      await _saveToStorage();
    } catch (e) {
      _list.removeLast(); // Rollback
      rethrow;
    }
  }

  @override
  Future<void> updateRecurringTransaction(RecurringTransactionEntity rec) async {
    final idx = _list.indexWhere((e) => e.id == rec.id);
    if (idx != -1) {
      final old = _list[idx];
      _list[idx] = rec;
      try {
        await _saveToStorage();
      } catch (e) {
        _list[idx] = old; // Rollback
        rethrow;
      }
    }
  }

  @override
  Future<void> deleteRecurringTransaction(String id) async {
    final idx = _list.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final removed = _list.removeAt(idx);
      try {
        await _saveToStorage();
      } catch (e) {
        _list.insert(idx, removed); // Rollback
        rethrow;
      }
    }
  }
}

abstract class NotificationDataSource {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> createNotification(NotificationEntity notification);
  Future<void> markNotificationRead(String id);
  Future<void> markAllNotificationsRead();
  Future<void> deleteNotification(String id);
  Future<void> clearReadNotifications();
  Future<NotificationSettingsEntity> getNotificationSettings();
  Future<void> updateNotificationSettings(NotificationSettingsEntity settings);
}

class MockNotificationDataSource implements NotificationDataSource {
  final SharedPreferences _prefs;
  static const _notificationsKey = 'persist_notifications';
  static const _settingsKey = 'persist_notification_settings';
  final List<NotificationEntity> _list = [];
  late NotificationSettingsEntity _settings;

  MockNotificationDataSource(this._prefs) {
    _init();
  }

  void _init() {
    final raw = _prefs.getString(_notificationsKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      _list.addAll(decoded.map((item) => NotificationEntity.fromMap(item)));
    }

    final rawSettings = _prefs.getString(_settingsKey);
    if (rawSettings != null) {
      _settings = NotificationSettingsEntity.fromMap(jsonDecode(rawSettings));
    } else {
      _settings = NotificationSettingsEntity();
    }
  }

  void _saveNotificationsSync() {
    final raw = jsonEncode(_list.map((n) => n.toMap()).toList());
    _prefs.setString(_notificationsKey, raw);
  }

  void _saveSettingsSync() {
    final raw = jsonEncode(_settings.toMap());
    _prefs.setString(_settingsKey, raw);
  }

  Future<void> _saveNotifications() async {
    final raw = jsonEncode(_list.map((n) => n.toMap()).toList());
    final success = await _prefs.setString(_notificationsKey, raw);
    if (!success) {
      throw const StorageException('Unable to save notifications. Try Again.');
    }
  }

  Future<void> _saveSettings() async {
    final raw = jsonEncode(_settings.toMap());
    final success = await _prefs.setString(_settingsKey, raw);
    if (!success) {
      throw const StorageException('Unable to save notification settings. Try Again.');
    }
  }

  @override
  Future<List<NotificationEntity>> getNotifications() async => _list;

  @override
  Future<void> createNotification(NotificationEntity notification) async {
    _list.add(notification);
    try {
      await _saveNotifications();
    } catch (e) {
      _list.removeLast(); // Rollback
      rethrow;
    }
  }

  @override
  Future<void> markNotificationRead(String id) async {
    final idx = _list.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final old = _list[idx];
      _list[idx] = _list[idx].copyWith(isRead: true);
      try {
        await _saveNotifications();
      } catch (e) {
        _list[idx] = old; // Rollback
        rethrow;
      }
    }
  }

  @override
  Future<void> markAllNotificationsRead() async {
    final oldList = List<NotificationEntity>.from(_list);
    for (int i = 0; i < _list.length; i++) {
      _list[i] = _list[i].copyWith(isRead: true);
    }
    try {
      await _saveNotifications();
    } catch (e) {
      _list.clear();
      _list.addAll(oldList); // Rollback
      rethrow;
    }
  }

  @override
  Future<void> deleteNotification(String id) async {
    final idx = _list.indexWhere((e) => e.id == id);
    if (idx != -1) {
      final removed = _list.removeAt(idx);
      try {
        await _saveNotifications();
      } catch (e) {
        _list.insert(idx, removed); // Rollback
        rethrow;
      }
    }
  }

  @override
  Future<void> clearReadNotifications() async {
    final oldList = List<NotificationEntity>.from(_list);
    _list.removeWhere((e) => e.isRead);
    try {
      await _saveNotifications();
    } catch (e) {
      _list.clear();
      _list.addAll(oldList); // Rollback
      rethrow;
    }
  }

  @override
  Future<NotificationSettingsEntity> getNotificationSettings() async => _settings;

  @override
  Future<void> updateNotificationSettings(NotificationSettingsEntity settings) async {
    final old = _settings;
    _settings = settings;
    try {
      await _saveSettings();
    } catch (e) {
      _settings = old; // Rollback
      rethrow;
    }
  }
}
