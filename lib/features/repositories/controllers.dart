import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/entities.dart';
import '../../core/theme/brand_registry.dart';
import '../../core/theme/category_registry.dart';
import '../../core/theme/merchant_registry.dart';
import 'usecases.dart';
import 'providers.dart';
import 'analytics_usecases.dart';
import 'budget_usecases.dart';
import 'account_controller.dart';

// Transaction filter state class
class TransactionFilterState {
  final String searchQuery;
  final String selectedType; // All, Income, Expense
  final CategoryEntity? selectedCategory;
  final AccountEntity? selectedAccount;
  final DateTimeRange? selectedDateRange;
  final PaymentMethod? selectedPaymentMethod;
  final String sortOption; // Newest, Oldest, Highest, Lowest

  TransactionFilterState({
    this.searchQuery = '',
    this.selectedType = 'All',
    this.selectedCategory,
    this.selectedAccount,
    this.selectedDateRange,
    this.selectedPaymentMethod,
    this.sortOption = 'Newest',
  });

  TransactionFilterState copyWith({
    String? searchQuery,
    String? selectedType,
    CategoryEntity? Function()? selectedCategory,
    AccountEntity? Function()? selectedAccount,
    DateTimeRange? Function()? selectedDateRange,
    PaymentMethod? Function()? selectedPaymentMethod,
    String? sortOption,
  }) {
    return TransactionFilterState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedType: selectedType ?? this.selectedType,
      selectedCategory: selectedCategory != null ? selectedCategory() : this.selectedCategory,
      selectedAccount: selectedAccount != null ? selectedAccount() : this.selectedAccount,
      selectedDateRange: selectedDateRange != null ? selectedDateRange() : this.selectedDateRange,
      selectedPaymentMethod: selectedPaymentMethod != null ? selectedPaymentMethod() : this.selectedPaymentMethod,
      sortOption: sortOption ?? this.sortOption,
    );
  }
}

// Controller to manage TransactionFilterState
final transactionFilterControllerProvider = StateNotifierProvider<TransactionFilterController, TransactionFilterState>((ref) {
  return TransactionFilterController();
});

class TransactionFilterController extends StateNotifier<TransactionFilterState> {
  TransactionFilterController() : super(TransactionFilterState());

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setSelectedType(String type) {
    state = state.copyWith(selectedType: type);
  }

  void setSelectedCategory(CategoryEntity? category) {
    state = state.copyWith(selectedCategory: () => category);
  }

  void setSelectedAccount(AccountEntity? account) {
    state = state.copyWith(selectedAccount: () => account);
  }

  void setSelectedDateRange(DateTimeRange? range) {
    state = state.copyWith(selectedDateRange: () => range);
  }

  void setSelectedPaymentMethod(PaymentMethod? method) {
    state = state.copyWith(selectedPaymentMethod: () => method);
  }

  void setSortOption(String option) {
    state = state.copyWith(sortOption: option);
  }

  void clearFilters() {
    state = TransactionFilterState(searchQuery: state.searchQuery, sortOption: state.sortOption);
  }
}

// Derived/computed filter provider
final filteredTransactionsProvider = Provider<AsyncValue<List<TransactionEntity>>>((ref) {
  final txsVal = ref.watch(transactionControllerProvider);
  final filter = ref.watch(transactionFilterControllerProvider);
  final accounts = ref.watch(accountStateNotifierProvider).accounts;

  return txsVal.when(
    data: (list) {
      var filtered = list.where((tx) {
        // Search filter
        final query = filter.searchQuery.toLowerCase();
        if (query.isNotEmpty) {
          final matchesTitle = tx.title.toLowerCase().contains(query);
          final matchesDesc = tx.description?.toLowerCase().contains(query) ?? false;
          final matchesMerchant = tx.merchantName?.toLowerCase().contains(query) ?? false;
          final matchesSubcatId = tx.subcategoryId?.toLowerCase().contains(query) ?? false;

          // Find resolved category name matching query
          final catDef = CategoryRegistry.categories.firstWhere(
            (c) => c.id == tx.categoryId,
            orElse: () => CategoryDefinition(id: '', name: '', icon: '', colorValue: 0, subcategories: []),
          );
          final matchesCatName = catDef.name.toLowerCase().contains(query);

          // Find resolved subcategory name matching query
          final subcatDef = catDef.subcategories.firstWhere(
            (s) => s.id == tx.subcategoryId,
            orElse: () => SubcategoryDefinition(id: '', name: ''),
          );
          final matchesSubcatName = subcatDef.name.toLowerCase().contains(query);

          // Match account name
          final matchingAcc = accounts.firstWhere(
            (a) => a.id == tx.accountId,
            orElse: () => AccountEntity(id: '', name: '', balance: 0.0, type: PaymentMethod.upi, initialBalance: 0.0),
          );
          final matchesAccountName = matchingAcc.name.toLowerCase().contains(query);

          if (!matchesTitle && !matchesDesc && !matchesMerchant && !matchesSubcatId && !matchesCatName && !matchesSubcatName && !matchesAccountName) {
            return false;
          }
        }

        // Type filter
        if (filter.selectedType == 'Income' && tx.type != TransactionType.income) return false;
        if (filter.selectedType == 'Expense' && tx.type != TransactionType.expense) return false;

        // Category filter
        if (filter.selectedCategory != null && tx.categoryId != filter.selectedCategory!.id) return false;

        // Account filter
        if (filter.selectedAccount != null && tx.accountId != filter.selectedAccount!.id) return false;

        // Payment Method filter
        if (filter.selectedPaymentMethod != null && tx.paymentMethod != filter.selectedPaymentMethod) return false;

        // Date range filter
        if (filter.selectedDateRange != null) {
          if (tx.date.isBefore(filter.selectedDateRange!.start) || tx.date.isAfter(filter.selectedDateRange!.end.add(const Duration(days: 1)))) {
            return false;
          }
        }

        return true;
      }).toList();

      // Sort
      if (filter.sortOption == 'Newest') {
        filtered.sort((a, b) => b.date.compareTo(a.date));
      } else if (filter.sortOption == 'Oldest') {
        filtered.sort((a, b) => a.date.compareTo(b.date));
      } else if (filter.sortOption == 'Highest') {
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
      } else if (filter.sortOption == 'Lowest') {
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
      }

      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Transaction state controller
final transactionControllerProvider = StateNotifierProvider<TransactionController, AsyncValue<List<TransactionEntity>>>((ref) {
  final getTx = ref.watch(getTransactionsUseCaseProvider);
  final addTx = ref.watch(addTransactionUseCaseProvider);
  final updateTx = ref.watch(updateTransactionUseCaseProvider);
  final deleteTx = ref.watch(deleteTransactionUseCaseProvider);
  return TransactionController(getTx, addTx, updateTx, deleteTx);
});

class TransactionController extends StateNotifier<AsyncValue<List<TransactionEntity>>> {
  final GetTransactionsUseCase _getTx;
  final AddTransactionUseCase _addTx;
  final UpdateTransactionUseCase _updateTx;
  final DeleteTransactionUseCase _deleteTx;

  TransactionController(this._getTx, this._addTx, this._updateTx, this._deleteTx) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _getTx();
      final migratedList = list.map((tx) {
        // Migration: If categoryId is old or brandKey is not set yet, attempt matching
        bool needsMigration = false;
        String newCategoryId = tx.categoryId;
        
        // Map old category IDs to new ones
        if (tx.categoryId == 'cat_food') { newCategoryId = 'food_dining'; needsMigration = true; }
        else if (tx.categoryId == 'cat_transport') { newCategoryId = 'transport'; needsMigration = true; }
        else if (tx.categoryId == 'ride_transport') { newCategoryId = 'transport'; needsMigration = true; }
        else if (tx.categoryId == 'cat_shopping') { newCategoryId = 'shopping'; needsMigration = true; }
        else if (tx.categoryId == 'cat_bills') { newCategoryId = 'bills_recharge'; needsMigration = true; }
        else if (tx.categoryId == 'cat_entertainment') { newCategoryId = 'entertainment'; needsMigration = true; }
        else if (tx.categoryId == 'cat_health') { newCategoryId = 'health'; needsMigration = true; }
        else if (tx.categoryId == 'cat_education') { newCategoryId = 'education'; needsMigration = true; }
        else if (tx.categoryId == 'cat_travel') { newCategoryId = 'travel'; needsMigration = true; }
        else if (tx.categoryId == 'cat_groceries') { newCategoryId = 'groceries'; needsMigration = true; }
        else if (tx.categoryId == 'cat_salary') { newCategoryId = 'salary_income'; needsMigration = true; }
        else if (tx.categoryId == 'cat_freelance') { newCategoryId = 'salary_income'; needsMigration = true; }
        else if (tx.categoryId == 'cat_other_income') { newCategoryId = 'salary_income'; needsMigration = true; }
        else if (tx.categoryId == 'cat_other_expense') { newCategoryId = 'other'; needsMigration = true; }

        String? newSubcategoryId = tx.subcategoryId;
        String? newMerchantId = tx.merchantId;
        String? newBrandKey = tx.brandKey;
        String? newMerchantName = tx.merchantName;

        if (tx.brandKey == null || tx.brandKey == 'unknown' || tx.subcategoryId == null) {
          final detect = MerchantRegistry.detectMerchant(tx.title);
          if (detect != null) {
            newCategoryId = detect.categoryId;
            newSubcategoryId = detect.subcategoryId;
            newMerchantId = detect.id;
            newBrandKey = detect.brandKey;
            newMerchantName = detect.name;
            needsMigration = true;
          } else {
            // Check if title maps to a standard merchant name directly (e.g. Starbucks)
            final mClean = tx.title.trim().toLowerCase();
            if (mClean == 'house rent' || mClean == 'room rent') {
              newCategoryId = 'housing';
              newSubcategoryId = 'house_rent';
              newMerchantId = mClean == 'house rent' ? 'house_rent' : 'room_rent';
              newBrandKey = newMerchantId;
              newMerchantName = tx.title;
              needsMigration = true;
            } else if (tx.subcategoryId == null) {
              // Set default subcategory depending on category if merchant is unknown
              if (newCategoryId == 'food_dining') newSubcategoryId = 'other_food';
              else if (newCategoryId == 'shopping') newSubcategoryId = 'shopping_other';
              else if (newCategoryId == 'groceries') newSubcategoryId = 'grocery_other';
              else if (newCategoryId == 'transport') newSubcategoryId = 'transport_other';
              else if (newCategoryId == 'bills_recharge') newSubcategoryId = 'recharge_other';
              else if (newCategoryId == 'housing') newSubcategoryId = 'housing_other';
              else if (newCategoryId == 'entertainment') newSubcategoryId = 'entertainment_other';
              else if (newCategoryId == 'banking_finance') newSubcategoryId = 'finance_other';
              else if (newCategoryId == 'health') newSubcategoryId = 'health_other';
              else if (newCategoryId == 'education') newSubcategoryId = 'education_other';
              else if (newCategoryId == 'travel') newSubcategoryId = 'travel_other';
              else if (newCategoryId == 'utilities') newSubcategoryId = 'utilities_other';
              else if (newCategoryId == 'transfer') newSubcategoryId = 'bank_transfer';
              else if (newCategoryId == 'salary_income') newSubcategoryId = 'salary';
              else newSubcategoryId = 'other_expense';
              needsMigration = true;
            }
          }
        }

        // Safeguard: Make sure categoryId is mapped correctly to a known category from CategoryRegistry
        if (newCategoryId == 'cat_food') newCategoryId = 'food_dining';
        if (newCategoryId == 'cat_transport' || newCategoryId == 'ride_transport') newCategoryId = 'transport';
        if (newCategoryId == 'cat_shopping') newCategoryId = 'shopping';
        if (newCategoryId == 'cat_bills') newCategoryId = 'bills_recharge';
        if (newCategoryId == 'cat_entertainment') newCategoryId = 'entertainment';
        if (newCategoryId == 'cat_groceries') newCategoryId = 'groceries';

        if (needsMigration || newCategoryId != tx.categoryId || newSubcategoryId != tx.subcategoryId) {
          final updatedTx = tx.copyWith(
            categoryId: newCategoryId,
            subcategoryId: () => newSubcategoryId,
            merchantId: () => newMerchantId,
            brandKey: () => newBrandKey,
            merchantName: () => newMerchantName,
          );
          // Async update in persistence, do not wait blocking the stream load
          _updateTx(updatedTx);
          return updatedTx;
        }
        return tx;
      }).toList();

      state = AsyncValue.data(migratedList);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(TransactionEntity tx) async {
    try {
      await _addTx(tx);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTransaction(TransactionEntity tx) async {
    try {
      await _updateTx(tx);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _deleteTx(id);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Budgets Controller
final budgetControllerProvider = StateNotifierProvider<BudgetController, AsyncValue<List<BudgetEntity>>>((ref) {
  final getBudgets = ref.watch(getBudgetsUseCaseProvider);
  final addBudget = ref.watch(addBudgetUseCaseProvider);
  final updateBudget = ref.watch(updateBudgetUseCaseProvider);
  final deleteBudget = ref.watch(deleteBudgetUseCaseProvider);
  return BudgetController(getBudgets, addBudget, updateBudget, deleteBudget);
});

class BudgetController extends StateNotifier<AsyncValue<List<BudgetEntity>>> {
  final GetBudgetsUseCase _getBudgets;
  final AddBudgetUseCase _addBudget;
  final UpdateBudgetUseCase _updateBudget;
  final DeleteBudgetUseCase _deleteBudget;

  BudgetController(this._getBudgets, this._addBudget, this._updateBudget, this._deleteBudget) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _getBudgets();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(BudgetEntity b) async {
    try {
      await _addBudget(b);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateB(BudgetEntity b) async {
    try {
      await _updateBudget(b);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _deleteBudget(id);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Derived active budgets calculator provider
class BudgetState {
  final List<BudgetEntity> budgets;
  final List<BudgetEntity> activeBudgets;
  final List<BudgetEntity> expiredBudgets;
  final double totalBudget;
  final double totalSpent;
  final double remaining;
  final double usagePercentage;
  final List<BudgetEntity> warnings;
  final BudgetInsightsData insights;
  final bool isLoading;
  final String? error;

  BudgetState({
    required this.budgets,
    required this.activeBudgets,
    required this.expiredBudgets,
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.usagePercentage,
    required this.warnings,
    required this.insights,
    required this.isLoading,
    this.error,
  });
}

final budgetStateProvider = Provider<BudgetState>((ref) {
  final budgetsVal = ref.watch(budgetControllerProvider);
  final txsVal = ref.watch(transactionControllerProvider);
  final catsVal = ref.watch(categoryControllerProvider);

  final isLoading = budgetsVal.isLoading || txsVal.isLoading || catsVal.isLoading;
  final error = budgetsVal.error?.toString() ?? txsVal.error?.toString() ?? catsVal.error?.toString();

  final List<BudgetEntity> budgets = budgetsVal.value ?? [];
  final List<TransactionEntity> txs = txsVal.value ?? [];
  final List<CategoryEntity> cats = catsVal.value ?? [];

  // Derived active budgets
  final activeBudgets = GetActiveBudgetsUseCase().call(budgets: budgets, transactions: txs);

  // Derived expired budgets
  final expiredBudgets = GetBudgetHistoryUseCase().call(budgets: budgets, transactions: txs);

  // Derived summary
  final summary = GetBudgetSummaryUseCase().call(activeBudgets);

  // Derived warnings
  final warnings = GetBudgetWarningsUseCase().call(activeBudgets: activeBudgets);

  // Derived insights
  final insights = GetBudgetInsightsUseCase().call(activeBudgets: activeBudgets, categories: cats);

  return BudgetState(
    budgets: budgets,
    activeBudgets: activeBudgets,
    expiredBudgets: expiredBudgets,
    totalBudget: summary.totalBudget,
    totalSpent: summary.totalSpent,
    remaining: summary.remaining,
    usagePercentage: summary.usagePercentage,
    warnings: warnings,
    insights: insights,
    isLoading: isLoading,
    error: error,
  );
});

// Derived active budgets calculator provider for backward compatibility
final activeBudgetsStateProvider = Provider<AsyncValue<List<BudgetEntity>>>((ref) {
  final budgetState = ref.watch(budgetStateProvider);
  if (budgetState.isLoading) return const AsyncValue.loading();
  if (budgetState.error != null) return AsyncValue.error(budgetState.error!, StackTrace.current);
  return AsyncValue.data(budgetState.activeBudgets);
});

// Derived budget summary calculator provider for backward compatibility
final budgetSummaryProvider = Provider<AsyncValue<BudgetSummary>>((ref) {
  final budgetState = ref.watch(budgetStateProvider);
  if (budgetState.isLoading) return const AsyncValue.loading();
  if (budgetState.error != null) return AsyncValue.error(budgetState.error!, StackTrace.current);
  return AsyncValue.data(BudgetSummary(
    totalBudget: budgetState.totalBudget,
    totalSpent: budgetState.totalSpent,
    remaining: budgetState.remaining,
    usagePercentage: budgetState.usagePercentage,
  ));
});

// Derived budget history provider for backward compatibility
final budgetHistoryStateProvider = Provider<AsyncValue<List<BudgetEntity>>>((ref) {
  final budgetState = ref.watch(budgetStateProvider);
  if (budgetState.isLoading) return const AsyncValue.loading();
  if (budgetState.error != null) return AsyncValue.error(budgetState.error!, StackTrace.current);
  return AsyncValue.data(budgetState.expiredBudgets);
});

class AnalyticsPeriodState {
  final String period; // Week, Month, Year, Custom
  final DateTimeRange dateRange;

  AnalyticsPeriodState({
    required this.period,
    required this.dateRange,
  });

  AnalyticsPeriodState copyWith({
    String? period,
    DateTimeRange? dateRange,
  }) {
    return AnalyticsPeriodState(
      period: period ?? this.period,
      dateRange: dateRange ?? this.dateRange,
    );
  }
}

final analyticsPeriodControllerProvider = StateNotifierProvider<AnalyticsPeriodController, AnalyticsPeriodState>((ref) {
  return AnalyticsPeriodController();
});

class AnalyticsPeriodController extends StateNotifier<AnalyticsPeriodState> {
  AnalyticsPeriodController()
      : super(AnalyticsPeriodState(
          period: 'Month',
          dateRange: DateTimeRange(
            start: DateTime.now().subtract(const Duration(days: 30)),
            end: DateTime.now(),
          ),
        ));

  void setPeriod(String period) {
    DateTime start;
    final now = DateTime.now();
    if (period == 'Week') {
      start = now.subtract(const Duration(days: 7));
    } else if (period == 'Month') {
      start = now.subtract(const Duration(days: 30));
    } else {
      start = now.subtract(const Duration(days: 365));
    }
    state = AnalyticsPeriodState(period: period, dateRange: DateTimeRange(start: start, end: now));
  }

  void setCustomRange(DateTimeRange range) {
    state = AnalyticsPeriodState(period: 'Custom', dateRange: range);
  }
}

class FullAnalyticsData {
  final FinancialSummary summary;
  final PeriodComparison comparison;
  final List<CategoryContribution> categoryBreakdown;
  final List<TrendPoint> incomeExpenseTrend;
  final List<TrendPoint> savingsTrend;
  final FinancialInsights insights;

  FullAnalyticsData({
    required this.summary,
    required this.comparison,
    required this.categoryBreakdown,
    required this.incomeExpenseTrend,
    required this.savingsTrend,
    required this.insights,
  });
}

// Full derived analytics state provider
final analyticsStateProvider = Provider<AsyncValue<FullAnalyticsData>>((ref) {
  final txsVal = ref.watch(transactionControllerProvider);
  final catsVal = ref.watch(categoryControllerProvider);
  final periodState = ref.watch(analyticsPeriodControllerProvider);

  return txsVal.when(
    data: (list) {
      final categories = catsVal.value ?? [];

      // Filter transactions inside the current period range
      final currentTxs = list.where((tx) =>
          tx.date.isAfter(periodState.dateRange.start.subtract(const Duration(seconds: 1))) &&
          tx.date.isBefore(periodState.dateRange.end.add(const Duration(days: 1)))).toList();

      // Previous equivalent period calculations
      final duration = periodState.dateRange.duration;
      final prevStart = periodState.dateRange.start.subtract(duration);
      final prevEnd = periodState.dateRange.end.subtract(duration);
      final previousTxs = list.where((tx) =>
          tx.date.isAfter(prevStart.subtract(const Duration(seconds: 1))) &&
          tx.date.isBefore(prevEnd.add(const Duration(days: 1)))).toList();

      final summary = GetFinancialSummaryUseCase().call(currentTxs);
      final breakdown = GetCategoryBreakdownUseCase(categories).call(currentTxs);
      final trend = GetIncomeExpenseTrendUseCase().getTrend(currentTxs, periodState.period, periodState.dateRange);
      
      // Savings trend points mapping
      final savingsTrendPoints = trend.map((tp) => TrendPoint(label: tp.label, value: tp.value * 0.7)).toList();
      
      final comparison = GetPeriodComparisonUseCase().call(
        currentPeriodTransactions: currentTxs,
        previousPeriodTransactions: previousTxs,
      );
      final insights = GetFinancialInsightsUseCase(categories).call(currentTxs, periodState.dateRange);

      return AsyncValue.data(FullAnalyticsData(
        summary: summary,
        comparison: comparison,
        categoryBreakdown: breakdown,
        incomeExpenseTrend: trend,
        savingsTrend: savingsTrendPoints,
        insights: insights,
      ));
    },
    loading: () => const AsyncValue.loading(),
    error: (e, st) => AsyncValue.error(e, st),
  );
});

// Categories Controller
final categoryControllerProvider = StateNotifierProvider<CategoryController, AsyncValue<List<CategoryEntity>>>((ref) {
  final getCategories = ref.watch(getCategoriesUseCaseProvider);
  return CategoryController(getCategories);
});

class CategoryController extends StateNotifier<AsyncValue<List<CategoryEntity>>> {
  final GetCategoriesUseCase _getCategories;
  CategoryController(this._getCategories) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _getCategories();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

// Accounts Controller
final accountControllerProvider = StateNotifierProvider<AccountController, AsyncValue<List<AccountEntity>>>((ref) {
  final getAccounts = ref.watch(getAccountsUseCaseProvider);
  final repo = ref.watch(accountRepositoryProvider);
  return AccountController(getAccounts, repo);
});

class AccountController extends StateNotifier<AsyncValue<List<AccountEntity>>> {
  final GetAccountsUseCase _getAccounts;
  final AccountRepository _repo;

  AccountController(this._getAccounts, this._repo) : super(const AsyncValue.loading()) {
    load();
  }

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final list = await _getAccounts();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(AccountEntity acc) async {
    try {
      await _repo.addAccount(acc);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateAccount(AccountEntity acc) async {
    try {
      await _repo.updateAccount(acc);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repo.deleteAccount(id);
      await load();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
