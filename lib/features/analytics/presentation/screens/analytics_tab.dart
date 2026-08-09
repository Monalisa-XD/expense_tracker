import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/utils/currency_utils.dart';
import '../../../../core/utils/date_utils.dart';
import '../../../repositories/controllers.dart';
import '../../../transactions/presentation/screens/transaction_detail_screen.dart';
import 'category_spending_details_screen.dart';

class AnalyticsTab extends ConsumerStatefulWidget {
  const AnalyticsTab({super.key});

  @override
  ConsumerState<AnalyticsTab> createState() => _AnalyticsTabState();
}

class _AnalyticsTabState extends ConsumerState<AnalyticsTab> {
  @override
  Widget build(BuildContext context) {
    final analyticsState = ref.watch(analyticsStateProvider);
    final periodState = ref.watch(analyticsPeriodControllerProvider);
    final periodNotifier = ref.read(analyticsPeriodControllerProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
        actions: [
          if (periodState.period == 'Custom')
            IconButton(
              icon: const Icon(Icons.date_range),
              onPressed: () async {
                final range = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                  initialDateRange: periodState.dateRange,
                );
                if (range != null) {
                  periodNotifier.setCustomRange(range);
                }
              },
            ),
        ],
      ),
      body: analyticsState.when(
        data: (data) {
          final summary = data.summary;
          final breakdown = data.categoryBreakdown;
          final insights = data.insights;

          // Donut segments
          final pieSections = breakdown.map((cb) {
            return PieChartSectionData(
              color: Color(cb.category.colorValue),
              value: cb.amount,
              title: '${cb.percentage.toStringAsFixed(0)}%',
              radius: 40,
              showTitle: cb.percentage > 8,
              titleStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
            );
          }).toList();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Segmented period buttons
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'Week', label: Text('Week')),
                    ButtonSegment(value: 'Month', label: Text('Month')),
                    ButtonSegment(value: 'Year', label: Text('Year')),
                    ButtonSegment(value: 'Custom', label: Text('Custom')),
                  ],
                  selected: {periodState.period},
                  onSelectionChanged: (set) {
                    if (set.first == 'Custom') {
                      showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      ).then((range) {
                        if (range != null) {
                          periodNotifier.setCustomRange(range);
                        }
                      });
                    } else {
                      periodNotifier.setPeriod(set.first);
                    }
                  },
                ),
                const SizedBox(height: 24),

                // Financial Summary
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildSummaryRow(
                          'Income',
                          CurrencyUtils.format(summary.totalIncome),
                          Colors.green,
                          data.comparison.incomeChangePercentage,
                        ),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          'Expenses',
                          CurrencyUtils.format(summary.totalExpenses),
                          Colors.red,
                          data.comparison.expenseChangePercentage,
                        ),
                        const Divider(height: 24),
                        _buildSummaryRow(
                          'Savings',
                          CurrencyUtils.format(summary.savings),
                          Colors.blue,
                          data.comparison.savingsChangePercentage,
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Savings Rate', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                            Text('${summary.savingsRate.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.purple)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Category Spending Breakdown
                const Text('Spending by Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (breakdown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.0),
                    child: Center(child: Text('No spending transactions recorded for this period.')),
                  )
                else ...[
                  SizedBox(
                    height: 160,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sections: pieSections,
                            sectionsSpace: 3,
                            centerSpaceRadius: 50,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Total Spent', style: TextStyle(fontSize: 10, color: Colors.grey)),
                              const SizedBox(height: 4),
                              Text(
                                CurrencyUtils.format(summary.totalExpenses),
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Categories Legend List
                  ...breakdown.map((cb) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(cb.category.colorValue).withOpacity(0.2),
                      child: Icon(Icons.category, color: Color(cb.category.colorValue), size: 16),
                    ),
                    title: Text(cb.category.name),
                    subtitle: Text('${cb.percentage.toStringAsFixed(1)}% of total'),
                    trailing: Text(
                      CurrencyUtils.format(cb.amount),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CategorySpendingDetailsScreen(category: cb.category),
                        ),
                      );
                    },
                  )),
                ],
                const SizedBox(height: 24),

                // Weekly/Monthly Spent Trend Graph
                const Text('Spending Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                if (data.incomeExpenseTrend.isEmpty)
                  const SizedBox(height: 100, child: Center(child: Text('No data for trend')))
                else
                  SizedBox(
                    height: 140,
                    child: BarChart(
                      BarChartData(
                        gridData: const FlGridData(show: false),
                        titlesData: FlTitlesData(
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                final idx = val.toInt();
                                if (idx >= 0 && idx < data.incomeExpenseTrend.length) {
                                  return Text(data.incomeExpenseTrend[idx].label, style: const TextStyle(fontSize: 10));
                                }
                                return const Text('');
                              },
                            ),
                          ),
                        ),
                        barGroups: data.incomeExpenseTrend.asMap().entries.map((e) {
                          return BarChartGroupData(
                            x: e.key,
                            barRods: [
                              BarChartRodData(
                                toY: e.value.value,
                                color: Theme.of(context).colorScheme.primary,
                                width: 14,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),

                // Savings trend line graph
                const Text('Savings Trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                SizedBox(
                  height: 120,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: false),
                      titlesData: const FlTitlesData(
                        rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      ),
                      lineBarsData: [
                        LineChartBarData(
                          spots: data.savingsTrend.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.value)).toList(),
                          isCurved: true,
                          color: Colors.green,
                          barWidth: 3,
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Financial Insights Card
                const Text('Financial Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildInsightRow('Top Category Spending', insights.highestSpendingCategory?.name ?? 'N/A', CurrencyUtils.format(insights.highestSpendingCategoryAmount)),
                        const Divider(),
                        _buildInsightRow('Average Daily Spent', 'Daily Average', CurrencyUtils.format(insights.averageDailySpending)),
                        const Divider(),
                        _buildInsightRow('Most Frequent Category', insights.mostFrequentCategory?.name ?? 'N/A', '${insights.mostFrequentCategoryCount} times'),
                        const Divider(),
                        _buildInsightRow('Best Spending Day', insights.bestSpendingDay, 'Least Spent'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (insights.largestExpense != null) ...[
                  const SizedBox(height: 12),
                  const Text('Largest Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  ListTile(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    tileColor: Theme.of(context).cardColor,
                    title: Text(insights.largestExpense!.title),
                    subtitle: Text(DateUtilsHelper.formatDate(insights.largestExpense!.date)),
                    trailing: Text(
                      '-${CurrencyUtils.format(insights.largestExpense!.amount)}',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                    ),
                    onTap: () {
                      final cat = breakdown.firstWhere((c) => c.category.id == insights.largestExpense!.categoryId).category;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TransactionDetailScreen(
                            transaction: insights.largestExpense!,
                            category: cat,
                            onDelete: () {
                              ref.read(transactionControllerProvider.notifier).delete(insights.largestExpense!.id);
                            },
                            onEdit: () {
                              // Edit larger expense
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Unable to load analytics data.'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => ref.refresh(analyticsStateProvider),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color, double changePct) {
    final isIncrease = changePct >= 0;
    final changeText = changePct == 0.0 ? 'No prev data' : '${isIncrease ? '↑' : '↓'} ${changePct.abs().toStringAsFixed(1)}%';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
            const SizedBox(height: 2),
            Text(changeText, style: TextStyle(fontSize: 11, color: changePct == 0.0 ? Colors.grey : (isIncrease ? Colors.green : Colors.red))),
          ],
        ),
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildInsightRow(String title, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            ],
          ),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
