import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'security_controller.dart';

class AppLockScreen extends ConsumerStatefulWidget {
  final Widget child;

  const AppLockScreen({super.key, required this.child});

  @override
  ConsumerState<AppLockScreen> createState() => _AppLockScreenState();
}

class _AppLockScreenState extends ConsumerState<AppLockScreen> {
  final List<int> _input = [];
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(securityControllerProvider.notifier).triggerBiometricUnlock();
    });
  }

  void _onKeyPress(int value) {
    if (_input.length < 6) {
      setState(() {
        _input.add(value);
        _errorMessage = '';
      });
      if (_input.length >= 4) {
        _verifyPin();
      }
    }
  }

  void _onBackspace() {
    if (_input.isNotEmpty) {
      setState(() {
        _input.removeLast();
        _errorMessage = '';
      });
    }
  }

  Future<void> _verifyPin() async {
    final pinStr = _input.join();
    final unlocked = await ref.read(securityControllerProvider.notifier).verifyAndUnlock(pinStr);
    if (!unlocked) {
      final state = ref.read(securityControllerProvider);
      setState(() {
        if (state.lockoutUntil != null) {
          _errorMessage = 'Too many attempts. Please try again later.';
        } else {
          _errorMessage = 'Incorrect PIN. Try again.';
        }
        if (pinStr.length >= 6 || pinStr.length == 4) {
          _input.clear();
        }
      });
    } else {
      setState(() {
        _input.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(securityControllerProvider);

    if (!state.isLocked || !state.hasPinSet) {
      return widget.child;
    }

    final isLockedOut = state.lockoutUntil != null && DateTime.now().isBefore(state.lockoutUntil!);
    final displayError = isLockedOut ? 'Too many attempts. Locked out.' : _errorMessage;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.lock_outline, size: 64, color: Colors.teal),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Welcome Back 👋',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Your finances are protected.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              const SizedBox(height: 32),

              // PIN Code Dots Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  final active = index < _input.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8.0),
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? Colors.teal : Colors.grey[800],
                      border: Border.all(color: Colors.grey[700]!, width: 1),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              if (displayError.isNotEmpty)
                Center(
                  child: Text(
                    displayError,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              const Spacer(),

              // Numerical Keyboard
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKey(1),
                      _buildKey(2),
                      _buildKey(3),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKey(4),
                      _buildKey(5),
                      _buildKey(6),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildKey(7),
                      _buildKey(8),
                      _buildKey(9),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Bottom Left action: Biometrics if enabled
                      state.settings.biometricEnabled
                          ? IconButton(
                              icon: const Icon(Icons.fingerprint, size: 32, color: Colors.teal),
                              onPressed: isLockedOut
                                  ? null
                                  : () => ref.read(securityControllerProvider.notifier).triggerBiometricUnlock(),
                            )
                          : const SizedBox(width: 48, height: 48),
                      _buildKey(0),
                      IconButton(
                        icon: const Icon(Icons.backspace_outlined, size: 28),
                        onPressed: isLockedOut ? null : _onBackspace,
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKey(int value) {
    final state = ref.read(securityControllerProvider);
    final isLockedOut = state.lockoutUntil != null && DateTime.now().isBefore(state.lockoutUntil!);

    return SizedBox(
      width: 72,
      height: 72,
      child: TextButton(
        onPressed: isLockedOut ? null : () => _onKeyPress(value),
        style: TextButton.styleFrom(
          shape: const CircleBorder(),
          backgroundColor: Colors.blueGrey.withOpacity(0.08),
        ),
        child: Text(
          '$value',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      ),
    );
  }
}
