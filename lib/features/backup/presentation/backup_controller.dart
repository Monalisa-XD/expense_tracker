import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/backup_usecases.dart';
import '../data/backup_datasource.dart';
import '../../repositories/providers.dart';
import '../../repositories/controllers.dart';
import '../../repositories/account_controller.dart';
import '../../repositories/recurring_controller.dart';
import '../../repositories/notification_controller.dart';

class BackupState {
  final bool isLoading;
  final String? successMessage;
  final String? errorMessage;
  final Map<String, dynamic>? previewData;
  final String? lastBackupDate;

  BackupState({
    this.isLoading = false,
    this.successMessage,
    this.errorMessage,
    this.previewData,
    this.lastBackupDate,
  });

  BackupState copyWith({
    bool? isLoading,
    String? Function()? successMessage,
    String? Function()? errorMessage,
    Map<String, dynamic>? Function()? previewData,
    String? Function()? lastBackupDate,
  }) {
    return BackupState(
      isLoading: isLoading ?? this.isLoading,
      successMessage: successMessage != null ? successMessage() : this.successMessage,
      errorMessage: errorMessage != null ? errorMessage() : this.errorMessage,
      previewData: previewData != null ? previewData() : this.previewData,
      lastBackupDate: lastBackupDate != null ? lastBackupDate() : this.lastBackupDate,
    );
  }
}

final backupDataSourceProvider = Provider<BackupDataSource>((ref) {
  return BackupDataSourceImpl();
});

final backupControllerProvider = StateNotifierProvider<BackupController, BackupState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final picker = ref.watch(backupDataSourceProvider);
  return BackupController(ref, prefs, picker);
});

class BackupController extends StateNotifier<BackupState> {
  final Ref _ref;
  final SharedPreferences _prefs;
  final BackupDataSource _picker;

  BackupController(this._ref, this._prefs, this._picker)
      : super(BackupState(
          lastBackupDate: _prefs.getString('last_backup_date'),
        ));

  void clearPreview() {
    state = state.copyWith(previewData: () => null, successMessage: () => null, errorMessage: () => null);
  }

  Future<void> exportBackup() async {
    state = state.copyWith(isLoading: true, successMessage: () => null, errorMessage: () => null);
    try {
      final jsonContent = ExportDataUseCase(_prefs).call();
      final dateStr = DateTime.now().toIso8601String().split('T')[0];
      final filename = 'expense_tracker_backup_$dateStr.json';

      await _picker.shareBackupFile(jsonContent, filename);

      final nowStr = DateTime.now().toLocal().toString().split('.')[0];
      await _prefs.setString('last_backup_date', nowStr);

      state = state.copyWith(
        isLoading: false,
        successMessage: () => 'Backup exported successfully!',
        lastBackupDate: () => nowStr,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Export failed: ${e.toString()}',
      );
    }
  }

  Future<void> startImport() async {
    state = state.copyWith(isLoading: true, successMessage: () => null, errorMessage: () => null);
    try {
      final jsonString = await _picker.pickBackupFile();
      if (jsonString == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final validation = ValidateBackupUseCase().call(jsonString);
      if (!validation.isValid) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: () => validation.errorMessage ?? 'Invalid backup file.',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        previewData: () => validation.decodedData,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Import failed: ${e.toString()}',
      );
    }
  }

  Future<void> executeRestore(Map<String, dynamic> backupData) async {
    state = state.copyWith(isLoading: true, successMessage: () => null, errorMessage: () => null);
    try {
      await RestoreBackupUseCase(_prefs).call(backupData);
      await _refreshAllData();
      state = state.copyWith(
        isLoading: false,
        successMessage: () => 'Backup restored successfully!',
        previewData: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Restore failed: ${e.toString()}',
      );
    }
  }

  Future<void> executeMerge(Map<String, dynamic> backupData) async {
    state = state.copyWith(isLoading: true, successMessage: () => null, errorMessage: () => null);
    try {
      await MergeBackupUseCase(_prefs).call(backupData);
      await _refreshAllData();
      state = state.copyWith(
        isLoading: false,
        successMessage: () => 'Backup merged successfully!',
        previewData: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Merge failed: ${e.toString()}',
      );
    }
  }

  Future<void> clearAllData() async {
    state = state.copyWith(isLoading: true, successMessage: () => null, errorMessage: () => null);
    try {
      await _prefs.remove('persist_transactions');
      await _prefs.remove('persist_accounts');
      await _prefs.remove('persist_budgets');
      await _prefs.remove('persist_recurring_transactions');
      await _prefs.remove('persist_notifications');
      await _prefs.remove('persist_notification_settings');
      await _prefs.remove('favorite_merchants');
      await _prefs.remove('last_backup_date');

      await _refreshAllData();

      state = state.copyWith(
        isLoading: false,
        successMessage: () => 'All local data cleared.',
        lastBackupDate: () => null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: () => 'Failed to clear data: ${e.toString()}',
      );
    }
  }

  Future<void> _refreshAllData() async {
    // Refresh all controllers/providers
    await _ref.read(transactionControllerProvider.notifier).load();
    await _ref.read(accountStateNotifierProvider.notifier).load();
    await _ref.read(budgetControllerProvider.notifier).load();
    await _ref.read(recurringControllerProvider.notifier).syncRecurringTransactions();
    await _ref.read(notificationControllerProvider.notifier).load();
  }
}
