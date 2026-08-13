import 'package:flutter/material.dart';
import '../../core/theme/entities.dart';
import '../../core/utils/currency_utils.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/app_icon_resolver.dart';
import '../../core/theme/brand_registry.dart';
import '../../core/theme/category_registry.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        leading: AppIconResolver.resolveTransactionIcon(
          categoryId: transaction.categoryId,
          brandKey: transaction.brandKey,
          merchantName: transaction.merchantName ?? transaction.title,
          size: 48,
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
                  (() {
                    final matchingCat = CategoryRegistry.categories.firstWhere(
                      (c) => c.id == transaction.categoryId,
                      orElse: () => CategoryDefinition(
                        id: 'other',
                        name: 'Other',
                        icon: 'widgets',
                        colorValue: 0xFF78716C,
                        subcategories: [],
                      ),
                    );

                    final categoryName = matchingCat.name;
                    if (transaction.subcategoryId != null && transaction.subcategoryId!.isNotEmpty) {
                      final subcat = matchingCat.subcategories.firstWhere(
                        (s) => s.id == transaction.subcategoryId,
                        orElse: () => SubcategoryDefinition(id: '', name: ''),
                      );
                      if (subcat.name.isNotEmpty) {
                        return '$categoryName · ${subcat.name}';
                      }
                    }
                    return categoryName;
                  })(),
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
          '${isExpense ? "-" : "+"}${CurrencyUtils.format(transaction.amount, isTransaction: true)}',
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
