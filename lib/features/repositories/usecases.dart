import '../../core/theme/entities.dart';

class GetTransactionsUseCase {
  final TransactionRepository _repo;
  GetTransactionsUseCase(this._repo);
  Future<List<TransactionEntity>> call() => _repo.getTransactions();
}

class AddTransactionUseCase {
  final TransactionRepository _repo;
  AddTransactionUseCase(this._repo);
  Future<void> call(TransactionEntity tx) => _repo.addTransaction(tx);
}

class UpdateTransactionUseCase {
  final TransactionRepository _repo;
  UpdateTransactionUseCase(this._repo);
  Future<void> call(TransactionEntity tx) => _repo.updateTransaction(tx);
}

class DeleteTransactionUseCase {
  final TransactionRepository _repo;
  DeleteTransactionUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteTransaction(id);
}

class GetBudgetsUseCase {
  final BudgetRepository _repo;
  GetBudgetsUseCase(this._repo);
  Future<List<BudgetEntity>> call() => _repo.getBudgets();
}

class AddBudgetUseCase {
  final BudgetRepository _repo;
  AddBudgetUseCase(this._repo);
  Future<void> call(BudgetEntity b) => _repo.addBudget(b);
}

class UpdateBudgetUseCase {
  final BudgetRepository _repo;
  UpdateBudgetUseCase(this._repo);
  Future<void> call(BudgetEntity b) => _repo.updateBudget(b);
}

class DeleteBudgetUseCase {
  final BudgetRepository _repo;
  DeleteBudgetUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteBudget(id);
}

class GetCategoriesUseCase {
  final CategoryRepository _repo;
  GetCategoriesUseCase(this._repo);
  Future<List<CategoryEntity>> call() => _repo.getCategories();
}

class GetAccountsUseCase {
  final AccountRepository _repo;
  GetAccountsUseCase(this._repo);
  Future<List<AccountEntity>> call() => _repo.getAccounts();
}

class GetAccountByIdUseCase {
  final AccountRepository _repo;
  GetAccountByIdUseCase(this._repo);
  Future<AccountEntity?> call(String id) async {
    final list = await _repo.getAccounts();
    final idx = list.indexWhere((a) => a.id == id);
    if (idx != -1) return list[idx];
    return null;
  }
}

class CreateAccountUseCase {
  final AccountRepository _repo;
  CreateAccountUseCase(this._repo);
  Future<void> call(AccountEntity acc) => _repo.addAccount(acc);
}

class UpdateAccountUseCase {
  final AccountRepository _repo;
  UpdateAccountUseCase(this._repo);
  Future<void> call(AccountEntity acc) => _repo.updateAccount(acc);
}

class ArchiveAccountUseCase {
  final AccountRepository _repo;
  ArchiveAccountUseCase(this._repo);
  Future<void> call(String id) async {
    final list = await _repo.getAccounts();
    final idx = list.indexWhere((a) => a.id == id);
    if (idx != -1) {
      final acc = list[idx];
      await _repo.updateAccount(acc.copyWith(isActive: false, isDefault: false));
    }
  }
}

class SetDefaultAccountUseCase {
  final AccountRepository _repo;
  SetDefaultAccountUseCase(this._repo);
  Future<void> call(String id) async {
    final list = await _repo.getAccounts();
    for (var acc in list) {
      if (acc.id == id) {
        await _repo.updateAccount(acc.copyWith(isDefault: true));
      } else if (acc.isDefault) {
        await _repo.updateAccount(acc.copyWith(isDefault: false));
      }
    }
  }
}

class CreateTransferUseCase {
  final TransactionRepository _txRepo;
  CreateTransferUseCase(this._txRepo);

  Future<void> call({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final transferId = 'tr_${DateTime.now().microsecondsSinceEpoch}';
    final tx = TransactionEntity(
      id: 'tx_tr_${DateTime.now().microsecondsSinceEpoch}',
      amount: amount,
      type: TransactionType.transfer,
      categoryId: 'cat_other_expense',
      accountId: fromAccountId,
      title: description ?? 'Transfer to Account',
      description: description,
      date: date,
      paymentMethod: PaymentMethod.bank,
      createdAt: DateTime.now(),
      transferId: transferId,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
    );
    await _txRepo.addTransaction(tx);
  }
}

class UpdateTransferUseCase {
  final TransactionRepository _txRepo;
  UpdateTransferUseCase(this._txRepo);

  Future<void> call({
    required String transferId,
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    final txs = await _txRepo.getTransactions();
    final idx = txs.indexWhere((t) => t.transferId == transferId);
    if (idx != -1) {
      final old = txs[idx];
      final updated = old.copyWith(
        amount: amount,
        accountId: fromAccountId,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        date: date,
        title: description ?? 'Transfer to Account',
        description: description,
      );
      await _txRepo.updateTransaction(updated);
    }
  }
}

class DeleteTransferUseCase {
  final TransactionRepository _txRepo;
  DeleteTransferUseCase(this._txRepo);

  Future<void> call(String transferId) async {
    final txs = await _txRepo.getTransactions();
    final idx = txs.indexWhere((t) => t.transferId == transferId);
    if (idx != -1) {
      await _txRepo.deleteTransaction(txs[idx].id);
    }
  }
}

class GetRecurringTransactionsUseCase {
  final RecurringRepository _repo;
  GetRecurringTransactionsUseCase(this._repo);
  Future<List<RecurringTransactionEntity>> call() => _repo.getRecurringTransactions();
}

class GetRecurringByIdUseCase {
  final RecurringRepository _repo;
  GetRecurringByIdUseCase(this._repo);
  Future<RecurringTransactionEntity?> call(String id) => _repo.getRecurringById(id);
}

class CreateRecurringTransactionUseCase {
  final RecurringRepository _repo;
  CreateRecurringTransactionUseCase(this._repo);
  Future<void> call(RecurringTransactionEntity rec) => _repo.createRecurringTransaction(rec);
}

class UpdateRecurringTransactionUseCase {
  final RecurringRepository _repo;
  UpdateRecurringTransactionUseCase(this._repo);
  Future<void> call(RecurringTransactionEntity rec) => _repo.updateRecurringTransaction(rec);
}

class DeleteRecurringTransactionUseCase {
  final RecurringRepository _repo;
  DeleteRecurringTransactionUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteRecurringTransaction(id);
}

class PauseRecurringTransactionUseCase {
  final RecurringRepository _repo;
  PauseRecurringTransactionUseCase(this._repo);
  Future<void> call(String id) async {
    final rec = await _repo.getRecurringById(id);
    if (rec != null) {
      await _repo.updateRecurringTransaction(rec.copyWith(isPaused: true));
    }
  }
}

class ResumeRecurringTransactionUseCase {
  final RecurringRepository _repo;
  ResumeRecurringTransactionUseCase(this._repo);
  Future<void> call(String id) async {
    final rec = await _repo.getRecurringById(id);
    if (rec != null) {
      // Upon resume, next occurrence is calculated
      await _repo.updateRecurringTransaction(rec.copyWith(isPaused: false));
    }
  }
}

class SkipNextOccurrenceUseCase {
  final RecurringRepository _repo;
  SkipNextOccurrenceUseCase(this._repo);
  Future<void> call(String id, DateTime nextOccurrenceDate) async {
    final rec = await _repo.getRecurringById(id);
    if (rec != null) {
      final dateStr = nextOccurrenceDate.toIso8601String().split('T')[0];
      final newSkipped = List<String>.from(rec.skippedOccurrences)..add(dateStr);
      await _repo.updateRecurringTransaction(rec.copyWith(
        skippedOccurrences: newSkipped,
      ));
    }
  }
}

class GetNotificationsUseCase {
  final NotificationRepository _repo;
  GetNotificationsUseCase(this._repo);
  Future<List<NotificationEntity>> call() => _repo.getNotifications();
}

class GetUnreadNotificationsUseCase {
  final NotificationRepository _repo;
  GetUnreadNotificationsUseCase(this._repo);
  Future<List<NotificationEntity>> call() async {
    final list = await _repo.getNotifications();
    return list.where((n) => !n.isRead).toList();
  }
}

class CreateNotificationUseCase {
  final NotificationRepository _repo;
  CreateNotificationUseCase(this._repo);
  Future<void> call(NotificationEntity notification) => _repo.createNotification(notification);
}

class MarkNotificationReadUseCase {
  final NotificationRepository _repo;
  MarkNotificationReadUseCase(this._repo);
  Future<void> call(String id) => _repo.markNotificationRead(id);
}

class MarkAllNotificationsReadUseCase {
  final NotificationRepository _repo;
  MarkAllNotificationsReadUseCase(this._repo);
  Future<void> call() => _repo.markAllNotificationsRead();
}

class DeleteNotificationUseCase {
  final NotificationRepository _repo;
  DeleteNotificationUseCase(this._repo);
  Future<void> call(String id) => _repo.deleteNotification(id);
}

class ClearReadNotificationsUseCase {
  final NotificationRepository _repo;
  ClearReadNotificationsUseCase(this._repo);
  Future<void> call() => _repo.clearReadNotifications();
}

class GetUnreadNotificationCountUseCase {
  final NotificationRepository _repo;
  GetUnreadNotificationCountUseCase(this._repo);
  Future<int> call() async {
    final list = await _repo.getNotifications();
    return list.where((n) => !n.isRead).length;
  }
}

class GetNotificationSettingsUseCase {
  final NotificationRepository _repo;
  GetNotificationSettingsUseCase(this._repo);
  Future<NotificationSettingsEntity> call() => _repo.getNotificationSettings();
}

class UpdateNotificationSettingsUseCase {
  final NotificationRepository _repo;
  UpdateNotificationSettingsUseCase(this._repo);
  Future<void> call(NotificationSettingsEntity settings) => _repo.updateNotificationSettings(settings);
}

abstract class TransactionRepository {
  Future<List<TransactionEntity>> getTransactions();
  Future<void> addTransaction(TransactionEntity tx);
  Future<void> updateTransaction(TransactionEntity tx);
  Future<void> deleteTransaction(String id);
}

abstract class BudgetRepository {
  Future<List<BudgetEntity>> getBudgets();
  Future<void> addBudget(BudgetEntity b);
  Future<void> updateBudget(BudgetEntity b);
  Future<void> deleteBudget(String id);
}

abstract class CategoryRepository {
  Future<List<CategoryEntity>> getCategories();
  Future<void> addCategory(CategoryEntity c);
  Future<void> updateCategory(CategoryEntity c);
  Future<void> deleteCategory(String id);
}

abstract class AccountRepository {
  Future<List<AccountEntity>> getAccounts();
  Future<void> addAccount(AccountEntity a);
  Future<void> updateAccount(AccountEntity a);
  Future<void> deleteAccount(String id);
}

abstract class RecurringRepository {
  Future<List<RecurringTransactionEntity>> getRecurringTransactions();
  Future<RecurringTransactionEntity?> getRecurringById(String id);
  Future<void> createRecurringTransaction(RecurringTransactionEntity rec);
  Future<void> updateRecurringTransaction(RecurringTransactionEntity rec);
  Future<void> deleteRecurringTransaction(String id);
}

abstract class NotificationRepository {
  Future<List<NotificationEntity>> getNotifications();
  Future<void> createNotification(NotificationEntity notification);
  Future<void> markNotificationRead(String id);
  Future<void> markAllNotificationsRead();
  Future<void> deleteNotification(String id);
  Future<void> clearReadNotifications();
  Future<NotificationSettingsEntity> getNotificationSettings();
  Future<void> updateNotificationSettings(NotificationSettingsEntity settings);
}

abstract class AuthRepository {
  Future<UserEntity?> login(String email, String password);
  Future<UserEntity?> register(String name, String email, String password);
  Future<void> logout();
  Future<UserEntity?> getCurrentUser();
}
