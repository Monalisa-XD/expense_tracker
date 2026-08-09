import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/entities.dart';
import '../../mock/mock_data.dart';

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
      _saveToStorage();
    } else {
      final List decoded = jsonDecode(raw);
      _list.addAll(decoded.map((item) => TransactionEntity.fromMap(item)));
    }
  }

  void _saveToStorage() {
    final raw = jsonEncode(_list.map((tx) => tx.toMap()).toList());
    _prefs.setString(_key, raw);
  }

  @override
  Future<List<TransactionEntity>> getTransactions() async => _list;

  @override
  Future<void> addTransaction(TransactionEntity tx) async {
    _list.insert(0, tx);
    _saveToStorage();
  }

  @override
  Future<void> updateTransaction(TransactionEntity tx) async {
    final idx = _list.indexWhere((e) => e.id == tx.id);
    if (idx != -1) {
      _list[idx] = tx;
      _saveToStorage();
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    _list.removeWhere((e) => e.id == id);
    _saveToStorage();
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
      _saveToStorage();
    } else {
      final List decoded = jsonDecode(raw);
      _list.addAll(decoded.map((item) => BudgetEntity.fromMap(item)));
    }
  }

  void _saveToStorage() {
    final raw = jsonEncode(_list.map((b) => b.toMap()).toList());
    _prefs.setString(_key, raw);
  }

  @override
  Future<List<BudgetEntity>> getBudgets() async => _list;

  @override
  Future<void> addBudget(BudgetEntity b) async {
    _list.add(b);
    _saveToStorage();
  }

  @override
  Future<void> updateBudget(BudgetEntity b) async {
    final idx = _list.indexWhere((e) => e.id == b.id);
    if (idx != -1) {
      _list[idx] = b;
      _saveToStorage();
    }
  }

  @override
  Future<void> deleteBudget(String id) async {
    _list.removeWhere((e) => e.id == id);
    _saveToStorage();
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
      _saveToStorage();
    } else {
      final List decoded = jsonDecode(raw);
      _list.addAll(decoded.map((item) => CategoryEntity.fromMap(item)));
    }
  }

  void _saveToStorage() {
    final raw = jsonEncode(_list.map((c) => c.toMap()).toList());
    _prefs.setString(_key, raw);
  }

  @override
  Future<List<CategoryEntity>> getCategories() async => _list;

  @override
  Future<void> addCategory(CategoryEntity c) async {
    _list.add(c);
    _saveToStorage();
  }

  @override
  Future<void> updateCategory(CategoryEntity c) async {
    final idx = _list.indexWhere((e) => e.id == c.id);
    if (idx != -1) {
      _list[idx] = c;
      _saveToStorage();
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    _list.removeWhere((e) => e.id == id);
    _saveToStorage();
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
      _saveToStorage();
    } else {
      final List decoded = jsonDecode(raw);
      _list.addAll(decoded.map((item) => AccountEntity.fromMap(item)));
    }
  }

  void _saveToStorage() {
    final raw = jsonEncode(_list.map((a) => a.toMap()).toList());
    _prefs.setString(_key, raw);
  }

  @override
  Future<List<AccountEntity>> getAccounts() async => _list;

  @override
  Future<void> addAccount(AccountEntity a) async {
    _list.add(a);
    _saveToStorage();
  }

  @override
  Future<void> updateAccount(AccountEntity a) async {
    final idx = _list.indexWhere((e) => e.id == a.id);
    if (idx != -1) {
      _list[idx] = a;
      _saveToStorage();
    }
  }

  @override
  Future<void> deleteAccount(String id) async {
    _list.removeWhere((e) => e.id == id);
    _saveToStorage();
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

  void _saveToStorage() {
    final raw = jsonEncode(_list.map((r) => r.toMap()).toList());
    _prefs.setString(_key, raw);
  }

  @override
  Future<List<RecurringTransactionEntity>> getRecurringTransactions() async => _list;

  @override
  Future<void> createRecurringTransaction(RecurringTransactionEntity rec) async {
    _list.add(rec);
    _saveToStorage();
  }

  @override
  Future<void> updateRecurringTransaction(RecurringTransactionEntity rec) async {
    final idx = _list.indexWhere((e) => e.id == rec.id);
    if (idx != -1) {
      _list[idx] = rec;
      _saveToStorage();
    }
  }

  @override
  Future<void> deleteRecurringTransaction(String id) async {
    _list.removeWhere((e) => e.id == id);
    _saveToStorage();
  }
}
