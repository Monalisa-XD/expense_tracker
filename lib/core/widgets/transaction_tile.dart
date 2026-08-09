import 'package:flutter/material.dart';
import '../../core/theme/entities.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';

class TransactionTile extends StatelessWidget {
  final TransactionEntity transaction;
  final CategoryEntity? category;
  final VoidCallback? onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.category,
    this.onTap,
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = category != null ? Color(category!.colorValue) : theme.colorScheme.primary;
    final isExpense = transaction.type == TransactionType.expense;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: theme.dividerColor.withOpacity(0.08)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            category != null ? _getIconData(category!.icon) : Icons.receipt,
            color: color,
          ),
        ),
        title: Text(
          transaction.title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  category?.name ?? 'Uncategorized',
                  style: TextStyle(color: theme.hintColor, fontSize: 12),
                ),
                if (transaction.recurringTransactionId != null) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.cached, size: 12, color: theme.colorScheme.secondary),
                ],
              ],
            ),
            const SizedBox(height: 2),
            Text(
              DateUtilsHelper.formatRelative(transaction.date),
              style: TextStyle(color: theme.hintColor.withOpacity(0.7), fontSize: 11),
            ),
          ],
        ),
        trailing: Text(
          '${isExpense ? "-" : "+"}${CurrencyUtils.format(transaction.amount)}',
          style: TextStyle(
            color: isExpense ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
