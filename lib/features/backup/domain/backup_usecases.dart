import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/entities.dart';

class BackupValidationResult {
  final bool isValid;
  final String? errorMessage;
  final Map<String, dynamic>? decodedData;

  BackupValidationResult({required this.isValid, this.errorMessage, this.decodedData});
}

class ValidateBackupUseCase {
  BackupValidationResult call(String jsonString) {
    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) {
        return BackupValidationResult(isValid: false, errorMessage: 'Backup file is not a valid JSON object.');
      }

      if (!decoded.containsKey('backupVersion')) {
        return BackupValidationResult(isValid: false, errorMessage: 'Missing backupVersion.');
      }
      final version = decoded['backupVersion'];
      if (version is! int) {
        return BackupValidationResult(isValid: false, errorMessage: 'backupVersion must be an integer.');
      }

      // Reject unsupported versions
      if (version < 1 || version > 2) {
        return BackupValidationResult(isValid: false, errorMessage: 'Unsupported backup version: $version.');
      }

      if (!decoded.containsKey('data')) {
        return BackupValidationResult(isValid: false, errorMessage: 'Missing data root element.');
      }

      final data = decoded['data'];
      if (data is! Map<String, dynamic>) {
        return BackupValidationResult(isValid: false, errorMessage: 'Invalid data element.');
      }

      // Validate required elements inside data
      final requiredLists = ['transactions', 'accounts', 'budgets', 'recurringTransactions'];
      for (var listKey in requiredLists) {
        if (!data.containsKey(listKey)) {
          return BackupValidationResult(isValid: false, errorMessage: 'Missing required list: $listKey.');
        }
        if (data[listKey] is! List) {
          return BackupValidationResult(isValid: false, errorMessage: '$listKey must be a JSON array.');
        }
      }

      return BackupValidationResult(isValid: true, decodedData: decoded);
    } catch (e) {
      return BackupValidationResult(isValid: false, errorMessage: 'Invalid JSON formatting: ${e.toString()}');
    }
  }
}

class ExportDataUseCase {
  final SharedPreferences _prefs;

  ExportDataUseCase(this._prefs);

  String call() {
    final payload = {
      'backupVersion': 1,
      'createdAt': DateTime.now().toIso8601String(),
      'appVersion': '1.0.0',
      'devicePlatform': 'Flutter',
      'data': {
        'transactions': _getListData('persist_transactions'),
        'accounts': _getListData('persist_accounts'),
        'budgets': _getListData('persist_budgets'),
        'categories': _getListData('persist_categories'),
        'recurringTransactions': _getListData('persist_recurring_transactions'),
        'notifications': _getListData('persist_notifications'),
        'notificationSettings': _getMapData('persist_notification_settings'),
        'favoriteMerchants': _prefs.getStringList('favorite_merchants') ?? <String>[],
        'themeMode': _prefs.getString('theme_mode') ?? 'system',
        'currencyType': _prefs.getString('currency_type') ?? 'inr',
      }
    };
    return jsonEncode(payload);
  }

  List<dynamic> _getListData(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) return decoded;
    } catch (_) {}
    return [];
  }

  dynamic _getMapData(String key) {
    final raw = _prefs.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {}
    return null;
  }
}

class RestoreBackupUseCase {
  final SharedPreferences _prefs;

  RestoreBackupUseCase(this._prefs);

  Future<void> call(Map<String, dynamic> backupData) async {
    final data = backupData['data'] as Map<String, dynamic>;

    // Keep backup copy of current values in case writing fails (Atomic Restore support)
    final backupCopy = <String, String?>{
      'persist_transactions': _prefs.getString('persist_transactions'),
      'persist_accounts': _prefs.getString('persist_accounts'),
      'persist_budgets': _prefs.getString('persist_budgets'),
      'persist_categories': _prefs.getString('persist_categories'),
      'persist_recurring_transactions': _prefs.getString('persist_recurring_transactions'),
      'persist_notifications': _prefs.getString('persist_notifications'),
      'persist_notification_settings': _prefs.getString('persist_notification_settings'),
    };
    final backupFavs = _prefs.getStringList('favorite_merchants');
    final backupTheme = _prefs.getString('theme_mode');
    final backupCurrency = _prefs.getString('currency_type');

    try {
      // Validate models can actually parse from map
      _parseModels(data);

      // Write data
      await _prefs.setString('persist_transactions', jsonEncode(data['transactions']));
      await _prefs.setString('persist_accounts', jsonEncode(data['accounts']));
      await _prefs.setString('persist_budgets', jsonEncode(data['budgets']));

      if (data.containsKey('categories')) {
        await _prefs.setString('persist_categories', jsonEncode(data['categories']));
      }
      await _prefs.setString('persist_recurring_transactions', jsonEncode(data['recurringTransactions']));

      if (data.containsKey('notifications')) {
        await _prefs.setString('persist_notifications', jsonEncode(data['notifications']));
      }
      if (data.containsKey('notificationSettings') && data['notificationSettings'] != null) {
        await _prefs.setString('persist_notification_settings', jsonEncode(data['notificationSettings']));
      }
      if (data.containsKey('favoriteMerchants')) {
        final favsList = List<String>.from(data['favoriteMerchants'] as List? ?? []);
        await _prefs.setStringList('favorite_merchants', favsList);
      }
      if (data.containsKey('themeMode')) {
        await _prefs.setString('theme_mode', data['themeMode'] as String? ?? 'system');
      }
      if (data.containsKey('currencyType')) {
        await _prefs.setString('currency_type', data['currencyType'] as String? ?? 'inr');
      }
    } catch (e) {
      // Rollback atomically
      for (var entry in backupCopy.entries) {
        if (entry.value != null) {
          await _prefs.setString(entry.key, entry.value!);
        } else {
          await _prefs.remove(entry.key);
        }
      }
      if (backupFavs != null) {
        await _prefs.setStringList('favorite_merchants', backupFavs);
      } else {
        await _prefs.remove('favorite_merchants');
      }
      if (backupTheme != null) {
        await _prefs.setString('theme_mode', backupTheme);
      } else {
        await _prefs.remove('theme_mode');
      }
      if (backupCurrency != null) {
        await _prefs.setString('currency_type', backupCurrency);
      } else {
        await _prefs.remove('currency_type');
      }
      rethrow;
    }
  }

  void _parseModels(Map<String, dynamic> data) {
    // Verifies entities parse properly to catch bad format early
    (data['transactions'] as List).forEach((tx) => TransactionEntity.fromMap(tx));
    (data['accounts'] as List).forEach((acc) => AccountEntity.fromMap(acc));
    (data['budgets'] as List).forEach((b) => BudgetEntity.fromMap(b));
    (data['recurringTransactions'] as List).forEach((rec) => RecurringTransactionEntity.fromMap(rec));
  }
}

class MergeBackupUseCase {
  final SharedPreferences _prefs;

  MergeBackupUseCase(this._prefs);

  Future<void> call(Map<String, dynamic> backupData) async {
    final data = backupData['data'] as Map<String, dynamic>;

    // Load current lists
    final curTxs = _getParsedList('persist_transactions', (m) => TransactionEntity.fromMap(m));
    final curAccs = _getParsedList('persist_accounts', (m) => AccountEntity.fromMap(m));
    final curBudgets = _getParsedList('persist_budgets', (m) => BudgetEntity.fromMap(m));
    final curCategories = _getParsedList('persist_categories', (m) => CategoryEntity.fromMap(m));
    final curRecurrings = _getParsedList('persist_recurring_transactions', (m) => RecurringTransactionEntity.fromMap(m));
    final curNotifs = _getParsedList('persist_notifications', (m) => NotificationEntity.fromMap(m));

    // Parse backup lists
    final backTxs = (data['transactions'] as List).map((m) => TransactionEntity.fromMap(m)).toList();
    final backAccs = (data['accounts'] as List).map((m) => AccountEntity.fromMap(m)).toList();
    final backBudgets = (data['budgets'] as List).map((m) => BudgetEntity.fromMap(m)).toList();
    final backCategories = (data['categories'] as List? ?? []).map((m) => CategoryEntity.fromMap(m)).toList();
    final backRecurrings = (data['recurringTransactions'] as List).map((m) => RecurringTransactionEntity.fromMap(m)).toList();
    final backNotifs = (data['notifications'] as List? ?? []).map((m) => NotificationEntity.fromMap(m)).toList();

    // Perform non-duplicating merges based on ID keys
    for (var tx in backTxs) {
      if (!curTxs.any((e) => e.id == tx.id)) {
        curTxs.add(tx);
      }
    }
    for (var acc in backAccs) {
      if (!curAccs.any((e) => e.id == acc.id)) {
        curAccs.add(acc);
      }
    }
    for (var b in backBudgets) {
      if (!curBudgets.any((e) => e.id == b.id)) {
        curBudgets.add(b);
      }
    }
    for (var c in backCategories) {
      if (!curCategories.any((e) => e.id == c.id)) {
        curCategories.add(c);
      }
    }
    for (var r in backRecurrings) {
      if (!curRecurrings.any((e) => e.id == r.id)) {
        curRecurrings.add(r);
      }
    }
    for (var n in backNotifs) {
      if (!curNotifs.any((e) => e.id == n.id)) {
        curNotifs.add(n);
      }
    }

    // Save lists
    await _prefs.setString('persist_transactions', jsonEncode(curTxs.map((e) => e.toMap()).toList()));
    await _prefs.setString('persist_accounts', jsonEncode(curAccs.map((e) => e.toMap()).toList()));
    await _prefs.setString('persist_budgets', jsonEncode(curBudgets.map((e) => e.toMap()).toList()));
    if (curCategories.isNotEmpty) {
      await _prefs.setString('persist_categories', jsonEncode(curCategories.map((e) => e.toMap()).toList()));
    }
    await _prefs.setString('persist_recurring_transactions', jsonEncode(curRecurrings.map((e) => e.toMap()).toList()));
    await _prefs.setString('persist_notifications', jsonEncode(curNotifs.map((e) => e.toMap()).toList()));

    // Merge favorites list
    final curFavs = _prefs.getStringList('favorite_merchants') ?? <String>[];
    final backFavs = List<String>.from(data['favoriteMerchants'] as List? ?? []);
    for (var f in backFavs) {
      if (!curFavs.contains(f)) {
        curFavs.add(f);
      }
    }
    await _prefs.setStringList('favorite_merchants', curFavs);
  }

  List<T> _getParsedList<T>(String key, T Function(Map<String, dynamic>) parser) {
    final raw = _prefs.getString(key);
    if (raw == null) return [];
    try {
      final List decoded = jsonDecode(raw);
      return decoded.map((m) => parser(m as Map<String, dynamic>)).toList();
    } catch (_) {}
    return [];
  }
}
