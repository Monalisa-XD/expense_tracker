import 'package:flutter/material.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';

import '../../../../core/utils/app_icon_resolver.dart';
import '../../../../core/theme/brand_registry.dart';
import '../../../../core/theme/category_registry.dart';

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

    final resolvedCategoryName = (() {
      if (category != null && category!.name != 'Unknown') {
        return category!.name;
      }
      final matchingCat = BrandRegistry.categories.firstWhere(
        (c) => c.id == transaction.categoryId,
        orElse: () => CategoryEntity(
          id: 'other',
          name: 'Other',
          icon: 'widgets',
          colorValue: 0xFF78716C,
          type: transaction.type,
        ),
      );
      return matchingCat.name;
    })();

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
              child: AppIconResolver.resolveTransactionIcon(
                categoryId: transaction.categoryId,
                brandKey: transaction.brandKey,
                merchantName: transaction.merchantName ?? transaction.title,
                size: 80,
              ),
            ),
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
                    _buildDetailRow(context, 'Category', resolvedCategoryName),
                    const Divider(),
                    _buildDetailRow(
                      context,
                      'Subcategory',
                      (() {
                        final catDef = CategoryRegistry.categories.firstWhere(
                          (c) => c.id == transaction.categoryId,
                          orElse: () => CategoryDefinition(id: '', name: '', icon: '', colorValue: 0, subcategories: []),
                        );
                        final subcatDef = catDef.subcategories.firstWhere(
                          (s) => s.id == transaction.subcategoryId,
                          orElse: () => SubcategoryDefinition(id: '', name: 'None'),
                        );
                        return subcatDef.name;
                      })(),
                    ),
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
                    if (transaction.receiptPath != null) ...[
                      const Divider(),
                      _buildDetailRow(context, 'Receipt', 'Attached'),
                      const SizedBox(height: 12),
                      Container(
                        height: 120,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.withOpacity(0.05),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.insert_drive_file, size: 36, color: Colors.blue),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                transaction.receiptPath!.split('/').last,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
