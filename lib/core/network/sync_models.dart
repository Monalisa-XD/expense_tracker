enum SyncStatus {
  synced,
  pending,
  failed,
  conflict,
}

class SyncQueueItem {
  final String id;
  final String entityType; // transaction, account, budget, recurring, notification
  final String entityId;
  final String operation; // create, update, delete
  final DateTime createdAt;
  final Map<String, dynamic> payload;
  final int retryCount;

  const SyncQueueItem({
    required this.id,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.createdAt,
    required this.payload,
    this.retryCount = 0,
  });

  factory SyncQueueItem.fromMap(Map<String, dynamic> map) {
    return SyncQueueItem(
      id: map['id']?.toString() ?? '',
      entityType: map['entityType']?.toString() ?? '',
      entityId: map['entityId']?.toString() ?? '',
      operation: map['operation']?.toString() ?? 'create',
      createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
      payload: Map<String, dynamic>.from(map['payload'] ?? {}),
      retryCount: int.tryParse(map['retryCount']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'entityType': entityType,
      'entityId': entityId,
      'operation': operation,
      'createdAt': createdAt.toIso8601String(),
      'payload': payload,
      'retryCount': retryCount,
    };
  }

  SyncQueueItem copyWith({
    int? retryCount,
  }) {
    return SyncQueueItem(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      createdAt: createdAt,
      payload: payload,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}
