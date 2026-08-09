import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/widgets/transaction_tile.dart';
import '../../../repositories/account_controller.dart';
import '../../../repositories/controllers.dart';
import 'add_account_screen.dart';
import 'transfer_detail_screen.dart';
import 'transaction_detail_screen.dart';

class AccountDetailScreen extends ConsumerWidget {
  final AccountEntity account;

  const AccountDetailScreen({super.key, required this.account});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final txState = ref.watch(transactionControllerProvider);
    final catsState = ref.watch(categoryControllerProvider);

    final transactions = (txState.value ?? []).where((t) =>
        t.accountId == account.id ||
        t.fromAccountId == account.id ||
        t.toAccountId == account.id).toList();

    double income = 0;
    double expenses = 0;
    double transfers = 0;

    for (var tx in transactions) {
      if (tx.type == TransactionType.income && tx.accountId == account.id) {
        income += tx.amount;
      } else if (tx.type == TransactionType.expense && tx.accountId == account.id) {
        expenses += tx.amount;
      } else if (tx.type == TransactionType.transfer) {
        if (tx.fromAccountId == account.id) {
          transfers -= tx.amount;
        } else if (tx.toAccountId == account.id) {
          transfers += tx.amount;
        }
      }
    }

    final netChange = income - expenses + transfers;

    return Scaffold(
      appBar: AppBar(
        title: Text(account.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddAccountScreen(editAccount: account)),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.archive),
            onPressed: () => _confirmArchive(context, ref),
          ),
          if (transactions.isEmpty)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(context, ref),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Center(
            child: Column(
              children: [
                Text(
                  CurrencyUtils.format(account.balance),
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: account.balance >= 0 ? Colors.green : Colors.red,
                  ),
                ),
                const SizedBox(height: 8),
                Text(account.type.name.toUpperCase(), style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Stats section
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildStatRow('Income', CurrencyUtils.format(income), Colors.green),
                  const Divider(),
                  _buildStatRow('Expenses', CurrencyUtils.format(expenses), Colors.red),
                  const Divider(),
                  _buildStatRow('Net Transfers', CurrencyUtils.format(transfers), Colors.blue),
                  const Divider(),
                  _buildStatRow('Net Change', CurrencyUtils.format(netChange), netChange >= 0 ? Colors.green : Colors.red),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Recent Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (transactions.isEmpty)
            const Center(child: Padding(padding: EdgeInsets.all(24.0), child: Text('No transactions registered yet.')))
          else
            ...transactions.map((tx) {
              final cat = (catsState.value ?? []).firstWhere((c) => c.id == tx.categoryId,
                  orElse: () => CategoryEntity(
                      id: 'unknown',
                      name: 'Unknown',
                      icon: 'widgets',
                      colorValue: 0xFF64748B,
                      type: tx.type));
              return _buildTile(context, ref, tx, cat);
            }),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildTile(BuildContext context, WidgetRef ref, TransactionEntity tx, CategoryEntity cat) {
    if (tx.type == TransactionType.transfer) {
      return Card(
        child: ListTile(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TransferDetailScreen(transaction: tx)),
            );
          },
          leading: const CircleAvatar(child: Icon(Icons.swap_horiz)),
          title: Text(tx.title, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(DateUtilsHelper.formatShortDate(tx.date)),
          trailing: Text(
            '${tx.fromAccountId == account.id ? "-" : "+"}${CurrencyUtils.format(tx.amount)}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: tx.fromAccountId == account.id ? Colors.red : Colors.green,
            ),
          ),
        ),
      );
    }
    return TransactionTile(
      transaction: tx,
      category: cat,
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TransactionDetailScreen(
              transaction: tx,
              category: cat,
              onDelete: () => ref.read(transactionControllerProvider.notifier).delete(tx.id),
              onEdit: () {},
            ),
          ),
        );
      },
    );
  }

  void _confirmArchive(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Archive Account?'),
        content: const Text('Archived accounts cannot be selected for new transactions.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Archive'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await ref.read(accountStateNotifierProvider.notifier).archiveAccount(account.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account?'),
        content: const Text('This action cannot be undone.'),
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
      await ref.read(accountStateNotifierProvider.notifier).deleteAccount(account.id);
      if (context.mounted) {
        Navigator.pop(context);
      }
    }
  }
}
