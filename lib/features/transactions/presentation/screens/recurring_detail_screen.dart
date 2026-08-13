import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/app_icon_resolver.dart';
import '../../../../core/widgets/transaction_tile.dart';
import '../../../repositories/recurring_controller.dart';
import '../../../repositories/controllers.dart';
import '../../../repositories/account_controller.dart';
import 'add_recurring_screen.dart';

class RecurringDetailScreen extends ConsumerWidget {
  final RecurringTransactionEntity recurring;

  const RecurringDetailScreen({super.key, required this.recurring});

  double _getNormalizedMonthlyCost(RecurringTransactionEntity item) {
    switch (item.frequency) {
      case RecurringFrequency.daily:
        return item.amount * 30.0;
      case RecurringFrequency.weekly:
        return item.amount * 4.33;
      case RecurringFrequency.monthly:
        return item.amount;
      case RecurringFrequency.quarterly:
        return item.amount / 3.0;
      case RecurringFrequency.halfYearly:
        return item.amount / 6.0;
      case RecurringFrequency.yearly:
        return item.amount / 12.0;
      case RecurringFrequency.custom:
        return item.amount;
    }
  }

  String _getCountdownText(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final due = DateUtils.dateOnly(date);
    final diff = due.difference(today).inDays;
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    if (diff < 0) return 'Overdue by ${diff.abs()} days';
    return 'Due in $diff days';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsState = ref.watch(categoryControllerProvider);
    final accountsState = ref.watch(accountStateNotifierProvider);
    final txsState = ref.watch(transactionControllerProvider);

    final cat = (catsState.value ?? []).firstWhere((c) => c.id == recurring.categoryId,
        orElse: () => CategoryEntity(id: '?', name: 'Other', icon: 'widgets', colorValue: 0xFF64748B, type: recurring.type));
    final account = accountsState.activeAccounts.firstWhere((a) => a.id == recurring.accountId,
        orElse: () => AccountEntity(id: '?', name: 'Other Account', balance: 0.0, type: PaymentMethod.bank));

    final generatedTxs = (txsState.value ?? [])
        .where((t) => t.recurringTransactionId == recurring.id)
        .toList();

    final isLowBalance = account.balance < recurring.amount && recurring.type == TransactionType.expense;

    final monthly = _getNormalizedMonthlyCost(recurring);
    final yearly = monthly * 12.0;

    String statusText = 'Active';
    if (!recurring.isActive) {
      statusText = 'Completed / Cancelled';
    } else if (recurring.isPaused) {
      statusText = 'Paused';
    }

    final trialEnd = recurring.trialEndDate;
    final inTrial = trialEnd != null && DateTime.now().isBefore(trialEnd);
    final trialDaysRemaining = trialEnd != null ? trialEnd.difference(DateTime.now()).inDays : 0;

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
          // Visual title logo card
          Center(
            child: Column(
              children: [
                AppIconResolver.resolveTransactionIcon(
                  categoryId: recurring.categoryId,
                  brandKey: recurring.brandKey,
                  merchantName: recurring.merchantName ?? recurring.title,
                  size: 72,
                ),
                const SizedBox(height: 12),
                Text(recurring.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(
                  '${recurring.type == TransactionType.expense ? "-" : "+"}${CurrencyUtils.format(recurring.amount)}',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: recurring.type == TransactionType.expense ? Colors.red : Colors.green,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Chip(label: Text(recurring.frequency.name.toUpperCase())),
                    if (recurring.recurringType != null) ...[
                      const SizedBox(width: 8),
                      Chip(
                        label: Text(recurring.recurringType!.toUpperCase()),
                        backgroundColor: Colors.teal[900],
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          if (isLowBalance)
            Card(
              color: Colors.redAccent.withOpacity(0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Colors.redAccent, width: 0.5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: const [
                    Icon(Icons.warning_amber_rounded, color: Colors.redAccent),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '⚠ Insufficient balance: Your HDFC account balance is less than this payment amount.',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          if (inTrial)
            Card(
              color: Colors.blue.withOpacity(0.08),
              child: ListTile(
                leading: const Icon(Icons.timer_outlined, color: Colors.blue),
                title: const Text('Free Trial Period Active'),
                subtitle: Text('Trial ends in $trialDaysRemaining days (${DateUtilsHelper.formatDate(trialEnd)})'),
              ),
            ),

          const SizedBox(height: 8),

          // Metadata Card
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
                  _buildDetailRow('Countdown', _getCountdownText(recurring.nextOccurrenceDate), Icons.hourglass_empty),
                  const Divider(),
                  _buildDetailRow('Monthly Normalized Cost', CurrencyUtils.format(monthly), Icons.trending_up),
                  const Divider(),
                  _buildDetailRow('Yearly Cost Estimate', CurrencyUtils.format(yearly), Icons.date_range),
                  const Divider(),
                  _buildDetailRow('Status', statusText, Icons.info_outline),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Actions
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
              if (recurring.isActive)
                ElevatedButton.icon(
                  onPressed: () => _confirmCancel(context, ref),
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Cancel Sub'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red[900]),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Generated Transactions list
          const Text('Payment History', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (generatedTxs.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('No historical payments found.')))
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

  void _confirmCancel(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text('This will cancel the subscription. Historic transactions remain.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Cancel Sub', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      ref.read(recurringControllerProvider.notifier).updateRecurring(recurring.copyWith(
            isActive: false,
          ));
      Navigator.pop(context);
    }
  }
}
