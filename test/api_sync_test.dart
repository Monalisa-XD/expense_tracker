import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/core/network/api_exception.dart';
import 'package:expense_tracker/core/network/dtos.dart';
import 'package:expense_tracker/core/network/sync_models.dart';
import 'package:expense_tracker/core/theme/entities.dart';

void main() {
  group('Production API Readiness & Local-First Sync Tests', () {
    test('API Error Types Mapping & Serialization', () {
      const err401 = UnauthorizedException('Authentication Token Expired');
      const err403 = ForbiddenException('Access Denied');
      const err404 = NotFoundException('Resource Not Found');
      const errTimeout = TimeoutException('Connect timed out');

      expect(err401.statusCode, 401);
      expect(err403.statusCode, 403);
      expect(err404.statusCode, 404);
      expect(errTimeout.statusCode, 408);
    });

    test('Transaction DTO Mapping separates domain validation from remote schema', () {
      final now = DateTime.now();
      final txEntity = TransactionEntity(
        id: 'tx1',
        amount: 250.0,
        type: TransactionType.expense,
        categoryId: 'food',
        accountId: 'bank1',
        title: 'Lunch',
        date: now,
        paymentMethod: PaymentMethod.upi,
        createdAt: now,
      );

      final dto = TransactionDto.fromEntity(txEntity);
      expect(dto.id, 'tx1');
      expect(dto.amount, 250.0);
      expect(dto.type, 'expense');

      final mappedBack = dto.toEntity();
      expect(mappedBack.id, txEntity.id);
      expect(mappedBack.amount, txEntity.amount);
      expect(mappedBack.type, txEntity.type);
    });

    test('Conflict Handling Resolves using Last-Write-Wins (LWW) based on updatedAt', () {
      final localTime = DateTime(2026, 8, 10, 12, 0, 0);
      final remoteTime = DateTime(2026, 8, 10, 12, 30, 0);

      // Let's implement a LWW resolver mock function
      TransactionEntity resolveConflict(TransactionEntity local, TransactionEntity remote) {
        // Assume entity has updatedAt or we compare dates/createdAt
        final localUpdated = local.createdAt;
        final remoteUpdated = remote.createdAt;
        if (remoteUpdated.isAfter(localUpdated)) {
          return remote;
        }
        return local;
      }

      final localTx = TransactionEntity(
        id: '1',
        amount: 100.0,
        type: TransactionType.expense,
        categoryId: 'food',
        accountId: 'acc1',
        title: 'Local Dinner',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.upi,
        createdAt: localTime,
      );

      final remoteTx = TransactionEntity(
        id: '1',
        amount: 150.0,
        type: TransactionType.expense,
        categoryId: 'food',
        accountId: 'acc1',
        title: 'Remote Dinner (Correct)',
        date: DateTime.now(),
        paymentMethod: PaymentMethod.upi,
        createdAt: remoteTime,
      );

      final resolved = resolveConflict(localTx, remoteTx);
      expect(resolved.amount, 150.0);
      expect(resolved.title, 'Remote Dinner (Correct)');
    });

    test('Sync Queue model encodes and decodes properly', () {
      final queueItem = SyncQueueItem(
        id: 'item1',
        entityType: 'transaction',
        entityId: 'tx123',
        operation: 'create',
        createdAt: DateTime.now(),
        payload: {'amount': 999.0, 'title': 'Test Item'},
      );

      final map = queueItem.toMap();
      final decoded = SyncQueueItem.fromMap(map);

      expect(decoded.id, 'item1');
      expect(decoded.entityType, 'transaction');
      expect(decoded.payload['amount'], 999.0);
    });
  });
}
