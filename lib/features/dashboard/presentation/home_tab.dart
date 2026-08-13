import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/network/sync_engine.dart';
import '../../../../core/network/sync_models.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/quick_action_btn.dart';
import '../../../../core/widgets/transaction_tile.dart';
import '../../repositories/controllers.dart';
import '../../repositories/recurring_controller.dart';
import '../../repositories/account_controller.dart';
import '../../repositories/budget_usecases.dart';
import '../../repositories/notification_controller.dart';
import '../../security/presentation/security_controller.dart';
import '../../transactions/presentation/screens/add_expense_screen.dart';
import '../../transactions/presentation/screens/add_income_screen.dart';
import '../../transactions/presentation/screens/add_transfer_screen.dart';
import '../../transactions/presentation/screens/notifications_screen.dart';
import '../../transactions/presentation/screens/accounts_tab.dart';
import '../../transactions/presentation/screens/recurring_tab.dart';
import '../../analytics/presentation/screens/category_spending_details_screen.dart';
import '../../../../core/theme/brand_registry.dart';
import '../../../../core/theme/category_registry.dart';
import '../../../../core/theme/merchant_registry.dart';
import '../../../../core/utils/app_icon_resolver.dart';

class HomeTab extends ConsumerWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeTab({super.key, this.onNavigateTab});

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good morning';
    } else if (hour < 17) {
      return 'Good afternoon';
    } else {
      return 'Good evening';
    }
  }

  String _getFinancialHealth(double savingsRate, List<BudgetEntity> budgets) {
    final hasExceededBudget = budgets.any((b) => b.spentAmount > b.limitAmount);
    if (hasExceededBudget || savingsRate <= 0.0) {
      return 'Needs Attention';
    } else if (savingsRate >= 20.0) {
      return 'Excellent';
    } else {
      return 'Good';
    }
  }

  Color _getFinancialHealthColor(String health) {
    switch (health) {
      case 'Excellent':
        return Colors.green;
      case 'Good':
        return Colors.teal;
      default:
        return Colors.orange;
    }
  }

  IconData _getAccountIcon(String name) {
    switch (name) {
      case 'credit_card': return Icons.credit_card;
      case 'wallet': return Icons.account_balance_wallet;
      case 'money': return Icons.money;
      case 'account_balance': return Icons.account_balance;
      default: return Icons.account_balance;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(transactionControllerProvider);
    final catsState = ref.watch(categoryControllerProvider);
    final budgetState = ref.watch(budgetStateProvider);
    final recurringState = ref.watch(recurringControllerProvider);
    final notifState = ref.watch(notificationControllerProvider);
    final accountState = ref.watch(accountStateNotifierProvider);
    final periodState = ref.watch(analyticsPeriodControllerProvider);
    final analyticsVal = ref.watch(analyticsStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${_getTimeBasedGreeting()}, Monalisa 👋', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.normal)),
        actions: [
          Consumer(
            builder: (context, ref, child) {
              final syncState = ref.watch(syncEngineProvider);
              IconData icon = Icons.cloud_done;
              Color color = Colors.green;
              String tooltip = 'Synced';

              if (syncState.status == SyncStatus.pending) {
                icon = Icons.sync;
                color = Colors.orange;
                tooltip = 'Sync pending';
              } else if (syncState.status == SyncStatus.failed) {
                icon = Icons.sync_problem;
                color = Colors.red;
                tooltip = 'Sync failed: ${syncState.error ?? 'Offline'}';
              }

              return Tooltip(
                message: tooltip,
                child: Icon(icon, color: color, size: 20),
              );
            },
          ),
          const SizedBox(width: 8),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_none),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              if (notifState.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${notifState.unreadCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Pull to refresh all states
          await ref.read(transactionControllerProvider.notifier).load();
          await ref.read(accountStateNotifierProvider.notifier).load();
          await ref.read(budgetControllerProvider.notifier).load();
          await ref.read(recurringControllerProvider.notifier).syncRecurringTransactions();
          await ref.read(notificationControllerProvider.notifier).load();
        },
        child: txState.when(
          data: (transactions) {
            if (transactions.isEmpty) {
              return _buildEmptyState(context);
            }

            final categories = catsState.value ?? [];
            final accounts = accountState.activeAccounts;

            // Calculate account derived total balance
            final totalBalance = accounts.fold<double>(0.0, (sum, acc) => sum + acc.balance);
            final netWorth = accountState.netWorth;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. Premium Total Balance & Net Worth Card
                  _buildBalanceCard(context, ref, totalBalance, netWorth, analyticsVal),
                  const SizedBox(height: 16),

                  // 2. Period Selector
                  _buildPeriodSelector(ref, periodState.period),
                  const SizedBox(height: 16),

                  // 3. Analytics summary: Income / Expense / Savings / Health
                  _buildSummarySection(context, analyticsVal, budgetState.budgets),
                  const SizedBox(height: 20),

                  // 4. Quick Actions
                  _buildQuickActions(context),
                  const SizedBox(height: 20),

                  // 5. Financial Alerts
                  _buildFinancialAlerts(context, notifState),
                  const SizedBox(height: 20),

                  // 6. Budget Overview
                  _buildBudgetOverview(context, budgetState.budgets, categories),
                  const SizedBox(height: 20),

                  // 7. Spending Breakdown
                  _buildSpendingBreakdown(context, analyticsVal),
                  const SizedBox(height: 20),

                  // 8. Upcoming Payments
                  _buildUpcomingPayments(context, recurringState.upcomingPayments, accounts),
                  const SizedBox(height: 20),

                  // 9. Accounts Overview
                  _buildAccountsOverview(context, accounts),
                  const SizedBox(height: 20),

                  // 10. Recent Transactions
                  _buildRecentTransactions(context, transactions, categories),
                ],
              ),
            );
          },
          loading: () => _buildSkeletonLoader(),
          error: (err, _) => Center(child: Text('Error loading dashboard: $err')),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_outlined, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Welcome to your finances 👋',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Start by adding your first transaction.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
                  icon: const Icon(Icons.remove),
                  label: const Text('Add Expense'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                ),
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddIncomeScreen())),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Income'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context, WidgetRef ref, double totalBalance, double netWorth, AsyncValue<FullAnalyticsData> analyticsVal) {
    final securityState = ref.watch(securityControllerProvider);
    final isPrivacyEnabled = securityState.settings.privacyModeEnabled;

    final comparisonStr = analyticsVal.maybeWhen(
      data: (data) {
        final change = data.comparison.savingsChangePercentage;
        if (change == 0) return 'No change from last period';
        final direction = change > 0 ? '↑' : '↓';
        return '$direction ${change.abs().toStringAsFixed(1)}% from last period';
      },
      orElse: () => '',
    );

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.secondary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: Icon(
                        isPrivacyEnabled ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white70,
                        size: 20,
                      ),
                      constraints: const BoxConstraints(),
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        ref.read(securityControllerProvider.notifier).saveSettings(
                          securityState.settings.copyWith(privacyModeEnabled: !isPrivacyEnabled),
                        );
                      },
                    ),
                  ],
                ),
                if (comparisonStr.isNotEmpty)
                  Text(comparisonStr, style: const TextStyle(color: Colors.white70, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              CurrencyUtils.format(totalBalance),
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Net Worth', style: TextStyle(color: Colors.white70, fontSize: 13)),
                Text(
                  CurrencyUtils.format(netWorth),
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeriodSelector(WidgetRef ref, String currentPeriod) {
    final List<String> periods = ['Week', 'Month', 'Year'];

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: periods.map((p) {
        final isSelected = p == currentPeriod;
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4.0),
          child: ChoiceChip(
            label: Text(p),
            selected: isSelected,
            onSelected: (selected) {
              if (selected) {
                ref.read(analyticsPeriodControllerProvider.notifier).setPeriod(p);
              }
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSummarySection(BuildContext context, AsyncValue<FullAnalyticsData> analyticsVal, List<BudgetEntity> budgets) {
    return analyticsVal.when(
      data: (data) {
        final summary = data.summary;
        final health = _getFinancialHealth(summary.savingsRate, budgets);

        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildMetricTile(context, 'Income', summary.totalIncome, Colors.green),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildMetricTile(context, 'Expenses', summary.totalExpenses, Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Savings', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(CurrencyUtils.format(summary.savings), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Savings Rate', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${summary.savingsRate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.teal)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Financial Health: ', style: TextStyle(color: Colors.grey, fontSize: 13)),
                Text(
                  health,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: _getFinancialHealthColor(health),
                  ),
                ),
              ],
            ),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Unable to load summary: $e')),
    );
  }

  Widget _buildMetricTile(BuildContext context, String label, double amount, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 4),
            Text(
              CurrencyUtils.format(amount),
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            QuickActionBtn(
              icon: Icons.remove,
              label: 'Expense',
              color: Colors.red,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddExpenseScreen())),
            ),
            QuickActionBtn(
              icon: Icons.add,
              label: 'Income',
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddIncomeScreen())),
            ),
            QuickActionBtn(
              icon: Icons.swap_horiz,
              label: 'Transfer',
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AddTransferScreen())),
            ),
            QuickActionBtn(
              icon: Icons.track_changes,
              label: 'Budget',
              color: Colors.purple,
              onTap: () {
                if (onNavigateTab != null) onNavigateTab!(3);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialAlerts(BuildContext context, NotificationState state) {
    final alerts = state.notifications.take(3).toList();
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Financial Alerts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              },
              child: const Text('View All →', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        ...alerts.map((n) {
          IconData icon = Icons.notifications;
          Color iconColor = Colors.teal;
          if (n.type == NotificationType.budgetWarning || n.type == NotificationType.budgetCritical || n.type == NotificationType.budgetExceeded) {
            icon = Icons.warning_amber;
            iconColor = Colors.orange;
          } else if (n.type == NotificationType.recurringPayment || n.type == NotificationType.recurringDue || n.type == NotificationType.recurringUpcoming) {
            icon = Icons.autorenew;
            iconColor = Colors.blue;
          } else if (n.type == NotificationType.lowBalance) {
            icon = Icons.account_balance;
            iconColor = Colors.red;
          }

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: Icon(icon, color: iconColor),
              title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(n.message, style: const TextStyle(fontSize: 12)),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen()));
              },
            ),
          );
        }),
      ],
    );
  }

  Widget _buildBudgetOverview(BuildContext context, List<BudgetEntity> budgets, List<CategoryEntity> categories) {
    final active = budgets.take(3).toList();
    if (active.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Budget Overview', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                if (onNavigateTab != null) onNavigateTab!(3);
              },
              child: const Text('View All →', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        ...active.map((b) {
          final cat = categories.firstWhere(
            (c) => c.id == b.categoryId,
            orElse: () => CategoryEntity(id: b.categoryId, name: b.categoryId, icon: 'widgets', colorValue: 0xFF64748B, type: TransactionType.expense),
          );

          final ratio = b.limitAmount > 0 ? (b.spentAmount / b.limitAmount) : 0.0;
          final percent = (ratio * 100).round();
          final status = BudgetStatusHelper.getStatus(b.spentAmount, b.limitAmount);
          final statusColor = BudgetStatusHelper.getStatusColor(b.spentAmount, b.limitAmount);

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        status,
                        style: TextStyle(color: statusColor, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${CurrencyUtils.format(b.spentAmount)} / ${CurrencyUtils.format(b.limitAmount)}'),
                      Text('$percent%'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: ratio.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    color: statusColor,
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildSpendingBreakdown(BuildContext context, AsyncValue<FullAnalyticsData> analyticsVal) {
    return analyticsVal.when(
      data: (data) {
        final breakdown = data.categoryBreakdown.take(4).toList();
        if (breakdown.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Spending Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...breakdown.map((cb) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Color(cb.category.colorValue).withOpacity(0.12),
                    child: Icon(AppIconResolver.resolveCategoryIcon(cb.category.id), color: Color(cb.category.colorValue)),
                  ),
                  title: Text(cb.category.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('${cb.percentage.toStringAsFixed(1)}% of spending'),
                  trailing: Text(
                    CurrencyUtils.format(cb.amount),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CategorySpendingDetailsScreen(category: cb.category)),
                    );
                  },
                ),
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (e, _) => Center(child: Text('Unable to load breakdown: $e')),
    );
  }

  Widget _buildUpcomingPayments(BuildContext context, List<RecurringTransactionEntity> upcoming, List<AccountEntity> accounts) {
    final list = upcoming.take(3).toList();
    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Upcoming Payments', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RecurringTab()));
              },
              child: const Text('View All →', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        ...list.map((item) {
          final targetAccount = accounts.firstWhere((a) => a.id == item.accountId, orElse: () => accounts.first);
          final daysLeft = item.nextOccurrenceDate.difference(DateTime.now()).inDays;
          String dueText = 'Due in $daysLeft days';
          if (daysLeft == 0) dueText = 'Due today';
          if (daysLeft == 1) dueText = 'Due tomorrow';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: AppIconResolver.resolveTransactionIcon(
                categoryId: item.categoryId,
                brandKey: BrandRegistry.merchants.firstWhere((m) => m.name.toLowerCase() == item.title.toLowerCase(), orElse: () => MerchantEntity(id: '', categoryId: '', name: '')).brandKey,
                merchantName: item.title,
                size: 36,
              ),
              title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('$dueText · ${targetAccount.name}'),
              trailing: Text(
                CurrencyUtils.format(item.amount),
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildAccountsOverview(BuildContext context, List<AccountEntity> accounts) {
    final list = accounts.take(3).toList();
    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Accounts', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const AccountsTab()));
              },
              child: const Text('View All →', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        ...list.map((acc) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(acc.color).withOpacity(0.12),
                child: Icon(_getAccountIcon(acc.icon), color: Color(acc.color)),
              ),
              title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(acc.type.name.toUpperCase()),
              trailing: Text(
                CurrencyUtils.format(acc.balance),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          );
        }),
      ],
    );
  }

  Widget _buildRecentTransactions(BuildContext context, List<TransactionEntity> transactions, List<CategoryEntity> categories) {
    final list = transactions.take(5).toList();
    if (list.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            TextButton(
              onPressed: () {
                if (onNavigateTab != null) onNavigateTab!(1);
              },
              child: const Text('View All →', style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        ...list.map((tx) {
          final cat = categories.firstWhere(
            (c) => c.id == tx.categoryId,
            orElse: () => CategoryEntity(id: 'other', name: 'Other', icon: 'widgets', colorValue: 0xFF78716C, type: tx.type),
          );

          return TransactionTile(transaction: tx, category: cat);
        }),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return const Center(child: CircularProgressIndicator());
  }
}
