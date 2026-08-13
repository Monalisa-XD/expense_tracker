class SecuritySettingsEntity {
  final bool appLockEnabled;
  final bool biometricEnabled;
  final String autoLockDuration; // Immediate, 1 minute, 5 minutes, 15 minutes, Never
  final bool privacyModeEnabled;
  final bool hideTransactionAmounts;

  SecuritySettingsEntity({
    this.appLockEnabled = false,
    this.biometricEnabled = false,
    this.autoLockDuration = '5 minutes',
    this.privacyModeEnabled = false,
    this.hideTransactionAmounts = false,
  });

  SecuritySettingsEntity copyWith({
    bool? appLockEnabled,
    bool? biometricEnabled,
    String? autoLockDuration,
    bool? privacyModeEnabled,
    bool? hideTransactionAmounts,
  }) {
    return SecuritySettingsEntity(
      appLockEnabled: appLockEnabled ?? this.appLockEnabled,
      biometricEnabled: biometricEnabled ?? this.biometricEnabled,
      autoLockDuration: autoLockDuration ?? this.autoLockDuration,
      privacyModeEnabled: privacyModeEnabled ?? this.privacyModeEnabled,
      hideTransactionAmounts: hideTransactionAmounts ?? this.hideTransactionAmounts,
    );
  }

  Map<String, dynamic> toMap() => {
        'appLockEnabled': appLockEnabled,
        'biometricEnabled': biometricEnabled,
        'autoLockDuration': autoLockDuration,
        'privacyModeEnabled': privacyModeEnabled,
        'hideTransactionAmounts': hideTransactionAmounts,
      };

  factory SecuritySettingsEntity.fromMap(Map<String, dynamic> map) {
    return SecuritySettingsEntity(
      appLockEnabled: map['appLockEnabled'] as bool? ?? false,
      biometricEnabled: map['biometricEnabled'] as bool? ?? false,
      autoLockDuration: map['autoLockDuration'] as String? ?? '5 minutes',
      privacyModeEnabled: map['privacyModeEnabled'] as bool? ?? false,
      hideTransactionAmounts: map['hideTransactionAmounts'] as bool? ?? false,
    );
  }
}
