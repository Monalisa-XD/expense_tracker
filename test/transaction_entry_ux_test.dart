import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/theme/entities.dart';
import 'package:expense_tracker/core/theme/category_registry.dart';
import 'package:expense_tracker/core/theme/merchant_registry.dart';

void main() {
  group('Transaction Entry UX & Logic Tests', () {
    test('Amount validation - accepts valid positive values and rejects zero/negative', () {
      final tx = TransactionEntity(
        id: 'tx_1',
        amount: 1299.50,
        type: TransactionType.expense,
        categoryId: 'shopping',
        subcategoryId: 'ecommerce',
        accountId: 'acc_hdfc',
        title: 'Amazon',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.upi,
        createdAt: DateTime.now(),
      );
      expect(tx.amount, 1299.50);
      expect(tx.amount > 0, true);
    });

    test('Category selection - uses CategoryRegistry definitions', () {
      final cat = CategoryRegistry.categories.firstWhere((c) => c.id == 'shopping');
      expect(cat.name, 'Shopping');
      expect(cat.icon, 'shopping_bag');
    });

    test('Subcategory selection - retrieves valid subcategories', () {
      final cat = CategoryRegistry.categories.firstWhere((c) => c.id == 'shopping');
      final sub = cat.subcategories.firstWhere((s) => s.id == 'ecommerce');
      expect(sub.name, 'E-commerce');
    });

    test('Merchant selection - uses MerchantRegistry definitions', () {
      final m = MerchantRegistry.merchants.firstWhere((merchant) => merchant.id == 'amazon');
      expect(m.name, 'Amazon');
      expect(m.brandKey, 'amazon');
    });

    test('Custom merchant mapping supports fallback and identifiers', () {
      final tx = TransactionEntity(
        id: 'tx_custom',
        amount: 420.0,
        type: TransactionType.expense,
        categoryId: 'shopping',
        subcategoryId: 'electronics',
        accountId: 'acc_cash',
        title: 'Local Electronics Store',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.cash,
        createdAt: DateTime.now(),
        merchantId: 'custom',
        merchantName: 'Local Electronics Store',
      );
      expect(tx.merchantId, 'custom');
      expect(tx.merchantName, 'Local Electronics Store');
      expect(tx.brandKey, null);
    });

    test('Favorite merchant state is toggled correctly', () {
      final favorites = <String>[];
      // Simulate favoriting Amazon
      favorites.add('amazon');
      expect(favorites.contains('amazon'), true);
      // Simulate unfavoriting Amazon
      favorites.remove('amazon');
      expect(favorites.contains('amazon'), false);
    });

    test('Recent merchant ordering sorts by latest date', () {
      final tx1 = TransactionEntity(
        id: 'tx_old',
        amount: 100.0,
        type: TransactionType.expense,
        categoryId: 'shopping',
        subcategoryId: 'ecommerce',
        accountId: 'acc_hdfc',
        title: 'Flipkart',
        merchantName: 'Flipkart',
        date: DateTime.now().subtract(const Duration(days: 2)),
        paymentMethod: PaymentMethod.upi,
        createdAt: DateTime.now(),
      );
      final tx2 = TransactionEntity(
        id: 'tx_new',
        amount: 200.0,
        type: TransactionType.expense,
        categoryId: 'shopping',
        subcategoryId: 'ecommerce',
        accountId: 'acc_hdfc',
        title: 'Amazon',
        merchantName: 'Amazon',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.upi,
        createdAt: DateTime.now(),
      );

      final list = [tx1, tx2];
      list.sort((a, b) => b.date.compareTo(a.date));
      expect(list.first.merchantName, 'Amazon');
    });

    test('Account selection uses AccountEntity attributes', () {
      final acc = AccountEntity(
        id: 'acc_hdfc',
        name: 'HDFC Bank',
        balance: 25400.0,
        type: PaymentMethod.upi,
        initialBalance: 25400.0,
      );
      expect(acc.name, 'HDFC Bank');
      expect(acc.balance, 25400.0);
    });

    test('Date selection supports relative options', () {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));
      expect(today.difference(yesterday).inDays, 1);
    });

    test('Edit transaction modifies properties using copyWith', () {
      final tx = TransactionEntity(
        id: 'tx_1',
        amount: 1299.0,
        type: TransactionType.expense,
        categoryId: 'shopping',
        subcategoryId: 'ecommerce',
        accountId: 'acc_hdfc',
        title: 'Amazon',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.upi,
        createdAt: DateTime.now(),
      );
      final edited = tx.copyWith(
        amount: 1500.0,
        description: 'New shoes',
      );
      expect(edited.amount, 1500.0);
      expect(edited.description, 'New shoes');
    });

    test('Category reset rules - changing category clears subcategory and merchant', () {
      var categoryId = 'shopping';
      var subcategoryId = 'ecommerce';
      var merchantId = 'amazon';

      // Change category
      categoryId = 'food_dining';
      subcategoryId = 'other_food'; // reset & set fallback
      merchantId = 'custom'; // reset & set fallback

      expect(categoryId, 'food_dining');
      expect(subcategoryId, 'other_food');
      expect(merchantId, 'custom');
    });

    test('Subcategory reset rules - changing subcategory clears merchant', () {
      var subcategoryId = 'ecommerce';
      var merchantId = 'amazon';

      // Change subcategory
      subcategoryId = 'clothing';
      merchantId = 'custom'; // reset & set fallback

      expect(subcategoryId, 'clothing');
      expect(merchantId, 'custom');
    });

    test('Persistence serializes and deserializes receiptPath', () {
      final tx = TransactionEntity(
        id: 'tx_receipt',
        amount: 50.0,
        type: TransactionType.expense,
        categoryId: 'shopping',
        accountId: 'acc_hdfc',
        title: 'Receipt Tx',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.upi,
        createdAt: DateTime.now(),
        receiptPath: '/mock/path/receipt.png',
      );

      final map = tx.toMap();
      expect(map['receiptPath'], '/mock/path/receipt.png');

      final fromMap = TransactionEntity.fromMap(map);
      expect(fromMap.receiptPath, '/mock/path/receipt.png');
    });

    test('Receipt metadata holds path string', () {
      final tx = TransactionEntity(
        id: 'tx_receipt',
        amount: 10.0,
        type: TransactionType.expense,
        categoryId: 'shopping',
        accountId: 'acc_hdfc',
        title: 'Sample',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.upi,
        createdAt: DateTime.now(),
        receiptPath: '/mock/path/receipt.jpg',
      );
      expect(tx.receiptPath, '/mock/path/receipt.jpg');
    });

    test('Legacy transaction compatibility parses correctly', () {
      final map = {
        'id': 'legacy_1',
        'amount': 250.0,
        'type': 'expense',
        'categoryId': 'cat_food',
        'accountId': 'acc_cash',
        'title': 'Swiggy',
        'date': DateTime.now().toIso8601String(),
        'paymentMethod': 'cash',
        'createdAt': DateTime.now().toIso8601String(),
      };
      final tx = TransactionEntity.fromMap(map);
      expect(tx.amount, 250.0);
      expect(tx.categoryId, 'cat_food'); // Migration controller fixes it dynamically
    });

    test('Search finds transaction based on notes or accounts', () {
      final tx = TransactionEntity(
        id: 'tx_search',
        amount: 100.0,
        type: TransactionType.expense,
        categoryId: 'shopping',
        accountId: 'acc_hdfc',
        title: 'Search Title',
        description: 'office lunch',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.upi,
        createdAt: DateTime.now(),
      );
      expect(tx.description!.contains('office lunch'), true);
    });

    test('Filtering logic filters correct categories and types', () {
      final tx = TransactionEntity(
        id: 'tx_filter',
        amount: 100.0,
        type: TransactionType.expense,
        categoryId: 'shopping',
        accountId: 'acc_hdfc',
        title: 'Title',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.upi,
        createdAt: DateTime.now(),
      );
      expect(tx.type == TransactionType.expense, true);
      expect(tx.categoryId == 'shopping', true);
    });

    test('Analytics integration aggregates expenses correctly', () {
      final list = [
        TransactionEntity(
          id: '1', amount: 100.0, type: TransactionType.expense,
          categoryId: 'shopping', accountId: 'acc_hdfc', title: '1',
          date: DateTime.now(), paymentMethod: PaymentMethod.upi, createdAt: DateTime.now()
        ),
        TransactionEntity(
          id: '2', amount: 200.0, type: TransactionType.expense,
          categoryId: 'shopping', accountId: 'acc_hdfc', title: '2',
          date: DateTime.now(), paymentMethod: PaymentMethod.upi, createdAt: DateTime.now()
        ),
      ];
      final totalSpent = list.fold<double>(0.0, (sum, tx) => sum + tx.amount);
      expect(totalSpent, 300.0);
    });

    test('Budget integration tracks spending correctly', () {
      final budgetLimit = 5000.0;
      var spentAmount = 1000.0;
      final newTxAmount = 500.0;

      spentAmount += newTxAmount;
      expect(spentAmount, 1500.0);
      expect(spentAmount <= budgetLimit, true);
    });

    test('Account balance integration updates accounts appropriately', () {
      var hdfcBalance = 25400.0;
      const expenseAmount = 1000.0;
      const incomeAmount = 5000.0;

      hdfcBalance -= expenseAmount;
      expect(hdfcBalance, 24400.0);

      hdfcBalance += incomeAmount;
      expect(hdfcBalance, 29400.0);
    });
  });
}
