import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/local_storage_service.dart';
import '../../core/theme/entities.dart';
import 'usecases.dart';
import 'datasources.dart';
import 'mock_repository_impls.dart';
import 'budget_usecases.dart';

// Service & Storage Providers
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Initialize sharedPreferencesProvider in main.dart');
});

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return LocalStorageService(prefs);
});

// Theme state
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, String>((ref) {
  final service = ref.watch(localStorageServiceProvider);
  return ThemeModeNotifier(service);
});

class ThemeModeNotifier extends StateNotifier<String> {
  final LocalStorageService _service;
  ThemeModeNotifier(this._service) : super(_service.getThemeMode());

  void toggleTheme() {
    final next = state == 'dark' ? 'light' : 'dark';
    state = next;
    _service.setThemeMode(next);
  }

  void setTheme(String val) {
    state = val;
    _service.setThemeMode(val);
  }
}

// Currency state
final currencyProvider = StateNotifierProvider<CurrencyNotifier, String>((ref) {
  final service = ref.watch(localStorageServiceProvider);
  return CurrencyNotifier(service);
});

class CurrencyNotifier extends StateNotifier<String> {
  final LocalStorageService _service;
  CurrencyNotifier(this._service) : super(_service.getCurrency());

  void setCurrency(String currency) {
    state = currency;
    _service.setCurrency(currency);
  }
}

// Data Sources
final transactionDataSourceProvider = Provider<TransactionDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MockTransactionDataSource(prefs);
});

final budgetDataSourceProvider = Provider<BudgetDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MockBudgetDataSource(prefs);
});

final categoryDataSourceProvider = Provider<CategoryDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MockCategoryDataSource(prefs);
});

final accountDataSourceProvider = Provider<AccountDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MockAccountDataSource(prefs);
});

final recurringDataSourceProvider = Provider<RecurringDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MockRecurringDataSource(prefs);
});

final notificationDataSourceProvider = Provider<NotificationDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return MockNotificationDataSource(prefs);
});

// Repositories
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return MockAuthRepository(storage);
});

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final ds = ref.watch(transactionDataSourceProvider);
  return MockTransactionRepository(ds);
});

final budgetRepositoryProvider = Provider<BudgetRepository>((ref) {
  final ds = ref.watch(budgetDataSourceProvider);
  return MockMockBudgetRepository(ds);
});

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final ds = ref.watch(notificationDataSourceProvider);
  return MockNotificationRepository(ds);
});

class MockMockBudgetRepository extends MockBudgetRepository {
  MockMockBudgetRepository(super.dataSource);
}

final accountRepositoryProvider = Provider<AccountRepository>((ref) {
  final ds = ref.watch(accountDataSourceProvider);
  return MockAccountRepository(ds);
});

final categoryRepositoryProvider = Provider<CategoryRepository>((ref) {
  final ds = ref.watch(categoryDataSourceProvider);
  return MockCategoryRepository(ds);
});

final recurringRepositoryProvider = Provider<RecurringRepository>((ref) {
  final ds = ref.watch(recurringDataSourceProvider);
  return MockRecurringRepository(ds);
});

// Notification Use Cases
final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return GetNotificationsUseCase(repo);
});

final getUnreadNotificationsUseCaseProvider = Provider<GetUnreadNotificationsUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return GetUnreadNotificationsUseCase(repo);
});

final createNotificationUseCaseProvider = Provider<CreateNotificationUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return CreateNotificationUseCase(repo);
});

final markNotificationReadUseCaseProvider = Provider<MarkNotificationReadUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return MarkNotificationReadUseCase(repo);
});

final markAllNotificationsReadUseCaseProvider = Provider<MarkAllNotificationsReadUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return MarkAllNotificationsReadUseCase(repo);
});

final deleteNotificationUseCaseProvider = Provider<DeleteNotificationUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return DeleteNotificationUseCase(repo);
});

final clearReadNotificationsUseCaseProvider = Provider<ClearReadNotificationsUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return ClearReadNotificationsUseCase(repo);
});

final getUnreadNotificationCountUseCaseProvider = Provider<GetUnreadNotificationCountUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return GetUnreadNotificationCountUseCase(repo);
});

final getNotificationSettingsUseCaseProvider = Provider<GetNotificationSettingsUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return GetNotificationSettingsUseCase(repo);
});

final updateNotificationSettingsUseCaseProvider = Provider<UpdateNotificationSettingsUseCase>((ref) {
  final repo = ref.watch(notificationRepositoryProvider);
  return UpdateNotificationSettingsUseCase(repo);
});

// Use Cases
final getTransactionsUseCaseProvider = Provider<GetTransactionsUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return GetTransactionsUseCase(repo);
});

final addTransactionUseCaseProvider = Provider<AddTransactionUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return AddTransactionUseCase(repo);
});

final updateTransactionUseCaseProvider = Provider<UpdateTransactionUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return UpdateTransactionUseCase(repo);
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransactionUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return DeleteTransactionUseCase(repo);
});

final getBudgetsUseCaseProvider = Provider<GetBudgetsUseCase>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return GetBudgetsUseCase(repo);
});

final addBudgetUseCaseProvider = Provider<AddBudgetUseCase>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return AddBudgetUseCase(repo);
});

final updateBudgetUseCaseProvider = Provider<UpdateBudgetUseCase>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return UpdateBudgetUseCase(repo);
});

final deleteBudgetUseCaseProvider = Provider<DeleteBudgetUseCase>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return DeleteBudgetUseCase(repo);
});

final getBudgetByIdUseCaseProvider = Provider<GetBudgetByIdUseCase>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return GetBudgetByIdUseCase(repo);
});

final createBudgetUseCaseProvider = Provider<CreateBudgetUseCase>((ref) {
  final repo = ref.watch(budgetRepositoryProvider);
  return CreateBudgetUseCase(repo);
});

final getBudgetWarningsUseCaseProvider = Provider<GetBudgetWarningsUseCase>((ref) {
  return GetBudgetWarningsUseCase();
});

final getBudgetSpendingUseCaseProvider = Provider<GetBudgetSpendingUseCase>((ref) {
  return GetBudgetSpendingUseCase();
});

final getActiveBudgetsUseCaseProvider = Provider<GetActiveBudgetsUseCase>((ref) {
  return GetActiveBudgetsUseCase();
});

final getBudgetSummaryUseCaseProvider = Provider<GetBudgetSummaryUseCase>((ref) {
  return GetBudgetSummaryUseCase();
});

final getBudgetHistoryUseCaseProvider = Provider<GetBudgetHistoryUseCase>((ref) {
  return GetBudgetHistoryUseCase();
});

final getBudgetInsightsUseCaseProvider = Provider<GetBudgetInsightsUseCase>((ref) {
  return GetBudgetInsightsUseCase();
});

final getCategoriesUseCaseProvider = Provider<GetCategoriesUseCase>((ref) {
  final repo = ref.watch(categoryRepositoryProvider);
  return GetCategoriesUseCase(repo);
});

final getAccountsUseCaseProvider = Provider<GetAccountsUseCase>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return GetAccountsUseCase(repo);
});

final getAccountByIdUseCaseProvider = Provider<GetAccountByIdUseCase>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return GetAccountByIdUseCase(repo);
});

final createAccountUseCaseProvider = Provider<CreateAccountUseCase>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return CreateAccountUseCase(repo);
});

final updateAccountUseCaseProvider = Provider<UpdateAccountUseCase>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return UpdateAccountUseCase(repo);
});

final archiveAccountUseCaseProvider = Provider<ArchiveAccountUseCase>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return ArchiveAccountUseCase(repo);
});

final setDefaultAccountUseCaseProvider = Provider<SetDefaultAccountUseCase>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return SetDefaultAccountUseCase(repo);
});

final createTransferUseCaseProvider = Provider<CreateTransferUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return CreateTransferUseCase(repo);
});

final updateTransferUseCaseProvider = Provider<UpdateTransferUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return UpdateTransferUseCase(repo);
});

final deleteTransferUseCaseProvider = Provider<DeleteTransferUseCase>((ref) {
  final repo = ref.watch(transactionRepositoryProvider);
  return DeleteTransferUseCase(repo);
});

final getRecurringTransactionsUseCaseProvider = Provider<GetRecurringTransactionsUseCase>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return GetRecurringTransactionsUseCase(repo);
});

final getRecurringByIdUseCaseProvider = Provider<GetRecurringByIdUseCase>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return GetRecurringByIdUseCase(repo);
});

final createRecurringTransactionUseCaseProvider = Provider<CreateRecurringTransactionUseCase>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return CreateRecurringTransactionUseCase(repo);
});

final updateRecurringTransactionUseCaseProvider = Provider<UpdateRecurringTransactionUseCase>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return UpdateRecurringTransactionUseCase(repo);
});

final deleteRecurringTransactionUseCaseProvider = Provider<DeleteRecurringTransactionUseCase>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return DeleteRecurringTransactionUseCase(repo);
});

final pauseRecurringTransactionUseCaseProvider = Provider<PauseRecurringTransactionUseCase>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return PauseRecurringTransactionUseCase(repo);
});

final resumeRecurringTransactionUseCaseProvider = Provider<ResumeRecurringTransactionUseCase>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return ResumeRecurringTransactionUseCase(repo);
});

final skipNextOccurrenceUseCaseProvider = Provider<SkipNextOccurrenceUseCase>((ref) {
  final repo = ref.watch(recurringRepositoryProvider);
  return SkipNextOccurrenceUseCase(repo);
});

// Authentication Controller State
class AuthState {
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;
  AuthState({required this.isLoading, this.user, this.errorMessage});
}

final authControllerProvider = StateNotifierProvider<AuthController, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthController(repo);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _repo;
  AuthController(this._repo) : super(AuthState(isLoading: true)) {
    _init();
  }

  Future<void> _init() async {
    final user = await _repo.getCurrentUser();
    state = AuthState(isLoading: false, user: user);
  }

  Future<bool> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final user = await _repo.login(email, password);
      if (user != null) {
        state = AuthState(isLoading: false, user: user);
        return true;
      }
      state = AuthState(isLoading: false, errorMessage: 'Invalid credentials');
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: e.toString());
    }
    return false;
  }

  Future<bool> register(String name, String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      final user = await _repo.register(name, email, password);
      if (user != null) {
        state = AuthState(isLoading: false, user: user);
        return true;
      }
      state = AuthState(isLoading: false, errorMessage: 'Registration failed');
    } catch (e) {
      state = AuthState(isLoading: false, errorMessage: e.toString());
    }
    return false;
  }

  Future<void> logout() async {
    state = AuthState(isLoading: true);
    await _repo.logout();
    state = AuthState(isLoading: false, user: null);
  }
}
