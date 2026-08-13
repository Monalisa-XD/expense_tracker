import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'sync_models.dart';
import 'network_info.dart';
import 'remote_datasources.dart';

class SyncEngineState {
  final List<SyncQueueItem> queue;
  final SyncStatus status;
  final String? lastSyncedTime;
  final String? error;

  const SyncEngineState({
    this.queue = const [],
    this.status = SyncStatus.synced,
    this.lastSyncedTime,
    this.error,
  });

  SyncEngineState copyWith({
    List<SyncQueueItem>? queue,
    SyncStatus? status,
    ValueGetter<String?>? lastSyncedTime,
    ValueGetter<String?>? error,
  }) {
    return SyncEngineState(
      queue: queue ?? this.queue,
      status: status ?? this.status,
      lastSyncedTime: lastSyncedTime != null ? lastSyncedTime() : this.lastSyncedTime,
      error: error != null ? error() : this.error,
    );
  }
}

class SyncEngineNotifier extends StateNotifier<SyncEngineState> {
  final SharedPreferences _prefs;
  final NetworkInfo _networkInfo;
  static const _queueKey = 'persist_sync_queue';

  SyncEngineNotifier(this._prefs, this._networkInfo) : super(const SyncEngineState()) {
    _loadQueue();
  }

  void _loadQueue() {
    final raw = _prefs.getString(_queueKey);
    if (raw != null) {
      final List decoded = jsonDecode(raw);
      final list = decoded.map((item) => SyncQueueItem.fromMap(item)).toList();
      state = state.copyWith(
        queue: list,
        status: list.isEmpty ? SyncStatus.synced : SyncStatus.pending,
      );
    }
  }

  Future<void> _saveQueue() async {
    final raw = jsonEncode(state.queue.map((item) => item.toMap()).toList());
    await _prefs.setString(_queueKey, raw);
  }

  Future<void> addToQueue({
    required String entityType,
    required String entityId,
    required String operation,
    required Map<String, dynamic> payload,
  }) async {
    final newItem = SyncQueueItem(
      id: 'sq_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(1000)}',
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      createdAt: DateTime.now(),
      payload: payload,
    );

    state = state.copyWith(
      queue: [...state.queue, newItem],
      status: SyncStatus.pending,
    );
    await _saveQueue();

    // Trigger sync automatically if network is online
    final online = await _networkInfo.isConnected;
    if (online) {
      await syncNow();
    }
  }

  Future<void> syncNow() async {
    if (state.queue.isEmpty) {
      state = state.copyWith(status: SyncStatus.synced, lastSyncedTime: () => _formatTime(DateTime.now()));
      return;
    }

    final online = await _networkInfo.isConnected;
    if (!online) {
      state = state.copyWith(status: SyncStatus.failed, error: () => 'Device is offline');
      return;
    }

    state = state.copyWith(status: SyncStatus.pending);

    final queueCopy = List<SyncQueueItem>.from(state.queue);
    final remaining = <SyncQueueItem>[];

    for (var item in queueCopy) {
      try {
        await _processQueueItem(item);
      } catch (e) {
        // Retry with backoff if within retry budget (max 5)
        if (item.retryCount < 5) {
          remaining.add(item.copyWith(retryCount: item.retryCount + 1));
        } else {
          // Permanently failed
          state = state.copyWith(status: SyncStatus.failed, error: () => 'Sync failed: Max retries exceeded');
          remaining.add(item);
        }
      }
    }

    state = state.copyWith(
      queue: remaining,
      status: remaining.isEmpty ? SyncStatus.synced : SyncStatus.failed,
      lastSyncedTime: () => remaining.isEmpty ? _formatTime(DateTime.now()) : state.lastSyncedTime,
    );
    await _saveQueue();
  }

  Future<void> _processQueueItem(SyncQueueItem item) async {
    // Process sync task based on entity type and operation
    await Future.delayed(const Duration(milliseconds: 100)); // Simulate remote round-trip latency
  }

  String _formatTime(DateTime dt) {
    final hrs = dt.hour.toString().padLeft(2, '0');
    final mins = dt.minute.toString().padLeft(2, '0');
    return '$hrs:$mins';
  }
}

final syncEngineProvider = StateNotifierProvider<SyncEngineNotifier, SyncEngineState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  final net = ref.watch(networkInfoProvider);
  return SyncEngineNotifier(prefs, net);
});

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Must override sharedPrefsProvider inside main.dart');
});
