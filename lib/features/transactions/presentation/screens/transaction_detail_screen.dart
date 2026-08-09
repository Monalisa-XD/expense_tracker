import 'package:flutter/material.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryEntity? category;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const TransactionDetailScreen({
    super.key,
    required this.transaction,
    this.category,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isExpense = transaction.type == TransactionType.expense;
    final color = isExpense ? Colors.red : Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.pop(context); // Close detail screen
              onEdit();
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Delete Transaction?'),
                  content: const Text('This action cannot be undone.'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context); // close dialog
                        onDelete();
                        Navigator.pop(context); // return to transaction list
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Transaction deleted successfully')),
                        );
                      },
                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Center(
              child: Text(
                transaction.type == TransactionType.expense ? 'EXPENSE' : 'INCOME',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '${isExpense ? "-" : "+"}${CurrencyUtils.format(transaction.amount)}',
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.w800, color: color),
              ),
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildDetailRow(context, 'Title', transaction.title),
                    const Divider(),
                    _buildDetailRow(context, 'Category', category?.name ?? 'Uncategorized'),
                    const Divider(),
                    _buildDetailRow(context, 'Date', DateUtilsHelper.formatDate(transaction.date)),
                    const Divider(),
                    _buildDetailRow(context, 'Payment Method', transaction.paymentMethod.name.toUpperCase()),
                    const Divider(),
                    _buildDetailRow(context, 'Account ID', transaction.accountId),
                    const Divider(),
                    _buildDetailRow(context, 'Description', transaction.description ?? 'None'),
                    const Divider(),
                    _buildDetailRow(context, 'Created At', DateUtilsHelper.formatDate(transaction.createdAt)),
                  ],
                ),
              ),
            ),
          ],
        ),
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
