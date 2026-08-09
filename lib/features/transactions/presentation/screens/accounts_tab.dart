import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/entities.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../repositories/account_controller.dart';
import 'add_account_screen.dart';
import 'add_transfer_screen.dart';
import 'account_detail_screen.dart';

class AccountsTab extends ConsumerStatefulWidget {
  const AccountsTab({super.key});

  @override
  ConsumerState<AccountsTab> createState() => _AccountsTabState();
}

class _AccountsTabState extends ConsumerState<AccountsTab> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedType = 'All';
  String _sortOption = 'Highest Balance';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(accountStateNotifierProvider.notifier).load();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<AccountEntity> _filterAndSort(List<AccountEntity> list) {
    var filtered = list.where((acc) {
      final query = _searchQuery.toLowerCase();
      if (query.isNotEmpty && !acc.name.toLowerCase().contains(query)) {
        return false;
      }
      if (_selectedType != 'All') {
        if (_selectedType == 'Bank' && acc.type != PaymentMethod.bank) return false;
        if (_selectedType == 'Cash' && acc.type != PaymentMethod.cash) return false;
        if (_selectedType == 'Wallet' && acc.type != PaymentMethod.wallet && acc.type != PaymentMethod.upi) return false;
        if (_selectedType == 'Credit Card' && acc.type != PaymentMethod.creditCard) return false;
      }
      return true;
    }).toList();

    if (_sortOption == 'Highest Balance') {
      filtered.sort((a, b) => b.balance.compareTo(a.balance));
    } else if (_sortOption == 'Lowest Balance') {
      filtered.sort((a, b) => a.balance.compareTo(b.balance));
    } else if (_sortOption == 'Name A-Z') {
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_sortOption == 'Name Z-A') {
      filtered.sort((a, b) => b.name.toLowerCase().compareTo(a.name.toLowerCase()));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(accountStateNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Accounts'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Archived'),
          ],
        ),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildBalanceSummary(state),
                _buildSearchAndFilterControls(),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildList(_filterAndSort(state.activeAccounts)),
                      _buildList(_filterAndSort(state.archivedAccounts)),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddTransferScreen()),
                    );
                  },
                  icon: const Icon(Icons.swap_horiz),
                  label: const Text('Transfer Money'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddAccountScreen()),
                    );
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Account'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceSummary(AccountState state) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.08)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Net Worth', style: TextStyle(fontSize: 14, color: Colors.grey)),
              Text(
                CurrencyUtils.format(state.netWorth),
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Total Assets', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(CurrencyUtils.format(state.totalAssets), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Total Liabilities', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(CurrencyUtils.format(state.totalLiabilities), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.red)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search accounts...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
              });
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              DropdownButton<String>(
                value: _selectedType,
                items: ['All', 'Bank', 'Cash', 'Wallet', 'Credit Card']
                    .map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedType = val;
                    });
                  }
                },
              ),
              DropdownButton<String>(
                value: _sortOption,
                items: ['Highest Balance', 'Lowest Balance', 'Name A-Z', 'Name Z-A']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s, style: const TextStyle(fontSize: 12))))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _sortOption = val;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<AccountEntity> list) {
    if (list.isEmpty) {
      return const Center(child: Text('No accounts found matching search or type.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final acc = list[idx];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AccountDetailScreen(account: acc)),
              ).then((_) {
                ref.read(accountStateNotifierProvider.notifier).load();
              });
            },
            leading: CircleAvatar(
              backgroundColor: Color(acc.color).withOpacity(0.12),
              child: Icon(_getIcon(acc.icon), color: Color(acc.color)),
            ),
            title: Row(
              children: [
                Text(acc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                if (acc.isDefault) ...[
                  const SizedBox(width: 8),
                  const Chip(
                    label: Text('Default', style: TextStyle(fontSize: 8, color: Colors.white)),
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.zero,
                  ),
                ],
              ],
            ),
            subtitle: Text(acc.type.name.toUpperCase()),
            trailing: Text(
              CurrencyUtils.format(acc.balance),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: acc.balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIcon(String name) {
    switch (name) {
      case 'credit_card': return Icons.credit_card;
      case 'wallet': return Icons.account_balance_wallet;
      case 'money': return Icons.money;
      case 'account_balance': return Icons.account_balance;
      default: return Icons.account_balance;
    }
  }
}
