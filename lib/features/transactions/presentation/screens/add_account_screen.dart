import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../repositories/account_controller.dart';

class AddAccountScreen extends ConsumerStatefulWidget {
  final AccountEntity? editAccount;

  const AddAccountScreen({super.key, this.editAccount});

  @override
  ConsumerState<AddAccountScreen> createState() => _AddAccountScreenState();
}

class _AddAccountScreenState extends ConsumerState<AddAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _initialBalanceController;

  PaymentMethod _selectedType = PaymentMethod.bank;
  String _selectedIcon = 'account_balance';
  int _selectedColor = 0xFF0F766E;
  bool _isDefault = false;

  final List<Map<String, dynamic>> _icons = [
    {'name': 'account_balance', 'icon': Icons.account_balance},
    {'name': 'credit_card', 'icon': Icons.credit_card},
    {'name': 'wallet', 'icon': Icons.account_balance_wallet},
    {'name': 'money', 'icon': Icons.money},
  ];

  final List<int> _colors = [
    0xFF0F766E, // Deep Teal
    0xFFEF4444, // Red
    0xFF3B82F6, // Blue
    0xFFF59E0B, // Amber
    0xFF10B981, // Green
    0xFF8B5CF6, // Purple
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.editAccount?.name);
    _initialBalanceController =
        TextEditingController(text: widget.editAccount?.initialBalance.toString() ?? '0');

    if (widget.editAccount != null) {
      final acc = widget.editAccount!;
      _selectedType = acc.type;
      _selectedIcon = acc.icon;
      _selectedColor = acc.color;
      _isDefault = acc.isDefault;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _initialBalanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editAccount != null ? 'Edit Account' : 'Add Account'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Account Name',
                border: OutlineInputBorder(),
              ),
              validator: (val) => val == null || val.isEmpty ? 'Account name is required' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<PaymentMethod>(
              value: _selectedType,
              decoration: const InputDecoration(
                labelText: 'Account Type',
                border: OutlineInputBorder(),
              ),
              items: PaymentMethod.values
                  .map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase())))
                  .toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedType = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            if (widget.editAccount == null)
              TextFormField(
                controller: _initialBalanceController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Initial Balance',
                  border: OutlineInputBorder(),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Initial balance is required';
                  if (double.tryParse(val) == null) return 'Enter a valid number';
                  return null;
                },
              ),
            const SizedBox(height: 16),

            const Text('Choose Icon', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _icons.map((item) {
                final isSelected = _selectedIcon == item['name'];
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedIcon = item['name'];
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : null,
                      border: Border.all(color: isSelected ? Theme.of(context).primaryColor : Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(item['icon'] as IconData),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            const Text('Choose Color', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: _colors.map((c) {
                final isSelected = _selectedColor == c;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedColor = c;
                    });
                  },
                  child: CircleAvatar(
                    backgroundColor: Color(c),
                    radius: 18,
                    child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            SwitchListTile(
              title: const Text('Set as Default Account'),
              value: _isDefault,
              onChanged: (val) {
                setState(() {
                  _isDefault = val;
                });
              },
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              child: Text(widget.editAccount != null ? 'Save Account' : 'Create Account'),
            ),
          ],
        ),
      ),
    );
  }

  bool _isSaving = false;

  void _save() async {
    if (_isSaving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final notifier = ref.read(accountStateNotifierProvider.notifier);

      if (widget.editAccount != null) {
        final updated = widget.editAccount!.copyWith(
          name: _nameController.text,
          type: _selectedType,
          icon: _selectedIcon,
          color: _selectedColor,
          isDefault: _isDefault,
          updatedAt: DateTime.now(),
        );
        await notifier.updateAccount(updated);
      } else {
        final created = AccountEntity(
          id: 'acc_${DateTime.now().millisecondsSinceEpoch}',
          name: _nameController.text,
          balance: double.parse(_initialBalanceController.text),
          type: _selectedType,
          initialBalance: double.parse(_initialBalanceController.text),
          icon: _selectedIcon,
          color: _selectedColor,
          isDefault: _isDefault,
        );
        await notifier.createAccount(created);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Unable to save account. Please try again.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }
}
