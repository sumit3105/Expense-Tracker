import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/presentation/providers/expense_provider.dart';
import 'package:expense_tracker/presentation/providers/filter_provider.dart';
import 'package:expense_tracker/presentation/providers/analytics_provider.dart';
import 'package:expense_tracker/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/presentation/widgets/expense_card.dart';
import 'package:expense_tracker/core/constants/currencies.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExpenses = ref.watch(expenseProvider);
    final aggregatedData = ref.watch(aggregatedDataProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              _showAboutDialog(context);
            },
          ),
        ],
      ),
      body: asyncExpenses.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(expenseProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (expenses) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(expenseProvider);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Currency totals section
              _buildCurrencyTotalsSection(aggregatedData.totalByCurrency, ref),
              
              const SizedBox(height: 24),
              
              // Today's expenses section
              _buildTodayExpensesSection(context, ref),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Expense'),
      ),
    );
  }
  
  Widget _buildCurrencyTotalsSection(Map<String, double> totalByCurrency, WidgetRef ref) {
    if (totalByCurrency.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.account_balance_wallet_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No expenses yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap the button below to add your first expense',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Total Expenses',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 150,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: totalByCurrency.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final entry = totalByCurrency.entries.elementAt(index);
              final currency = entry.key;
              final total = entry.value;
              final symbol = Currencies.getSymbol(currency);
              
              // Calculate current month total for this currency
              final monthExpenses = ref.watch(monthExpensesProvider);
              final monthTotal = monthExpenses
                  .where((e) => e.currency == currency)
                  .fold(0.0, (sum, e) => sum + e.amount);
              
              return Card(
                child: Container(
                  width: 180,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        currency,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // All-time total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'All Time',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            '$symbol${NumberFormat('#,##0.00').format(total)}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Current month total
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'This Month',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[500],
                            ),
                          ),
                          Text(
                            '$symbol${NumberFormat('#,##0.00').format(monthTotal)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildTodayExpensesSection(
    BuildContext context,
    WidgetRef ref,
  ) {
    final todayExpenses = ref.watch(todayExpensesProvider);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Today\'s Expenses',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        
        if (todayExpenses.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 48,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No expenses today',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Start tracking by adding an expense',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        else
          ...todayExpenses.map((expense) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ExpenseCard(
              expense: expense,
              onTap: () => _editExpense(context, expense),
              onDelete: () => _deleteExpense(ref, expense.id),
            ),
          )),
      ],
    );
  }
  
  void _editExpense(BuildContext context, expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );
  }
  
  void _deleteExpense(WidgetRef ref, String id) {
    ref.read(expenseProvider.notifier).deleteExpense(id);
  }
  
  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Expense Tracker v1.0.0\n\n'
          'A simple, offline-first expense tracking app.\n\n'
          'Features:\n'
          '• Multi-currency support\n'
          '• Payment method tracking\n'
          '• Data visualization\n'
          '• Offline-first architecture',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
