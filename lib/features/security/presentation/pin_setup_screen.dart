import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'security_controller.dart';

class PinSetupScreen extends ConsumerStatefulWidget {
  const PinSetupScreen({super.key});

  @override
  ConsumerState<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends ConsumerState<PinSetupScreen> {
  final List<int> _firstInput = [];
  final List<int> _secondInput = [];
  bool _isConfirming = false;
  String _errorMessage = '';

  void _onKeyPress(int value) {
    setState(() {
      _errorMessage = '';
    });

    final targetList = _isConfirming ? _secondInput : _firstInput;
    if (targetList.length < 6) {
      setState(() {
        targetList.add(value);
      });

      if (targetList.length >= 4) {
        if (!_isConfirming) {
          // Allow up to 6 digits, but auto-transition to confirm at 6 or if they press a confirm action
          // To keep it simple, we can provide a small "Next" button or check automatically when they stop entering digits.
          // Wait! Personal finance apps usually use exactly 4 or 6 digits. Let's auto-confirm at 4 digits if they want 4 digits, or we can add a checkmark button. Let's automatically transition when first PIN reaches 4 digits for a 4-digit PIN, or support a "Next" button.
          // Better: auto-transition if first reaches 4 digits! Or we can have them enter 4 digits. Let's set a strict 4-digit PIN rule which is simple, fast, and standard!
          if (targetList.length == 4) {
            setState(() {
              _isConfirming = true;
            });
          }
        } else {
          if (targetList.length == 4) {
            _verifyAndSave();
          }
        }
      }
    }
  }

  void _onBackspace() {
    final targetList = _isConfirming ? _secondInput : _firstInput;
    if (targetList.isNotEmpty) {
      setState(() {
        targetList.removeLast();
        _errorMessage = '';
      });
    }
  }

  void _verifyAndSave() {
    final pin1 = _firstInput.join();
    final pin2 = _secondInput.join();

    if (pin1 == pin2) {
      ref.read(securityControllerProvider.notifier).setPin(pin1);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN created successfully!')),
      );
      Navigator.pop(context);
    } else {
      setState(() {
        _secondInput.clear();
        _errorMessage = 'PINs do not match. Please try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = _isConfirming ? 'Confirm your PIN' : 'Create a 4-digit PIN';
    final targetList = _isConfirming ? _secondInput : _firstInput;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Setup PIN'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Icon(Icons.security, size: 64, color: Colors.teal),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _isConfirming ? 'Re-enter your PIN to confirm' : 'Enter a PIN to protect your financial data',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ),
              const SizedBox(height: 32),

              // PIN Code Dots Row (Always show 4 dots since we locked PIN length to 4 digits)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  final active = index < targetList.length;
                  return Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12.0),
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: active ? Colors.teal : Colors.grey[800],
                      border: Border.all(color: Colors.grey[700]!, width: 1.5),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 20),

              if (_errorMessage.isNotEmpty)
                Center(
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.redAccent, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              const Spacer(),

              // Keypad
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
                      const SizedBox(width: 72, height: 72),
                      _buildKey(0),
                      IconButton(
                        icon: const Icon(Icons.backspace_outlined, size: 28),
                        onPressed: _onBackspace,
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
    return SizedBox(
      width: 72,
      height: 72,
      child: TextButton(
        onPressed: () => _onKeyPress(value),
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
