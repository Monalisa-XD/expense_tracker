import 'package:local_auth/local_auth.dart';
import '../data/secure_storage_service.dart';

class SecurityUseCases {
  final SecureStorageService _storageService;
  final LocalAuthentication _localAuth = LocalAuthentication();

  SecurityUseCases(this._storageService);

  Future<void> savePin(String pin) async {
    await _storageService.savePin(pin);
  }

  Future<bool> verifyPin(String pin) async {
    return _storageService.verifyPin(pin);
  }

  Future<bool> hasPin() async {
    return _storageService.hasPin();
  }

  Future<void> deletePin() async {
    await _storageService.deletePin();
  }

  Future<bool> canAuthenticateWithBiometrics() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return isSupported && canCheck;
    } catch (_) {
      return false;
    }
  }

  Future<bool> authenticateWithBiometrics() async {
    try {
      final available = await canAuthenticateWithBiometrics();
      if (!available) return false;

      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to unlock Expense Tracker',
        biometricOnly: true,
      );
    } catch (_) {
      return false;
    }
  }
}
