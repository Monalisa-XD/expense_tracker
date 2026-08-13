enum TransactionType { income, expense, transfer }

enum PaymentMethod { cash, bank, creditCard, wallet, upi }

class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? profilePhoto;

  UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.profilePhoto,
  });
}

class CategoryEntity {
  final String id;
  final String name;
  final String icon; // Icon name reference or key
  final int colorValue; // ARGB Hex representation
  final TransactionType type;
  final int sortOrder;
  final bool isActive;
  final bool isDefault;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.type,
    this.sortOrder = 0,
    this.isActive = true,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'colorValue': colorValue,
      'type': type.name,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'isDefault': isDefault,
    };
  }

  factory CategoryEntity.fromMap(Map<String, dynamic> map) {
    return CategoryEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      icon: map['icon'] ?? '',
      colorValue: map['colorValue'] ?? 0,
      type: TransactionType.values.firstWhere((e) => e.name == map['type'], orElse: () => TransactionType.expense),
      sortOrder: map['sortOrder'] ?? 0,
      isActive: map['isActive'] ?? true,
      isDefault: map['isDefault'] ?? false,
    );
  }
}

class MerchantEntity {
  final String id;
  final String categoryId;
  final String name;
  final String? brandKey;
  final String? iconAsset;
  final bool isDefault;
  final bool isActive;

  MerchantEntity({
    required this.id,
    required this.categoryId,
    required this.name,
    this.brandKey,
    this.iconAsset,
    this.isDefault = false,
    this.isActive = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'name': name,
      'brandKey': brandKey,
      'iconAsset': iconAsset,
      'isDefault': isDefault,
      'isActive': isActive,
    };
  }

  factory MerchantEntity.fromMap(Map<String, dynamic> map) {
    return MerchantEntity(
      id: map['id'] ?? '',
      categoryId: map['categoryId'] ?? '',
      name: map['name'] ?? '',
      brandKey: map['brandKey'],
      iconAsset: map['iconAsset'],
      isDefault: map['isDefault'] ?? false,
      isActive: map['isActive'] ?? true,
    );
  }
}

class TransactionEntity {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String? subcategoryId;
  final String accountId;
  final String title;
  final String? description;
  final DateTime date;
  final PaymentMethod paymentMethod;
  final DateTime createdAt;
  final String? recurringTransactionId;
  final DateTime? occurrenceDate;
  final String? transferId;
  final String? fromAccountId;
  final String? toAccountId;
  final String? merchantId;
  final String? brandKey;
  final String? merchantName;
  final String? receiptPath;

  TransactionEntity({
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
    this.recurringTransactionId,
    this.occurrenceDate,
    this.transferId,
    this.fromAccountId,
    this.toAccountId,
    this.merchantId,
    this.brandKey,
    this.merchantName,
    this.receiptPath,
  });

  TransactionEntity copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? Function()? subcategoryId,
    String? accountId,
    String? title,
    String? description,
    DateTime? date,
    PaymentMethod? paymentMethod,
    DateTime? createdAt,
    String? recurringTransactionId,
    DateTime? occurrenceDate,
    String? transferId,
    String? fromAccountId,
    String? toAccountId,
    String? Function()? merchantId,
    String? Function()? brandKey,
    String? Function()? merchantName,
    String? Function()? receiptPath,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      subcategoryId: subcategoryId != null ? subcategoryId() : this.subcategoryId,
      accountId: accountId ?? this.accountId,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      recurringTransactionId: recurringTransactionId ?? this.recurringTransactionId,
      occurrenceDate: occurrenceDate ?? this.occurrenceDate,
      transferId: transferId ?? this.transferId,
      fromAccountId: fromAccountId ?? this.fromAccountId,
      toAccountId: toAccountId ?? this.toAccountId,
      merchantId: merchantId != null ? merchantId() : this.merchantId,
      brandKey: brandKey != null ? brandKey() : this.brandKey,
      merchantName: merchantName != null ? merchantName() : this.merchantName,
      receiptPath: receiptPath != null ? receiptPath() : this.receiptPath,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'accountId': accountId,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'paymentMethod': paymentMethod.name,
      'createdAt': createdAt.toIso8601String(),
      'recurringTransactionId': recurringTransactionId,
      'occurrenceDate': occurrenceDate?.toIso8601String(),
      'transferId': transferId,
      'fromAccountId': fromAccountId,
      'toAccountId': toAccountId,
      'merchantId': merchantId,
      'brandKey': brandKey,
      'merchantName': merchantName,
      'receiptPath': receiptPath,
    };
  }

  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map['id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere((e) => e.name == map['type'], orElse: () => TransactionType.expense),
      categoryId: map['categoryId'] ?? '',
      subcategoryId: map['subcategoryId'],
      accountId: map['accountId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      date: DateTime.parse(map['date']),
      paymentMethod: PaymentMethod.values.firstWhere((e) => e.name == map['paymentMethod'], orElse: () => PaymentMethod.upi),
      createdAt: DateTime.parse(map['createdAt']),
      recurringTransactionId: map['recurringTransactionId'],
      occurrenceDate: map['occurrenceDate'] != null ? DateTime.parse(map['occurrenceDate']) : null,
      transferId: map['transferId'],
      fromAccountId: map['fromAccountId'],
      toAccountId: map['toAccountId'],
      merchantId: map['merchantId'],
      brandKey: map['brandKey'],
      merchantName: map['merchantName'],
      receiptPath: map['receiptPath'],
    );
  }
}

class BudgetEntity {
  final String id;
  final String categoryId;
  final double limitAmount;
  final double spentAmount; // derived/injected at runtime
  final DateTime startDate;
  final DateTime endDate;
  final double alertPercentage; // e.g. 80.0 for 80%
  final String periodType; // monthly, weekly, custom
  final DateTime createdAt;

  BudgetEntity({
    required this.id,
    required this.categoryId,
    required this.limitAmount,
    this.spentAmount = 0.0,
    required this.startDate,
    required this.endDate,
    required this.alertPercentage,
    this.periodType = 'monthly',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  BudgetEntity copyWith({
    String? id,
    String? categoryId,
    double? limitAmount,
    double? spentAmount,
    DateTime? startDate,
    DateTime? endDate,
    double? alertPercentage,
    String? periodType,
    DateTime? createdAt,
  }) {
    return BudgetEntity(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      limitAmount: limitAmount ?? this.limitAmount,
      spentAmount: spentAmount ?? this.spentAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      alertPercentage: alertPercentage ?? this.alertPercentage,
      periodType: periodType ?? this.periodType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'limitAmount': limitAmount,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'alertPercentage': alertPercentage,
      'periodType': periodType,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory BudgetEntity.fromMap(Map<String, dynamic> map) {
    return BudgetEntity(
      id: map['id'] ?? '',
      categoryId: map['categoryId'] ?? '',
      limitAmount: (map['limitAmount'] as num?)?.toDouble() ?? 0.0,
      spentAmount: 0.0, // default derived at runtime
      startDate: DateTime.parse(map['startDate']),
      endDate: DateTime.parse(map['endDate']),
      alertPercentage: (map['alertPercentage'] as num?)?.toDouble() ?? 80.0,
      periodType: map['periodType'] ?? 'monthly',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : null,
    );
  }
}

class AccountEntity {
  final String id;
  final String name;
  final double balance; // Computed at runtime / derived
  final PaymentMethod type;
  final double initialBalance;
  final String icon;
  final int color;
  final bool isActive;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  AccountEntity({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
    this.initialBalance = 0.0,
    this.icon = 'account_balance',
    this.color = 0xFF0F766E,
    this.isActive = true,
    this.isDefault = false,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  AccountEntity copyWith({
    String? id,
    String? name,
    double? balance,
    PaymentMethod? type,
    double? initialBalance,
    String? icon,
    int? color,
    bool? isActive,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      balance: balance ?? this.balance,
      type: type ?? this.type,
      initialBalance: initialBalance ?? this.initialBalance,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      isActive: isActive ?? this.isActive,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'balance': balance,
      'type': type.name,
      'initialBalance': initialBalance,
      'icon': icon,
      'color': color,
      'isActive': isActive,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory AccountEntity.fromMap(Map<String, dynamic> map) {
    return AccountEntity(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      balance: (map['balance'] as num?)?.toDouble() ?? 0.0,
      type: PaymentMethod.values.firstWhere((e) => e.name == map['type'], orElse: () => PaymentMethod.bank),
      initialBalance: (map['initialBalance'] as num?)?.toDouble() ?? 0.0,
      icon: map['icon'] ?? 'account_balance',
      color: map['color'] ?? 0xFF0F766E,
      isActive: map['isActive'] ?? true,
      isDefault: map['isDefault'] ?? false,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
    );
  }
}

enum RecurringFrequency { daily, weekly, monthly, quarterly, halfYearly, yearly, custom }

class RecurringTransactionEntity {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String accountId;
  final PaymentMethod paymentMethod;
  final String? description;
  final String? notes;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime nextOccurrenceDate;
  final DateTime? lastGeneratedDate;
  final bool isActive;
  final bool isPaused;
  final bool autoGenerate;
  final DateTime createdAt;
  final List<String> skippedOccurrences; // Dates as ISO strings
  final String? subcategoryId;
  final String? merchantId;
  final String? merchantName;
  final String? brandKey;
  final String? recurringType; // subscription, rent, emi, insurance, utilities, bills, membership, salary, recurringIncome, other
  final DateTime? trialEndDate;
  final int? reminderDays;
  final bool? isSubscription;

  RecurringTransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.paymentMethod,
    this.description,
    this.notes,
    required this.frequency,
    required this.startDate,
    this.endDate,
    required this.nextOccurrenceDate,
    this.lastGeneratedDate,
    this.isActive = true,
    this.isPaused = false,
    this.autoGenerate = true,
    required this.createdAt,
    this.skippedOccurrences = const [],
    this.subcategoryId,
    this.merchantId,
    this.merchantName,
    this.brandKey,
    this.recurringType = 'other',
    this.trialEndDate,
    this.reminderDays = 1,
    this.isSubscription = false,
  });

  RecurringTransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    TransactionType? type,
    String? categoryId,
    String? accountId,
    PaymentMethod? paymentMethod,
    String? description,
    String? notes,
    RecurringFrequency? frequency,
    DateTime? startDate,
    DateTime? Function()? endDate,
    DateTime? nextOccurrenceDate,
    DateTime? Function()? lastGeneratedDate,
    bool? isActive,
    bool? isPaused,
    bool? autoGenerate,
    DateTime? createdAt,
    List<String>? skippedOccurrences,
    String? Function()? subcategoryId,
    String? Function()? merchantId,
    String? Function()? merchantName,
    String? Function()? brandKey,
    String? recurringType,
    DateTime? Function()? trialEndDate,
    int? reminderDays,
    bool? isSubscription,
  }) {
    return RecurringTransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      description: description ?? this.description,
      notes: notes ?? this.notes,
      frequency: frequency ?? this.frequency,
      startDate: startDate ?? this.startDate,
      endDate: endDate != null ? endDate() : this.endDate,
      nextOccurrenceDate: nextOccurrenceDate ?? this.nextOccurrenceDate,
      lastGeneratedDate: lastGeneratedDate != null ? lastGeneratedDate() : this.lastGeneratedDate,
      isActive: isActive ?? this.isActive,
      isPaused: isPaused ?? this.isPaused,
      autoGenerate: autoGenerate ?? this.autoGenerate,
      createdAt: createdAt ?? this.createdAt,
      skippedOccurrences: skippedOccurrences ?? this.skippedOccurrences,
      subcategoryId: subcategoryId != null ? subcategoryId() : this.subcategoryId,
      merchantId: merchantId != null ? merchantId() : this.merchantId,
      merchantName: merchantName != null ? merchantName() : this.merchantName,
      brandKey: brandKey != null ? brandKey() : this.brandKey,
      recurringType: recurringType ?? this.recurringType,
      trialEndDate: trialEndDate != null ? trialEndDate() : this.trialEndDate,
      reminderDays: reminderDays ?? this.reminderDays,
      isSubscription: isSubscription ?? this.isSubscription,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
      'accountId': accountId,
      'paymentMethod': paymentMethod.name,
      'description': description,
      'notes': notes,
      'frequency': frequency.name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'nextOccurrenceDate': nextOccurrenceDate.toIso8601String(),
      'lastGeneratedDate': lastGeneratedDate?.toIso8601String(),
      'isActive': isActive,
      'isPaused': isPaused,
      'autoGenerate': autoGenerate,
      'createdAt': createdAt.toIso8601String(),
      'skippedOccurrences': skippedOccurrences,
      'subcategoryId': subcategoryId,
      'merchantId': merchantId,
      'merchantName': merchantName,
      'brandKey': brandKey,
      'recurringType': recurringType,
      'trialEndDate': trialEndDate?.toIso8601String(),
      'reminderDays': reminderDays,
      'isSubscription': isSubscription,
    };
  }

  factory RecurringTransactionEntity.fromMap(Map<String, dynamic> map) {
    return RecurringTransactionEntity(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere((e) => e.name == map['type'], orElse: () => TransactionType.expense),
      categoryId: map['categoryId'] ?? '',
      accountId: map['accountId'] ?? '',
      paymentMethod: PaymentMethod.values.firstWhere((e) => e.name == map['paymentMethod'], orElse: () => PaymentMethod.upi),
      description: map['description'],
      notes: map['notes'],
      frequency: RecurringFrequency.values.firstWhere((e) => e.name == map['frequency'], orElse: () => RecurringFrequency.monthly),
      startDate: DateTime.parse(map['startDate']),
      endDate: map['endDate'] != null ? DateTime.parse(map['endDate']) : null,
      nextOccurrenceDate: DateTime.parse(map['nextOccurrenceDate']),
      lastGeneratedDate: map['lastGeneratedDate'] != null ? DateTime.parse(map['lastGeneratedDate']) : null,
      isActive: map['isActive'] ?? true,
      isPaused: map['isPaused'] ?? false,
      autoGenerate: map['autoGenerate'] ?? true,
      createdAt: DateTime.parse(map['createdAt']),
      skippedOccurrences: List<String>.from(map['skippedOccurrences'] ?? []),
      subcategoryId: map['subcategoryId'],
      merchantId: map['merchantId'],
      merchantName: map['merchantName'],
      brandKey: map['brandKey'],
      recurringType: map['recurringType'] ?? 'other',
      trialEndDate: map['trialEndDate'] != null ? DateTime.parse(map['trialEndDate']) : null,
      reminderDays: map['reminderDays'] as int? ?? 1,
      isSubscription: map['isSubscription'] as bool? ?? false,
    );
  }
}

class RecurringExpenseEntity {
  final String id;
  final String name;
  final double amount;
  final String categoryId;
  final String accountId;
  final RecurringFrequency frequency;
  final DateTime startDate;
  final DateTime? endDate;
  final bool reminderActive;

  RecurringExpenseEntity({
    required this.id,
    required this.name,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.reminderActive = true,
  });
}

enum NotificationType {
  budgetWarning,
  budgetCritical,
  budgetExceeded,
  recurringUpcoming,
  recurringDue,
  recurringPayment,
  lowBalance,
  largeExpense,
  weeklySummary,
  monthlySummary,
  accountUpdate,
  system
}

enum NotificationPriority {
  low,
  normal,
  high,
  critical
}

class NotificationEntity {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationPriority priority;
  final String? relatedEntityId;
  final String? relatedEntityType;
  final DateTime? scheduledFor;
  final Map<String, dynamic> metadata;

  NotificationEntity({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    this.priority = NotificationPriority.normal,
    this.relatedEntityId,
    this.relatedEntityType,
    this.scheduledFor,
    this.metadata = const {},
  });

  NotificationEntity copyWith({
    String? id,
    NotificationType? type,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    NotificationPriority? priority,
    String? Function()? relatedEntityId,
    String? Function()? relatedEntityType,
    DateTime? Function()? scheduledFor,
    Map<String, dynamic>? metadata,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      priority: priority ?? this.priority,
      relatedEntityId: relatedEntityId != null ? relatedEntityId() : this.relatedEntityId,
      relatedEntityType: relatedEntityType != null ? relatedEntityType() : this.relatedEntityType,
      scheduledFor: scheduledFor != null ? scheduledFor() : this.scheduledFor,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.name,
      'title': title,
      'message': message,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'priority': priority.name,
      'relatedEntityId': relatedEntityId,
      'relatedEntityType': relatedEntityType,
      'scheduledFor': scheduledFor?.toIso8601String(),
      'metadata': metadata,
    };
  }

  factory NotificationEntity.fromMap(Map<String, dynamic> map) {
    return NotificationEntity(
      id: map['id'] ?? '',
      type: NotificationType.values.firstWhere((e) => e.name == map['type'], orElse: () => NotificationType.system),
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      createdAt: DateTime.parse(map['createdAt']),
      isRead: map['isRead'] ?? false,
      priority: NotificationPriority.values.firstWhere((e) => e.name == map['priority'], orElse: () => NotificationPriority.normal),
      relatedEntityId: map['relatedEntityId'],
      relatedEntityType: map['relatedEntityType'],
      scheduledFor: map['scheduledFor'] != null ? DateTime.parse(map['scheduledFor']) : null,
      metadata: Map<String, dynamic>.from(map['metadata'] ?? {}),
    );
  }
}

class NotificationSettingsEntity {
  final bool masterNotifications;
  final bool budgetAlerts;
  final bool recurringPaymentAlerts;
  final bool lowBalanceAlerts;
  final bool largeExpenseAlerts;
  final bool weeklySummary;
  final bool monthlySummary;
  final double lowBalanceThreshold;
  final double largeExpenseThreshold;
  final double budgetWarningThreshold;

  NotificationSettingsEntity({
    this.masterNotifications = true,
    this.budgetAlerts = true,
    this.recurringPaymentAlerts = true,
    this.lowBalanceAlerts = true,
    this.largeExpenseAlerts = true,
    this.weeklySummary = true,
    this.monthlySummary = true,
    this.lowBalanceThreshold = 3000.0,
    this.largeExpenseThreshold = 10000.0,
    this.budgetWarningThreshold = 90.0,
  });

  NotificationSettingsEntity copyWith({
    bool? masterNotifications,
    bool? budgetAlerts,
    bool? recurringPaymentAlerts,
    bool? lowBalanceAlerts,
    bool? largeExpenseAlerts,
    bool? weeklySummary,
    bool? monthlySummary,
    double? lowBalanceThreshold,
    double? largeExpenseThreshold,
    double? budgetWarningThreshold,
  }) {
    return NotificationSettingsEntity(
      masterNotifications: masterNotifications ?? this.masterNotifications,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      recurringPaymentAlerts: recurringPaymentAlerts ?? this.recurringPaymentAlerts,
      lowBalanceAlerts: lowBalanceAlerts ?? this.lowBalanceAlerts,
      largeExpenseAlerts: largeExpenseAlerts ?? this.largeExpenseAlerts,
      weeklySummary: weeklySummary ?? this.weeklySummary,
      monthlySummary: monthlySummary ?? this.monthlySummary,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
      largeExpenseThreshold: largeExpenseThreshold ?? this.largeExpenseThreshold,
      budgetWarningThreshold: budgetWarningThreshold ?? this.budgetWarningThreshold,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'masterNotifications': masterNotifications,
      'budgetAlerts': budgetAlerts,
      'recurringPaymentAlerts': recurringPaymentAlerts,
      'lowBalanceAlerts': lowBalanceAlerts,
      'largeExpenseAlerts': largeExpenseAlerts,
      'weeklySummary': weeklySummary,
      'monthlySummary': monthlySummary,
      'lowBalanceThreshold': lowBalanceThreshold,
      'largeExpenseThreshold': largeExpenseThreshold,
      'budgetWarningThreshold': budgetWarningThreshold,
    };
  }

  factory NotificationSettingsEntity.fromMap(Map<String, dynamic> map) {
    return NotificationSettingsEntity(
      masterNotifications: map['masterNotifications'] ?? true,
      budgetAlerts: map['budgetAlerts'] ?? true,
      recurringPaymentAlerts: map['recurringPaymentAlerts'] ?? true,
      lowBalanceAlerts: map['lowBalanceAlerts'] ?? true,
      largeExpenseAlerts: map['largeExpenseAlerts'] ?? true,
      weeklySummary: map['weeklySummary'] ?? true,
      monthlySummary: map['monthlySummary'] ?? true,
      lowBalanceThreshold: (map['lowBalanceThreshold'] as num?)?.toDouble() ?? 3000.0,
      largeExpenseThreshold: (map['largeExpenseThreshold'] as num?)?.toDouble() ?? 10000.0,
      budgetWarningThreshold: (map['budgetWarningThreshold'] as num?)?.toDouble() ?? 90.0,
    );
  }
}
