import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../repositories/notification_controller.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _lowBalanceController;
  late TextEditingController _largeExpenseController;
  late TextEditingController _budgetWarningController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(notificationControllerProvider).settings;
    _lowBalanceController = TextEditingController(text: settings.lowBalanceThreshold.toStringAsFixed(0));
    _largeExpenseController = TextEditingController(text: settings.largeExpenseThreshold.toStringAsFixed(0));
    _budgetWarningController = TextEditingController(text: settings.budgetWarningThreshold.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _lowBalanceController.dispose();
    _largeExpenseController.dispose();
    _budgetWarningController.dispose();
    super.dispose();
  }

  void _saveSettings(NotificationSettingsEntity currentSettings) {
    if (_formKey.currentState!.validate()) {
      final updated = currentSettings.copyWith(
        lowBalanceThreshold: double.tryParse(_lowBalanceController.text) ?? currentSettings.lowBalanceThreshold,
        largeExpenseThreshold: double.tryParse(_largeExpenseController.text) ?? currentSettings.largeExpenseThreshold,
        budgetWarningThreshold: double.tryParse(_budgetWarningController.text) ?? currentSettings.budgetWarningThreshold,
      );

      ref.read(notificationControllerProvider.notifier).updateSettings(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✓ Notification settings saved successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notificationControllerProvider);
    final settings = state.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notification Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () => _saveSettings(settings),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  SwitchListTile(
                    title: const Text('Master Notifications', style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text('Enable or disable all notifications'),
                    value: settings.masterNotifications,
                    onChanged: (val) {
                      ref.read(notificationControllerProvider.notifier).updateSettings(
                            settings.copyWith(masterNotifications: val),
                          );
                    },
                  ),
                  const Divider(),
                  if (settings.masterNotifications) ...[
                    SwitchListTile(
                      title: const Text('Budget Alerts'),
                      subtitle: const Text('Alerts when budget thresholds are reached'),
                      value: settings.budgetAlerts,
                      onChanged: (val) {
                        ref.read(notificationControllerProvider.notifier).updateSettings(
                              settings.copyWith(budgetAlerts: val),
                            );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Recurring Payment Reminders'),
                      subtitle: const Text('Due date warnings for subscriptions & bills'),
                      value: settings.recurringPaymentAlerts,
                      onChanged: (val) {
                        ref.read(notificationControllerProvider.notifier).updateSettings(
                              settings.copyWith(recurringPaymentAlerts: val),
                            );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Low Balance Alerts'),
                      subtitle: const Text('Warnings when accounts drop below minimum'),
                      value: settings.lowBalanceAlerts,
                      onChanged: (val) {
                        ref.read(notificationControllerProvider.notifier).updateSettings(
                              settings.copyWith(lowBalanceAlerts: val),
                            );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Large Expense Alerts'),
                      subtitle: const Text('Notify when a single expense exceeds limit'),
                      value: settings.largeExpenseAlerts,
                      onChanged: (val) {
                        ref.read(notificationControllerProvider.notifier).updateSettings(
                              settings.copyWith(largeExpenseAlerts: val),
                            );
                      },
                    ),
                    SwitchListTile(
                      title: const Text('Monthly Summary & Savings Insights'),
                      subtitle: const Text('Get monthly updates & savings rate change alerts'),
                      value: settings.monthlySummary,
                      onChanged: (val) {
                        ref.read(notificationControllerProvider.notifier).updateSettings(
                              settings.copyWith(monthlySummary: val),
                            );
                      },
                    ),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: Text('Threshold Configurations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextFormField(
                        controller: _budgetWarningController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Budget Warning Threshold (%)',
                          suffixText: '%',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter budget threshold';
                          final d = double.tryParse(val);
                          if (d == null || d <= 0 || d > 100) return 'Enter valid percent (1 - 100)';
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextFormField(
                        controller: _largeExpenseController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Large Expense Threshold (₹)',
                          prefixText: '₹',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter large expense threshold';
                          final d = double.tryParse(val);
                          if (d == null || d <= 0) return 'Enter positive amount';
                          return null;
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                      child: TextFormField(
                        controller: _lowBalanceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Minimum Account Balance (₹)',
                          prefixText: '₹',
                          border: OutlineInputBorder(),
                        ),
                        validator: (val) {
                          if (val == null || val.isEmpty) return 'Enter minimum balance';
                          final d = double.tryParse(val);
                          if (d == null || d < 0) return 'Enter valid balance';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: ElevatedButton(
                        onPressed: () => _saveSettings(settings),
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        child: const Text('Save Settings', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}
