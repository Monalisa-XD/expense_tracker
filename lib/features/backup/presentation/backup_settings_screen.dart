import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'backup_controller.dart';
import '../../repositories/controllers.dart';
import '../../repositories/account_controller.dart';
import '../../repositories/recurring_controller.dart';
import '../../repositories/notification_controller.dart';

class BackupSettingsScreen extends ConsumerWidget {
  const BackupSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(backupControllerProvider);
    final txs = ref.watch(transactionControllerProvider).value ?? [];
    final accounts = ref.watch(accountStateNotifierProvider).activeAccounts;
    final budgets = ref.watch(budgetStateProvider).budgets;
    final recurring = ref.watch(recurringControllerProvider).upcomingPayments;
    final notifications = ref.watch(notificationControllerProvider).notifications;

    // Listen to changes to show success/error snackbars
    ref.listen<BackupState>(backupControllerProvider, (prev, next) {
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green),
                const SizedBox(width: 8),
                Expanded(child: Text(next.successMessage!)),
              ],
            ),
            backgroundColor: Colors.teal[900],
          ),
        );
      }
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(child: Text(next.errorMessage!)),
              ],
            ),
            backgroundColor: Colors.red[900],
          ),
        );
      }

      // Show preview dialog if previewData is loaded
      if (next.previewData != null && (prev == null || prev.previewData == null)) {
        _showPreviewDialog(context, ref, next.previewData!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Data & Backup'),
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // 1. Last Backup Card
              _buildLastBackupCard(context, state),
              const SizedBox(height: 20),

              // 2. Storage Summary Section
              _buildSectionHeader('Storage Summary'),
              _buildStorageSummary(txs.length, accounts.length, budgets.length, recurring.length, notifications.length),
              const SizedBox(height: 20),

              // 3. Backup Actions Section
              _buildSectionHeader('Backup & Import'),
              _buildBackupActions(context, ref, state),
              const SizedBox(height: 20),

              // 4. Danger Zone
              _buildSectionHeader('Danger Zone'),
              _buildDangerZone(context, ref, txs.length),
            ],
          ),
          if (state.isLoading)
            Container(
              color: Colors.black45,
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, top: 8.0),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
    );
  }

  Widget _buildLastBackupCard(BuildContext context, BackupState state) {
    final date = state.lastBackupDate;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.backup_outlined, size: 40, color: Colors.teal),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Last Backup', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    date ?? 'No backup created yet.',
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageSummary(int txCount, int accCount, int budgetCount, int recCount, int notifCount) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildStorageRow(Icons.receipt_long, 'Transactions', txCount),
            const Divider(),
            _buildStorageRow(Icons.account_balance, 'Accounts', accCount),
            const Divider(),
            _buildStorageRow(Icons.track_changes, 'Budgets', budgetCount),
            const Divider(),
            _buildStorageRow(Icons.autorenew, 'Recurring Payments', recCount),
            const Divider(),
            _buildStorageRow(Icons.notifications_none, 'Notifications', notifCount),
          ],
        ),
      ),
    );
  }

  Widget _buildStorageRow(IconData icon, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 14)),
            ],
          ),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildBackupActions(BuildContext context, WidgetRef ref, BackupState state) {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.upload, color: Colors.blue),
            title: const Text('Export Data'),
            subtitle: const Text('Share or save your financial data as JSON'),
            onTap: () => ref.read(backupControllerProvider.notifier).exportBackup(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.download, color: Colors.teal),
            title: const Text('Import Backup'),
            subtitle: const Text('Import local backup from file'),
            onTap: () => ref.read(backupControllerProvider.notifier).startImport(),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, WidgetRef ref, int txCount) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.redAccent, width: 0.8),
      ),
      child: ListTile(
        leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
        title: const Text('Clear All Data', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
        subtitle: const Text('Permanently clear all local transactions, budgets, and settings'),
        onTap: () => _showClearConfirmation(context, ref),
      ),
    );
  }

  void _showClearConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete All Local Data?'),
        content: const Text(
          'This will permanently delete:\n\n'
          '• Transactions\n'
          '• Accounts\n'
          '• Budgets\n'
          '• Recurring Payments\n'
          '• Notifications\n\n'
          'This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(backupControllerProvider.notifier).clearAllData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete Everything'),
          ),
        ],
      ),
    );
  }

  void _showPreviewDialog(BuildContext context, WidgetRef ref, Map<String, dynamic> backupData) {
    final metaMap = backupData['metadata'] as Map<String, dynamic>? ?? {};
    final data = backupData['data'] as Map<String, dynamic>? ?? {};

    final created = metaMap['createdAt'] ?? 'Unknown date';
    final txsCount = (data['transactions'] as List?)?.length ?? 0;
    final accsCount = (data['accounts'] as List?)?.length ?? 0;
    final budgetsCount = (data['budgets'] as List?)?.length ?? 0;
    final recCount = (data['recurringTransactions'] as List?)?.length ?? 0;
    final notifCount = (data['notifications'] as List?)?.length ?? 0;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Backup Preview'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Created: $created', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 12),
            _buildDialogStatsRow(Icons.receipt_long, 'Transactions', txsCount),
            _buildDialogStatsRow(Icons.account_balance, 'Accounts', accsCount),
            _buildDialogStatsRow(Icons.track_changes, 'Budgets', budgetsCount),
            _buildDialogStatsRow(Icons.autorenew, 'Recurring Payments', recCount),
            _buildDialogStatsRow(Icons.notifications_none, 'Notifications', notifCount),
            const SizedBox(height: 16),
            const Text(
              'Import Strategy:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(backupControllerProvider.notifier).clearPreview();
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showRestoreConfirmation(context, ref, backupData, txsCount);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restore (Replace)'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(backupControllerProvider.notifier).executeMerge(backupData);
              Navigator.pop(ctx);
            },
            child: const Text('Merge'),
          ),
        ],
      ),
    );
  }

  void _showRestoreConfirmation(BuildContext context, WidgetRef ref, Map<String, dynamic> backupData, int backupTxsCount) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Restore Backup?'),
        content: Text(
          'This will replace your current local financial data.\n\n'
          'Backup contains: $backupTxsCount transactions.\n\n'
          'This action cannot be automatically undone.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(backupControllerProvider.notifier).clearPreview();
              Navigator.pop(ctx);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(backupControllerProvider.notifier).executeRestore(backupData);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  Widget _buildDialogStatsRow(IconData icon, String label, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(fontSize: 13)),
            ],
          ),
          Text('$count', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }
}
