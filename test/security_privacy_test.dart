import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/features/security/domain/security_settings_entity.dart';
import 'package:expense_tracker/features/security/presentation/privacy_mode_controller.dart';

void main() {
  group('Security & Privacy Mode Unit Tests', () {
    test('SecuritySettingsEntity properties and json mapping', () {
      final settings = SecuritySettingsEntity(
        appLockEnabled: true,
        biometricEnabled: true,
        autoLockDuration: '1 minute',
        privacyModeEnabled: true,
        hideTransactionAmounts: true,
      );

      final map = settings.toMap();
      expect(map['appLockEnabled'], true);
      expect(map['biometricEnabled'], true);
      expect(map['autoLockDuration'], '1 minute');

      final fromMap = SecuritySettingsEntity.fromMap(map);
      expect(fromMap.appLockEnabled, true);
      expect(fromMap.privacyModeEnabled, true);
    });

    test('PrivacyUtils amount masking logic', () {
      // Normal amount masking
      final masked = PrivacyUtils.maskAmount('₹73,850', true);
      expect(masked.contains('₹'), true);
      expect(masked.contains('7'), false);
      expect(masked.contains('8'), false);

      // Unmasked amount
      final normal = PrivacyUtils.maskAmount('₹73,850', false);
      expect(normal, '₹73,850');
    });

    test('PrivacyUtils notification preview masking', () {
      final maskedExpense = PrivacyUtils.maskNotification('Amazon expense of ₹1,299 recorded', true);
      expect(maskedExpense, 'New expense recorded.');

      final maskedIncome = PrivacyUtils.maskNotification('Salary income of ₹75,000 received', true);
      expect(maskedIncome, 'New income recorded.');
    });
  });
}
