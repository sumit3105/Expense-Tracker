import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/presentation/providers/analytics_provider.dart';
import 'package:expense_tracker/presentation/providers/filter_provider.dart';
import 'package:expense_tracker/core/constants/currencies.dart';
import 'package:expense_tracker/data/models/expense_model.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aggregatedData = ref.watch(aggregatedDataProvider);
    final availableCurrencies = ref.watch(availableCurrenciesProvider);
    final selectedCurrency = ref.watch(selectedCurrencyProvider);
    final totalAmount = ref.watch(totalAmountProvider);
    final expenseCount = ref.watch(expenseCountProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: expenseCount == 0 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No data to analyze',
                    style: TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add some expenses to see analytics',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Currency selector
                if (availableCurrencies.isNotEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Filter by Currency',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            children: [
                              ChoiceChip(
                                label: const Text('All'),
                                selected: selectedCurrency == null,
                                onSelected: (selected) {
                                  if (selected) {
                                    ref.read(selectedCurrencyProvider.notifier).state = null;
                                  }
                                },
                              ),
                              ...availableCurrencies.map((currency) {
                                return ChoiceChip(
                                  label: Text(currency),
                                  selected: selectedCurrency == currency,
                                  onSelected: (selected) {
                                    if (selected) {
                                      ref.read(selectedCurrencyProvider.notifier).state = currency;
                                    }
                                  },
                                );
                              }),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Total card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Text(
                          selectedCurrency != null 
                              ? 'Total in $selectedCurrency' 
                              : 'Total (All Currencies)',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          selectedCurrency != null
                              ? '${Currencies.getSymbol(selectedCurrency)}${NumberFormat('#,##0.00').format(totalAmount)}'
                              : aggregatedData.totalByCurrency.entries
                                  .map((e) => '${Currencies.getSymbol(e.key)}${NumberFormat('#,##0.00').format(e.value)}')
                                  .join('\n'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$expenseCount ${expenseCount == 1 ? 'expense' : 'expenses'}',
                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Payment method distribution
                if (aggregatedData.totalByPaymentMethod.isNotEmpty) ...[
                  _buildSectionHeader('Payment Methods'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 250,
                        child: _buildPaymentMethodPieChart(
                          aggregatedData.totalByPaymentMethod,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Category distribution (by emoji)
                if (aggregatedData.totalByCategory.isNotEmpty) ...[
                  _buildSectionHeader('Categories'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 250,
                        child: _buildCategoryPieChart(
                          aggregatedData.totalByCategory,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Daily expenses (last 7 days)
                if (aggregatedData.dailyTotals.isNotEmpty) ...[
                  _buildSectionHeader('Last 7 Days'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 250,
                        child: _buildDailyBarChart(
                          aggregatedData.dailyTotals,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Weekly expenses
                if (aggregatedData.weeklyTotals.isNotEmpty) ...[
                  _buildSectionHeader('Weekly Expenses'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 250,
                        child: _buildWeeklyBarChart(
                          aggregatedData.weeklyTotals,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
                
                // Monthly expenses
                if (aggregatedData.monthlyTotals.isNotEmpty) ...[
                  _buildSectionHeader('Monthly Trends'),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        height: 250,
                        child: _buildMonthlyBarChart(
                          aggregatedData.monthlyTotals,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }
  
  Widget _buildPaymentMethodPieChart(Map<PaymentMethod, double> data) {
    final sections = data.entries.map((e) {
      final color = _getPaymentMethodColor(e.key);
      final percentage = (e.value / data.values.reduce((a, b) => a + b)) * 100;
      
      return PieChartSectionData(
        color: color,
        value: e.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
    
    return Row(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: data.entries.map((e) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getPaymentMethodColor(e.key),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${e.key.icon} ${e.key.displayName}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
  
  Widget _buildCategoryPieChart(Map<String, double> data) {
    // Take top 8 categories
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topCategories = sortedEntries.take(8).toList();
    
    final sections = topCategories.asMap().entries.map((entry) {
      final index = entry.key;
      final data = entry.value;
      final color = _getCategoryColor(index);
      final percentage = (data.value / topCategories.fold(0.0, (sum, e) => sum + e.value)) * 100;
      
      return PieChartSectionData(
        color: color,
        value: data.value,
        title: percentage > 5 ? '${percentage.toStringAsFixed(0)}%' : '',
        radius: 80,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
    
    return Column(
      children: [
        // Pie chart on top
        SizedBox(
          height: 180,
          child: PieChart(
            PieChartData(
              sections: sections,
              sectionsSpace: 2,
              centerSpaceRadius: 40,
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Categories list horizontally below
        SizedBox(
          height: 40,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: topCategories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final data = topCategories[index];
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _getCategoryColor(index),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    data.key,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildDailyBarChart(Map<DateTime, double> data) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final last7Days = sortedEntries.reversed.take(7).toList().reversed.toList();
    
    if (last7Days.isEmpty) return const SizedBox.shrink();
    
    final barGroups = last7Days.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value,
            color: Colors.blue,
            width: 16,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
    
    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < last7Days.length) {
                  final date = last7Days[value.toInt()].key;
                  return Text(
                    DateFormat('MM/dd').format(date),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
  
  Widget _buildWeeklyBarChart(Map<DateTime, double> data) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final last8Weeks = sortedEntries.reversed.take(8).toList().reversed.toList();
    
    if (last8Weeks.isEmpty) return const SizedBox.shrink();
    
    final barGroups = last8Weeks.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value,
            color: Colors.teal,
            width: 18,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
    
    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < last8Weeks.length) {
                  final weekStart = last8Weeks[value.toInt()].key;
                  return Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      DateFormat('MM/dd').format(weekStart),
                      style: const TextStyle(fontSize: 9),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
  
  Widget _buildMonthlyBarChart(Map<DateTime, double> data) {
    final sortedEntries = data.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final last6Months = sortedEntries.reversed.take(6).toList().reversed.toList();
    
    if (last6Months.isEmpty) return const SizedBox.shrink();
    
    final barGroups = last6Months.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.value,
            color: Colors.purple,
            width: 20,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
    
    return BarChart(
      BarChartData(
        barGroups: barGroups,
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() < last6Months.length) {
                  final date = last6Months[value.toInt()].key;
                  return Text(
                    DateFormat('MMM').format(date),
                    style: const TextStyle(fontSize: 10),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  NumberFormat.compact().format(value),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(show: true, drawVerticalLine: false),
        borderData: FlBorderData(show: false),
      ),
    );
  }
  
  Color _getPaymentMethodColor(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.cash:
        return Colors.green;
      case PaymentMethod.upi:
        return Colors.blue;
      case PaymentMethod.atmCard:
        return Colors.orange;
    }
  }
  
  Color _getCategoryColor(int index) {
    final colors = [
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
    ];
    return colors[index % colors.length];
  }
}
