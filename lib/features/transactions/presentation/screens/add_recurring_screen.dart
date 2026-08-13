import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/theme/brand_registry.dart';
import '../../../repositories/recurring_controller.dart';
import '../../../repositories/controllers.dart';
import '../../../repositories/account_controller.dart';

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
  String _recurringType = 'subscription'; // subscription, rent, emi, insurance, utilities, bills, membership, salary, other
  CategoryEntity? _selectedCategory;
  AccountEntity? _selectedAccount;
  PaymentMethod _paymentMethod = PaymentMethod.upi;
  RecurringFrequency _frequency = RecurringFrequency.monthly;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _autoGenerate = true;

  // New fields
  MerchantEntity? _selectedMerchant;
  bool _isTrial = false;
  DateTime? _trialEndDate;
  int _reminderDays = 1;

  final List<String> _recurringTypes = [
    'subscription',
    'rent',
    'emi',
    'insurance',
    'utilities',
    'bills',
    'membership',
    'salary',
    'other'
  ];

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
      _recurringType = rec.recurringType ?? 'subscription';
      _isTrial = rec.trialEndDate != null;
      _trialEndDate = rec.trialEndDate;
      _reminderDays = rec.reminderDays ?? 1;
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
    final accountsState = ref.watch(accountStateNotifierProvider);

    final categories = (catsState.value ?? []).where((c) => c.type == _type).toList();
    final accounts = accountsState.activeAccounts;

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

    // Filter merchants based on category
    final categoryMerchants = BrandRegistry.merchants
        .where((m) => _selectedCategory != null && m.categoryId == _selectedCategory!.id)
        .toList();

    if (_selectedMerchant == null && categoryMerchants.isNotEmpty && widget.editRecurring != null) {
      final match = categoryMerchants.where((m) => m.brandKey == widget.editRecurring!.brandKey);
      if (match.isNotEmpty) {
        _selectedMerchant = match.first;
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
                  // segment Transaction Type
                  if (widget.editRecurring == null) ...[
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
                          _selectedMerchant = null;
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Dropdown choosing Recurring Type (Rent, Subscription, EMI, etc)
                  DropdownButtonFormField<String>(
                    value: _recurringType,
                    decoration: const InputDecoration(labelText: 'Recurring Type', border: OutlineInputBorder()),
                    items: _recurringTypes.map((t) => DropdownMenuItem(value: t, child: Text(t.toUpperCase()))).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _recurringType = val;
                        });
                      }
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
                        _selectedMerchant = null; // reset merchant on category change
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Merchant Selector
                  if (categoryMerchants.isNotEmpty) ...[
                    DropdownButtonFormField<MerchantEntity?>(
                      value: _selectedMerchant,
                      decoration: const InputDecoration(
                        labelText: 'Merchant / Provider (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      items: [
                        const DropdownMenuItem<MerchantEntity?>(value: null, child: Text('None / Custom')),
                        ...categoryMerchants.map((m) => DropdownMenuItem(value: m, child: Text(m.name))),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedMerchant = val;
                          if (val != null) {
                            _titleController.text = val.name;
                          }
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                  ],

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
                      final parsed = double.tryParse(val);
                      if (parsed == null || parsed <= 0) return 'Enter a valid positive number';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Account Dropdown
                  DropdownButtonFormField<AccountEntity>(
                    value: _selectedAccount,
                    decoration: const InputDecoration(
                      labelText: 'Billing Account',
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

                  // Frequency Dropdown Selector
                  DropdownButtonFormField<RecurringFrequency>(
                    value: _frequency,
                    decoration: const InputDecoration(
                      labelText: 'Billing Cycle',
                      border: OutlineInputBorder(),
                    ),
                    items: RecurringFrequency.values.map((f) {
                      String label = f.name.toUpperCase();
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

                  // Reminder days input
                  DropdownButtonFormField<int>(
                    value: _reminderDays,
                    decoration: const InputDecoration(labelText: 'Notification Reminder', border: OutlineInputBorder()),
                    items: [0, 1, 3, 7].map((d) {
                      final label = d == 0 ? 'Due day only' : '$d days before';
                      return DropdownMenuItem(value: d, child: Text(label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setState(() {
                          _reminderDays = val;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Free trial check
                  SwitchListTile(
                    title: const Text('Free Trial Period'),
                    subtitle: const Text('Choose when the subscription trial finishes'),
                    value: _isTrial,
                    onChanged: (val) {
                      setState(() {
                        _isTrial = val;
                        if (val && _trialEndDate == null) {
                          _trialEndDate = DateTime.now().add(const Duration(days: 7));
                        }
                      });
                    },
                  ),
                  if (_isTrial && _trialEndDate != null) ...[
                    ListTile(
                      title: const Text('Trial End Date'),
                      subtitle: Text(DateUtilsHelper.formatDate(_trialEndDate!)),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: _trialEndDate!,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setState(() {
                            _trialEndDate = picked;
                          });
                        }
                      },
                    ),
                    const Divider(),
                  ],

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
                    title: const Text('End Date (Optional)'),
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

  bool _isSaving = false;

  void _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate() || _selectedCategory == null || _selectedAccount == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
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
          merchantId: () => _selectedMerchant?.id,
          merchantName: () => _selectedMerchant?.name,
          brandKey: () => _selectedMerchant?.brandKey,
          recurringType: _recurringType,
          trialEndDate: () => _isTrial ? _trialEndDate : null,
          reminderDays: _reminderDays,
          isSubscription: _recurringType == 'subscription',
        );
        await notifier.updateRecurring(updated);
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
          merchantId: _selectedMerchant?.id,
          merchantName: _selectedMerchant?.name,
          brandKey: _selectedMerchant?.brandKey,
          recurringType: _recurringType,
          trialEndDate: _isTrial ? _trialEndDate : null,
          reminderDays: _reminderDays,
          isSubscription: _recurringType == 'subscription',
        );
        await notifier.addRecurring(created);
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save recurring transaction. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
