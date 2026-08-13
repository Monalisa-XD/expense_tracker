import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../../core/utils/app_icon_resolver.dart';
import '../../../repositories/recurring_controller.dart';
import '../../../repositories/account_controller.dart';
import 'add_recurring_screen.dart';
import 'recurring_detail_screen.dart';

class RecurringTab extends ConsumerStatefulWidget {
  const RecurringTab({super.key});

  @override
  ConsumerState<RecurringTab> createState() => _RecurringTabState();
}

class _RecurringTabState extends ConsumerState<RecurringTab> {
  String _searchQuery = '';
  String _selectedStatus = 'All'; // All, Active, Paused, Completed
  String _selectedType = 'All'; // All, Subscription, Rent, EMI, Bill, Insurance, Membership, Other
  String _sortBy = 'Next payment'; // Next payment, Highest amount, Lowest amount, Alphabetical

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(recurringControllerProvider.notifier).syncRecurringTransactions();
    });
  }

  double _getNormalizedMonthlyCost(RecurringTransactionEntity item) {
    switch (item.frequency) {
      case RecurringFrequency.daily:
        return item.amount * 30.0;
      case RecurringFrequency.weekly:
        return item.amount * 4.33;
      case RecurringFrequency.monthly:
        return item.amount;
      case RecurringFrequency.quarterly:
        return item.amount / 3.0;
      case RecurringFrequency.halfYearly:
        return item.amount / 6.0;
      case RecurringFrequency.yearly:
        return item.amount / 12.0;
      case RecurringFrequency.custom:
        return item.amount;
    }
  }

  String _getCountdownText(DateTime date) {
    final today = DateUtils.dateOnly(DateTime.now());
    final due = DateUtils.dateOnly(date);
    final diff = due.difference(today).inDays;
    if (diff == 0) return 'Due today';
    if (diff == 1) return 'Due tomorrow';
    if (diff < 0) return 'Overdue by ${diff.abs()} days';
    return 'Due in $diff days';
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(recurringControllerProvider);
    final accountsState = ref.watch(accountStateNotifierProvider);

    // 1. Calculations
    double totalMonthlyCost = 0.0;
    int activeSubscriptions = 0;
    int upcomingThisWeek = 0;
    final now = DateTime.now();
    final weekLater = now.add(const Duration(days: 7));

    for (var r in state.activeRecurring) {
      if (r.type == TransactionType.expense) {
        totalMonthlyCost += _getNormalizedMonthlyCost(r);
      }
      if (r.isSubscription == true || r.recurringType == 'subscription') {
        activeSubscriptions++;
      }
      if (r.nextOccurrenceDate.isBefore(weekLater)) {
        upcomingThisWeek++;
      }
    }

    double totalYearlyCost = totalMonthlyCost * 12.0;

    // Largest subscription search
    String largestSubName = '';
    double largestSubAmt = 0.0;
    for (var r in state.activeRecurring) {
      if (r.type == TransactionType.expense && r.amount > largestSubAmt) {
        largestSubAmt = r.amount;
        largestSubName = r.title;
      }
    }

    // 2. Filter & Sort list
    var filtered = state.recurringTransactions.where((item) {
      // Search query filter
      final matchesSearch = item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (item.notes?.toLowerCase().contains(_searchQuery.toLowerCase()) ?? false) ||
          item.categoryId.toLowerCase().contains(_searchQuery.toLowerCase());

      // Status Filter
      bool matchesStatus = true;
      if (_selectedStatus == 'Active') {
        matchesStatus = item.isActive && !item.isPaused;
      } else if (_selectedStatus == 'Paused') {
        matchesStatus = item.isActive && item.isPaused;
      } else if (_selectedStatus == 'Completed') {
        matchesStatus = !item.isActive;
      }

      // Type Filter
      bool matchesType = true;
      if (_selectedType != 'All') {
        matchesType = (item.recurringType ?? 'other').toLowerCase() == _selectedType.toLowerCase();
      }

      return matchesSearch && matchesStatus && matchesType;
    }).toList();

    // Sorting
    if (_sortBy == 'Next payment') {
      filtered.sort((a, b) => a.nextOccurrenceDate.compareTo(b.nextOccurrenceDate));
    } else if (_sortBy == 'Highest amount') {
      filtered.sort((a, b) => b.amount.compareTo(a.amount));
    } else if (_sortBy == 'Lowest amount') {
      filtered.sort((a, b) => a.amount.compareTo(b.amount));
    } else if (_sortBy == 'Alphabetical') {
      filtered.sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    }

    // Grouping upcoming active items
    final today = DateUtils.dateOnly(DateTime.now());
    final nextWeek = today.add(const Duration(days: 7));
    final fortnight = today.add(const Duration(days: 14));

    final todayList = <RecurringTransactionEntity>[];
    final thisWeekList = <RecurringTransactionEntity>[];
    final nextWeekList = <RecurringTransactionEntity>[];
    final laterList = <RecurringTransactionEntity>[];

    for (var r in state.activeRecurring) {
      final due = DateUtils.dateOnly(r.nextOccurrenceDate);
      if (due == today) {
        todayList.add(r);
      } else if (due.isAfter(today) && !due.isAfter(nextWeek)) {
        thisWeekList.add(r);
      } else if (due.isAfter(nextWeek) && !due.isAfter(fortnight)) {
        nextWeekList.add(r);
      } else {
        laterList.add(r);
      }
    }

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
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Top Commitments Dashboard card
                _buildCommitmentsDashboard(totalMonthlyCost, totalYearlyCost, activeSubscriptions, upcomingThisWeek),
                const SizedBox(height: 12),

                // Insights banner
                if (state.activeRecurring.isNotEmpty)
                  _buildInsightsCard(totalMonthlyCost, totalYearlyCost, largestSubName, upcomingThisWeek),
                const SizedBox(height: 16),

                // Upcoming Groups lists
                if (state.activeRecurring.isNotEmpty) ...[
                  _buildSectionHeader('Upcoming Timeline'),
                  const SizedBox(height: 8),
                  if (todayList.isNotEmpty) ...[
                    _buildSubHeader('TODAY'),
                    ...todayList.map((item) => _buildTimelineTile(context, item, accountsState.activeAccounts)),
                  ],
                  if (thisWeekList.isNotEmpty) ...[
                    _buildSubHeader('THIS WEEK'),
                    ...thisWeekList.map((item) => _buildTimelineTile(context, item, accountsState.activeAccounts)),
                  ],
                  if (nextWeekList.isNotEmpty) ...[
                    _buildSubHeader('NEXT WEEK'),
                    ...nextWeekList.map((item) => _buildTimelineTile(context, item, accountsState.activeAccounts)),
                  ],
                  if (laterList.isNotEmpty) ...[
                    _buildSubHeader('LATER'),
                    ...laterList.map((item) => _buildTimelineTile(context, item, accountsState.activeAccounts)),
                  ],
                  const SizedBox(height: 20),
                ],

                // Search, Filters & Sorting Controls
                _buildSectionHeader('All Recurring Items'),
                const SizedBox(height: 8),
                _buildSearchAndFilters(context),
                const SizedBox(height: 12),

                // Filtered List
                if (filtered.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 32.0),
                      child: Text('No recurring items match your filters.'),
                    ),
                  )
                else
                  ...filtered.map((item) => Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => RecurringDetailScreen(recurring: item)),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: Colors.teal.withOpacity(0.08),
                            child: AppIconResolver.resolveTransactionIcon(
                              categoryId: item.categoryId,
                              brandKey: item.brandKey,
                              merchantName: item.merchantName ?? item.title,
                              size: 32,
                            ),
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
                              Text('${item.frequency.name.toUpperCase()} · ${_getCountdownText(item.nextOccurrenceDate)}',
                                  style: const TextStyle(fontSize: 10, color: Colors.grey)),
                            ],
                          ),
                        ),
                      )),
              ],
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
    );
  }

  Widget _buildSubHeader(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
      ),
    );
  }

  Widget _buildCommitmentsDashboard(double monthly, double yearly, int activeCount, int weekCount) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Monthly Commitments', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyUtils.format(monthly),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Yearly Commitments', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 4),
                      Text(
                        CurrencyUtils.format(yearly),
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Active Subscriptions: $activeCount', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                Text('Upcoming (This Week): $weekCount', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsCard(double monthly, double yearly, String largestSubName, int weekCount) {
    final buffer = StringBuffer();
    buffer.write('You spend ${CurrencyUtils.format(monthly)}/month on recurring payments. ');
    buffer.write('Your subscriptions cost approximately ${CurrencyUtils.format(yearly)}/year. ');
    if (largestSubName.isNotEmpty) {
      buffer.write('$largestSubName is your largest subscription. ');
    }
    if (weekCount > 0) {
      buffer.write('$weekCount payments are due this week.');
    }

    return Card(
      color: Colors.teal.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Colors.teal, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const Icon(Icons.lightbulb_outline, color: Colors.teal),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                buffer.toString(),
                style: const TextStyle(fontSize: 12, color: Colors.white70, height: 1.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineTile(BuildContext context, RecurringTransactionEntity item, List<AccountEntity> accounts) {
    final account = accounts.firstWhere((a) => a.id == item.accountId,
        orElse: () => AccountEntity(id: '?', name: 'Other Account', balance: 0.0, type: PaymentMethod.bank));
    final isLowBalance = account.balance < item.amount && item.type == TransactionType.expense;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => RecurringDetailScreen(recurring: item)),
          );
        },
        leading: AppIconResolver.resolveTransactionIcon(
          categoryId: item.categoryId,
          brandKey: item.brandKey,
          merchantName: item.merchantName ?? item.title,
          size: 40,
        ),
        title: Row(
          children: [
            Expanded(child: Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold))),
            if (isLowBalance)
              const Tooltip(
                message: 'Insufficient balance',
                child: Icon(Icons.warning, color: Colors.orangeAccent, size: 18),
              ),
          ],
        ),
        subtitle: Text('${account.name} · ${_getCountdownText(item.nextOccurrenceDate)}'),
        trailing: Text(
          '${item.type == TransactionType.expense ? "-" : "+"}${CurrencyUtils.format(item.amount)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: item.type == TransactionType.expense ? Colors.red : Colors.green,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: (val) {
            setState(() {
              _searchQuery = val;
            });
          },
          decoration: const InputDecoration(
            labelText: 'Search merchant, category, account...',
            prefixIcon: Icon(Icons.search),
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedStatus,
                decoration: const InputDecoration(labelText: 'Status', border: OutlineInputBorder()),
                items: ['All', 'Active', 'Paused', 'Completed'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedStatus = val ?? 'All';
                  });
                },
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: const InputDecoration(labelText: 'Sort By', border: OutlineInputBorder()),
                items: ['Next payment', 'Highest amount', 'Lowest amount', 'Alphabetical'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                onChanged: (val) {
                  setState(() {
                    _sortBy = val ?? 'Next payment';
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
