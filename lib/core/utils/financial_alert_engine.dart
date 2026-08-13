import '../../core/theme/entities.dart';
import '../../core/theme/category_registry.dart';

class FinancialAlertEngine {
  /// Evaluates active budgets, checks thresholds (50%, 75%, 80%, 90%, 100%, and >100%+),
  /// and returns new alerts that haven't been created yet.
  static List<NotificationEntity> checkBudgetAlerts({
    required List<BudgetEntity> budgets,
    required List<NotificationEntity> existing,
    NotificationSettingsEntity? settings,
    bool? enabled,
  }) {
    final isEnabled = settings?.budgetAlerts ?? enabled ?? true;
    if (!isEnabled) return [];
    final List<NotificationEntity> generated = [];
    final periodStr = _getPeriodKey(DateTime.now());

    for (var b in budgets) {
      final total = b.limitAmount;
      final spent = b.spentAmount;
      if (total <= 0) continue;

      final pct = spent / total;
      final percentValue = (pct * 100).round();

      // Find matching category name
      final catDef = CategoryRegistry.categories.firstWhere(
        (c) => c.id == b.categoryId,
        orElse: () => CategoryDefinition(id: b.categoryId, name: b.categoryId, icon: '', colorValue: 0, subcategories: []),
      );

      final List<int> targetThresholds;
      if (settings != null) {
        targetThresholds = [50, 75, 80, 90, 100];
        final userTh = settings.budgetWarningThreshold.round();
        if (!targetThresholds.contains(userTh)) {
          targetThresholds.add(userTh);
          targetThresholds.sort();
        }
      } else {
        targetThresholds = [80, 90, 100];
      }

      // Check exceeded (>100%)
      if (spent > total) {
        final alertId = 'budget_${b.id}_${periodStr}_exceeded';
        final alreadyExists = existing.any((n) => n.id == alertId) || generated.any((n) => n.id == alertId);

        if (!alreadyExists) {
          generated.add(NotificationEntity(
            id: alertId,
            type: NotificationType.budgetExceeded,
            title: '⚠ ${catDef.name} budget exceeded',
            message: 'Spent: ₹${spent.toStringAsFixed(0)} / ₹${total.toStringAsFixed(0)}\nExceeded by: ₹${(spent - total).toStringAsFixed(0)}',
            createdAt: DateTime.now(),
            priority: NotificationPriority.critical,
            relatedEntityId: b.id,
            relatedEntityType: 'budget',
          ));
        }
      }

      // Check warning thresholds
      for (var th in targetThresholds) {
        if (percentValue >= th) {
          final alertId = 'budget_${b.id}_${periodStr}_$th';
          final alreadyExists = existing.any((n) => n.id == alertId) || generated.any((n) => n.id == alertId);

          if (!alreadyExists) {
            final remaining = (total - spent).clamp(0.0, double.infinity);
            final nType = th >= 100
                ? NotificationType.budgetExceeded
                : (th == 90 ? NotificationType.budgetCritical : NotificationType.budgetWarning);

            generated.add(NotificationEntity(
              id: alertId,
              type: nType,
              title: '${catDef.name} Budget',
              message: '${catDef.name} budget is $th% used.\nYou have ₹${remaining.toStringAsFixed(0)} remaining.',
              createdAt: DateTime.now(),
              priority: th >= 90 ? NotificationPriority.high : NotificationPriority.normal,
              relatedEntityId: b.id,
              relatedEntityType: 'budget',
            ));
          }
        }
      }
    }
    return generated;
  }

  /// Evaluates upcoming recurring items due in 7 days, 3 days, 1 day, or today.
  /// Also flags insufficient balance if the target account balance is below the due amount.
  static List<NotificationEntity> checkRecurringAlerts({
    required List<RecurringTransactionEntity> upcoming,
    required List<NotificationEntity> existing,
    required List<AccountEntity> accounts,
    NotificationSettingsEntity? settings,
    bool? enabled,
  }) {
    final isEnabled = settings?.recurringPaymentAlerts ?? enabled ?? true;
    if (!isEnabled) return [];
    final List<NotificationEntity> generated = [];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    for (var r in upcoming) {
      if (r.isPaused || !r.isActive) continue;

      final due = DateTime(r.nextOccurrenceDate.year, r.nextOccurrenceDate.month, r.nextOccurrenceDate.day);
      final diff = due.difference(today).inDays;
      final occStr = due.toIso8601String().split('T')[0];

      // Check if target account has insufficient balance
      final targetAccount = accounts.firstWhere((a) => a.id == r.accountId, orElse: () => accounts.first);
      if (diff >= 0 && diff <= 7 && targetAccount.balance < r.amount) {
        final alertId = 'recurring_insufficient_${r.id}_$occStr';
        final alreadyExists = existing.any((n) => n.id == alertId) || generated.any((n) => n.id == alertId);

        if (!alreadyExists) {
          generated.add(NotificationEntity(
            id: alertId,
            type: NotificationType.lowBalance,
            title: '⚠ Insufficient balance',
            message: '${r.title} payment: ₹${r.amount.toStringAsFixed(0)}\nAccount balance: ₹${targetAccount.balance.toStringAsFixed(0)}\nRequired: ₹${r.amount.toStringAsFixed(0)}',
            createdAt: DateTime.now(),
            priority: NotificationPriority.critical,
            relatedEntityId: r.id,
            relatedEntityType: 'recurring',
          ));
        }
      }

      // Check reminders at 7, 3, 1 day, and 0 (due today)
      final List<int> reminderDays = [0, 1, 3, 7];
      if (reminderDays.contains(diff)) {
        final alertId = 'recurring_reminder_${r.id}_${occStr}_$diff';
        final alreadyExists = existing.any((n) => n.id == alertId) || generated.any((n) => n.id == alertId);

        if (!alreadyExists) {
          String dueText = '';
          if (diff == 0) dueText = 'due today';
          else if (diff == 1) dueText = 'due tomorrow';
          else dueText = 'due in $diff days';

          generated.add(NotificationEntity(
            id: alertId,
            type: NotificationType.recurringPayment,
            title: '${r.title} Reminder',
            message: '${r.title} payment $dueText.\n₹${r.amount.toStringAsFixed(0)}\nAccount: ${targetAccount.name}',
            createdAt: DateTime.now(),
            priority: diff == 0 ? NotificationPriority.high : NotificationPriority.normal,
            relatedEntityId: r.id,
            relatedEntityType: 'recurring',
          ));
        }
      }
    }
    return generated;
  }

  /// Evaluates account balances against low balance threshold.
  static List<NotificationEntity> checkLowBalanceAlerts({
    required List<AccountEntity> accounts,
    required List<NotificationEntity> existing,
    NotificationSettingsEntity? settings,
    double? threshold,
    bool? enabled,
  }) {
    final isEnabled = settings?.lowBalanceAlerts ?? enabled ?? true;
    if (!isEnabled) return [];
    final List<NotificationEntity> generated = [];
    final limitThreshold = settings?.lowBalanceThreshold ?? threshold ?? 3000.0;

    for (var acc in accounts) {
      if (!acc.isActive) continue;
      if (acc.type == PaymentMethod.creditCard) continue;

      if (acc.balance < limitThreshold) {
        final accAlerts = existing.where((n) => n.relatedEntityId == acc.id && n.type == NotificationType.lowBalance).toList();
        bool shouldAlert = true;

        if (accAlerts.isNotEmpty) {
          accAlerts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          final lastAlert = accAlerts.first;
          final lastAlertBalance = (lastAlert.metadata['balance'] as num?)?.toDouble() ?? 0.0;
          if (lastAlertBalance < limitThreshold && acc.balance < limitThreshold) {
            shouldAlert = false;
          }
        }

        if (shouldAlert) {
          final alertId = 'low_balance_${acc.id}_${DateTime.now().millisecondsSinceEpoch}';
          generated.add(NotificationEntity(
            id: alertId,
            type: NotificationType.lowBalance,
            title: 'Low Balance Alert',
            message: '${acc.name} balance is below your minimum threshold.\nCurrent balance: ₹${acc.balance.toStringAsFixed(0)}',
            createdAt: DateTime.now(),
            priority: NotificationPriority.high,
            relatedEntityId: acc.id,
            relatedEntityType: 'account',
            metadata: {'balance': acc.balance},
          ));
        }
      }
    }
    return generated;
  }

  /// Evaluates transactions for large expense.
  static List<NotificationEntity> checkLargeExpenses({
    required List<TransactionEntity> transactions,
    required List<NotificationEntity> existing,
    NotificationSettingsEntity? settings,
    double? threshold,
    bool? enabled,
  }) {
    final isEnabled = settings?.largeExpenseAlerts ?? enabled ?? true;
    if (!isEnabled) return [];
    final List<NotificationEntity> generated = [];
    final limitThreshold = settings?.largeExpenseThreshold ?? threshold ?? 10000.0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.expense && tx.amount >= limitThreshold) {
        final alertId = 'large_expense_${tx.id}';
        final alreadyExists = existing.any((n) => n.id == alertId) || generated.any((n) => n.id == alertId);

        if (!alreadyExists) {
          final cat = CategoryRegistry.categories.firstWhere(
            (c) => c.id == tx.categoryId,
            orElse: () => CategoryDefinition(id: '', name: 'Other', icon: '', colorValue: 0, subcategories: []),
          );

          generated.add(NotificationEntity(
            id: alertId,
            type: NotificationType.largeExpense,
            title: 'Large Expense Detected',
            message: '${tx.title} · ${cat.name}\n₹${tx.amount.toStringAsFixed(0)}',
            createdAt: DateTime.now(),
            priority: NotificationPriority.normal,
            relatedEntityId: tx.id,
            relatedEntityType: 'transaction',
          ));
        }
      }
    }
    return generated;
  }

  /// Detect unusually high spending compared with normal category averages.
  static List<NotificationEntity> checkUnusualSpending({
    required List<TransactionEntity> transactions,
    required List<NotificationEntity> existing,
    NotificationSettingsEntity? settings,
  }) {
    final isEnabled = settings?.budgetAlerts ?? true;
    if (!isEnabled) return [];
    final List<NotificationEntity> generated = [];
    final now = DateTime.now();

    final previousTxs = transactions.where((t) => t.type == TransactionType.expense && (t.date.year < now.year || (t.date.year == now.year && t.date.month < now.month))).toList();
    final currentTxs = transactions.where((t) => t.type == TransactionType.expense && t.date.year == now.year && t.date.month == now.month).toList();

    final Map<String, Map<String, double>> categoryMonthTotal = {};
    for (var tx in previousTxs) {
      final monthKey = '${tx.date.year}_${tx.date.month}';
      categoryMonthTotal.putIfAbsent(tx.categoryId, () => {});
      categoryMonthTotal[tx.categoryId]![monthKey] = (categoryMonthTotal[tx.categoryId]![monthKey] ?? 0.0) + tx.amount;
    }

    final Map<String, double> categoryAverage = {};
    categoryMonthTotal.forEach((catId, monthsMap) {
      if (monthsMap.isNotEmpty) {
        categoryAverage[catId] = monthsMap.values.reduce((a, b) => a + b) / monthsMap.length;
      }
    });

    final Map<String, double> currentSpent = {};
    for (var tx in currentTxs) {
      currentSpent[tx.categoryId] = (currentSpent[tx.categoryId] ?? 0.0) + tx.amount;
    }

    currentSpent.forEach((catId, spent) {
      final average = categoryAverage[catId] ?? 3000.0;
      if (spent > average * 1.5 && spent > 1000) {
        final periodStr = '${now.year}_${now.month}';
        final alertId = 'unusual_spending_${catId}_$periodStr';
        final alreadyExists = existing.any((n) => n.id == alertId) || generated.any((n) => n.id == alertId);

        if (!alreadyExists) {
          final cat = CategoryRegistry.categories.firstWhere((c) => c.id == catId, orElse: () => CategoryDefinition(id: '', name: 'Other', icon: '', colorValue: 0, subcategories: []));
          generated.add(NotificationEntity(
            id: alertId,
            type: NotificationType.budgetWarning,
            title: 'Unusual Spending Detected',
            message: '${cat.name} spending is significantly higher than usual this month.\nNormal: ₹${average.toStringAsFixed(0)}/month\nCurrent: ₹${spent.toStringAsFixed(0)}',
            createdAt: DateTime.now(),
            priority: NotificationPriority.high,
          ));
        }
      }
    });

    return generated;
  }

  /// Generates monthly financial summary & savings rate insights.
  static List<NotificationEntity> checkMonthlySummaryAndInsights({
    required List<TransactionEntity> transactions,
    required List<NotificationEntity> existing,
    NotificationSettingsEntity? settings,
  }) {
    final isEnabled = settings?.monthlySummary ?? true;
    if (!isEnabled) return [];
    final List<NotificationEntity> generated = [];
    final now = DateTime.now();

    final alertId = 'monthly_summary_${now.year}_${now.month}';
    final alreadyExists = existing.any((n) => n.id == alertId);

    if (!alreadyExists) {
      final currentMonthTxs = transactions.where((tx) => tx.date.year == now.year && tx.date.month == now.month).toList();
      double income = 0;
      double expenses = 0;
      TransactionEntity? highestExpense;

      final Map<String, double> catSpent = {};

      for (var tx in currentMonthTxs) {
        if (tx.type == TransactionType.income) {
          income += tx.amount;
        } else if (tx.type == TransactionType.expense) {
          expenses += tx.amount;
          catSpent[tx.categoryId] = (catSpent[tx.categoryId] ?? 0.0) + tx.amount;
          if (highestExpense == null || tx.amount > highestExpense.amount) {
            highestExpense = tx;
          }
        }
      }

      final savings = income - expenses;
      final savingsRate = income > 0 ? (savings / income) * 100 : 0.0;

      String topCatName = 'None';
      double maxSpent = 0;
      catSpent.forEach((catId, val) {
        if (val > maxSpent) {
          maxSpent = val;
          final cat = CategoryRegistry.categories.firstWhere((c) => c.id == catId, orElse: () => CategoryDefinition(id: '', name: 'Other', icon: '', colorValue: 0, subcategories: []));
          topCatName = cat.name;
        }
      });

      final highestExpenseStr = highestExpense != null ? '${highestExpense.title} · ₹${highestExpense.amount.toStringAsFixed(0)}' : 'None';

      final msg = 'Income: ₹${income.toStringAsFixed(0)}\nExpenses: ₹${expenses.toStringAsFixed(0)}\nSavings: ₹${savings.toStringAsFixed(0)}\nSavings Rate: ${savingsRate.toStringAsFixed(1)}%\nTop Category: $topCatName\nHighest Expense: $highestExpenseStr';

      generated.add(NotificationEntity(
        id: alertId,
        type: NotificationType.monthlySummary,
        title: '${_getMonthName(now.month)} Financial Summary',
        message: msg,
        createdAt: DateTime.now(),
        priority: NotificationPriority.normal,
      ));

      final lastMonth = now.month == 1 ? 12 : now.month - 1;
      final lastYear = now.month == 1 ? now.year - 1 : now.year;
      final lastMonthTxs = transactions.where((tx) => tx.date.year == lastYear && tx.date.month == lastMonth).toList();

      double lastIncome = 0;
      double lastExpenses = 0;
      for (var tx in lastMonthTxs) {
        if (tx.type == TransactionType.income) {
          lastIncome += tx.amount;
        } else if (tx.type == TransactionType.expense) {
          lastExpenses += tx.amount;
        }
      }
      final lastSavings = lastIncome - lastExpenses;
      final lastSavingsRate = lastIncome > 0 ? (lastSavings / lastIncome) * 100 : 0.0;

      final insightAlertId = 'savings_insight_${now.year}_${now.month}';
      final insightExists = existing.any((n) => n.id == insightAlertId);

      if (!insightExists && (income > 0 || lastIncome > 0)) {
        final diff = savingsRate - lastSavingsRate;
        if (diff.abs() > 0.1) {
          String insightMsg = '';
          if (diff > 0) {
            insightMsg = 'Great job!\nYour savings rate increased by ${diff.toStringAsFixed(1)}% compared with last month.';
          } else {
            insightMsg = 'Your savings rate decreased by ${diff.abs().toStringAsFixed(1)}% this month.';
          }
          generated.add(NotificationEntity(
            id: insightAlertId,
            type: NotificationType.system,
            title: 'Savings Insight',
            message: insightMsg,
            createdAt: DateTime.now(),
            priority: NotificationPriority.normal,
          ));
        }
      }
    }

    return generated;
  }

  static String _getPeriodKey(DateTime date) {
    return '${date.year}_${date.month.toString().padLeft(2, '0')}';
  }

  static String _getMonthName(int month) {
    const names = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return names[month - 1];
  }
}
