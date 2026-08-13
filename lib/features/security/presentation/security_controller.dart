import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../domain/security_settings_entity.dart';
import '../domain/security_usecases.dart';
import '../data/secure_storage_service.dart';
import '../../repositories/providers.dart';
import '../../../core/utils/currency_utils.dart';

class SecurityState {
  final SecuritySettingsEntity settings;
  final bool isLocked;
  final bool hasPinSet;
  final int failedAttempts;
  final DateTime? lockoutUntil;
  final DateTime? lastActiveTime;

  SecurityState({
    required this.settings,
    this.isLocked = false,
    this.hasPinSet = false,
    this.failedAttempts = 0,
    this.lockoutUntil,
    this.lastActiveTime,
  });

  SecurityState copyWith({
    SecuritySettingsEntity? settings,
    bool? isLocked,
    bool? hasPinSet,
    int? failedAttempts,
    DateTime? Function()? lockoutUntil,
    DateTime? Function()? lastActiveTime,
  }) {
    return SecurityState(
      settings: settings ?? this.settings,
      isLocked: isLocked ?? this.isLocked,
      hasPinSet: hasPinSet ?? this.hasPinSet,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockoutUntil: lockoutUntil != null ? lockoutUntil() : this.lockoutUntil,
      lastActiveTime: lastActiveTime != null ? lastActiveTime() : this.lastActiveTime,
    );
  }
}

final securityControllerProvider = StateNotifierProvider<SecurityController, SecurityState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final storage = SecureStorageService();
  final useCases = SecurityUseCases(storage);
  return SecurityController(prefs, useCases);
});

class SecurityController extends StateNotifier<SecurityState> with WidgetsBindingObserver {
  final SharedPreferences _prefs;
  final SecurityUseCases _useCases;

  SecurityController(this._prefs, this._useCases)
      : super(SecurityState(
          settings: SecuritySettingsEntity(),
        )) {
    _init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _init() async {
    final raw = _prefs.getString('persist_security_settings');
    var settings = SecuritySettingsEntity();
    if (raw != null) {
      try {
        settings = SecuritySettingsEntity.fromMap(jsonDecode(raw));
      } catch (_) {}
    }
    final hasPin = await _useCases.hasPin();

    CurrencyUtils.privacyMode = settings.privacyModeEnabled;
    CurrencyUtils.hideTransactionAmounts = settings.hideTransactionAmounts;
    state = SecurityState(
      settings: settings,
      hasPinSet: hasPin,
      isLocked: settings.appLockEnabled && hasPin,
      lastActiveTime: DateTime.now(),
    );
  }

  Future<void> saveSettings(SecuritySettingsEntity newSettings) async {
    await _prefs.setString('persist_security_settings', jsonEncode(newSettings.toMap()));
    CurrencyUtils.privacyMode = newSettings.privacyModeEnabled;
    CurrencyUtils.hideTransactionAmounts = newSettings.hideTransactionAmounts;
    state = state.copyWith(settings: newSettings);
  }

  Future<void> setPin(String pin) async {
    await _useCases.savePin(pin);
    state = state.copyWith(hasPinSet: true);
    await saveSettings(state.settings.copyWith(appLockEnabled: true));
  }

  Future<void> removePin() async {
    await _useCases.deletePin();
    state = state.copyWith(hasPinSet: false, isLocked: false);
    await saveSettings(state.settings.copyWith(appLockEnabled: false));
  }

  Future<bool> verifyAndUnlock(String pin) async {
    if (state.lockoutUntil != null && DateTime.now().isBefore(state.lockoutUntil!)) {
      return false;
    }

    final success = await _useCases.verifyPin(pin);
    if (success) {
      state = state.copyWith(
        isLocked: false,
        failedAttempts: 0,
        lockoutUntil: () => null,
        lastActiveTime: () => DateTime.now(),
      );
      return true;
    } else {
      final attempts = state.failedAttempts + 1;
      DateTime? lockout;
      if (attempts >= 5) {
        lockout = DateTime.now().add(const Duration(minutes: 1)); // 1 min lock
      }
      state = state.copyWith(
        failedAttempts: attempts,
        lockoutUntil: () => lockout,
      );
      return false;
    }
  }

  Future<bool> triggerBiometricUnlock() async {
    if (!state.settings.biometricEnabled || !state.hasPinSet) return false;
    final success = await _useCases.authenticateWithBiometrics();
    if (success) {
      state = state.copyWith(
        isLocked: false,
        failedAttempts: 0,
        lockoutUntil: () => null,
        lastActiveTime: () => DateTime.now(),
      );
    }
    return success;
  }

  void forceLock() {
    if (state.hasPinSet) {
      state = state.copyWith(isLocked: true);
    }
  }

  void updateLastActive() {
    state = state.copyWith(lastActiveTime: () => DateTime.now());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycleState) {
    if (!state.settings.appLockEnabled || !state.hasPinSet) return;

    if (lifecycleState == AppLifecycleState.paused) {
      // Going to background: save timestamp
      state = state.copyWith(lastActiveTime: () => DateTime.now());
    } else if (lifecycleState == AppLifecycleState.resumed) {
      // Returning to foreground: evaluate timeout
      final lastActive = state.lastActiveTime;
      if (lastActive != null) {
        final diff = DateTime.now().difference(lastActive);
        final timeout = _getTimeoutDuration(state.settings.autoLockDuration);

        if (timeout != null && diff >= timeout) {
          state = state.copyWith(isLocked: true);
        }
      }
    }
  }

  Duration? _getTimeoutDuration(String option) {
    switch (option) {
      case 'Immediate':
        return Duration.zero;
      case '1 minute':
        return const Duration(minutes: 1);
      case '5 minutes':
        return const Duration(minutes: 5);
      case '15 minutes':
        return const Duration(minutes: 15);
      default:
        return null; // Never
    }
  }
}
