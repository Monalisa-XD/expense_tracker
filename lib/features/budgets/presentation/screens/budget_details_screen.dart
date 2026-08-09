import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../transactions/presentation/screens/transaction_detail_screen.dart';
import '../../../transactions/presentation/screens/add_expense_screen.dart';
import '../../../repositories/controllers.dart';
import '../../../repositories/budget_usecases.dart';
import 'add_budget_screen.dart';

class BudgetDetailsScreen extends ConsumerWidget {
  final BudgetEntity budget;
  final CategoryEntity category;

  const BudgetDetailsScreen({
    super.key,
    required this.budget,
    required this.category,
  });

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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch budgetStateProvider to get the latest updated budget with correct derived spentAmount
    final state = ref.watch(budgetStateProvider);
    final txsState = ref.watch(transactionControllerProvider);

    // Find the latest version of this budget from active/expired/all budgets
    final allBudgets = state.budgets;
    final currentBudget = allBudgets.firstWhere((b) => b.id == budget.id, orElse: () => budget);

    // Filter transactions for category within budget range
    final List<TransactionEntity> list = txsState.value ?? [];
    final budgetTxs = list.where((tx) =>
        tx.type == TransactionType.expense &&
        tx.categoryId == currentBudget.categoryId &&
        GetBudgetSpendingUseCase().isDateWithinRange(tx.date, currentBudget.startDate, currentBudget.endDate)).toList();

    // RecomputespentAmount based on matching transactions
    final double spent = GetBudgetSpendingUseCase().call(
      categoryId: currentBudget.categoryId,
      startDate: currentBudget.startDate,
      endDate: currentBudget.endDate,
      transactions: list,
    );

    final percent = currentBudget.limitAmount == 0.0 ? 0.0 : (spent / currentBudget.limitAmount) * 100;
    final isExceeded = spent > currentBudget.limitAmount;
    final diff = (currentBudget.limitAmount - spent).abs();
    final status = BudgetStatusHelper.getStatus(spent, currentBudget.limitAmount);
    final statusColor = BudgetStatusHelper.getStatusColor(spent, currentBudget.limitAmount);

    return Scaffold(
      appBar: AppBar(
        title: Text('${category.name} Budget Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddBudgetScreen(editBudget: currentBudget)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            onPressed: () => _showDeleteConfirmation(context, ref, currentBudget.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Category Icon & Name Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: Color(category.colorValue).withOpacity(0.15),
                    child: Icon(_getIconData(category.icon), color: Color(category.colorValue), size: 36),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    category.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateUtilsHelper.formatShortDate(currentBudget.startDate)} – ${DateUtilsHelper.formatShortDate(currentBudget.endDate)}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Progress Overview Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Budget Progress', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: currentBudget.limitAmount == 0.0 ? 0.0 : (spent / currentBudget.limitAmount).clamp(0.0, 1.0),
                        minHeight: 10,
                        color: statusColor,
                        backgroundColor: Colors.grey[850],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${percent.toStringAsFixed(1)}% used',
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                        Text(
                          isExceeded
                              ? '${CurrencyUtils.format(diff)} over limit'
                              : '${CurrencyUtils.format(diff)} remaining',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: isExceeded ? Colors.red : Colors.green),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Budget vs Actual Component
            const Text('Budget vs Actual', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildComparisonRow('Budget Limit', CurrencyUtils.format(currentBudget.limitAmount), Colors.grey),
                    const Divider(height: 24),
                    _buildComparisonRow('Actual Spending', CurrencyUtils.format(spent), Colors.redAccent),
                    const Divider(height: 24),
                    _buildComparisonRow(
                      isExceeded ? 'Over Budget' : 'Remaining',
                      CurrencyUtils.format(diff),
                      isExceeded ? Colors.red : Colors.green,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Settings Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(context, 'Period Type', currentBudget.periodType.toUpperCase()),
                    const Divider(),
                    _buildDetailRow(context, 'Alert Threshold', '${currentBudget.alertPercentage.toStringAsFixed(0)}%'),
                    const Divider(),
                    _buildDetailRow(context, 'Created On', DateUtilsHelper.formatShortDate(currentBudget.createdAt)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Recent Transactions List
            const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (budgetTxs.isEmpty)
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey[850]!),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0, horizontal: 16.0),
                  child: Center(
                    child: Text(
                      'No transactions registered in this period.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: budgetTxs.length,
                itemBuilder: (context, idx) {
                  final tx = budgetTxs[idx];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(DateUtilsHelper.formatDate(tx.date)),
                      trailing: Text(
                        '-${CurrencyUtils.format(tx.amount)}',
                        style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TransactionDetailScreen(
                              transaction: tx,
                              category: category,
                              onDelete: () {
                                ref.read(transactionControllerProvider.notifier).delete(tx.id);
                              },
                              onEdit: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => AddExpenseScreen(editTransaction: tx)),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildComparisonRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).hintColor, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, WidgetRef ref, String budgetId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Budget?'),
        content: const Text('Your transaction history will not be deleted.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              ref.read(budgetControllerProvider.notifier).delete(budgetId);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // pop detail screen back to list
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Budget deleted successfully')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
