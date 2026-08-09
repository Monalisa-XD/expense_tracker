import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../repositories/controllers.dart';

class AddBudgetScreen extends ConsumerStatefulWidget {
  final BudgetEntity? editBudget;

  const AddBudgetScreen({super.key, this.editBudget});

  @override
  ConsumerState<AddBudgetScreen> createState() => _AddBudgetScreenState();
}

class _AddBudgetScreenState extends ConsumerState<AddBudgetScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;

  CategoryEntity? _selectedCategory;
  late DateTime _startDate;
  late DateTime _endDate;
  double _alertThreshold = 80.0;
  String _periodType = 'monthly'; // monthly, weekly, custom
  BudgetEntity? _currentEditingBudget; // To track if we switched to editing an existing budget

  @override
  void initState() {
    super.initState();
    _currentEditingBudget = widget.editBudget;
    final b = _currentEditingBudget;
    _amountController = TextEditingController(text: b != null ? b.limitAmount.toString() : '');
    _alertThreshold = b != null ? b.alertPercentage : 80.0;
    _periodType = b != null ? b.periodType : 'monthly';

    if (b != null) {
      _startDate = b.startDate;
      _endDate = b.endDate;
    } else {
      _updateDatesForPeriod('monthly');
    }

    _amountController.addListener(() {
      setState(() {}); // refresh formatted preview
    });
  }

  void _updateDatesForPeriod(String period) {
    final now = DateTime.now();
    if (period == 'monthly') {
      _startDate = DateTime(now.year, now.month, 1);
      _endDate = DateTime(now.year, now.month + 1, 0); // last day of month
    } else if (period == 'weekly') {
      // Start of current week (Monday)
      final weekday = now.weekday;
      final monday = now.subtract(Duration(days: weekday - 1));
      _startDate = DateTime(monday.year, monday.month, monday.day);
      _endDate = _startDate.add(const Duration(days: 6));
    }
  }

  Future<void> _selectDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
        _periodType = 'custom';
      });
    }
  }

  bool _datesOverlap(DateTime s1, DateTime e1, DateTime s2, DateTime e2) {
    final start1 = DateTime(s1.year, s1.month, s1.day);
    final end1 = DateTime(e1.year, e1.month, e1.day);
    final start2 = DateTime(s2.year, s2.month, s2.day);
    final end2 = DateTime(e2.year, e2.month, e2.day);
    return (start1.isBefore(end2) || start1.isAtSameMomentAs(end2)) &&
        (start2.isBefore(end1) || start2.isAtSameMomentAs(end1));
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categoriesVal = ref.watch(categoryControllerProvider);
    final budgetsVal = ref.watch(budgetControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primaryColor = Theme.of(context).colorScheme.primary;

    double enteredAmount = double.tryParse(_amountController.text) ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentEditingBudget != null ? 'Edit Budget' : 'Add Budget'),
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
                  'Budget Limit',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _amountController,
                  validator: AppValidators.amount,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                  ],
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.w900, color: primaryColor),
                  decoration: const InputDecoration(
                    hintText: '0.00',
                    border: InputBorder.none,
                    prefixText: '₹',
                    errorStyle: TextStyle(fontSize: 12),
                  ),
                ),
                if (enteredAmount > 0)
                  Text(
                    'Preview: ${CurrencyUtils.format(enteredAmount)}',
                    style: const TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 32),

                // Category Selector
                categoriesVal.when(
                  data: (cats) {
                    final expenseCats = cats.where((c) => c.type == TransactionType.expense).toList();
                    if (_selectedCategory == null && expenseCats.isNotEmpty) {
                      final b = _currentEditingBudget;
                      if (b != null) {
                        _selectedCategory = expenseCats.firstWhere((c) => c.id == b.categoryId, orElse: () => expenseCats.first);
                      } else {
                        _selectedCategory = expenseCats.first;
                      }
                    }
                    return DropdownButtonFormField<CategoryEntity>(
                      value: _selectedCategory,
                      decoration: InputDecoration(
                        labelText: 'Category',
                        prefixIcon: _selectedCategory != null
                            ? Icon(Icons.category, color: Color(_selectedCategory!.colorValue))
                            : const Icon(Icons.category),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      items: expenseCats.map((c) => DropdownMenuItem(value: c, child: Text(c.name))).toList(),
                      onChanged: (val) => setState(() => _selectedCategory = val),
                    );
                  },
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Text(e.toString()),
                ),
                const SizedBox(height: 20),

                // Period Type Selection (Monthly, Weekly, Custom)
                const Text('Period Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'monthly', label: Text('Monthly'), icon: Icon(Icons.calendar_month)),
                    ButtonSegment(value: 'weekly', label: Text('Weekly'), icon: Icon(Icons.view_week)),
                    ButtonSegment(value: 'custom', label: Text('Custom'), icon: Icon(Icons.edit_calendar)),
                  ],
                  selected: {_periodType},
                  onSelectionChanged: (Set<String> selection) {
                    setState(() {
                      _periodType = selection.first;
                      if (_periodType != 'custom') {
                        _updateDatesForPeriod(_periodType);
                      } else {
                        _selectDateRange();
                      }
                    });
                  },
                ),
                const SizedBox(height: 20),

                // Date Display / Selection Tile
                ListTile(
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  leading: const Icon(Icons.date_range),
                  title: const Text('Budget Duration'),
                  subtitle: Text(
                    '${DateUtilsHelper.formatShortDate(_startDate)} - ${DateUtilsHelper.formatShortDate(_endDate)}',
                    style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.edit, size: 18),
                  onTap: _selectDateRange,
                ),
                const SizedBox(height: 20),

                // Alert Threshold Dropdown
                DropdownButtonFormField<double>(
                  value: _alertThreshold,
                  decoration: InputDecoration(
                    labelText: 'Alert Threshold',
                    prefixIcon: const Icon(Icons.notifications_active),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  items: [50.0, 60.0, 70.0, 80.0, 90.0].map((val) => DropdownMenuItem(
                    value: val,
                    child: Text('${val.toStringAsFixed(0)}% of limit'),
                  )).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _alertThreshold = val);
                  },
                ),
                const SizedBox(height: 36),

                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState?.validate() ?? false) {
                      final category = _selectedCategory;
                      if (category == null) return;

                      // Check for duplicate/overlapping budgets
                      final budgets = budgetsVal.value ?? [];
                      BudgetEntity? overlappingBudget;

                      for (var b in budgets) {
                        // Skip checking against itself if in edit mode
                        if (b.id == _currentEditingBudget?.id) continue;

                        if (b.categoryId == category.id && _datesOverlap(_startDate, _endDate, b.startDate, b.endDate)) {
                          overlappingBudget = b;
                          break;
                        }
                      }

                      if (overlappingBudget != null) {
                        final conflict = overlappingBudget;
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Budget Already Exists'),
                            content: Text('${category.name} already has a budget for this period.'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context); // close dialog
                                  // Switch screen to edit mode for the conflicting budget
                                  setState(() {
                                    _currentEditingBudget = conflict;
                                    _amountController.text = conflict.limitAmount.toString();
                                    _selectedCategory = category;
                                    _startDate = conflict.startDate;
                                    _endDate = conflict.endDate;
                                    _alertThreshold = conflict.alertPercentage;
                                    _periodType = conflict.periodType;
                                  });
                                },
                                child: const Text('Edit Existing Budget'),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      if (_currentEditingBudget != null) {
                        final updated = _currentEditingBudget!.copyWith(
                          limitAmount: double.parse(_amountController.text),
                          categoryId: category.id,
                          startDate: _startDate,
                          endDate: _endDate,
                          alertPercentage: _alertThreshold,
                          periodType: _periodType,
                        );
                        ref.read(budgetControllerProvider.notifier).updateB(updated);
                      } else {
                        final newB = BudgetEntity(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          categoryId: category.id,
                          limitAmount: double.parse(_amountController.text),
                          spentAmount: 0.0,
                          startDate: _startDate,
                          endDate: _endDate,
                          alertPercentage: _alertThreshold,
                          periodType: _periodType,
                        );
                        ref.read(budgetControllerProvider.notifier).add(newB);
                      }

                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(_currentEditingBudget != null ? 'Save Changes' : 'Create Budget'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
