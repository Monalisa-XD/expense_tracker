import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'security_controller.dart';

final privacyModeProvider = Provider<bool>((ref) {
  final securityState = ref.watch(securityControllerProvider);
  return securityState.settings.privacyModeEnabled;
});

final hideTransactionAmountsProvider = Provider<bool>((ref) {
  final securityState = ref.watch(securityControllerProvider);
  return securityState.settings.hideTransactionAmounts;
});

class PrivacyUtils {
  static String maskAmount(String formattedAmount, bool isPrivacyEnabled) {
    if (!isPrivacyEnabled) return formattedAmount;
    
    final buffer = StringBuffer();
    for (var i = 0; i < formattedAmount.length; i++) {
      final char = formattedAmount[i];
      if (char == '-' || char == '+' || char == '₹' || char == '\$' || char == '€' || char == '£') {
        buffer.write(char);
      } else {
        if (buffer.length < 5) {
          buffer.write('•');
        }
      }
    }
    return buffer.toString();
  }

  static String maskText(String original, bool isPrivacyEnabled) {
    if (!isPrivacyEnabled) return original;
    return '••••';
  }

  static String maskNotification(String text, bool isPrivacyEnabled) {
    if (!isPrivacyEnabled) return text;
    if (text.toLowerCase().contains('expense')) {
      return 'New expense recorded.';
    }
    if (text.toLowerCase().contains('income')) {
      return 'New income recorded.';
    }
    return 'Notification details hidden.';
  }
}
