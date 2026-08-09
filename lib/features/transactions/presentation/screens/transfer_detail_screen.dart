import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../repositories/account_controller.dart';
import 'add_transfer_screen.dart';

class TransferDetailScreen extends ConsumerWidget {
  final TransactionEntity transaction;

  const TransferDetailScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(accountStateNotifierProvider);
    final accounts = state.accounts;

    final fromAcc = accounts.firstWhere((a) => a.id == transaction.fromAccountId,
        orElse: () => AccountEntity(id: '?', name: 'Unknown', balance: 0.0, type: PaymentMethod.bank));
    final toAcc = accounts.firstWhere((a) => a.id == transaction.toAccountId,
        orElse: () => AccountEntity(id: '?', name: 'Unknown', balance: 0.0, type: PaymentMethod.bank));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transfer Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddTransferScreen(editTransfer: transaction)),
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
        padding: const EdgeInsets.all(24.0),
        children: [
          Center(
            child: Column(
              children: [
                const Icon(Icons.swap_horiz, size: 48, color: Colors.blue),
                const SizedBox(height: 12),
                Text(
                  CurrencyUtils.format(transaction.amount),
                  style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Chip(label: Text('MONEY TRANSFER')),
              ],
            ),
          ),
          const SizedBox(height: 32),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildRow('From Account', fromAcc.name, Icons.upload_file),
                  const Divider(),
                  _buildRow('To Account', toAcc.name, Icons.download_done),
                  const Divider(),
                  _buildRow('Date', DateUtilsHelper.formatDate(transaction.date), Icons.calendar_today),
                  const Divider(),
                  _buildRow('Description', transaction.description ?? 'None', Icons.description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(color: Colors.grey)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transfer?'),
        content: const Text('This will reverse account balance changes.'),
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
      await ref.read(accountStateNotifierProvider.notifier).deleteTransfer(transaction.transferId!);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
