import 'package:flutter/material.dart';
import '../theme/entities.dart';
import '../theme/brand_registry.dart';

class AppIconResolver {
  static IconData resolveCategoryIcon(String categoryId) {
    final cat = BrandRegistry.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryEntity(id: 'other', name: 'Other', icon: 'widgets', colorValue: 0xFF78716C, type: TransactionType.expense),
    );

    switch (cat.icon) {
      case 'swap_horiz': return Icons.swap_horiz;
      case 'shopping_bag': return Icons.shopping_bag;
      case 'restaurant': return Icons.restaurant;
      case 'local_grocery_store': return Icons.local_grocery_store;
      case 'directions_car': return Icons.directions_car;
      case 'receipt_long': return Icons.receipt_long;
      case 'home': return Icons.home;
      case 'account_balance': return Icons.account_balance;
      case 'sports_esports': return Icons.sports_esports;
      case 'medical_services': return Icons.medical_services;
      case 'school': return Icons.school;
      case 'flight': return Icons.flight;
      case 'settings': return Icons.settings;
      case 'monetization_on': return Icons.monetization_on;
      default: return Icons.widgets;
    }
  }

  static Widget resolveTransactionIcon({
    required String categoryId,
    String? brandKey,
    String? merchantName,
    double size = 40.0,
  }) {
    // If brandKey is recognized and carries an asset logo, try displaying it
    if (brandKey != null) {
      final merchant = BrandRegistry.merchants.firstWhere(
        (m) => m.brandKey == brandKey,
        orElse: () => MerchantEntity(id: '', categoryId: categoryId, name: merchantName ?? 'Other'),
      );
      if (merchant.iconAsset != null) {
        // Safe fallback image wrapper in case asset doesn't load
        return Image.asset(
          merchant.iconAsset!,
          width: size,
          height: size,
          errorBuilder: (context, error, stackTrace) {
            return _buildInitialsPlaceholder(merchant.name, size);
          },
        );
      }
    }

    // Fallback to initials if merchantName exists
    if (merchantName != null && merchantName.isNotEmpty && merchantName != 'Other Shopping' && merchantName != 'Other Food' && merchantName != 'Other Grocery' && merchantName != 'Other Transport' && merchantName != 'Other Bills' && merchantName != 'Other Housing' && merchantName != 'Other Finance' && merchantName != 'Other Entertainment' && merchantName != 'Other Health' && merchantName != 'Other Education' && merchantName != 'Other Travel') {
      return _buildInitialsPlaceholder(merchantName, size);
    }

    // Else fall back to standard Category Icon
    final catColor = BrandRegistry.categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryEntity(id: 'other', name: 'Other', icon: 'widgets', colorValue: 0xFF78716C, type: TransactionType.expense),
    ).colorValue;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Color(catColor).withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: Icon(
        resolveCategoryIcon(categoryId),
        color: Color(catColor),
        size: size * 0.5,
      ),
    );
  }

  static Widget _buildInitialsPlaceholder(String name, double size) {
    final initials = name.trim().split(' ').map((e) => e[0]).take(2).join().toUpperCase();
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.blueGrey.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
          color: Colors.blueGrey,
        ),
      ),
    );
  }
}
