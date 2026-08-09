import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../repositories/controllers.dart';
import '../../../repositories/budget_usecases.dart';
import 'add_budget_screen.dart';
import 'budget_details_screen.dart';

class BudgetsTab extends ConsumerWidget {
  const BudgetsTab({super.key});

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'receipt_long': return Icons.receipt_long;
      case 'sports_esports': return Icons.sports_esports;
      case 'medical_services': return Icons.medical_services;
      case 'school': return Icons.school;
      case 'flight': return Icons.flight;
      case 'local_grocery_store': return Icons.local_grocery_store;
      case 'payments': return Icons.payments;
      case 'work': return Icons.work;
      case 'monetization_on': return Icons.monetization_on;
      default: return Icons.widgets;
    }
  }

  String _getHistoryStatus(BudgetEntity b) {
    if (b.spentAmount > b.limitAmount) return 'Exceeded';
    if (b.spentAmount == b.limitAmount) return 'Completed';
    return 'Under Budget';
  }

  Color _getHistoryStatusColor(String status) {
    switch (status) {
      case 'Exceeded': return Colors.red;
      case 'Completed': return Colors.blue;
      default: return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(budgetStateProvider);
    final categoriesState = ref.watch(categoryControllerProvider);
    final categories = categoriesState.value ?? [];

    if (state.isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Budgets'),
        ),
        body: _buildSkeletonLoader(),
      );
    }

    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Budgets'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Unable to load budgets.',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  state.error!,
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    ref.invalidate(budgetControllerProvider);
                    ref.invalidate(transactionControllerProvider);
                    ref.invalidate(categoryControllerProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final activeList = state.activeBudgets;
    final historyList = state.expiredBudgets;
    final isOver = state.totalSpent > state.totalBudget;
    final diff = (state.totalBudget - state.totalSpent).abs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Budgets'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
              );
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(budgetControllerProvider);
          ref.invalidate(transactionControllerProvider);
          ref.invalidate(categoryControllerProvider);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Overall Summary Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'TOTAL BUDGET SUMMARY',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.grey, letterSpacing: 1.1),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSummaryMetric('TOTAL BUDGET', CurrencyUtils.format(state.totalBudget)),
                          _buildSummaryMetric('SPENT', CurrencyUtils.format(state.totalSpent)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSummaryMetric(
                            isOver ? 'OVER LIMIT' : 'REMAINING',
                            CurrencyUtils.format(diff),
                            color: isOver ? Colors.red : Colors.green,
                          ),
                          _buildSummaryMetric('USED', '${state.usagePercentage.toStringAsFixed(1)}%'),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: LinearProgressIndicator(
                          value: state.totalBudget == 0 ? 0 : (state.totalSpent / state.totalBudget).clamp(0.0, 1.0),
                          minHeight: 10,
                          backgroundColor: Colors.grey[800],
                          valueColor: AlwaysStoppedAnimation<Color>(isOver ? Colors.red : Theme.of(context).primaryColor),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Active Budgets Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Active Budgets', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (activeList.isNotEmpty)
                    Text(
                      '${activeList.length} Active',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              if (activeList.isEmpty)
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.grey[850]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
                    child: Column(
                      children: [
                        const Icon(Icons.track_changes, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'No budgets yet',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Create spending limits for your categories and stay on track.',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const AddBudgetScreen()),
                            );
                          },
                          child: const Text('Create Budget'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeList.length,
                  itemBuilder: (context, idx) {
                    final b = activeList[idx];
                    final cat = categories.firstWhere(
                      (c) => c.id == b.categoryId,
                      orElse: () => CategoryEntity(id: '?', name: 'Other', icon: 'widgets', colorValue: 0xFF64748B, type: TransactionType.expense),
                    );
                    final percent = b.limitAmount == 0.0 ? 0.0 : (b.spentAmount / b.limitAmount);
                    final isOverBudget = b.spentAmount > b.limitAmount;
                    final diffAmount = (b.limitAmount - b.spentAmount).abs();
                    final status = BudgetStatusHelper.getStatus(b.spentAmount, b.limitAmount);
                    final statusColor = BudgetStatusHelper.getStatusColor(b.spentAmount, b.limitAmount);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BudgetDetailsScreen(budget: b, category: cat),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Color(cat.colorValue).withOpacity(0.2),
                                    child: Icon(_getIconData(cat.icon), color: Color(cat.colorValue)),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(cat.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        Text(
                                          '${DateUtilsHelper.formatShortDate(b.startDate)} - ${DateUtilsHelper.formatShortDate(b.endDate)}',
                                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: statusColor.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      status.toUpperCase(),
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '${CurrencyUtils.format(b.spentAmount)} / ${CurrencyUtils.format(b.limitAmount)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                  ),
                                  Text(
                                    '${(percent * 100).toStringAsFixed(1)}% used',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: percent.clamp(0.0, 1.0),
                                  color: statusColor,
                                  backgroundColor: Colors.grey[850],
                                  minHeight: 6,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    isOverBudget
                                        ? '${CurrencyUtils.format(diffAmount)} over budget'
                                        : '${CurrencyUtils.format(diffAmount)} remaining',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isOverBudget ? Colors.red : Colors.green,
                                    ),
                                  ),
                                  const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              const SizedBox(height: 24),

              // Budget Insights
              if (activeList.isNotEmpty) ...[
                const Text('Budget Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                _buildBudgetInsightsCard(state.insights),
                const SizedBox(height: 24),
              ],

              // Budget History
              const Text('Budget History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (historyList.isEmpty)
                const Card(
                  elevation: 0,
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: Center(
                      child: Text('No expired budgets.', style: TextStyle(color: Colors.grey)),
                    ),
                  ),
                )
              else
                Column(
                  children: historyList.map((b) {
                    final cat = categories.firstWhere(
                      (c) => c.id == b.categoryId,
                      orElse: () => CategoryEntity(id: '?', name: 'Other', icon: 'widgets', colorValue: 0xFF64748B, type: TransactionType.expense),
                    );
                    final percent = b.limitAmount == 0.0 ? 0.0 : (b.spentAmount / b.limitAmount);
                    final historyStatus = _getHistoryStatus(b);
                    final statusColor = _getHistoryStatusColor(historyStatus);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(cat.colorValue).withOpacity(0.1),
                          child: Icon(_getIconData(cat.icon), color: Color(cat.colorValue), size: 20),
                        ),
                        title: Text('${cat.name} Budget', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        subtitle: Text(
                          '${DateUtilsHelper.formatShortDate(b.startDate)} - ${DateUtilsHelper.formatShortDate(b.endDate)}',
                          style: const TextStyle(fontSize: 11, color: Colors.grey),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '${(percent * 100).toStringAsFixed(0)}% used',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              historyStatus,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryMetric(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: color),
        ),
      ],
    );
  }

  Widget _buildBudgetInsightsCard(BudgetInsightsData insights) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInsightRow('Best Managed Budget', insights.bestManagedCategory, '${insights.bestManagedPercentage.toStringAsFixed(0)}% used'),
            const Divider(height: 20),
            _buildInsightRow('Highest Budget Usage', insights.highestSpendingCategory, '${insights.highestSpendingPercentage.toStringAsFixed(0)}% used'),
            const Divider(height: 20),
            _buildInsightRow('Total Over Budget', 'Spent Limit Exceeded', CurrencyUtils.format(insights.totalOverBudget)),
            const Divider(height: 20),
            _buildInsightRow('Budgets Within Limit', 'Healthy Limits', insights.budgetsWithinLimit),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightRow(String title, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ],
    );
  }

  Widget _buildSkeletonLoader() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Summary card skeleton
          Container(
            height: 160,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(24),
            ),
          ),
          const SizedBox(height: 24),
          // Active budgets header skeleton
          Container(
            height: 20,
            width: 150,
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(height: 12),
          // Cards skeletons
          ...List.generate(3, (idx) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              height: 110,
              decoration: BoxDecoration(
                color: Colors.grey[950],
                borderRadius: BorderRadius.circular(16),
              ),
            );
          }),
        ],
      ),
    );
  }
}
