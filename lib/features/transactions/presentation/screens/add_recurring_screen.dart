import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../repositories/recurring_controller.dart';
import '../../../repositories/controllers.dart';

class AddRecurringScreen extends ConsumerStatefulWidget {
  final RecurringTransactionEntity? editRecurring;

  const AddRecurringScreen({super.key, this.editRecurring});

  @override
  ConsumerState<AddRecurringScreen> createState() => _AddRecurringScreenState();
}

class _AddRecurringScreenState extends ConsumerState<AddRecurringScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _amountController;
  late TextEditingController _notesController;

  TransactionType _type = TransactionType.expense;
  CategoryEntity? _selectedCategory;
  AccountEntity? _selectedAccount;
  PaymentMethod _paymentMethod = PaymentMethod.upi;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _autoGenerate = true;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.editRecurring?.title);
    _amountController = TextEditingController(text: widget.editRecurring?.amount.toString());
    _notesController = TextEditingController(text: widget.editRecurring?.notes);

    if (widget.editRecurring != null) {
      final rec = widget.editRecurring!;
      _type = rec.type;
      _paymentMethod = rec.paymentMethod;
      _frequency = rec.frequency;
      _startDate = rec.startDate;
      _endDate = rec.endDate;
      _autoGenerate = rec.autoGenerate;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catsState = ref.watch(categoryControllerProvider);
    final accountsState = ref.watch(accountControllerProvider);

    final categories = (catsState.value ?? []).where((c) => c.type == _type).toList();
    final accounts = accountsState.value ?? [];

    if (_selectedCategory == null && categories.isNotEmpty) {
      if (widget.editRecurring != null) {
        _selectedCategory = categories.firstWhere((c) => c.id == widget.editRecurring!.categoryId, orElse: () => categories.first);
      } else {
        _selectedCategory = categories.first;
      }
    }

    if (_selectedAccount == null && accounts.isNotEmpty) {
      if (widget.editRecurring != null) {
        _selectedAccount = accounts.firstWhere((a) => a.id == widget.editRecurring!.accountId, orElse: () => accounts.first);
      } else {
        _selectedAccount = accounts.first;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editRecurring != null ? 'Edit Recurring' : 'Add Recurring'),
      ),
      body: catsState.isLoading || accountsState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  // Type selection segments
                  if (widget.editRecurring == null)
                    SegmentedButton<TransactionType>(
                      segments: const [
                        ButtonSegment(value: TransactionType.expense, label: Text('Expense'), icon: Icon(Icons.arrow_upward)),
                        ButtonSegment(value: TransactionType.income, label: Text('Income'), icon: Icon(Icons.arrow_downward)),
                      ],
                      selected: {_type},
                      onSelectionChanged: (set) {
                        setState(() {
                          _type = set.first;
                          _selectedCategory = null;
                        });
                      },
                    ),
                  const SizedBox(height: 20),

                  // Title Form Field
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 16),

                  // Amount Form Field
                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Amount is required';
                      if (double.tryParse(val) == null) return 'Enter a valid number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Dropdown
                  DropdownButtonFormField<CategoryEntity>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategory = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Account Dropdown
                  DropdownButtonFormField<AccountEntity>(
                    value: _selectedAccount,
                    decoration: const InputDecoration(
                      labelText: 'Account',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedAccount = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Payment Method Dropdown
                  DropdownButtonFormField<PaymentMethod>(
                    value: _paymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items: PaymentMethod.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _paymentMethod = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Frequency Dropdown Selector
                  DropdownButtonFormField<RecurringFrequency>(
                    value: _frequency,
                    decoration: const InputDecoration(
                      labelText: 'Frequency',
                      border: OutlineInputBorder(),
                    ),
                    items: RecurringFrequency.values.map((f) {
                      String label = 'Every month';
                      if (f == RecurringFrequency.daily) label = 'Every day';
                      if (f == RecurringFrequency.weekly) label = 'Every week';
                      if (f == RecurringFrequency.yearly) label = 'Every year';
                      return DropdownMenuItem(value: f, child: Text(label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _frequency = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Start Date Picker Row
                  ListTile(
                    title: const Text('Start Date'),
                    subtitle: Text(DateUtilsHelper.formatDate(_startDate)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _startDate = picked;
                        });
                      }
                    },
                  ),
                  const Divider(),

                  // End Date Picker Row
                  ListTile(
                    title: const Text('End Date'),
                    subtitle: Text(_endDate == null ? 'No End Date' : DateUtilsHelper.formatDate(_endDate!)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_endDate != null)
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              setState(() {
                                _endDate = null;
                              });
                            },
                          ),
                        const Icon(Icons.calendar_today),
                      ],
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _endDate = picked;
                        });
                      }
                    },
                  ),
                  const Divider(),

                  // Auto Generate Switch Row
                  SwitchListTile(
                    title: const Text('Auto Generate Transaction'),
                    subtitle: const Text('Automatically record transaction when due'),
                    value: _autoGenerate,
                    onChanged: (val) {
                      setState(() {
                        _autoGenerate = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Notes Form Field
                  TextFormField(
                    controller: _notesController,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Notes (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(widget.editRecurring != null ? 'Save Recurring' : 'Create Recurring'),
                  ),
                ],
              ),
            ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _selectedCategory == null || _selectedAccount == null) {
      return;
    }

    final notifier = ref.read(recurringControllerProvider.notifier);
    
    if (widget.editRecurring != null) {
      final updated = widget.editRecurring!.copyWith(
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        categoryId: _selectedCategory!.id,
        accountId: _selectedAccount!.id,
        paymentMethod: _paymentMethod,
        frequency: _frequency,
        startDate: _startDate,
        endDate: () => _endDate,
        autoGenerate: _autoGenerate,
        notes: _notesController.text,
      );
      notifier.updateRecurring(updated);
    } else {
      final created = RecurringTransactionEntity(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        type: _type,
        categoryId: _selectedCategory!.id,
        accountId: _selectedAccount!.id,
        paymentMethod: _paymentMethod,
        frequency: _frequency,
        startDate: _startDate,
        endDate: _endDate,
        nextOccurrenceDate: _startDate,
        createdAt: DateTime.now(),
        notes: _notesController.text,
        autoGenerate: _autoGenerate,
      );
      notifier.addRecurring(created);
    }

    Navigator.pop(context);
  }
}
