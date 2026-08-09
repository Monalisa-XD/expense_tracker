import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../repositories/providers.dart';

class ProfileTab extends ConsumerWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final isDark = ref.watch(themeModeProvider) == 'dark';
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile Settings')),
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

          // Account Section
          _buildSectionHeader('Account'),
          _buildTile(Icons.person_outline, 'Personal Information', () {}),
          _buildTile(Icons.security_outlined, 'Security', () {}),

          // Preferences Section
          _buildSectionHeader('Preferences'),
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
          _buildTile(Icons.notifications_none_outlined, 'Notifications Settings', () {}),

          // Data Section
          _buildSectionHeader('Data'),
          _buildTile(Icons.import_export, 'Export Data', () {}),
          _buildTile(Icons.backup_outlined, 'Backup & Restore', () {}),

          // Other Section
          _buildSectionHeader('Other'),
          _buildTile(Icons.info_outline, 'About ExpenseX', () {}),
          _buildTile(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
          const Divider(),
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
