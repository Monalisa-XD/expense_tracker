import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/transaction_tile.dart';
import '../../../repositories/recurring_controller.dart';
import '../../../repositories/controllers.dart';
import 'add_recurring_screen.dart';

class RecurringDetailScreen extends ConsumerWidget {
  final RecurringTransactionEntity recurring;

  const RecurringDetailScreen({super.key, required this.recurring});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsState = ref.watch(categoryControllerProvider);
    final accountsState = ref.watch(accountControllerProvider);
    final txsState = ref.watch(transactionControllerProvider);

    final cat = (catsState.value ?? []).firstWhere((c) => c.id == recurring.categoryId,
        orElse: () => CategoryEntity(id: '?', name: 'Other', icon: 'widgets', colorValue: 0xFF64748B, type: recurring.type));
    final account = (accountsState.value ?? []).firstWhere((a) => a.id == recurring.accountId,
        orElse: () => AccountEntity(id: '?', name: 'Other Account', balance: 0.0, type: PaymentMethod.bank));

    final generatedTxs = (txsState.value ?? [])
        .where((t) => t.recurringTransactionId == recurring.id)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddRecurringScreen(editRecurring: recurring)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _confirmDelete(context, ref),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Subtitle Title / Amount
          Center(
            child: Column(
              children: [
                Text(recurring.title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(
                  '${recurring.type == TransactionType.expense ? "-" : "+"}${CurrencyUtils.format(recurring.amount)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: recurring.type == TransactionType.expense ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 4),
                Chip(label: Text(recurring.frequency.name.toUpperCase())),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Metadata properties
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildDetailRow('Category', cat.name, Icons.category),
                  const Divider(),
                  _buildDetailRow('Account', account.name, Icons.account_balance),
                  const Divider(),
                  _buildDetailRow('Payment Method', recurring.paymentMethod.name.toUpperCase(), Icons.payment),
                  const Divider(),
                  _buildDetailRow('Next Payment', DateUtilsHelper.formatDate(recurring.nextOccurrenceDate), Icons.calendar_today),
                  const Divider(),
                  _buildDetailRow('Start Date', DateUtilsHelper.formatDate(recurring.startDate), Icons.date_range),
                  const Divider(),
                  _buildDetailRow('End Date', recurring.endDate == null ? 'No End Date' : DateUtilsHelper.formatDate(recurring.endDate!), Icons.event_busy),
                  const Divider(),
                  _buildDetailRow('Status', recurring.isPaused ? 'Paused' : (recurring.isActive ? 'Active' : 'Completed'), Icons.info_outline),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Actions box
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  final notifier = ref.read(recurringControllerProvider.notifier);
                  if (recurring.isPaused) {
                    notifier.resumeRecurring(recurring.id);
                  } else {
                    notifier.pauseRecurring(recurring.id);
                  }
                },
                icon: Icon(recurring.isPaused ? Icons.play_arrow : Icons.pause),
                label: Text(recurring.isPaused ? 'Resume' : 'Pause'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(recurringControllerProvider.notifier).skipNext(recurring.id, recurring.nextOccurrenceDate);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Next occurrence skipped')),
                  );
                },
                icon: const Icon(Icons.skip_next),
                label: const Text('Skip Next'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Generated Transactions history
          const Text('Generated Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (generatedTxs.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('No transactions generated yet.')))
          else
            ...generatedTxs.map((t) => TransactionTile(transaction: t, category: cat)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Recurring Payment?'),
        content: const Text('Previously generated transactions will remain.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      ref.read(recurringControllerProvider.notifier).deleteRecurring(recurring.id);
      Navigator.pop(context); // Go back to tab list
    }
  }
}
