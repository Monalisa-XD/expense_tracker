import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/entities.dart';
import '../../../core/utils/currency_utils.dart';
import '../../../core/utils/date_utils.dart';
import '../../../core/widgets/quick_action_btn.dart';
import '../../../core/widgets/transaction_tile.dart';
import '../../repositories/controllers.dart';
import '../../repositories/recurring_controller.dart';
import '../../repositories/account_controller.dart';
import '../../transactions/presentation/screens/add_expense_screen.dart';
import '../../transactions/presentation/screens/add_income_screen.dart';

class HomeTab extends ConsumerWidget {
  final ValueChanged<int>? onNavigateTab;

  const HomeTab({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(transactionControllerProvider);
    final catsState = ref.watch(categoryControllerProvider);
    final budgetState = ref.watch(budgetStateProvider);
    final recurringState = ref.watch(recurringControllerProvider);

    // Run sync when home tab is first loaded
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recurringControllerProvider.notifier).syncRecurringTransactions();
    });

    return Scaffold(
      body: SafeArea(
        child: txState.when(
          data: (transactions) {
            final categories = catsState.value ?? [];
            final warnings = budgetState.warnings;

            double incomeTotal = 0;
            double expenseTotal = 0;

            for (var tx in transactions) {
              if (tx.type == TransactionType.income) {
                incomeTotal += tx.amount;
              } else {
                expenseTotal += tx.amount;
              }
            }

            final accountState = ref.watch(accountStateNotifierProvider);
            final balance = accountState.isLoading ? 0.0 : accountState.netWorth;
            final savingsRate = incomeTotal > 0 ? ((incomeTotal - expenseTotal) / incomeTotal * 100) : 0.0;
            final recentList = transactions.take(4).toList();

            // Monthly Spending Chart Data
            final monthlySpent = _calculateMonthlyData(transactions);

            return SingleChildScrollView(
              padding: const EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0, bottom: kBottomNavigationBarHeight + 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Good morning, Monalisa 👋', style: TextStyle(fontSize: 16, color: Colors.grey)),
                  const SizedBox(height: 4),
                  const Text('Your financial overview', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  
                  // Main Overview Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Theme.of(context).colorScheme.primary, Theme.of(context).colorScheme.primaryContainer],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text(
                          CurrencyUtils.format(balance),
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.arrow_downward, color: Colors.greenAccent, size: 16),
                                    SizedBox(width: 4),
                                    Text('Income', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyUtils.format(incomeTotal),
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Row(
                                  children: [
                                    Icon(Icons.arrow_upward, color: Colors.redAccent, size: 16),
                                    SizedBox(width: 4),
                                    Text('Expenses', style: TextStyle(color: Colors.white70, fontSize: 12)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  CurrencyUtils.format(expenseTotal),
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Quick Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      QuickActionBtn(
                        icon: Icons.remove,
                        label: 'Expense',
                        color: Colors.red,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
                          );
                        },
                      ),
                      QuickActionBtn(
                        icon: Icons.add,
                        label: 'Income',
                        color: Colors.green,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const AddIncomeScreen()),
                          );
                        },
                      ),
                      QuickActionBtn(
                        icon: Icons.swap_horiz,
                        label: 'Transfer',
                        color: Colors.blue,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Mock Transfer Triggered')),
                          );
                        },
                      ),
                      QuickActionBtn(
                        icon: Icons.track_changes,
                        label: 'Budget',
                        color: Colors.purple,
                        onTap: () {
                          if (onNavigateTab != null) onNavigateTab!(4);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Savings & Comparisons Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildMetricCard(context, 'Savings Rate', '${savingsRate.toStringAsFixed(1)}%', Icons.savings),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildMetricCard(context, 'Vs Last Month', '+4.2%', Icons.compare_arrows),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Budget Alerts
                  _buildBudgetWarnings(warnings, categories),
                  const SizedBox(height: 20),

                  // Compact Upcoming Payments Section on Home
                  if (recurringState.upcomingPayments.isNotEmpty) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Upcoming Payments', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        TextButton(
                          onPressed: () {
                            if (onNavigateTab != null) onNavigateTab!(2);
                          },
                          child: const Text('View All →'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: recurringState.upcomingPayments.take(2).length,
                      itemBuilder: (context, idx) {
                        final item = recurringState.upcomingPayments[idx];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.autorenew)),
                            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('Next Payment: ${DateUtilsHelper.formatShortDate(item.nextOccurrenceDate)}'),
                            trailing: Text(
                              '${item.type == TransactionType.expense ? "-" : "+"}${CurrencyUtils.format(item.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: item.type == TransactionType.expense ? Colors.red : Colors.green,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Monthly Spending Graph Card
                  const Text('Monthly Spending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 120,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 22,
                              getTitlesWidget: (value, meta) {
                                switch (value.toInt()) {
                                  case 0: return const Padding(padding: EdgeInsets.only(top: 4.0), child: Text('W1', style: TextStyle(fontSize: 10)));
                                  case 1: return const Padding(padding: EdgeInsets.only(top: 4.0), child: Text('W2', style: TextStyle(fontSize: 10)));
                                  case 2: return const Padding(padding: EdgeInsets.only(top: 4.0), child: Text('W3', style: TextStyle(fontSize: 10)));
                                  case 3: return const Padding(padding: EdgeInsets.only(top: 4.0), child: Text('W4', style: TextStyle(fontSize: 10)));
                                  default: return const Text('');
                                }
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 42,
                              getTitlesWidget: (value, meta) {
                                if (value == 0) return const Text('₹0', style: TextStyle(fontSize: 10));
                                if (value >= 1000) return Text('₹${(value / 1000).toStringAsFixed(0)}K', style: const TextStyle(fontSize: 10));
                                return Text('₹${value.toStringAsFixed(0)}', style: const TextStyle(fontSize: 10));
                              },
                            ),
                          ),
                        ),
                        barGroups: monthlySpent
                            .asMap()
                            .entries
                            .map((e) => BarChartGroupData(
                                  x: e.key,
                                  barRods: [BarChartRodData(toY: e.value, color: Theme.of(context).primaryColor, width: 22, borderRadius: BorderRadius.circular(4))],
                                ))
                            .toList(),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Recent Transactions Header with View All
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      TextButton(
                        onPressed: () {
                          if (onNavigateTab != null) onNavigateTab!(1);
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (recentList.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('No transactions registered yet.')),
                    )
                  else
                    ...recentList.map((tx) {
                      final cat = categories.firstWhere((c) => c.id == tx.categoryId,
                          orElse: () => CategoryEntity(
                              id: 'other',
                              name: 'Other',
                              icon: 'widgets',
                              colorValue: 0xFF64748B,
                              type: tx.type));
                      return TransactionTile(transaction: tx, category: cat);
                    }),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String label, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, color: Theme.of(context).primaryColor),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBudgetWarnings(List<BudgetEntity> warnings, List<CategoryEntity> categories) {
    if (warnings.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Budget Warnings', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.red)),
        const SizedBox(height: 8),
        ...warnings.map((b) {
          final cat = categories.firstWhere((c) => c.id == b.categoryId,
              orElse: () => CategoryEntity(id: '?', name: 'Unknown', icon: 'widgets', colorValue: 0xFF000000, type: TransactionType.expense));
          final percent = b.limitAmount == 0.0 ? 0.0 : (b.spentAmount / b.limitAmount) * 100.0;
          final isExceeded = b.spentAmount > b.limitAmount;
          final diff = (b.limitAmount - b.spentAmount).abs();

          return Card(
            color: const Color(0xFFFEE2E2), // solid pinkish-red background
            child: ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: Text('${cat.name} — ${percent.toStringAsFixed(0)}% used', style: const TextStyle(color: Color(0xFF991B1B), fontWeight: FontWeight.bold)),
              subtitle: Text(
                isExceeded 
                  ? '${CurrencyUtils.format(diff)} over budget' 
                  : 'Spent ${percent.toStringAsFixed(0)}% of your ${CurrencyUtils.format(b.limitAmount)} limit',
                style: const TextStyle(color: Color(0xFF7F1D1D)),
              ),
            ),
          );
        }),
      ],
    );
  }

  List<double> _calculateMonthlyData(List<TransactionEntity> transactions) {
    // Calculate spending per week (W1, W2, W3, W4) for the last 28 days
    final Map<int, double> sums = {0: 0, 1: 0, 2: 0, 3: 0};
    for (var tx in transactions) {
      if (tx.type == TransactionType.expense) {
        final diff = DateTime.now().difference(tx.date).inDays;
        if (diff >= 0 && diff < 28) {
          final weekIdx = 3 - (diff / 7).floor(); // 0 represents oldest week (W1), 3 is current week (W4)
          sums[weekIdx] = (sums[weekIdx] ?? 0) + tx.amount;
        }
      }
    }
    return sums.values.toList();
  }
}
