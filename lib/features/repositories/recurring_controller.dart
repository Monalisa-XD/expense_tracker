import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/entities.dart';
import '../../core/utils/recurrence_engine.dart';
import 'providers.dart';
import 'controllers.dart';

class RecurringState {
  final List<RecurringTransactionEntity> recurringTransactions;
  final List<RecurringTransactionEntity> activeRecurring;
  final List<RecurringTransactionEntity> pausedRecurring;
  final List<RecurringTransactionEntity> completedRecurring;
  final List<RecurringTransactionEntity> upcomingPayments;
  final double monthlyRecurringExpense;
  final double monthlyRecurringIncome;
  final bool isLoading;
  final String? error;

  RecurringState({
    required this.recurringTransactions,
    required this.activeRecurring,
    required this.pausedRecurring,
    required this.completedRecurring,
    required this.upcomingPayments,
    required this.monthlyRecurringExpense,
    required this.monthlyRecurringIncome,
    required this.isLoading,
    this.error,
  });

  RecurringState copyWith({
    List<RecurringTransactionEntity>? recurringTransactions,
    List<RecurringTransactionEntity>? activeRecurring,
    List<RecurringTransactionEntity>? pausedRecurring,
    List<RecurringTransactionEntity>? completedRecurring,
    List<RecurringTransactionEntity>? upcomingPayments,
    double? monthlyRecurringExpense,
    double? monthlyRecurringIncome,
    bool? isLoading,
    String? Function()? error,
  }) {
    return RecurringState(
      recurringTransactions: recurringTransactions ?? this.recurringTransactions,
      activeRecurring: activeRecurring ?? this.activeRecurring,
      pausedRecurring: pausedRecurring ?? this.pausedRecurring,
      completedRecurring: completedRecurring ?? this.completedRecurring,
      upcomingPayments: upcomingPayments ?? this.upcomingPayments,
      monthlyRecurringExpense: monthlyRecurringExpense ?? this.monthlyRecurringExpense,
      monthlyRecurringIncome: monthlyRecurringIncome ?? this.monthlyRecurringIncome,
      isLoading: isLoading ?? this.isLoading,
      error: error != null ? error() : this.error,
    );
  }
}

final recurringControllerProvider = StateNotifierProvider<RecurringController, RecurringState>((ref) {
  return RecurringController(ref);
});

class RecurringController extends StateNotifier<RecurringState> {
  final Ref _ref;

  RecurringController(this._ref)
      : super(RecurringState(
          recurringTransactions: [],
          activeRecurring: [],
          pausedRecurring: [],
          completedRecurring: [],
          upcomingPayments: [],
          monthlyRecurringExpense: 0,
          monthlyRecurringIncome: 0,
          isLoading: true,
        )) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true, error: () => null);
    try {
      final getRec = _ref.read(getRecurringTransactionsUseCaseProvider);
      final list = await getRec();
      _computeState(list);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => 'Unable to load recurring transactions.');
    }
  }

  void _computeState(List<RecurringTransactionEntity> list) {
    final active = list.where((e) => e.isActive && !e.isPaused).toList();
    final paused = list.where((e) => e.isActive && e.isPaused).toList();
    final completed = list.where((e) => !e.isActive).toList();

    double expenseSum = 0;
    double incomeSum = 0;

    for (var r in active) {
      double factor = 1.0;
      switch (r.frequency) {
        case RecurringFrequency.daily:
          factor = 30.0;
          break;
        case RecurringFrequency.weekly:
          factor = 4.33;
          break;
        case RecurringFrequency.monthly:
          factor = 1.0;
          break;
        case RecurringFrequency.yearly:
          factor = 1.0 / 12.0;
          break;
      }
      if (r.type == TransactionType.expense) {
        expenseSum += r.amount * factor;
      } else {
        incomeSum += r.amount * factor;
      }
    }

    final upcoming = List<RecurringTransactionEntity>.from(active);
    upcoming.sort((a, b) => a.nextOccurrenceDate.compareTo(b.nextOccurrenceDate));

    state = RecurringState(
      recurringTransactions: list,
      activeRecurring: active,
      pausedRecurring: paused,
      completedRecurring: completed,
      upcomingPayments: upcoming,
      monthlyRecurringExpense: expenseSum,
      monthlyRecurringIncome: incomeSum,
      isLoading: false,
    );
  }

  Future<void> addRecurring(RecurringTransactionEntity rec) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(createRecurringTransactionUseCaseProvider)(rec);
      await load();
      await syncRecurringTransactions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> updateRecurring(RecurringTransactionEntity rec) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(updateRecurringTransactionUseCaseProvider)(rec);
      await load();
      await syncRecurringTransactions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> deleteRecurring(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(deleteRecurringTransactionUseCaseProvider)(id);
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> pauseRecurring(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(pauseRecurringTransactionUseCaseProvider)(id);
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> resumeRecurring(String id) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(resumeRecurringTransactionUseCaseProvider)(id);
      await load();
      await syncRecurringTransactions();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> skipNext(String id, DateTime date) async {
    try {
      state = state.copyWith(isLoading: true);
      await _ref.read(skipNextOccurrenceUseCaseProvider)(id, date);
      
      final getRec = _ref.read(getRecurringTransactionsUseCaseProvider);
      final list = await getRec();
      final idx = list.indexWhere((e) => e.id == id);
      if (idx != -1) {
        final rec = list[idx];
        final next = RecurrenceEngine.calculateNextOccurrence(rec.nextOccurrenceDate, rec.frequency);
        await _ref.read(updateRecurringTransactionUseCaseProvider)(rec.copyWith(
          nextOccurrenceDate: next,
        ));
      }
      await load();
    } catch (e) {
      state = state.copyWith(isLoading: false, error: () => e.toString());
    }
  }

  Future<void> syncRecurringTransactions() async {
    try {
      final getRec = _ref.read(getRecurringTransactionsUseCaseProvider);
      final list = await getRec();
      final today = DateTime.now();
      bool changed = false;

      final existingTxList = _ref.read(transactionControllerProvider).value ?? [];

      for (var rec in list) {
        if (!rec.isActive || rec.isPaused) continue;

        final dueDates = RecurrenceEngine.generateDueDates(
          startDate: rec.startDate,
          endDate: rec.endDate,
          frequency: rec.frequency,
          lastGenerated: rec.lastGeneratedDate ?? rec.startDate.subtract(const Duration(minutes: 1)),
          today: today,
          skippedOccurrences: rec.skippedOccurrences,
        );

        if (dueDates.isNotEmpty) {
          changed = true;
          DateTime lastGen = rec.lastGeneratedDate ?? rec.startDate;
          
          for (var date in dueDates) {
            final dateStr = date.toIso8601String().split('T')[0];
            final exists = existingTxList.any((t) =>
                t.recurringTransactionId == rec.id &&
                t.occurrenceDate?.toIso8601String().split('T')[0] == dateStr);

            if (!exists && rec.autoGenerate) {
              final newTx = TransactionEntity(
                id: 'gen_tx_${DateTime.now().microsecondsSinceEpoch}_${rec.id.substring(0, 4)}',
                amount: rec.amount,
                type: rec.type,
                categoryId: rec.categoryId,
                accountId: rec.accountId,
                title: rec.title,
                description: 'Generated occurrence on $dateStr',
                date: date,
                paymentMethod: rec.paymentMethod,
                createdAt: DateTime.now(),
                recurringTransactionId: rec.id,
                occurrenceDate: date,
              );
              await _ref.read(addTransactionUseCaseProvider)(newTx);
            }
            lastGen = date;
          }

          DateTime next = RecurrenceEngine.calculateNextOccurrence(lastGen, rec.frequency);
          bool isCompleted = false;
          if (rec.endDate != null && next.isAfter(rec.endDate!)) {
            isCompleted = true;
          }

          await _ref.read(updateRecurringTransactionUseCaseProvider)(rec.copyWith(
            lastGeneratedDate: () => lastGen,
            nextOccurrenceDate: next,
            isActive: !isCompleted,
          ));
        }
      }

      if (changed) {
        await load();
        await _ref.read(transactionControllerProvider.notifier).load();
        await _ref.read(budgetControllerProvider.notifier).load();
      }
    } catch (e) {
      // Fail silently or capture error
    }
  }
}
