import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'security_controller.dart';
import 'pin_setup_screen.dart';

class SecuritySettingsScreen extends ConsumerWidget {
  const SecuritySettingsScreen({super.key});

  void _showAutoLockPicker(BuildContext context, WidgetRef ref, String current) {
    final options = ['Immediate', '1 minute', '5 minutes', '15 minutes', 'Never'];
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((opt) {
            return ListTile(
              title: Text(opt),
              trailing: opt == current ? const Icon(Icons.check, color: Colors.teal) : null,
              onTap: () {
                final state = ref.read(securityControllerProvider);
                ref.read(securityControllerProvider.notifier).saveSettings(
                      state.settings.copyWith(autoLockDuration: opt),
                    );
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _verifyCurrentPinDialog(BuildContext context, WidgetRef ref, {required VoidCallback onSuccess}) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        String error = '';
        return StatefulBuilder(
          builder: (context, setState) => AlertDialog(
            title: const Text('Enter Current PIN'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: controller,
                  obscureText: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: InputDecoration(
                    labelText: 'PIN',
                    errorText: error.isEmpty ? null : error,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final correct = await ref.read(securityControllerProvider.notifier).verifyAndUnlock(controller.text);
                  if (correct) {
                    Navigator.pop(ctx);
                    onSuccess();
                  } else {
                    setState(() {
                      error = 'Incorrect PIN';
                    });
                  }
                },
                child: const Text('Verify'),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(securityControllerProvider);
    final settings = state.settings;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Security & Privacy'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Security Status Header
          _buildSecurityStatusCard(context, state),
          const SizedBox(height: 20),

          _buildSectionHeader('Security Settings'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('App Lock'),
                  subtitle: const Text('Require PIN to open the app'),
                  value: state.hasPinSet && settings.appLockEnabled,
                  onChanged: (val) {
                    if (val) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const PinSetupScreen()),
                      );
                    } else {
                      _verifyCurrentPinDialog(context, ref, onSuccess: () {
                        ref.read(securityControllerProvider.notifier).removePin();
                      });
                    }
                  },
                ),
                if (state.hasPinSet) ...[
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Biometric Authentication'),
                    subtitle: const Text('Use Face ID / Fingerprint to unlock'),
                    value: settings.biometricEnabled,
                    onChanged: (val) async {
                      final useCases = SecurityUseCases(SecureStorageService());
                      final supported = await useCases.canAuthenticateWithBiometrics();
                      if (supported) {
                        ref.read(securityControllerProvider.notifier).saveSettings(
                              settings.copyWith(biometricEnabled: val),
                            );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Biometric authentication is not available on this device.')),
                        );
                      }
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Auto Lock Timeout'),
                    subtitle: Text('Lock app after: ${settings.autoLockDuration}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showAutoLockPicker(context, ref, settings.autoLockDuration),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    title: const Text('Change PIN'),
                    subtitle: const Text('Modify your security passcode'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _verifyCurrentPinDialog(context, ref, onSuccess: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const PinSetupScreen()),
                        );
                      });
                    },
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 20),

          _buildSectionHeader('Privacy Settings'),
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Privacy Mode'),
                  subtitle: const Text('Mask all balances and summaries'),
                  value: settings.privacyModeEnabled,
                  onChanged: (val) {
                    ref.read(securityControllerProvider.notifier).saveSettings(
                          settings.copyWith(privacyModeEnabled: val),
                        );
                  },
                ),
                const Divider(height: 1),
                SwitchListTile(
                  title: const Text('Hide Transaction Amounts'),
                  subtitle: const Text('Conceal values in transaction lists'),
                  value: settings.hideTransactionAmounts,
                  onChanged: (val) {
                    ref.read(securityControllerProvider.notifier).saveSettings(
                          settings.copyWith(hideTransactionAmounts: val),
                        );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          if (state.hasPinSet) ...[
            ElevatedButton.icon(
              onPressed: () {
                ref.read(securityControllerProvider.notifier).forceLock();
              },
              icon: const Icon(Icons.lock_outline),
              label: const Text('Lock App Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => _showForgotPinDialog(context),
                child: const Text('Forgot PIN?', style: TextStyle(color: Colors.redAccent)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
    );
  }

  Widget _buildSecurityStatusCard(BuildContext context, SecurityState state) {
    final protected = state.hasPinSet && state.settings.appLockEnabled;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(
              protected ? Icons.verified_user : Icons.gpp_maybe,
              size: 40,
              color: protected ? Colors.green : Colors.orange,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    protected ? 'Device Protected' : 'Security Setup Incomplete',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    protected
                        ? 'App Lock and PIN security are active.'
                        : 'Enable App Lock to secure your financial records.',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showForgotPinDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Forgot PIN?'),
        content: const Text(
          'For your privacy and security, PINs cannot be recovered from this device.\n\n'
          'To reset your PIN, you must uninstall and reinstall the application, which will permanently delete all local financial data.',
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
