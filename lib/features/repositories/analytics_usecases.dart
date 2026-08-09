import 'package:flutter/material.dart';
import '../../core/theme/entities.dart';

class FinancialSummary {
  final double totalIncome;
  final double totalExpenses;
  final double savings;
  final double savingsRate;

  FinancialSummary({
    required this.totalIncome,
    required this.totalExpenses,
    required this.savings,
    required this.savingsRate,
  });
}

class CategoryContribution {
  final CategoryEntity category;
  final double amount;
  final double percentage;

  CategoryContribution({
    required this.category,
    required this.amount,
    required this.percentage,
  });
}

class TrendPoint {
  final String label;
  final double value;

  TrendPoint({required this.label, required this.value});
}

class FinancialInsights {
  final CategoryEntity? highestSpendingCategory;
  final double highestSpendingCategoryAmount;
  final TransactionEntity? largestExpense;
  final double averageDailySpending;
  final CategoryEntity? mostFrequentCategory;
  final int mostFrequentCategoryCount;
  final String bestSpendingDay;

  FinancialInsights({
    this.highestSpendingCategory,
    this.highestSpendingCategoryAmount = 0.0,
    this.largestExpense,
    this.averageDailySpending = 0.0,
    this.mostFrequentCategory,
    this.mostFrequentCategoryCount = 0,
    this.bestSpendingDay = 'N/A',
  });
}

class PeriodComparison {
  final double incomeChangePercentage;
  final double expenseChangePercentage;
  final double savingsChangePercentage;

  PeriodComparison({
    required this.incomeChangePercentage,
    required this.expenseChangePercentage,
    required this.savingsChangePercentage,
  });
}

class GetFinancialSummaryUseCase {
  FinancialSummary call(List<TransactionEntity> transactions) {
    double income = 0;
    double expenses = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        expenses += tx.amount;
      }
    }

    final savings = income - expenses;
    final rate = income == 0 ? 0.0 : (savings / income) * 100;

    return FinancialSummary(
      totalIncome: income,
      totalExpenses: expenses,
      savings: savings,
      savingsRate: rate.clamp(0.0, 100.0),
    );
  }
}

class GetCategoryBreakdownUseCase {
  final List<CategoryEntity> categories;

  GetCategoryBreakdownUseCase(this.categories);

  List<CategoryContribution> call(List<TransactionEntity> transactions) {
    final Map<String, double> sums = {};
    double totalExpenses = 0.0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        sums[tx.categoryId] = (sums[tx.categoryId] ?? 0.0) + tx.amount;
        totalExpenses += tx.amount;
      }
    }

    final List<CategoryContribution> list = [];
    sums.forEach((catId, amount) {
      final cat = categories.firstWhere((c) => c.id == catId,
          orElse: () => CategoryEntity(
              id: catId,
              name: 'Other',
              icon: 'widgets',
              colorValue: 0xFF64748B,
              type: TransactionType.expense));
      final percentage = totalExpenses == 0 ? 0.0 : (amount / totalExpenses) * 100;
      list.add(CategoryContribution(category: cat, amount: amount, percentage: percentage));
    });

    list.sort((a, b) => b.amount.compareTo(a.amount));
    return list;
  }
}

class GetIncomeExpenseTrendUseCase {
  List<TrendPoint> getTrend(List<TransactionEntity> transactions, String period, DateTimeRange range) {
    // Generate trend points representing bars or nodes
    if (period == 'Week') {
      final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final Map<int, double> expenseMap = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
      for (var tx in transactions) {
        if (tx.type == TransactionType.expense) {
          expenseMap[tx.date.weekday] = (expenseMap[tx.date.weekday] ?? 0) + tx.amount;
        }
      }
      return List.generate(7, (idx) => TrendPoint(label: days[idx], value: expenseMap[idx + 1] ?? 0.0));
    } else if (period == 'Month') {
      final Map<int, double> expenseMap = {0: 0, 1: 0, 2: 0, 3: 0};
      for (var tx in transactions) {
        if (tx.type == TransactionType.expense) {
          final diff = DateTime.now().difference(tx.date).inDays;
          if (diff >= 0 && diff < 28) {
            final weekIdx = 3 - (diff / 7).floor();
            if (weekIdx >= 0 && weekIdx < 4) {
              expenseMap[weekIdx] = (expenseMap[weekIdx] ?? 0) + tx.amount;
            }
          }
        }
      }
      return [
        TrendPoint(label: 'W1', value: expenseMap[0] ?? 0.0),
        TrendPoint(label: 'W2', value: expenseMap[1] ?? 0.0),
        TrendPoint(label: 'W3', value: expenseMap[2] ?? 0.0),
        TrendPoint(label: 'W4', value: expenseMap[3] ?? 0.0),
      ];
    } else {
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final Map<int, double> expenseMap = {};
      for (var tx in transactions) {
        if (tx.type == TransactionType.expense) {
          expenseMap[tx.date.month] = (expenseMap[tx.date.month] ?? 0) + tx.amount;
        }
      }
      return List.generate(12, (idx) => TrendPoint(label: months[idx], value: expenseMap[idx + 1] ?? 0.0));
    }
  }
}

class GetPeriodComparisonUseCase {
  PeriodComparison call({
    required List<TransactionEntity> currentPeriodTransactions,
    required List<TransactionEntity> previousPeriodTransactions,
  }) {
    double curInc = 0, curExp = 0;
    for (var tx in currentPeriodTransactions) {
      if (tx.type == TransactionType.income) {
        curInc += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        curExp += tx.amount;
      }
    }
    double prevInc = 0, prevExp = 0;
    for (var tx in previousPeriodTransactions) {
      if (tx.type == TransactionType.income) {
        prevInc += tx.amount;
      } else if (tx.type == TransactionType.expense) {
        prevExp += tx.amount;
      }
    }

    final curSav = curInc - curExp;
    final prevSav = prevInc - prevExp;

    double incPct = prevInc == 0 ? 0.0 : ((curInc - prevInc) / prevInc) * 100;
    double expPct = prevExp == 0 ? 0.0 : ((curExp - prevExp) / prevExp) * 100;
    double savPct = prevSav == 0 ? 0.0 : ((curSav - prevSav) / prevSav).abs() * 100; // handle negative base securely

    return PeriodComparison(
      incomeChangePercentage: incPct,
      expenseChangePercentage: expPct,
      savingsChangePercentage: savPct,
    );
  }
}

class GetFinancialInsightsUseCase {
  final List<CategoryEntity> categories;

  GetFinancialInsightsUseCase(this.categories);

  FinancialInsights call(List<TransactionEntity> transactions, DateTimeRange range) {
    if (transactions.isEmpty) return FinancialInsights();

    final expenses = transactions.where((tx) => tx.type == TransactionType.expense).toList();
    if (expenses.isEmpty) return FinancialInsights();

    // Highest category spending
    final Map<String, double> catSpent = {};
    final Map<String, int> catCounts = {};
    for (var tx in expenses) {
      catSpent[tx.categoryId] = (catSpent[tx.categoryId] ?? 0.0) + tx.amount;
      catCounts[tx.categoryId] = (catCounts[tx.categoryId] ?? 0) + 1;
    }

    String? maxCatId;
    double maxSpent = 0.0;
    catSpent.forEach((catId, val) {
      if (val > maxSpent) {
        maxSpent = val;
        maxCatId = catId;
      }
    });

    final highestCat = maxCatId == null
        ? null
        : categories.firstWhere((c) => c.id == maxCatId,
            orElse: () => CategoryEntity(id: maxCatId!, name: 'Other', icon: 'widgets', colorValue: 0xFF64748B, type: TransactionType.expense));

    // Most frequent category
    String? freqCatId;
    int maxCount = 0;
    catCounts.forEach((catId, count) {
      if (count > maxCount) {
        maxCount = count;
        freqCatId = catId;
      }
    });

    final freqCat = freqCatId == null
        ? null
        : categories.firstWhere((c) => c.id == freqCatId,
            orElse: () => CategoryEntity(id: freqCatId!, name: 'Other', icon: 'widgets', colorValue: 0xFF64748B, type: TransactionType.expense));

    // Largest individual expense
    TransactionEntity? largestExp;
    for (var tx in expenses) {
      if (largestExp == null || tx.amount > largestExp.amount) {
        largestExp = tx;
      }
    }

    // Average daily spending
    final days = range.duration.inDays == 0 ? 1 : range.duration.inDays;
    double totalExpSum = expenses.fold(0.0, (sum, tx) => sum + tx.amount);
    final avgDaily = totalExpSum / days;

    // Best spending day (day with least spending)
    final Map<int, double> daySpending = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0, 7: 0};
    for (var tx in expenses) {
      daySpending[tx.date.weekday] = (daySpending[tx.date.weekday] ?? 0.0) + tx.amount;
    }
    int bestDayIdx = 1;
    double minSpentDayVal = double.infinity;
    daySpending.forEach((day, amt) {
      if (amt < minSpentDayVal) {
        minSpentDayVal = amt;
        bestDayIdx = day;
      }
    });

    final weekdayNames = {
      1: 'Monday',
      2: 'Tuesday',
      3: 'Wednesday',
      4: 'Thursday',
      5: 'Friday',
      6: 'Saturday',
      7: 'Sunday'
    };

    return FinancialInsights(
      highestSpendingCategory: highestCat,
      highestSpendingCategoryAmount: maxSpent,
      largestExpense: largestExp,
      averageDailySpending: avgDaily,
      mostFrequentCategory: freqCat,
      mostFrequentCategoryCount: maxCount,
      bestSpendingDay: weekdayNames[bestDayIdx] ?? 'N/A',
    );
  }
}
