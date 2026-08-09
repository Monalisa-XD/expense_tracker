import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../repositories/account_controller.dart';

class AddTransferScreen extends ConsumerStatefulWidget {
  final TransactionEntity? editTransfer;

  const AddTransferScreen({super.key, this.editTransfer});

  @override
  ConsumerState<AddTransferScreen> createState() => _AddTransferScreenState();
}

class _AddTransferScreenState extends ConsumerState<AddTransferScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _descriptionController;

  AccountEntity? _fromAccount;
  AccountEntity? _toAccount;
  DateTime _date = DateTime.now();

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(text: widget.editTransfer?.amount.toString());
    _descriptionController = TextEditingController(text: widget.editTransfer?.description);

    if (widget.editTransfer != null) {
      _date = widget.editTransfer!.date;
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountStateNotifierProvider);
    final accounts = state.activeAccounts;

    if (_fromAccount == null && accounts.isNotEmpty) {
      if (widget.editTransfer != null) {
        _fromAccount = accounts.firstWhere((a) => a.id == widget.editTransfer!.fromAccountId, orElse: () => accounts.first);
      } else {
        _fromAccount = accounts.first;
      }
    }

    if (_toAccount == null && accounts.isNotEmpty) {
      if (widget.editTransfer != null) {
        _toAccount = accounts.firstWhere((a) => a.id == widget.editTransfer!.toAccountId, orElse: () => accounts.last);
      } else {
        _toAccount = accounts.length > 1 ? accounts[1] : accounts.first;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.editTransfer != null ? 'Edit Transfer' : 'Transfer Money'),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  DropdownButtonFormField<AccountEntity>(
                    value: _fromAccount,
                    decoration: const InputDecoration(
                      labelText: 'From Account',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _fromAccount = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  DropdownButtonFormField<AccountEntity>(
                    value: _toAccount,
                    decoration: const InputDecoration(
                      labelText: 'To Account',
                      border: OutlineInputBorder(),
                    ),
                    items: accounts.map((a) => DropdownMenuItem(value: a, child: Text(a.name))).toList(),
                    onChanged: (val) {
                      setState(() {
                        _toAccount = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) return 'Amount is required';
                      final amt = double.tryParse(val);
                      if (amt == null || amt <= 0) return 'Enter a valid amount';
                      if (_fromAccount != null && _fromAccount!.type != PaymentMethod.creditCard && amt > _fromAccount!.balance) {
                        return 'Amount exceeds available balance';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(DateUtilsHelper.formatDate(_date)),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() {
                          _date = picked;
                        });
                      }
                    },
                  ),
                  const Divider(),

                  TextFormField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 32),

                  ElevatedButton(
                    onPressed: _save,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(widget.editTransfer != null ? 'Save Changes' : 'Transfer Money'),
                  ),
                ],
              ),
            ),
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate() || _fromAccount == null || _toAccount == null) {
      return;
    }

    if (_fromAccount!.id == _toAccount!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot transfer money to the same account.')),
      );
      return;
    }

    final amt = double.parse(_amountController.text);
    final desc = _descriptionController.text.isNotEmpty ? _descriptionController.text : 'Transfer to ${_toAccount!.name}';

    final notifier = ref.read(accountStateNotifierProvider.notifier);

    if (widget.editTransfer != null) {
      notifier.updateTransfer(
        transferId: widget.editTransfer!.transferId!,
        fromAccountId: _fromAccount!.id,
        toAccountId: _toAccount!.id,
        amount: amt,
        date: _date,
        description: desc,
      );
    } else {
      notifier.createTransfer(
        fromAccountId: _fromAccount!.id,
        toAccountId: _toAccount!.id,
        amount: amt,
        date: _date,
        description: desc,
      );
    }

    Navigator.pop(context);
  }
}
