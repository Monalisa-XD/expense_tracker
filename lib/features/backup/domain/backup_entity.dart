import '../../../../core/theme/entities.dart';

class BackupMetadata {
  final int backupVersion;
  final String createdAt;
  final String appVersion;
  final String? devicePlatform;

  BackupMetadata({
    required this.backupVersion,
    required this.createdAt,
    required this.appVersion,
    this.devicePlatform,
  });

  Map<String, dynamic> toJson() => {
        'backupVersion': backupVersion,
        'createdAt': createdAt,
        'appVersion': appVersion,
        if (devicePlatform != null) 'devicePlatform': devicePlatform,
      };

  factory BackupMetadata.fromJson(Map<String, dynamic> json) {
    return BackupMetadata(
      backupVersion: json['backupVersion'] as int? ?? 1,
      createdAt: json['createdAt'] as String? ?? '',
      appVersion: json['appVersion'] as String? ?? '1.0.0',
      devicePlatform: json['devicePlatform'] as String?,
    );
  }
}

class BackupPayload {
  final BackupMetadata metadata;
  final List<TransactionEntity> transactions;
  final List<AccountEntity> accounts;
  final List<BudgetEntity> budgets;
  final List<RecurringTransactionEntity> recurringTransactions;
  final List<NotificationEntity> notifications;
  final NotificationSettingsEntity? notificationSettings;

  BackupPayload({
    required this.metadata,
    required this.transactions,
    required this.accounts,
    required this.budgets,
    required this.recurringTransactions,
    required this.notifications,
    this.notificationSettings,
  });
}
