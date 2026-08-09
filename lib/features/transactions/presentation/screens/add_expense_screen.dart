import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../repositories/controllers.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final TransactionEntity? editTransaction;

  const AddExpenseScreen({super.key, this.editTransaction});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _titleController;
  late final TextEditingController _descController;
  late final TextEditingController _notesController;

  CategoryEntity? _selectedCategory;
  AccountEntity? _selectedAccount;
  late PaymentMethod _selectedMethod;
  late DateTime _selectedDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final tx = widget.editTransaction;
    _amountController = TextEditingController(text: tx != null ? tx.amount.toString() : '');
    _titleController = TextEditingController(text: tx != null ? tx.title : '');
    _descController = TextEditingController(text: tx != null ? tx.description ?? '' : '');
    _notesController = TextEditingController(text: ''); // optional notes

    _selectedMethod = tx != null ? tx.paymentMethod : PaymentMethod.upi;
    _selectedDate = tx != null ? tx.date : DateTime.now();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _showCategorySelector(List<CategoryEntity> categories) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              SizedBox(
                height: 240,
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final cat = categories[index];
                    return InkWell(
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        Navigator.pop(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            backgroundColor: Color(cat.colorValue).withOpacity(0.2),
                            child: Icon(Icons.category, color: Color(cat.colorValue)),
                          ),
                          const SizedBox(height: 4),
                          Text(cat.name, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPaymentMethodSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...PaymentMethod.values.map((method) => ListTile(
                title: Text(method.name.toUpperCase()),
                onTap: () {
                  setState(() => _selectedMethod = method);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  void _showAccountSelector(List<AccountEntity> accounts) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Select Account', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ...accounts.map((acc) => ListTile(
                title: Text(acc.name),
                onTap: () {
                  setState(() => _selectedAccount = acc);
                  Navigator.pop(context);
                },
              )),
            ],
          ),
        );
      },
    );
  }

  Future<void> _handleSave(List<CategoryEntity> categories, List<AccountEntity> accounts) async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSaving = true);
      final finalCat = _selectedCategory ?? categories.firstWhere((c) => c.type == TransactionType.expense);
      final finalAcc = _selectedAccount ?? accounts.first;

      final amount = double.parse(_amountController.text);

      if (widget.editTransaction != null) {
        // Edit flow: Update the existing transaction & adjust budget values dynamically
        final oldTx = widget.editTransaction!;
        final tx = oldTx.copyWith(
          amount: amount,
          categoryId: finalCat.id,
          accountId: finalAcc.id,
          title: _titleController.text.trim().isEmpty ? finalCat.name : _titleController.text.trim(),
          description: _descController.text.trim(),
          date: _selectedDate,
          paymentMethod: _selectedMethod,
        );

        await ref.read(transactionControllerProvider.notifier).updateTransaction(tx);

        // Adjust budgets
        final budgets = ref.read(budgetControllerProvider).value ?? [];
        if (oldTx.categoryId == finalCat.id) {
          // Same category, adjust the difference
          final idx = budgets.indexWhere((b) => b.categoryId == finalCat.id);
          if (idx != -1) {
            final b = budgets[idx];
            final updatedB = b.copyWith(spentAmount: b.spentAmount - oldTx.amount + amount);
            await ref.read(budgetControllerProvider.notifier).updateB(updatedB);
          }
        } else {
          // Different category, decrease old, increase new
          final oldIdx = budgets.indexWhere((b) => b.categoryId == oldTx.categoryId);
          if (oldIdx != -1) {
            final b = budgets[oldIdx];
            final updatedB = b.copyWith(spentAmount: (b.spentAmount - oldTx.amount).clamp(0, double.infinity));
            await ref.read(budgetControllerProvider.notifier).updateB(updatedB);
          }
          final newIdx = budgets.indexWhere((b) => b.categoryId == finalCat.id);
          if (newIdx != -1) {
            final b = budgets[newIdx];
            final updatedB = b.copyWith(spentAmount: b.spentAmount + amount);
            await ref.read(budgetControllerProvider.notifier).updateB(updatedB);
          }
        }
      } else {
        // Create flow
        final tx = TransactionEntity(
          id: const Uuid().v4(),
          amount: amount,
          type: TransactionType.expense,
          categoryId: finalCat.id,
          accountId: finalAcc.id,
          title: _titleController.text.trim().isEmpty ? finalCat.name : _titleController.text.trim(),
          description: _descController.text.trim(),
          date: _selectedDate,
          paymentMethod: _selectedMethod,
          createdAt: DateTime.now(),
        );

        await ref.read(transactionControllerProvider.notifier).add(tx);

        // Update budget
        final budgets = ref.read(budgetControllerProvider).value ?? [];
        final budgetIndex = budgets.indexWhere((b) => b.categoryId == finalCat.id);
        if (budgetIndex != -1) {
          final b = budgets[budgetIndex];
          final updatedB = b.copyWith(spentAmount: b.spentAmount + tx.amount);
          await ref.read(budgetControllerProvider.notifier).updateB(updatedB);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.editTransaction != null ? '✓ Expense updated successfully' : '✓ Expense added successfully')),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesVal = ref.watch(categoryControllerProvider);
    final accountsVal = ref.watch(accountControllerProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editTransaction != null ? 'Edit Expense' : 'Add Expense'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Amount',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _amountController,
                  validator: AppValidators.amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: primaryColor),
                  decoration: const InputDecoration(
                    hintText: '₹ 0.00',
                    border: InputBorder.none,
                    errorStyle: TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(height: 24),

                TextFormField(
                  controller: _titleController,
                  maxLength: 40,
                  decoration: InputDecoration(
                    labelText: 'Description',
                    hintText: 'What did you spend on?',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 16),

                categoriesVal.when(
                  data: (cats) {
                    final expenseCats = cats.where((c) => c.type == TransactionType.expense).toList();
                    if (_selectedCategory == null && expenseCats.isNotEmpty) {
                      final tx = widget.editTransaction;
                      if (tx != null) {
                        _selectedCategory = expenseCats.firstWhere((c) => c.id == tx.categoryId, orElse: () => expenseCats.first);
                      } else {
                        _selectedCategory = expenseCats.first;
                      }
                    }
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: const Icon(Icons.category),
                      title: const Text('Category'),
                      trailing: Text(_selectedCategory?.name ?? 'Select', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      onTap: () => _showCategorySelector(expenseCats),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text(e.toString()),
                ),
                const SizedBox(height: 16),

                ListTile(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: const Icon(Icons.calendar_month),
                  title: const Text('Date'),
                  trailing: Text(
                    DateUtilsHelper.formatDate(_selectedDate),
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                  onTap: _selectDate,
                ),
                const SizedBox(height: 16),

                ListTile(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: const Icon(Icons.payment),
                  title: const Text('Payment Method'),
                  trailing: Text(
                    _selectedMethod.name.toUpperCase(),
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                  onTap: _showPaymentMethodSelector,
                ),
                const SizedBox(height: 16),

                accountsVal.when(
                  data: (accs) {
                    if (_selectedAccount == null && accs.isNotEmpty) {
                      final tx = widget.editTransaction;
                      if (tx != null) {
                        _selectedAccount = accs.firstWhere((a) => a.id == tx.accountId, orElse: () => accs.first);
                      } else {
                        _selectedAccount = accs.firstWhere((a) => a.isDefault, orElse: () => accs.first);
                      }
                    }
                    return ListTile(
                      shape: RoundedRectangleBorder(
                        side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      leading: const Icon(Icons.account_balance),
                      title: const Text('Account'),
                      trailing: Text(_selectedAccount?.name ?? 'Select', style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
                      onTap: () => _showAccountSelector(accs),
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text(e.toString()),
                ),
                const SizedBox(height: 16),

                TextFormField(
                  controller: _notesController,
                  maxLines: 3,
                  decoration: InputDecoration(
                    labelText: 'Notes',
                    hintText: 'Optional notes',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isSaving ? null : () {
                    final cats = categoriesVal.value ?? [];
                    final accs = accountsVal.value ?? [];
                    _handleSave(cats, accs);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(_isSaving ? 'Saving...' : 'Save Expense'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
