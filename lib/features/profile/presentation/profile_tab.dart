import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/providers.dart';
import '../../../../core/network/sync_engine.dart';
import '../../../../core/network/sync_models.dart';
import '../../transactions/presentation/screens/accounts_tab.dart';
import '../../transactions/presentation/screens/recurring_tab.dart';
import '../../transactions/presentation/screens/notifications_screen.dart';
import '../../transactions/presentation/screens/notification_settings_screen.dart';
import '../../repositories/notification_controller.dart';
import '../../backup/presentation/backup_settings_screen.dart';
import '../../security/presentation/security_settings_screen.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isDark = ref.watch(themeModeProvider) == 'dark';
    final currency = ref.watch(currencyProvider);
    final notifState = ref.watch(notificationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const NotificationsScreen()),
                  );
                },
              ),
              if (notifState.unreadCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${notifState.unreadCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 20),
          Center(
            child: CircleAvatar(
              radius: 44,
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                authState.user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              authState.user?.name ?? 'User Name',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Center(
            child: Text(
              authState.user?.email ?? 'user@example.com',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          const SizedBox(height: 24),

          // Financial Management Section
          _buildSectionHeader('Financial Management'),
          _buildTile(Icons.account_balance, 'Accounts', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AccountsTab()),
            );
          }),
          _buildTile(Icons.autorenew, 'Recurring Payments', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RecurringTab()),
            );
          }),
          _buildNotificationTile(context, ref),

          // Preferences Section
          _buildSectionHeader('Preferences'),
          _buildTile(Icons.settings, 'Notification Settings', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const NotificationSettingsScreen()),
            );
          }),
          _buildTile(Icons.backup_outlined, 'Data & Backup', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const BackupSettingsScreen()),
            );
          }),
          _buildTile(Icons.security, 'Security & Privacy', () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SecuritySettingsScreen()),
            );
          }),
          // Data Sync section
          _buildSectionHeader('Data Sync'),
          Consumer(
            builder: (context, ref, child) {
              final syncState = ref.watch(syncEngineProvider);
              return ListTile(
                leading: const Icon(Icons.sync),
                title: const Text('Synchronization status'),
                subtitle: Text(
                  'Status: ${syncState.status.name.toUpperCase()}\n'
                  'Pending changes: ${syncState.queue.length}\n'
                  'Last synced: ${syncState.lastSyncedTime ?? "Never"}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: ElevatedButton(
                  onPressed: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Synchronizing with remote server...')),
                    );
                    await ref.read(syncEngineProvider.notifier).syncNow();
                    if (context.mounted) {
                      final updatedState = ref.read(syncEngineProvider);
                      final msg = updatedState.status == SyncStatus.synced
                          ? 'Sync complete'
                          : 'Some changes could not be synchronized.';
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(msg)),
                      );
                    }
                  },
                  child: const Text('Sync Now'),
                ),
              );
            },
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            secondary: const Icon(Icons.dark_mode_outlined),
            value: isDark,
            onChanged: (val) {
              ref.read(themeModeProvider.notifier).toggleTheme();
            },
          ),
          ListTile(
            leading: const Icon(Icons.currency_rupee),
            title: const Text('Default Currency'),
            trailing: DropdownButton<String>(
              value: currency,
              items: const [
                DropdownMenuItem(value: 'inr', child: Text('INR (₹)')),
                DropdownMenuItem(value: 'usd', child: Text('USD (\$)')),
                DropdownMenuItem(value: 'eur', child: Text('EUR (€)')),
                DropdownMenuItem(value: 'gbp', child: Text('GBP (£)')),
              ],
              onChanged: (val) {
                if (val != null) {
                  ref.read(currencyProvider.notifier).setCurrency(val);
                }
              },
            ),
          ),

          // Account Section
          _buildSectionHeader('Account'),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await ref.read(authControllerProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);
    final count = state.unreadCount;

    return ListTile(
      leading: const Icon(Icons.notifications_none_outlined),
      title: const Text('Notifications'),
      subtitle: const Text('Financial alerts and reminders'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, size: 20),
        ],
      ),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsScreen()),
        );
      },
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
