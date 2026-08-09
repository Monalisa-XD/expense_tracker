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
  final bool isDefault;

  CategoryEntity({
    required this.id,
    required this.name,
    required this.icon,
    required this.colorValue,
    required this.type,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'colorValue': colorValue,
      'type': type.name,
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
      isDefault: map['isDefault'] ?? false,
    );
  }
}

class TransactionEntity {
  final String id;
  final double amount;
  final TransactionType type;
  final String categoryId;
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

  TransactionEntity({
    required this.id,
    required this.amount,
    required this.type,
    required this.categoryId,
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
  });

  TransactionEntity copyWith({
    String? id,
    double? amount,
    TransactionType? type,
    String? categoryId,
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
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      categoryId: categoryId ?? this.categoryId,
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
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type.name,
      'categoryId': categoryId,
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
    };
  }

  factory TransactionEntity.fromMap(Map<String, dynamic> map) {
    return TransactionEntity(
      id: map['id'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      type: TransactionType.values.firstWhere((e) => e.name == map['type'], orElse: () => TransactionType.expense),
      categoryId: map['categoryId'] ?? '',
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

enum RecurringFrequency { daily, weekly, monthly, yearly }

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

class NotificationEntity {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final bool isRead;

  NotificationEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    this.isRead = false,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      isRead: isRead ?? this.isRead,
    );
  }
}
