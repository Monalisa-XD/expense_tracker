import '../../core/theme/entities.dart';

class TransactionDto {
  final String id;
  final double amount;
  final String type;
  final String categoryId;
  final String? subcategoryId;
  final String accountId;
  final String title;
  final String? description;
  final String date;
  final String paymentMethod;
  final String createdAt;
  final String? transferId;
  final String? fromAccountId;
  final String? toAccountId;
  final String? merchantId;
  final String? brandKey;
  final String? merchantName;
  final String? receiptPath;

  const TransactionDto({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
    this.subcategoryId,
    required this.accountId,
    required this.title,
    this.description,
    required this.date,
    required this.paymentMethod,
    required this.createdAt,
    this.transferId,
    this.fromAccountId,
    this.toAccountId,
    this.merchantId,
    this.brandKey,
    this.merchantName,
    this.receiptPath,
  });

  factory TransactionDto.fromMap(Map<String, dynamic> map) {
    return TransactionDto(
      id: map['id']?.toString() ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      type: map['type']?.toString() ?? 'expense',
      categoryId: map['categoryId']?.toString() ?? '',
      subcategoryId: map['subcategoryId']?.toString(),
      accountId: map['accountId']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      date: map['date']?.toString() ?? '',
      paymentMethod: map['paymentMethod']?.toString() ?? 'upi',
      createdAt: map['createdAt']?.toString() ?? '',
      transferId: map['transferId']?.toString(),
      fromAccountId: map['fromAccountId']?.toString(),
      toAccountId: map['toAccountId']?.toString(),
      merchantId: map['merchantId']?.toString(),
      brandKey: map['brandKey']?.toString(),
      merchantName: map['merchantName']?.toString(),
      receiptPath: map['receiptPath']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'accountId': accountId,
      'title': title,
      'description': description,
      'date': date,
      'paymentMethod': paymentMethod,
      'createdAt': createdAt,
      'transferId': transferId,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'merchantId': merchantId,
      'brandKey': brandKey,
      'merchantName': merchantName,
      'receiptPath': receiptPath,
    };
  }

  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      amount: amount,
      type: type == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: categoryId,
      subcategoryId: subcategoryId,
      accountId: accountId,
      title: title,
      description: description,
      date: DateTime.tryParse(date) ?? DateTime.now(),
      paymentMethod: PaymentMethod.values.firstWhere((p) => p.name == paymentMethod, orElse: () => PaymentMethod.upi),
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      transferId: transferId,
      fromAccountId: fromAccountId,
      toAccountId: toAccountId,
      merchantId: merchantId,
      brandKey: brandKey,
      merchantName: merchantName,
      receiptPath: receiptPath,
    );
  }

  factory TransactionDto.fromEntity(TransactionEntity entity) {
    return TransactionDto(
      id: entity.id,
      amount: entity.amount,
      type: entity.type.name,
      categoryId: entity.categoryId,
      subcategoryId: entity.subcategoryId,
      accountId: entity.accountId,
      title: entity.title,
      description: entity.description,
      date: entity.date.toIso8601String(),
      paymentMethod: entity.paymentMethod.name,
      createdAt: entity.createdAt.toIso8601String(),
      transferId: entity.transferId,
      fromAccountId: entity.fromAccountId,
      toAccountId: entity.toAccountId,
      merchantId: entity.merchantId,
      brandKey: entity.brandKey,
      merchantName: entity.merchantName,
      receiptPath: entity.receiptPath,
    );
  }
}

class AccountDto {
  final String id;
  final String name;
  final double balance;
  final String type;
  final double initialBalance;
  final String icon;
  final int color;
  final bool isDefault;
  final bool isActive;

  const AccountDto({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    required this.initialBalance,
    required this.icon,
    required this.color,
    required this.isDefault,
    required this.isActive,
  });

  factory AccountDto.fromMap(Map<String, dynamic> map) {
    return AccountDto(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? '',
      balance: double.tryParse(map['balance']?.toString() ?? '0') ?? 0.0,
      type: map['type']?.toString() ?? 'bank',
      initialBalance: double.tryParse(map['initialBalance']?.toString() ?? '0') ?? 0.0,
      icon: map['icon']?.toString() ?? 'account_balance',
      color: int.tryParse(map['color']?.toString() ?? '0') ?? 0,
      isDefault: map['isDefault'] == true,
      isActive: map['isActive'] != false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'type': type,
      'initialBalance': initialBalance,
      'icon': icon,
      'color': color,
      'isDefault': isDefault,
      'isActive': isActive,
    };
  }

  AccountEntity toEntity() {
    return AccountEntity(
      id: id,
      name: name,
      balance: balance,
      type: PaymentMethod.values.firstWhere((p) => p.name == type, orElse: () => PaymentMethod.bank),
      initialBalance: initialBalance,
      icon: icon,
      color: color,
      isDefault: isDefault,
      isActive: isActive,
    );
  }

  factory AccountDto.fromEntity(AccountEntity entity) {
    return AccountDto(
      id: entity.id,
      name: entity.name,
      balance: entity.balance,
      type: entity.type.name,
      initialBalance: entity.initialBalance,
      icon: entity.icon,
      color: entity.color,
      isDefault: entity.isDefault,
      isActive: entity.isActive,
    );
  }
}

class BudgetDto {
  final String id;
  final String categoryId;
  final double limitAmount;
  final double spentAmount;
  final String startDate;
  final String endDate;
  final double alertPercentage;
  final String periodType;
  final String createdAt;

  const BudgetDto({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    required this.spentAmount,
    required this.startDate,
    required this.endDate,
    required this.alertPercentage,
    required this.periodType,
    required this.createdAt,
  });

  factory BudgetDto.fromMap(Map<String, dynamic> map) {
    return BudgetDto(
      id: map['id']?.toString() ?? '',
      categoryId: map['categoryId']?.toString() ?? '',
      limitAmount: double.tryParse(map['limitAmount']?.toString() ?? '0') ?? 0.0,
      spentAmount: double.tryParse(map['spentAmount']?.toString() ?? '0') ?? 0.0,
      startDate: map['startDate']?.toString() ?? '',
      endDate: map['endDate']?.toString() ?? '',
      alertPercentage: double.tryParse(map['alertPercentage']?.toString() ?? '80') ?? 80.0,
      periodType: map['periodType']?.toString() ?? 'monthly',
      createdAt: map['createdAt']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'limitAmount': limitAmount,
      'spentAmount': spentAmount,
      'startDate': startDate,
      'endDate': endDate,
      'alertPercentage': alertPercentage,
      'periodType': periodType,
      'createdAt': createdAt,
    };
  }

  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      categoryId: categoryId,
      limitAmount: limitAmount,
      spentAmount: spentAmount,
      startDate: DateTime.tryParse(startDate) ?? DateTime.now(),
      endDate: DateTime.tryParse(endDate) ?? DateTime.now(),
      alertPercentage: alertPercentage,
      periodType: periodType,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
    );
  }

  factory BudgetDto.fromEntity(BudgetEntity entity) {
    return BudgetDto(
      id: entity.id,
      categoryId: entity.categoryId,
      limitAmount: entity.limitAmount,
      spentAmount: entity.spentAmount,
      startDate: entity.startDate.toIso8601String(),
      endDate: entity.endDate.toIso8601String(),
      alertPercentage: entity.alertPercentage,
      periodType: entity.periodType,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}

class RecurringDto {
  final String id;
  final String title;
  final double amount;
  final String type;
  final String categoryId;
  final String accountId;
  final String paymentMethod;
  final String frequency;
  final String startDate;
  final String? endDate;
  final String nextOccurrenceDate;
  final bool isActive;
  final bool isPaused;
  final bool autoGenerate;
  final String createdAt;
  final String? notes;
  final String? subcategoryId;
  final String? merchantId;
  final String? merchantName;
  final String? brandKey;
  final String? recurringType;
  final String? trialEndDate;
  final int? reminderDays;
  final bool? isSubscription;

  const RecurringDto({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.paymentMethod,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextOccurrenceDate,
    required this.isActive,
    required this.isPaused,
    required this.autoGenerate,
    required this.createdAt,
    this.notes,
    this.subcategoryId,
    this.merchantId,
    this.merchantName,
    this.brandKey,
    this.recurringType,
    this.trialEndDate,
    this.reminderDays,
    this.isSubscription,
  });

  factory RecurringDto.fromMap(Map<String, dynamic> map) {
    return RecurringDto(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      amount: double.tryParse(map['amount']?.toString() ?? '0') ?? 0.0,
      type: map['type']?.toString() ?? 'expense',
      categoryId: map['categoryId']?.toString() ?? '',
      accountId: map['accountId']?.toString() ?? '',
      paymentMethod: map['paymentMethod']?.toString() ?? 'upi',
      frequency: map['frequency']?.toString() ?? 'monthly',
      startDate: map['startDate']?.toString() ?? '',
      endDate: map['endDate']?.toString(),
      nextOccurrenceDate: map['nextOccurrenceDate']?.toString() ?? '',
      isActive: map['isActive'] != false,
      isPaused: map['isPaused'] == true,
      autoGenerate: map['autoGenerate'] != false,
      createdAt: map['createdAt']?.toString() ?? '',
      notes: map['notes']?.toString(),
      subcategoryId: map['subcategoryId']?.toString(),
      merchantId: map['merchantId']?.toString(),
      merchantName: map['merchantName']?.toString(),
      brandKey: map['brandKey']?.toString(),
      recurringType: map['recurringType']?.toString(),
      trialEndDate: map['trialEndDate']?.toString(),
      reminderDays: int.tryParse(map['reminderDays']?.toString() ?? ''),
      isSubscription: map['isSubscription'] == true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'categoryId': categoryId,
      'accountId': accountId,
      'paymentMethod': paymentMethod,
      'frequency': frequency,
      'startDate': startDate,
      'endDate': endDate,
      'nextOccurrenceDate': nextOccurrenceDate,
      'isActive': isActive,
      'isPaused': isPaused,
      'autoGenerate': autoGenerate,
      'createdAt': createdAt,
      'notes': notes,
      'subcategoryId': subcategoryId,
      'merchantId': merchantId,
      'merchantName': merchantName,
      'brandKey': brandKey,
      'recurringType': recurringType,
      'trialEndDate': trialEndDate,
      'reminderDays': reminderDays,
      'isSubscription': isSubscription,
    };
  }

  RecurringTransactionEntity toEntity() {
    return RecurringTransactionEntity(
      id: id,
      title: title,
      amount: amount,
      type: type == 'income' ? TransactionType.income : TransactionType.expense,
      categoryId: categoryId,
      accountId: accountId,
      paymentMethod: PaymentMethod.values.firstWhere((p) => p.name == paymentMethod, orElse: () => PaymentMethod.upi),
      frequency: RecurringFrequency.values.firstWhere((f) => f.name == frequency, orElse: () => RecurringFrequency.monthly),
      startDate: DateTime.tryParse(startDate) ?? DateTime.now(),
      endDate: endDate != null ? DateTime.tryParse(endDate!) : null,
      nextOccurrenceDate: DateTime.tryParse(nextOccurrenceDate) ?? DateTime.now(),
      isActive: isActive,
      isPaused: isPaused,
      autoGenerate: autoGenerate,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      notes: notes,
      subcategoryId: subcategoryId,
      merchantId: merchantId,
      merchantName: merchantName,
      brandKey: brandKey,
      recurringType: recurringType,
      trialEndDate: trialEndDate != null ? DateTime.tryParse(trialEndDate!) : null,
      reminderDays: reminderDays,
      isSubscription: isSubscription,
    );
  }

  factory RecurringDto.fromEntity(RecurringTransactionEntity entity) {
    return RecurringDto(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: entity.type.name,
      categoryId: entity.categoryId,
      accountId: entity.accountId,
      paymentMethod: entity.paymentMethod.name,
      frequency: entity.frequency.name,
      startDate: entity.startDate.toIso8601String(),
      endDate: entity.endDate?.toIso8601String(),
      nextOccurrenceDate: entity.nextOccurrenceDate.toIso8601String(),
      isActive: entity.isActive,
      isPaused: entity.isPaused,
      autoGenerate: entity.autoGenerate,
      createdAt: entity.createdAt.toIso8601String(),
      notes: entity.notes,
      subcategoryId: entity.subcategoryId,
      merchantId: entity.merchantId,
      merchantName: entity.merchantName,
      brandKey: entity.brandKey,
      recurringType: entity.recurringType,
      trialEndDate: entity.trialEndDate?.toIso8601String(),
      reminderDays: entity.reminderDays,
      isSubscription: entity.isSubscription,
    );
  }
}

class NotificationDto {
  final String id;
  final String title;
  final String message;
  final String createdAt;
  final bool isRead;
  final String type;
  final String priority;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final String? scheduledFor;
  final Map<String, dynamic> metadata;

  const NotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.isRead,
    required this.type,
    required this.priority,
    this.relatedEntityId,
    this.relatedEntityType,
    this.scheduledFor,
    required this.metadata,
  });

  factory NotificationDto.fromMap(Map<String, dynamic> map) {
    return NotificationDto(
      id: map['id']?.toString() ?? '',
      title: map['title']?.toString() ?? '',
      message: map['message']?.toString() ?? '',
      createdAt: map['createdAt']?.toString() ?? '',
      isRead: map['isRead'] == true,
      type: map['type']?.toString() ?? 'system',
      priority: map['priority']?.toString() ?? 'normal',
      relatedEntityId: map['relatedEntityId']?.toString(),
      relatedEntityType: map['relatedEntityType']?.toString(),
      scheduledFor: map['scheduledFor']?.toString(),
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'createdAt': createdAt,
      'isRead': isRead,
      'type': type,
      'priority': priority,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
      'scheduledFor': scheduledFor,
      'metadata': metadata,
    };
  }

  NotificationEntity toEntity() {
    return NotificationEntity(
      id: id,
      title: title,
      message: message,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.now(),
      isRead: isRead,
      type: NotificationType.values.firstWhere((t) => t.name == type, orElse: () => NotificationType.system),
      priority: NotificationPriority.values.firstWhere((p) => p.name == priority, orElse: () => NotificationPriority.normal),
      relatedEntityId: relatedEntityId,
      relatedEntityType: relatedEntityType,
      scheduledFor: scheduledFor != null ? DateTime.tryParse(scheduledFor!) : null,
      metadata: metadata,
    );
  }

  factory NotificationDto.fromEntity(NotificationEntity entity) {
    return NotificationDto(
      id: entity.id,
      title: entity.title,
      message: entity.message,
      createdAt: entity.createdAt.toIso8601String(),
      isRead: entity.isRead,
      type: entity.type.name,
      priority: entity.priority.name,
      relatedEntityId: entity.relatedEntityId,
      relatedEntityType: entity.relatedEntityType,
      scheduledFor: entity.scheduledFor?.toIso8601String(),
      metadata: entity.metadata,
    );
  }
}
