import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../transactions/presentation/screens/transaction_detail_screen.dart';
import '../../../repositories/controllers.dart';

class CategorySpendingDetailsScreen extends ConsumerWidget {
  final CategoryEntity category;

  const CategorySpendingDetailsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periodState = ref.watch(analyticsPeriodControllerProvider);
    final txsState = ref.watch(transactionControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('${category.name} Details'),
      ),
      body: txsState.when(
        data: (list) {
          // Filter matching category inside active period range
          final catTxs = list.where((tx) =>
              tx.categoryId == category.id &&
              tx.date.isAfter(periodState.dateRange.start.subtract(const Duration(seconds: 1))) &&
              tx.date.isBefore(periodState.dateRange.end.add(const Duration(days: 1)))).toList();

          if (catTxs.isEmpty) {
            return const Center(
              child: Text('No transactions registered for this category in this period.'),
            );
          }

          final totalSpent = catTxs.fold(0.0, (sum, tx) => sum + tx.amount);
          final avgSpent = totalSpent / catTxs.length;
          final maxSpent = catTxs.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Text(
                    category.name.toUpperCase(),
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    CurrencyUtils.format(totalSpent),
                    style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w800),
                  ),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDetailRow(context, 'Transactions Count', '${catTxs.length}'),
                        const Divider(),
                        _buildDetailRow(context, 'Average Transaction', CurrencyUtils.format(avgSpent)),
                        const Divider(),
                        _buildDetailRow(context, 'Highest Expense', CurrencyUtils.format(maxSpent)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Merchant Breakdown', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Builder(
                      builder: (context) {
                        // Aggregate spending by merchant
                        final Map<String, double> merchantSpend = {};
                        for (var tx in catTxs) {
                          final mName = tx.merchantName ?? 'Other / Custom';
                          merchantSpend[mName] = (merchantSpend[mName] ?? 0.0) + tx.amount;
                        }
                        // Sort by spend descending
                        final sortedMerchants = merchantSpend.entries.toList()
                          ..sort((a, b) => b.value.compareTo(a.value));

                        return Column(
                          children: sortedMerchants.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w500)),
                                  Text(CurrencyUtils.format(entry.value), style: const TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: catTxs.length,
                  itemBuilder: (context, idx) {
                    final tx = catTxs[idx];
                    return ListTile(
                      title: Text(tx.title),
                      subtitle: Text(DateUtilsHelper.formatDate(tx.date)),
                      trailing: Text(
                        '-${CurrencyUtils.format(tx.amount)}',
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
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
                                // Navigate to edit
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
