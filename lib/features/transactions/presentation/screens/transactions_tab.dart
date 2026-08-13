import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/widgets/transaction_tile.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../repositories/controllers.dart';
import 'transaction_detail_screen.dart';
import 'add_income_screen.dart';
import 'multi_step_expense_flow.dart';

class TransactionsTab extends ConsumerStatefulWidget {
  const TransactionsTab({super.key});

  @override
  ConsumerState<TransactionsTab> createState() => _TransactionsTabState();
}

class _TransactionsTabState extends ConsumerState<TransactionsTab> {
  final TextEditingController _searchController = TextEditingController();

  void _showFilterBottomSheet(List<CategoryEntity> categories, List<AccountEntity> accounts) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final filter = ref.watch(transactionFilterControllerProvider);
            final filterNotifier = ref.read(transactionFilterControllerProvider.notifier);

            return DraggableScrollableSheet(
              initialChildSize: 0.7,
              maxChildSize: 0.9,
              expand: false,
              builder: (context, scrollController) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Filter Transactions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          TextButton(
                            onPressed: () {
                              filterNotifier.clearFilters();
                              Navigator.pop(context);
                            },
                            child: const Text('Clear All'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Transaction Type
                      const Text('Transaction Type', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Row(
                        children: ['All', 'Income', 'Expense'].map((type) {
                          final selected = filter.selectedType == type;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ChoiceChip(
                              label: Text(type),
                              selected: selected,
                              onSelected: (_) => filterNotifier.setSelectedType(type),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),

                      // Date Range
                      const Text('Date Range', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ListTile(
                        leading: const Icon(Icons.calendar_today),
                        title: Text(filter.selectedDateRange == null
                            ? 'Select Date Range'
                            : '${DateUtilsHelper.formatShortDate(filter.selectedDateRange!.start)} - ${DateUtilsHelper.formatShortDate(filter.selectedDateRange!.end)}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () async {
                          final picked = await showDateRangePicker(
                            context: context,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                            initialDateRange: filter.selectedDateRange,
                          );
                          if (picked != null) {
                            filterNotifier.setSelectedDateRange(picked);
                          }
                        },
                      ),
                      const SizedBox(height: 20),

                      // Categories
                      const Text('Category', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<CategoryEntity?>(
                        value: filter.selectedCategory,
                        hint: const Text('All Categories'),
                        items: [
                          const DropdownMenuItem<CategoryEntity?>(value: null, child: Text('All Categories')),
                          ...categories.map((c) => DropdownMenuItem(value: c, child: Text(c.name))),
                        ],
                        onChanged: (val) => filterNotifier.setSelectedCategory(val),
                      ),
                      const SizedBox(height: 20),

                      // Accounts
                      const Text('Account', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<AccountEntity?>(
                        value: filter.selectedAccount,
                        hint: const Text('All Accounts'),
                        items: [
                          const DropdownMenuItem<AccountEntity?>(value: null, child: Text('All Accounts')),
                          ...accounts.map((a) => DropdownMenuItem(value: a, child: Text(a.name))),
                        ],
                        onChanged: (val) => filterNotifier.setSelectedAccount(val),
                      ),
                      const SizedBox(height: 20),

                      // Payment Method
                      const Text('Payment Method', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<PaymentMethod?>(
                        value: filter.selectedPaymentMethod,
                        hint: const Text('All Payment Methods'),
                        items: [
                          const DropdownMenuItem<PaymentMethod?>(value: null, child: Text('All Payment Methods')),
                          ...PaymentMethod.values.map((p) => DropdownMenuItem(value: p, child: Text(p.name.toUpperCase()))),
                        ],
                        onChanged: (val) => filterNotifier.setSelectedPaymentMethod(val),
                      ),
                      const SizedBox(height: 32),

                      ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Apply Filters'),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _triggerEdit(TransactionEntity tx) {
    if (tx.type == TransactionType.expense) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => MultiStepExpenseFlow(editTransaction: tx)),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => AddIncomeScreen(editTransaction: tx)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTxsVal = ref.watch(filteredTransactionsProvider);
    final filter = ref.watch(transactionFilterControllerProvider);
    final filterNotifier = ref.read(transactionFilterControllerProvider.notifier);

    final catsState = ref.watch(categoryControllerProvider);
    final accountsState = ref.watch(accountControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              final categories = catsState.value ?? [];
              final accounts = accountsState.value ?? [];
              _showFilterBottomSheet(categories, accounts);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search box
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search transactions...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onChanged: (val) => filterNotifier.setSearchQuery(val),
            ),
          ),

          // Active filter chips UI row
          _buildFilterChips(filter, filterNotifier),

          // Sorting selector bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sort by:', style: TextStyle(fontSize: 12, color: Colors.grey)),
                DropdownButton<String>(
                  value: filter.sortOption,
                  items: ['Newest', 'Oldest', 'Highest', 'Lowest']
                      .map((opt) => DropdownMenuItem(value: opt, child: Text(opt, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) filterNotifier.setSortOption(val);
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: filteredTxsVal.when(
              data: (list) {
                if (list.isEmpty) {
                  return _buildEmptyState(filter, filterNotifier);
                }

                // Group transactions by Date String representation
                final grouped = _groupTransactionsByDate(list);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final item = grouped[index];

                    if (item is String) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Text(
                          item.toUpperCase(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
                        ),
                      );
                    }

                    final tx = item as TransactionEntity;
                    final cat = (catsState.value ?? []).firstWhere((c) => c.id == tx.categoryId,
                        orElse: () => CategoryEntity(
                            id: 'unknown',
                            name: 'Unknown',
                            icon: 'widgets',
                            colorValue: 0xFF64748B,
                            type: tx.type));

                    return Dismissible(
                      key: Key(tx.id),
                      direction: DismissDirection.horizontal,
                      background: Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(left: 20.0),
                        color: Colors.blue,
                        child: const Icon(Icons.edit, color: Colors.white),
                      ),
                      secondaryBackground: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: Colors.red,
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      confirmDismiss: (direction) async {
                        if (direction == DismissDirection.startToEnd) {
                          // Swipe Right -> Trigger Edit
                          _triggerEdit(tx);
                          return false; // do not dismiss from UI list directly
                        } else {
                          // Swipe Left -> Delete with Dialog
                          final deleteConfirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Transaction?'),
                              content: const Text('This action cannot be undone.'),
                              actions: [
                                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                          if (deleteConfirm == true) {
                            ref.read(transactionControllerProvider.notifier).delete(tx.id);
                            return true;
                          }
                          return false;
                        }
                      },
                      child: TransactionTile(
                        transaction: tx,
                        category: cat,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => TransactionDetailScreen(
                                transaction: tx,
                                category: cat,
                                onDelete: () {
                                  ref.read(transactionControllerProvider.notifier).delete(tx.id);
                                },
                                onEdit: () => _triggerEdit(tx),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterChips(TransactionFilterState filter, TransactionFilterController notifier) {
    final List<Widget> chips = [];

    if (filter.selectedType != 'All') {
      chips.add(InputChip(
        label: Text(filter.selectedType),
        onDeleted: () => notifier.setSelectedType('All'),
      ));
    }
    if (filter.selectedCategory != null) {
      chips.add(InputChip(
        label: Text(filter.selectedCategory!.name),
        onDeleted: () => notifier.setSelectedCategory(null),
      ));
    }
    if (filter.selectedAccount != null) {
      chips.add(InputChip(
        label: Text(filter.selectedAccount!.name),
        onDeleted: () => notifier.setSelectedAccount(null),
      ));
    }
    if (filter.selectedDateRange != null) {
      chips.add(InputChip(
        label: const Text('Date Range'),
        onDeleted: () => notifier.setSelectedDateRange(null),
      ));
    }
    if (filter.selectedPaymentMethod != null) {
      chips.add(InputChip(
        label: Text(filter.selectedPaymentMethod!.name.toUpperCase()),
        onDeleted: () => notifier.setSelectedPaymentMethod(null),
      ));
    }

    if (chips.isEmpty) return const SizedBox.shrink();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
      child: Row(
        children: [
          ...chips.map((c) => Padding(padding: const EdgeInsets.only(right: 6.0), child: c)),
          TextButton(
            onPressed: () => notifier.clearFilters(),
            child: const Text('Clear All', style: TextStyle(fontSize: 12)),
          )
        ],
      ),
    );
  }

  Widget _buildEmptyState(TransactionFilterState filter, TransactionFilterController notifier) {
    final hasFilters = filter.selectedType != 'All' ||
        filter.selectedCategory != null ||
        filter.selectedAccount != null ||
        filter.selectedDateRange != null ||
        filter.selectedPaymentMethod != null;

    if (filter.searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.search_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No matching transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Try a different search query.', style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      );
    }

    if (hasFilters) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.filter_alt_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No transactions match your filters.', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => notifier.clearFilters(),
                child: const Text('Clear Filters'),
              ),
            ],
          ),
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No transactions yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Start tracking your spending.', style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }

  List<dynamic> _groupTransactionsByDate(List<TransactionEntity> list) {
    final List<dynamic> grouped = [];
    String lastDate = '';

    for (var tx in list) {
      final dateStr = DateUtilsHelper.formatRelative(tx.date);
      if (dateStr != lastDate) {
        grouped.add(dateStr);
        lastDate = dateStr;
      }
      grouped.add(tx);
    }
    return grouped;
  }
}
