import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../repositories/notification_controller.dart';
import '../../../repositories/controllers.dart';
import '../../../repositories/account_controller.dart';
import '../../../budgets/presentation/screens/budget_details_screen.dart';
import 'recurring_tab.dart'; 
import 'transaction_detail_screen.dart';
import 'account_detail_screen.dart';
import '../../../../features/analytics/presentation/screens/analytics_tab.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.notifications.any((n) => !n.isRead))
            IconButton(
              icon: const Icon(Icons.done_all),
              tooltip: 'Mark all as read',
              onPressed: () {
                ref.read(notificationControllerProvider.notifier).markAllAsRead();
              },
            ),
          if (state.notifications.any((n) => n.isRead))
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Delete all read',
              onPressed: () {
                ref.read(notificationControllerProvider.notifier).clearReadNotifications();
              },
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.notifications.isEmpty
              ? _buildEmptyState(context)
              : _buildList(context, ref, state.notifications),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notifications_none, size: 80, color: Theme.of(context).disabledColor),
          const SizedBox(height: 16),
          const Text(
            "🎉 You're all caught up!",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'No financial alerts right now.',
            style: TextStyle(color: Theme.of(context).disabledColor),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<NotificationEntity> list) {
    // Group notifications: Today, Yesterday, Earlier
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final List<NotificationEntity> todayNotifs = [];
    final List<NotificationEntity> yesterdayNotifs = [];
    final List<NotificationEntity> earlierNotifs = [];

    for (var n in list) {
      final createdDate = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (createdDate.isAtSameMomentAs(today)) {
        todayNotifs.add(n);
      } else if (createdDate.isAtSameMomentAs(yesterday)) {
        yesterdayNotifs.add(n);
      } else {
        earlierNotifs.add(n);
      }
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        if (todayNotifs.isNotEmpty) ...[
          _buildGroupHeader('Today'),
          ...todayNotifs.map((n) => _buildItem(context, ref, n)),
          const SizedBox(height: 16),
        ],
        if (yesterdayNotifs.isNotEmpty) ...[
          _buildGroupHeader('Yesterday'),
          ...yesterdayNotifs.map((n) => _buildItem(context, ref, n)),
          const SizedBox(height: 16),
        ],
        if (earlierNotifs.isNotEmpty) ...[
          _buildGroupHeader('Earlier'),
          ...earlierNotifs.map((n) => _buildItem(context, ref, n)),
        ],
      ],
    );
  }

  Widget _buildGroupHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.grey),
      ),
    );
  }

  Widget _buildItem(BuildContext context, WidgetRef ref, NotificationEntity n) {
    final leadingIcon = _getIcon(n.type);
    final leadingColor = _getPriorityColor(n.priority);

    return Dismissible(
      key: Key(n.id),
      direction: DismissDirection.endToStart,
      onDismissed: (dir) {
        ref.read(notificationControllerProvider.notifier).deleteNotification(n.id);
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        color: n.isRead ? null : Theme.of(context).colorScheme.primaryContainer.withOpacity(0.08),
        margin: const EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: n.isRead ? Colors.grey.withOpacity(0.15) : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            width: n.isRead ? 1 : 1.5,
          ),
        ),
        child: ListTile(
          onTap: () => _handleNavigation(context, ref, n),
          leading: CircleAvatar(
            backgroundColor: leadingColor.withOpacity(0.12),
            child: Icon(leadingIcon, color: leadingColor),
          ),
          title: Text(
            n.title,
            style: TextStyle(
              fontWeight: n.isRead ? FontWeight.normal : FontWeight.bold,
              fontSize: 14,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(n.message, style: const TextStyle(fontSize: 13)),
              const SizedBox(height: 6),
              Text(
                DateUtilsHelper.formatShortDate(n.createdAt),
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
          trailing: n.isRead
              ? null
              : Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                ),
        ),
      ),
    );
  }

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.budgetWarning:
      case NotificationType.budgetCritical:
      case NotificationType.budgetExceeded:
        return Icons.track_changes;
      case NotificationType.recurringUpcoming:
      case NotificationType.recurringDue:
      case NotificationType.recurringPayment:
        return Icons.autorenew;
      case NotificationType.lowBalance:
        return Icons.account_balance;
      case NotificationType.largeExpense:
        return Icons.warning_amber;
      case NotificationType.weeklySummary:
      case NotificationType.monthlySummary:
        return Icons.analytics;
      default:
        return Icons.notifications;
    }
  }

  Color _getPriorityColor(NotificationPriority p) {
    switch (p) {
      case NotificationPriority.critical:
        return Colors.red;
      case NotificationPriority.high:
        return Colors.orange;
      case NotificationPriority.normal:
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  void _handleNavigation(BuildContext context, WidgetRef ref, NotificationEntity n) async {
    // 1. Mark as read
    await ref.read(notificationControllerProvider.notifier).markAsRead(n.id);

    if (n.relatedEntityId == null || !context.mounted) return;

    if (n.relatedEntityType == 'budget') {
      final budgets = ref.read(budgetControllerProvider).value ?? [];
      final b = budgets.firstWhere((item) => item.id == n.relatedEntityId);
      final cats = ref.read(categoryControllerProvider).value ?? [];
      final cat = cats.firstWhere((item) => item.id == b.categoryId,
          orElse: () => CategoryEntity(id: b.categoryId, name: 'Category', icon: 'widgets', colorValue: 0xFF64748B, type: TransactionType.expense));
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => BudgetDetailsScreen(budget: b, category: cat)),
      );
    } else if (n.relatedEntityType == 'recurring') {
      // Navigate to Recurring screen (can push standard list view screen)
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const RecurringTab()),
      );
    } else if (n.relatedEntityType == 'transaction') {
      final txs = ref.read(transactionControllerProvider).value ?? [];
      final tx = txs.firstWhere((item) => item.id == n.relatedEntityId);
      final cats = ref.read(categoryControllerProvider).value ?? [];
      final cat = cats.firstWhere((item) => item.id == tx.categoryId,
          orElse: () => CategoryEntity(id: '', name: 'Other', icon: '', colorValue: 0, type: TransactionType.expense));
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TransactionDetailScreen(
            transaction: tx,
            category: cat,
            onDelete: () => ref.read(transactionControllerProvider.notifier).delete(tx.id),
            onEdit: () {},
          ),
        ),
      );
    } else if (n.relatedEntityType == 'account') {
      final accounts = ref.read(accountStateNotifierProvider).accounts;
      final acc = accounts.firstWhere((item) => item.id == n.relatedEntityId);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AccountDetailScreen(account: acc)),
      );
    } else if (n.type == NotificationType.weeklySummary || n.type == NotificationType.monthlySummary) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AnalyticsTab()),
      );
    }
  }
}
