import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/merchant_registry.dart';
import 'package:expense_tracker/core/theme/entities.dart';

void main() {
  group('Category, Subcategory & Merchant Hierarchy Unit Tests', () {
    test('TEST 1 — Shopping -> E-commerce -> Amazon', () {
      final m = MerchantRegistry.detectMerchant('Amazon Shopping');
      expect(m, isNotNull);
      expect(m!.categoryId, 'shopping');
      expect(m.subcategoryId, 'ecommerce');
      expect(m.brandKey, 'amazon');
    });

    test('TEST 2 — Food -> Restaurants -> Swiggy', () {
      final m = MerchantRegistry.detectMerchant('Swiggy food delivery');
      expect(m, isNotNull);
      expect(m!.categoryId, 'food_dining');
      expect(m.subcategoryId, 'food_delivery');
      expect(m.brandKey, 'swiggy');
    });

    test('TEST 3 — Groceries -> Quick Commerce -> Blinkit', () {
      final m = MerchantRegistry.detectMerchant('Blinkit orders');
      expect(m, isNotNull);
      expect(m!.categoryId, 'groceries');
      expect(m.subcategoryId, 'quick_commerce');
      expect(m.brandKey, 'blinkit');
    });

    test('TEST 4 — Transport -> Cab -> Uber', () {
      final m = MerchantRegistry.detectMerchant('Uber ride to office');
      expect(m, isNotNull);
      expect(m!.categoryId, 'transport');
      expect(m.subcategoryId, 'cab');
      expect(m.brandKey, 'uber');
    });

    test('TEST 5 — Bills & Recharge -> Mobile -> Airtel', () {
      final m = MerchantRegistry.detectMerchant('Airtel mobile recharge');
      expect(m, isNotNull);
      expect(m!.categoryId, 'bills_recharge');
      expect(m.subcategoryId, 'mobile');
      expect(m.brandKey, 'airtel');
    });

    test('TEST 6 — Entertainment -> Streaming -> Netflix', () {
      final m = MerchantRegistry.detectMerchant('Netflix Premium subscription');
      expect(m, isNotNull);
      expect(m!.categoryId, 'entertainment');
      expect(m.subcategoryId, 'streaming');
      expect(m.brandKey, 'netflix');
    });

    test('TEST 7 — Legacy migration maps Swiggy correctly', () {
      final oldTx = TransactionEntity(
        id: 'tx_old_1',
        amount: 250.0,
        type: TransactionType.expense,
        categoryId: 'cat_food',
        accountId: 'acc_1',
        title: 'Swiggy',
        paymentMethod: PaymentMethod.upi,
        createdAt: DateTime.now(),
        date: DateTime.now(),
      );

      // Verify the simulated load mapping
      final detected = MerchantRegistry.detectMerchant(oldTx.title);
      expect(detected, isNotNull);
      final updatedTx = oldTx.copyWith(
        categoryId: detected!.categoryId,
        subcategoryId: () => detected.subcategoryId,
        merchantId: () => detected.id,
        brandKey: () => detected.brandKey,
        merchantName: () => detected.name,
      );

      expect(updatedTx.categoryId, 'food_dining');
      expect(updatedTx.subcategoryId, 'food_delivery');
      expect(updatedTx.merchantId, 'swiggy');
      expect(updatedTx.brandKey, 'swiggy');
      expect(updatedTx.merchantName, 'Swiggy');
    });
  });
}
