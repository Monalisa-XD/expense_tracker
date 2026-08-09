import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../repositories/recurring_controller.dart';
import '../../../repositories/controllers.dart';
import 'add_recurring_screen.dart';
import 'recurring_detail_screen.dart';

class RecurringTab extends ConsumerStatefulWidget {
  const RecurringTab({super.key});

  @override
  ConsumerState<RecurringTab> createState() => _RecurringTabState();
}

class _RecurringTabState extends ConsumerState<RecurringTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recurringControllerProvider.notifier).syncRecurringTransactions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recurringControllerProvider);
    final catsState = ref.watch(categoryControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Recurring Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(recurringControllerProvider.notifier).syncRecurringTransactions();
            },
          ),
        ],
      ),
      body: state.isLoading
          ? _buildSkeletonLoader()
          : state.error != null
              ? _buildErrorState(state.error!)
              : SafeArea(
                  child: Column(
                    children: [
                      // Summary Section
                      _buildSummary(state),
                      const SizedBox(height: 8),

                      // Tabs selector
                      TabBar(
                        controller: _tabController,
                        tabs: const [
                          Tab(text: 'Active'),
                          Tab(text: 'Paused'),
                          Tab(text: 'Completed'),
                        ],
                      ),

                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildList(state.activeRecurring, catsState.value ?? [], 'No active recurring payments yet'),
                            _buildList(state.pausedRecurring, catsState.value ?? [], 'No paused recurring payments yet'),
                            _buildList(state.completedRecurring, catsState.value ?? [], 'No completed recurring payments yet'),
                          ],
                        ),
                      ),

                      // Upcoming payments header/list
                      if (state.upcomingPayments.isNotEmpty) ...[
                        const Divider(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: const [
                              Text('Upcoming Payments', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text('Next 30 days', style: TextStyle(color: Colors.grey, fontSize: 12)),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 110,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            itemCount: state.upcomingPayments.take(5).length,
                            itemBuilder: (context, index) {
                              final item = state.upcomingPayments[index];
                              return _buildUpcomingCard(item);
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddRecurringScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Recurring'),
      ),
    );
  }

  Widget _buildSummary(RecurringState state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Upcoming This Month',
                  CurrencyUtils.format(state.monthlyRecurringExpense + state.monthlyRecurringIncome),
                  Icons.calendar_today,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              _buildSummaryCard(
                'Active Recurring',
                state.activeRecurring.length.toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'Monthly Expenses',
                  CurrencyUtils.format(state.monthlyRecurringExpense),
                  Icons.arrow_upward,
                  Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'Monthly Income',
                  CurrencyUtils.format(state.monthlyRecurringIncome),
                  Icons.arrow_downward,
                  Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.1),
              radius: 18,
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey), overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 2),
                  Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(List<RecurringTransactionEntity> list, List<CategoryEntity> categories, String emptyMsg) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.autorenew, size: 48, color: Colors.grey),
              const SizedBox(height: 16),
              Text(emptyMsg, style: const TextStyle(color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final item = list[index];
        final cat = categories.firstWhere((c) => c.id == item.categoryId,
            orElse: () => CategoryEntity(id: '?', name: 'Other', icon: 'widgets', colorValue: 0xFF64748B, type: item.type));

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RecurringDetailScreen(recurring: item)),
              );
            },
            leading: CircleAvatar(
              backgroundColor: Color(cat.colorValue).withOpacity(0.12),
              child: Icon(Icons.cached, color: Color(cat.colorValue)),
            ),
            title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Next: ${DateUtilsHelper.formatDate(item.nextOccurrenceDate)}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${item.type == TransactionType.expense ? "-" : "+"}${CurrencyUtils.format(item.amount)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: item.type == TransactionType.expense ? Colors.red : Colors.green,
                  ),
                ),
                Text(item.frequency.name.toUpperCase(), style: const TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUpcomingCard(RecurringTransactionEntity item) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
            Text(
              '${item.type == TransactionType.expense ? "-" : "+"}${CurrencyUtils.format(item.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: item.type == TransactionType.expense ? Colors.red : Colors.green,
              ),
            ),
            Text(
              DateUtilsHelper.formatShortDate(item.nextOccurrenceDate),
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonLoader() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String msg) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(msg, style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () => ref.read(recurringControllerProvider.notifier).load(),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
