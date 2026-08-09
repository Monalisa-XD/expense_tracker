import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/entities.dart';
import 'providers.dart';
import 'controllers.dart';

class AccountState {
  final List<AccountEntity> accounts;
  final List<AccountEntity> activeAccounts;
  final List<AccountEntity> archivedAccounts;
  final double totalAssets;
  final double totalLiabilities;
  final double netWorth;
  final AccountEntity? defaultAccount;
  final bool isLoading;
  final String? error;

  AccountState({
    required this.accounts,
    required this.activeAccounts,
    required this.archivedAccounts,
    required this.totalAssets,
    required this.totalLiabilities,
    required this.netWorth,
    this.defaultAccount,
    required this.isLoading,
    this.error,
  });

  AccountState copyWith({
    List<AccountEntity>? accounts,
    List<AccountEntity>? activeAccounts,
    List<AccountEntity>? archivedAccounts,
    double? totalAssets,
    double? totalLiabilities,
    double? netWorth,
    AccountEntity? Function()? defaultAccount,
    bool? isLoading,
    String? Function()? error,
  }) {
    return AccountState(
      accounts: accounts ?? this.accounts,
      activeAccounts: activeAccounts ?? this.activeAccounts,
      archivedAccounts: archivedAccounts ?? this.archivedAccounts,
      totalAssets: totalAssets ?? this.totalAssets,
      totalLiabilities: totalLiabilities ?? this.totalLiabilities,
      netWorth: netWorth ?? this.netWorth,
      defaultAccount: defaultAccount != null ? defaultAccount() : this.defaultAccount,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

final accountStateNotifierProvider = StateNotifierProvider<AccountStateController, AccountState>((ref) {
  return AccountStateController(ref);
});

class AccountStateController extends StateNotifier<AccountState> {
  final Ref _ref;

  AccountStateController(this._ref)
      : super(AccountState(
          accounts: [],
          activeAccounts: [],
          archivedAccounts: [],
          totalAssets: 0.0,
          totalLiabilities: 0.0,
          netWorth: 0.0,
          isLoading: true,
        )) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final getAccs = _ref.read(getAccountsUseCaseProvider);
      final rawAccounts = await getAccs();

      // Recalculate balances dynamically based on transactions
      final txsVal = _ref.watch(transactionControllerProvider);
      final transactions = txsVal.value ?? [];

      final List<AccountEntity> computedAccounts = [];
      for (var acc in rawAccounts) {
        double balance = acc.initialBalance;

        for (var tx in transactions) {
          if (tx.type == TransactionType.income && tx.accountId == acc.id) {
            balance += tx.amount;
          } else if (tx.type == TransactionType.expense && tx.accountId == acc.id) {
            balance -= tx.amount;
          } else if (tx.type == TransactionType.transfer) {
            if (tx.fromAccountId == acc.id) {
              balance -= tx.amount;
            } else if (tx.toAccountId == acc.id) {
              balance += tx.amount;
            }
          }
        }
        computedAccounts.add(acc.copyWith(balance: balance));
      }

      final active = computedAccounts.where((a) => a.isActive).toList();
      final archived = computedAccounts.where((a) => !a.isActive).toList();

      double assets = 0.0;
      double liabilities = 0.0;

      for (var a in active) {
        if (a.type == PaymentMethod.creditCard) {
          if (a.balance < 0) {
            liabilities += a.balance.abs();
          } else {
            assets += a.balance;
          }
        } else {
          if (a.balance >= 0) {
            assets += a.balance;
          } else {
            liabilities += a.balance.abs();
          }
        }
      }

      final defaultAcc = active.firstWhere((a) => a.isDefault, orElse: () => active.first);

      state = AccountState(
        accounts: computedAccounts,
        activeAccounts: active,
        archivedAccounts: archived,
        totalAssets: assets,
        totalLiabilities: liabilities,
        netWorth: assets - liabilities,
        defaultAccount: defaultAcc,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => 'Unable to load accounts.');
    }
  }

  Future<void> createAccount(AccountEntity acc) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(createAccountUseCaseProvider)(acc);
      if (acc.isDefault) {
        await _ref.read(setDefaultAccountUseCaseProvider)(acc.id);
      }
      await _ref.read(accountControllerProvider.notifier).load();
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> updateAccount(AccountEntity acc) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(updateAccountUseCaseProvider)(acc);
      if (acc.isDefault) {
        await _ref.read(setDefaultAccountUseCaseProvider)(acc.id);
      }
      await _ref.read(accountControllerProvider.notifier).load();
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> archiveAccount(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(archiveAccountUseCaseProvider)(id);
      await _ref.read(accountControllerProvider.notifier).load();
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> setDefaultAccount(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(setDefaultAccountUseCaseProvider)(id);
      await _ref.read(accountControllerProvider.notifier).load();
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> deleteAccount(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(accountRepositoryProvider).deleteAccount(id);
      await _ref.read(accountControllerProvider.notifier).load();
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> createTransfer({
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(createTransferUseCaseProvider)(
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        date: date,
        description: description,
      );
      await _ref.read(transactionControllerProvider.notifier).load();
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> updateTransfer({
    required String transferId,
    required String fromAccountId,
    required String toAccountId,
    required double amount,
    required DateTime date,
    String? description,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(updateTransferUseCaseProvider)(
        transferId: transferId,
        fromAccountId: fromAccountId,
        toAccountId: toAccountId,
        amount: amount,
        date: date,
        description: description,
      );
      await _ref.read(transactionControllerProvider.notifier).load();
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> deleteTransfer(String transferId) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(deleteTransferUseCaseProvider)(transferId);
      await _ref.read(transactionControllerProvider.notifier).load();
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }
}
