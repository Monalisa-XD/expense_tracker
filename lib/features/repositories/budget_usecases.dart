import 'package:flutter/material.dart';
import '../../core/theme/entities.dart';
import 'usecases.dart';

class BudgetSummary {
  final double totalBudget;
  final double totalSpent;
  final double remaining;
  final double usagePercentage;

  BudgetSummary({
    required this.totalBudget,
    required this.totalSpent,
    required this.remaining,
    required this.usagePercentage,
  });
}

class BudgetInsightsData {
  final String bestManagedCategory;
  final double bestManagedPercentage;
  final String highestSpendingCategory;
  final double highestSpendingPercentage;
  final double totalOverBudget;
  final String budgetsWithinLimit;

  BudgetInsightsData({
    required this.bestManagedCategory,
    required this.bestManagedPercentage,
    required this.highestSpendingCategory,
    required this.highestSpendingPercentage,
    required this.totalOverBudget,
    required this.budgetsWithinLimit,
  });
}

class BudgetStatusHelper {
  static String getStatus(double spent, double limit) {
    if (limit == 0.0) return 'Healthy';
    final percent = (spent / limit) * 100.0;
    if (percent >= 100.0) return 'Budget Exceeded';
    if (percent >= 90.0) return 'Critical';
    if (percent >= 80.0) return 'Warning';
    if (percent >= 50.0) return 'On Track';
    return 'Healthy';
  }

  static Color getStatusColor(double spent, double limit) {
    if (limit == 0.0) return Colors.green;
    final percent = (spent / limit) * 100.0;
    if (percent >= 100.0) return Colors.red;
    if (percent >= 90.0) return Colors.redAccent;
    if (percent >= 80.0) return Colors.orange;
    if (percent >= 50.0) return Colors.blue;
    return Colors.green;
  }
}

class GetBudgetSpendingUseCase {
  bool isDateWithinRange(DateTime date, DateTime start, DateTime end) {
    final d = DateTime(date.year, date.month, date.day);
    final s = DateTime(start.year, start.month, start.day);
    final e = DateTime(end.year, end.month, end.day);
    return (d.isAfter(s) || d.isAtSameMomentAs(s)) && (d.isBefore(e) || d.isAtSameMomentAs(e));
  }

  double call({
    required String categoryId,
    required DateTime startDate,
    required DateTime endDate,
    required List<TransactionEntity> transactions,
  }) {
    double spent = 0.0;
    for (var tx in transactions) {
      if (tx.type == TransactionType.expense &&
          tx.categoryId == categoryId &&
          isDateWithinRange(tx.date, startDate, endDate)) {
        spent += tx.amount;
      }
    }
    return spent;
  }
}

class GetActiveBudgetsUseCase {
  List<BudgetEntity> call({
    required List<BudgetEntity> budgets,
    required List<TransactionEntity> transactions,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return budgets.where((b) {
      final start = DateTime(b.startDate.year, b.startDate.month, b.startDate.day);
      final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
      return (today.isAfter(start) || today.isAtSameMomentAs(start)) &&
             (today.isBefore(end) || today.isAtSameMomentAs(end));
    }).map((b) {
      final spent = GetBudgetSpendingUseCase().call(
        categoryId: b.categoryId,
        startDate: b.startDate,
        endDate: b.endDate,
        transactions: transactions,
      );
      return b.copyWith(spentAmount: spent);
    }).toList();
  }
}

class GetBudgetSummaryUseCase {
  BudgetSummary call(List<BudgetEntity> activeBudgets) {
    double totalBudget = 0.0;
    double totalSpent = 0.0;

    for (var b in activeBudgets) {
      totalBudget += b.limitAmount;
      totalSpent += b.spentAmount;
    }

    final remaining = (totalBudget - totalSpent).clamp(0.0, double.infinity);
    final usage = totalBudget == 0.0 ? 0.0 : (totalSpent / totalBudget) * 100;

    return BudgetSummary(
      totalBudget: totalBudget,
      totalSpent: totalSpent,
      remaining: remaining,
      usagePercentage: usage,
    );
  }
}

class GetBudgetHistoryUseCase {
  List<BudgetEntity> call({
    required List<BudgetEntity> budgets,
    required List<TransactionEntity> transactions,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return budgets.where((b) {
      final end = DateTime(b.endDate.year, b.endDate.month, b.endDate.day);
      return end.isBefore(today);
    }).map((b) {
      final spent = GetBudgetSpendingUseCase().call(
        categoryId: b.categoryId,
        startDate: b.startDate,
        endDate: b.endDate,
        transactions: transactions,
      );
      return b.copyWith(spentAmount: spent);
    }).toList();
  }
}

class GetBudgetInsightsUseCase {
  BudgetInsightsData call({
    required List<BudgetEntity> activeBudgets,
    required List<CategoryEntity> categories,
  }) {
    if (activeBudgets.isEmpty) {
      return BudgetInsightsData(
        bestManagedCategory: 'None',
        bestManagedPercentage: 0.0,
        highestSpendingCategory: 'None',
        highestSpendingPercentage: 0.0,
        totalOverBudget: 0.0,
        budgetsWithinLimit: '0 / 0',
      );
    }

    BudgetEntity? best;
    BudgetEntity? worst;
    double totalOver = 0.0;
    int withinLimitCount = 0;

    for (var b in activeBudgets) {
      final usage = b.limitAmount == 0.0 ? 0.0 : (b.spentAmount / b.limitAmount);
      if (b.spentAmount > b.limitAmount) {
        totalOver += (b.spentAmount - b.limitAmount);
      } else {
        withinLimitCount++;
      }

      if (best == null || usage < (best.spentAmount / best.limitAmount)) {
        best = b;
      }
      if (worst == null || usage > (worst.spentAmount / worst.limitAmount)) {
        worst = b;
      }
    }

    final bestCat = categories.firstWhere((c) => c.id == best?.categoryId,
        orElse: () => CategoryEntity(id: '?', name: 'Other', icon: 'widgets', colorValue: 0xFF000000, type: TransactionType.expense));
    final worstCat = categories.firstWhere((c) => c.id == worst?.categoryId,
        orElse: () => CategoryEntity(id: '?', name: 'Other', icon: 'widgets', colorValue: 0xFF000000, type: TransactionType.expense));

    final bestPct = best == null ? 0.0 : (best.spentAmount / best.limitAmount) * 100;
    final worstPct = worst == null ? 0.0 : (worst.spentAmount / worst.limitAmount) * 100;

    return BudgetInsightsData(
      bestManagedCategory: bestCat.name,
      bestManagedPercentage: bestPct,
      highestSpendingCategory: worstCat.name,
      highestSpendingPercentage: worstPct,
      totalOverBudget: totalOver,
      budgetsWithinLimit: '$withinLimitCount / ${activeBudgets.length}',
    );
  }
}

class GetBudgetByIdUseCase {
  final BudgetRepository _repo;
  GetBudgetByIdUseCase(this._repo);

  Future<BudgetEntity?> call(String id, List<TransactionEntity> transactions) async {
    final list = await _repo.getBudgets();
    final idx = list.indexWhere((b) => b.id == id);
    if (idx == -1) return null;
    final b = list[idx];
    final spent = GetBudgetSpendingUseCase().call(
      categoryId: b.categoryId,
      startDate: b.startDate,
      endDate: b.endDate,
      transactions: transactions,
    );
    return b.copyWith(spentAmount: spent);
  }
}

class CreateBudgetUseCase {
  final BudgetRepository _repo;
  CreateBudgetUseCase(this._repo);
  Future<void> call(BudgetEntity b) => _repo.addBudget(b);
}



class GetBudgetWarningsUseCase {
  List<BudgetEntity> call({
    required List<BudgetEntity> activeBudgets,
  }) {
    return activeBudgets.where((b) {
      if (b.limitAmount == 0.0) return false;
      final usagePercent = (b.spentAmount / b.limitAmount) * 100.0;
      return usagePercent >= b.alertPercentage;
    }).toList();
  }
}
