import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/theme/category_registry.dart';
import '../../../../core/theme/merchant_registry.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/app_icon_resolver.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../repositories/controllers.dart';
import '../../../repositories/providers.dart';
import '../../../repositories/account_controller.dart';

class MultiStepExpenseFlow extends ConsumerStatefulWidget {
  final TransactionEntity? editTransaction;
  final TransactionType defaultType;

  const MultiStepExpenseFlow({
    super.key,
    this.editTransaction,
    this.defaultType = TransactionType.expense,
  });

  @override
  ConsumerState<MultiStepExpenseFlow> createState() => _MultiStepExpenseFlowState();
}

class _MultiStepExpenseFlowState extends ConsumerState<MultiStepExpenseFlow> {
  late TransactionType _transactionType;
  int _currentStep = 0;

  // Step Values
  final TextEditingController _amountController = TextEditingController();
  CategoryDefinition? _selectedCategory;
  SubcategoryDefinition? _selectedSubcategory;
  MerchantDefinition? _selectedMerchant;
  String? _customMerchantName;
  AccountEntity? _selectedAccount;
  PaymentMethod? _selectedPaymentMethod;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _notesController = TextEditingController();
  String? _receiptPath;

  // Merchant search & favorites
  String _merchantSearchQuery = '';
  final TextEditingController _merchantSearchController = TextEditingController();
  final TextEditingController _customMerchantInputController = TextEditingController();
  List<String> _favoriteMerchantIds = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _transactionType = widget.defaultType;

    // Load favorites from local storage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final storage = ref.read(localStorageServiceProvider);
      setState(() {
        _favoriteMerchantIds = storage.getFavoriteMerchants();
      });
    });

    if (widget.editTransaction != null) {
      final tx = widget.editTransaction!;
      _transactionType = tx.type;
      _amountController.text = tx.amount.toString();
      _selectedCategory = CategoryRegistry.categories.firstWhere(
        (c) => c.id == tx.categoryId,
        orElse: () => CategoryRegistry.categories.first,
      );
      if (tx.subcategoryId != null) {
        _selectedSubcategory = _selectedCategory!.subcategories.firstWhere(
          (s) => s.id == tx.subcategoryId,
          orElse: () => _selectedCategory!.subcategories.first,
        );
      }
      if (tx.merchantId == 'custom') {
        _customMerchantName = tx.merchantName;
      } else if (tx.merchantId != null) {
        _selectedMerchant = MerchantRegistry.merchants.firstWhere(
          (m) => m.id == tx.merchantId,
          orElse: () => MerchantRegistry.merchants.first,
        );
      }
      _selectedDate = tx.date;
      _selectedPaymentMethod = tx.paymentMethod;
      _notesController.text = tx.description ?? '';
      _receiptPath = tx.receiptPath;
    } else {
      if (_transactionType == TransactionType.income) {
        _selectedCategory = CategoryRegistry.categories.firstWhere(
          (c) => c.id == 'salary_income',
          orElse: () => CategoryRegistry.categories.first,
        );
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _merchantSearchController.dispose();
    _customMerchantInputController.dispose();
    super.dispose();
  }

  // Steps definition helper
  List<String> get _stepSequence {
    if (_transactionType == TransactionType.income) {
      return ['Amount', 'Subcategory', 'Merchant', 'Account', 'Payment Method', 'Date', 'Notes', 'Receipt', 'Review'];
    } else {
      return ['Amount', 'Category', 'Subcategory', 'Merchant', 'Account', 'Payment Method', 'Date', 'Notes', 'Receipt', 'Review'];
    }
  }

  void _nextStep() {
    if (_currentStep < _stepSequence.length - 1) {
      setState(() => _currentStep++);
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    }
  }

  void _jumpToStep(String stepName) {
    final idx = _stepSequence.indexOf(stepName);
    if (idx != -1) {
      setState(() => _currentStep = idx);
    }
  }

  // Toggle favorite merchant
  void _toggleFavoriteMerchant(String merchantId) {
    final storage = ref.read(localStorageServiceProvider);
    setState(() {
      if (_favoriteMerchantIds.contains(merchantId)) {
        _favoriteMerchantIds.remove(merchantId);
      } else {
        _favoriteMerchantIds.add(merchantId);
      }
      storage.saveFavoriteMerchants(_favoriteMerchantIds);
    });
  }

  @override
  Widget build(BuildContext context) {
    final accountState = ref.watch(accountStateNotifierProvider);
    final accounts = accountState.activeAccounts;

    if (_selectedAccount == null && accounts.isNotEmpty) {
      if (widget.editTransaction != null) {
        _selectedAccount = accounts.firstWhere((a) => a.id == widget.editTransaction!.accountId, orElse: () => accounts.first);
      } else {
        _selectedAccount = accountState.defaultAccount ?? accounts.first;
      }
    }

    if (_selectedPaymentMethod == null && _selectedAccount != null) {
      _selectedPaymentMethod = _selectedAccount!.type;
    }

    // Generate dynamic steps list
    final List<Widget> steps = [];
    for (var step in _stepSequence) {
      switch (step) {
        case 'Amount':
          steps.add(_buildAmountStep());
          break;
        case 'Category':
          steps.add(_buildCategoryStep());
          break;
        case 'Subcategory':
          steps.add(_buildSubcategoryStep());
          break;
        case 'Merchant':
          steps.add(_buildMerchantStep());
          break;
        case 'Account':
          steps.add(_buildAccountStep(accounts));
          break;
        case 'Payment Method':
          steps.add(_buildPaymentMethodStep());
          break;
        case 'Date':
          steps.add(_buildDateStep());
          break;
        case 'Notes':
          steps.add(_buildNotesStep());
          break;
        case 'Receipt':
          steps.add(_buildReceiptStep());
          break;
        case 'Review':
          steps.add(_buildReviewStep());
          break;
      }
    }

    final String titleType = _transactionType == TransactionType.income ? 'Income' : 'Expense';
    final String titleAction = widget.editTransaction != null ? 'Edit' : 'Add';

    return Scaffold(
      appBar: AppBar(
        title: Text('$titleAction $titleType'),
        leading: _currentStep > 0
            ? IconButton(icon: const Icon(Icons.arrow_back), onPressed: _prevStep)
            : IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
      ),
      body: SafeArea(
        child: steps[_currentStep],
      ),
    );
  }

  Widget _buildAmountStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 20),
          Text(
            _transactionType == TransactionType.income ? 'How much did you receive?' : 'How much did you spend?',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            autofocus: true,
            decoration: const InputDecoration(
              prefixText: '₹',
              hintText: '0',
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: 24),
          // Quick amount buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [100, 500, 1000, 2000].map((amt) {
              return ElevatedButton(
                onPressed: () {
                  setState(() {
                    _amountController.text = amt.toString();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                  foregroundColor: Theme.of(context).primaryColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
                child: Text('+₹$amt'),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: () {
              final val = double.tryParse(_amountController.text);
              if (val != null && val > 0) {
                _nextStep();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid amount greater than 0')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: const Text('Continue', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryStep() {
    final expenseCats = CategoryRegistry.categories.where((c) => c.id != 'salary_income' && c.id != 'transfer').toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Select Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
              ),
              itemCount: expenseCats.length,
              itemBuilder: (context, index) {
                final cat = expenseCats[index];
                final isSelected = _selectedCategory?.id == cat.id;

                return InkWell(
                  onTap: () {
                    setState(() {
                      if (_selectedCategory?.id != cat.id) {
                        _selectedCategory = cat;
                        _selectedSubcategory = null;
                        _selectedMerchant = null;
                        _customMerchantName = null;
                      }
                    });
                    _nextStep();
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected ? Color(cat.colorValue).withOpacity(0.15) : Color(cat.colorValue).withOpacity(0.06),
                      border: Border.all(
                        color: isSelected ? Color(cat.colorValue) : Color(cat.colorValue).withOpacity(0.2),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(cat.colorValue).withOpacity(0.15),
                          child: Icon(AppIconResolver.resolveCategoryIcon(cat.id), color: Color(cat.colorValue)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            cat.name,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubcategoryStep() {
    if (_selectedCategory == null) return const SizedBox();
    final subcats = _selectedCategory!.subcategories;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Select ${_selectedCategory!.name} Subcategory', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: subcats.length,
              itemBuilder: (context, idx) {
                final sub = subcats[idx];
                final isSelected = _selectedSubcategory?.id == sub.id;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: isSelected ? Color(_selectedCategory!.colorValue) : Colors.grey.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected ? Color(_selectedCategory!.colorValue).withOpacity(0.08) : null,
                    title: Text(sub.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: isSelected ? Icon(Icons.check_circle, color: Color(_selectedCategory!.colorValue)) : const Icon(Icons.chevron_right),
                    onTap: () {
                      setState(() {
                        if (_selectedSubcategory?.id != sub.id) {
                          _selectedSubcategory = sub;
                          _selectedMerchant = null;
                          _customMerchantName = null;
                        }
                      });
                      _nextStep();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantStep() {
    if (_selectedCategory == null || _selectedSubcategory == null) return const SizedBox();

    // 1. Get all merchants matching this category + subcategory
    final allCategoryMerchants = MerchantRegistry.merchants
        .where((m) => m.categoryId == _selectedCategory!.id && m.subcategoryId == _selectedSubcategory!.id)
        .toList();

    // 2. Derive Recent Merchants from transaction history
    final transactionsState = ref.read(transactionControllerProvider);
    final recentMerchantNames = <String>[];
    if (transactionsState.value != null) {
      final list = transactionsState.value!;
      // Sort by date descending
      final sortedTxs = List<TransactionEntity>.from(list)..sort((a, b) => b.date.compareTo(a.date));
      for (var tx in sortedTxs) {
        if (tx.merchantName != null && tx.categoryId == _selectedCategory!.id && tx.subcategoryId == _selectedSubcategory!.id) {
          if (!recentMerchantNames.contains(tx.merchantName!)) {
            recentMerchantNames.add(tx.merchantName!);
          }
        }
      }
    }

    // Filter merchants based on search query
    final query = _merchantSearchQuery.toLowerCase();
    final List<MerchantDefinition> filteredMerchants = allCategoryMerchants.where((m) {
      if (query.isEmpty) return true;
      return m.name.toLowerCase().contains(query) || m.keywords.any((kw) => kw.contains(query));
    }).toList();

    // Split filtered list into favorites and non-favorites
    final List<MerchantDefinition> favoriteMerchants = [];
    final List<MerchantDefinition> remainingMerchants = [];

    for (var m in filteredMerchants) {
      if (_favoriteMerchantIds.contains(m.id)) {
        favoriteMerchants.add(m);
      } else {
        remainingMerchants.add(m);
      }
    }

    // Build lists for display
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _merchantSearchController,
            decoration: InputDecoration(
              hintText: 'Search merchants...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              setState(() {
                _merchantSearchQuery = val;
              });
            },
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              children: [
                // Recent Merchants Section (only if search is empty)
                if (query.isEmpty && recentMerchantNames.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Recent Merchants', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                  ),
                  ...recentMerchantNames.take(4).map((name) {
                    final matchingDef = allCategoryMerchants.firstWhere((m) => m.name == name, orElse: () {
                      return MerchantDefinition(id: 'custom', name: name, categoryId: _selectedCategory!.id, subcategoryId: _selectedSubcategory!.id, keywords: []);
                    });
                    final isSelected = _selectedMerchant?.name == name || _customMerchantName == name;

                    return ListTile(
                      leading: AppIconResolver.resolveTransactionIcon(
                        categoryId: _selectedCategory!.id,
                        brandKey: matchingDef.brandKey,
                        merchantName: name,
                        size: 36,
                      ),
                      title: Text(name),
                      trailing: isSelected ? Icon(Icons.check_circle, color: Color(_selectedCategory!.colorValue)) : null,
                      onTap: () {
                        setState(() {
                          if (matchingDef.id == 'custom') {
                            _selectedMerchant = null;
                            _customMerchantName = name;
                          } else {
                            _selectedMerchant = matchingDef;
                            _customMerchantName = null;
                          }
                        });
                        _nextStep();
                      },
                    );
                  }),
                  const Divider(),
                ],

                // Favorites Section
                if (favoriteMerchants.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('Favorites', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                  ),
                  ...favoriteMerchants.map((m) => _buildMerchantTile(m, true)),
                  const Divider(),
                ],

                // All Merchants Section
                if (remainingMerchants.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.0),
                    child: Text('All Merchants', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.grey)),
                  ),
                  ...remainingMerchants.map((m) => _buildMerchantTile(m, false)),
                ],

                // Custom Merchant option
                const SizedBox(height: 12),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.grey.withOpacity(0.12),
                    child: const Icon(Icons.add, color: Colors.grey),
                  ),
                  title: const Text('Other Merchant'),
                  onTap: _showCustomMerchantDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMerchantTile(MerchantDefinition m, bool isFav) {
    final isSelected = _selectedMerchant?.id == m.id;
    return ListTile(
      leading: AppIconResolver.resolveTransactionIcon(
        categoryId: _selectedCategory!.id,
        brandKey: m.brandKey,
        merchantName: m.name,
        size: 36,
      ),
      title: Text(m.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(isFav ? Icons.star : Icons.star_border, color: Colors.orange),
            onPressed: () => _toggleFavoriteMerchant(m.id),
          ),
          if (isSelected) Icon(Icons.check_circle, color: Color(_selectedCategory!.colorValue)),
        ],
      ),
      onTap: () {
        setState(() {
          _selectedMerchant = m;
          _customMerchantName = null;
        });
        _nextStep();
      },
    );
  }

  void _showCustomMerchantDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Custom Merchant'),
        content: TextField(
          controller: _customMerchantInputController,
          decoration: const InputDecoration(
            labelText: 'Merchant Name',
            hintText: 'Enter name',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = _customMerchantInputController.text.trim();
              if (name.isNotEmpty) {
                setState(() {
                  _selectedMerchant = null;
                  _customMerchantName = name;
                });
                Navigator.pop(context);
                _nextStep();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountStep(List<AccountEntity> accounts) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Select Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: accounts.length,
              itemBuilder: (context, idx) {
                final acc = accounts[idx];
                final isSelected = _selectedAccount?.id == acc.id;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.08) : null,
                    title: Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(CurrencyUtils.format(acc.balance), style: TextStyle(color: Colors.grey[600])),
                    trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : const Icon(Icons.chevron_right),
                    onTap: () {
                      setState(() {
                        _selectedAccount = acc;
                        // Auto update payment method if not set manually
                        _selectedPaymentMethod = acc.type;
                      });
                      _nextStep();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodStep() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: PaymentMethod.values.length,
              itemBuilder: (context, idx) {
                final method = PaymentMethod.values[idx];
                final isSelected = _selectedPaymentMethod == method;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: isSelected ? Theme.of(context).primaryColor : Colors.grey.withOpacity(0.2)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    tileColor: isSelected ? Theme.of(context).primaryColor.withOpacity(0.08) : null,
                    title: Text(method.name.toUpperCase(), style: const TextStyle(fontWeight: FontWeight.bold)),
                    trailing: isSelected ? Icon(Icons.check_circle, color: Theme.of(context).primaryColor) : const Icon(Icons.chevron_right),
                    onTap: () {
                      setState(() {
                        _selectedPaymentMethod = method;
                      });
                      _nextStep();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('When did this happen?', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() => _selectedDate = DateTime.now());
                  _nextStep();
                },
                child: const Text('Today'),
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() => _selectedDate = DateTime.now().subtract(const Duration(days: 1)));
                  _nextStep();
                },
                child: const Text('Yesterday'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          TextButton.icon(
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2100),
              );
              if (picked != null) {
                setState(() => _selectedDate = picked);
                _nextStep();
              }
            },
            icon: const Icon(Icons.calendar_today),
            label: Text('Custom Date: ${DateUtilsHelper.formatDate(_selectedDate)}'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotesStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Add optional notes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          TextField(
            controller: _notesController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'e.g., Office lunch, subscription, shoes',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  Widget _buildReceiptStep() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Attach Receipt (Optional)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          if (_receiptPath != null) ...[
            Container(
              height: 120,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
                color: Colors.grey.withOpacity(0.05),
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(Icons.insert_drive_file, size: 48, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Receipt Selected', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(_receiptPath!.split('/').last, style: const TextStyle(fontSize: 12, color: Colors.grey), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() => _receiptPath = null);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _receiptPath = '/mock/receipt_camera_${const Uuid().v4().substring(0, 6)}.jpg');
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Camera'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() => _receiptPath = '/mock/receipt_gallery_${const Uuid().v4().substring(0, 6)}.png');
                },
                icon: const Icon(Icons.photo),
                label: const Text('Gallery'),
              ),
            ],
          ),
          const SizedBox(height: 40),
          ElevatedButton(
            onPressed: _nextStep,
            style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: const Text('Review Details'),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewStep() {
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    final merchantName = _customMerchantName ?? _selectedMerchant?.name ?? 'Other';
    final categoryName = _selectedCategory?.name ?? 'Other';
    final subcategoryName = _selectedSubcategory?.name ?? 'Other';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text('Review Transaction', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    '${_transactionType == TransactionType.expense ? "-" : "+"}${CurrencyUtils.format(amount)}',
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: _transactionType == TransactionType.expense ? Colors.red : Colors.green,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    merchantName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$categoryName · $subcategoryName',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Divider(height: 32),
                  _buildReviewRow('Account', _selectedAccount?.name ?? '', 'Account'),
                  _buildReviewRow('Payment Method', _selectedPaymentMethod?.name.toUpperCase() ?? '', 'Payment Method'),
                  _buildReviewRow('Date', DateUtilsHelper.formatDate(_selectedDate), 'Date'),
                  _buildReviewRow('Notes', _notesController.text.isEmpty ? 'None' : _notesController.text, 'Notes'),
                  _buildReviewRow('Receipt', _receiptPath != null ? 'Attached' : 'None', 'Receipt'),
                ],
              ),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _isSaving ? null : _saveTransaction,
            style: ElevatedButton.styleFrom(
              backgroundColor: _transactionType == TransactionType.expense ? Colors.red : Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Text(
                    widget.editTransaction != null ? 'Save Changes' : (_transactionType == TransactionType.expense ? 'Save Expense' : 'Save Income'),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewRow(String label, String value, String stepToJump) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: InkWell(
                onTap: () => _jumpToStep(stepToJump),
                child: Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                  textAlign: TextAlign.right,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (_isSaving) return;
    final amount = double.tryParse(_amountController.text) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter an amount.')));
      return;
    }
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a category.')));
      return;
    }
    if (_selectedSubcategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a subcategory.')));
      return;
    }
    final merchantName = _customMerchantName ?? _selectedMerchant?.name;
    if (merchantName == null || merchantName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select a merchant.')));
      return;
    }
    if (_selectedAccount == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Select an account.')));
      return;
    }

    setState(() => _isSaving = true);

    final finalCat = _selectedCategory!.id;
    final finalSubcat = _selectedSubcategory!.id;
    final finalAcc = _selectedAccount!;
    final merchantId = _selectedMerchant?.id ?? 'custom';
    final brandKey = _selectedMerchant?.brandKey;

    try {
      if (widget.editTransaction != null) {
        final oldTx = widget.editTransaction!;
        final tx = oldTx.copyWith(
          amount: amount,
          type: _transactionType,
          categoryId: finalCat,
          subcategoryId: () => finalSubcat,
          accountId: finalAcc.id,
          title: merchantName,
          description: _notesController.text.trim(),
          date: _selectedDate,
          paymentMethod: _selectedPaymentMethod ?? finalAcc.type,
          merchantId: () => merchantId,
          brandKey: () => brandKey,
          merchantName: () => merchantName,
          receiptPath: () => _receiptPath,
        );

        await ref.read(transactionControllerProvider.notifier).updateTransaction(tx);

        // Adjust budgets if type is expense
        if (_transactionType == TransactionType.expense) {
          final budgets = ref.read(budgetControllerProvider).value ?? [];
          if (oldTx.type == TransactionType.expense) {
            if (oldTx.categoryId == finalCat) {
              final idx = budgets.indexWhere((b) => b.categoryId == finalCat);
              if (idx != -1) {
                final b = budgets[idx];
                final updatedB = b.copyWith(spentAmount: b.spentAmount - oldTx.amount + amount);
                await ref.read(budgetControllerProvider.notifier).updateB(updatedB);
              }
            } else {
              final oldIdx = budgets.indexWhere((b) => b.categoryId == oldTx.categoryId);
              if (oldIdx != -1) {
                final b = budgets[oldIdx];
                final updatedB = b.copyWith(spentAmount: (b.spentAmount - oldTx.amount).clamp(0, double.infinity));
                await ref.read(budgetControllerProvider.notifier).updateB(updatedB);
              }
              final newIdx = budgets.indexWhere((b) => b.categoryId == finalCat);
              if (newIdx != -1) {
                final b = budgets[newIdx];
                final updatedB = b.copyWith(spentAmount: b.spentAmount + amount);
                await ref.read(budgetControllerProvider.notifier).updateB(updatedB);
              }
            }
          }
        }
      } else {
        final tx = TransactionEntity(
          id: const Uuid().v4(),
          amount: amount,
          type: _transactionType,
          categoryId: finalCat,
          subcategoryId: finalSubcat,
          accountId: finalAcc.id,
          title: merchantName,
          description: _notesController.text.trim(),
          date: _selectedDate,
          paymentMethod: _selectedPaymentMethod ?? finalAcc.type,
          createdAt: DateTime.now(),
          merchantId: merchantId,
          brandKey: brandKey,
          merchantName: merchantName,
          receiptPath: _receiptPath,
        );

        await ref.read(transactionControllerProvider.notifier).add(tx);

        // Update budget if expense
        if (_transactionType == TransactionType.expense) {
          final budgets = ref.read(budgetControllerProvider).value ?? [];
          final budgetIndex = budgets.indexWhere((b) => b.categoryId == finalCat);
          if (budgetIndex != -1) {
            final b = budgets[budgetIndex];
            final updatedB = b.copyWith(spentAmount: b.spentAmount + tx.amount);
            await ref.read(budgetControllerProvider.notifier).updateB(updatedB);
          }
        }
      }

      // Force account balances refresh
      await ref.read(accountStateNotifierProvider.notifier).load();

      if (mounted) {
        final actionText = widget.editTransaction != null ? 'updated' : 'added';
        final symbol = _transactionType == TransactionType.expense ? '-' : '+';
        final typeStr = _transactionType == TransactionType.income ? 'Income' : 'Expense';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✓ $typeStr $actionText\n$merchantName · $symbol${CurrencyUtils.format(amount)}'),
            duration: const Duration(seconds: 2),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save transaction. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
