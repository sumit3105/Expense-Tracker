import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/presentation/providers/expense_provider.dart';
import 'package:expense_tracker/presentation/providers/filter_provider.dart';
import 'package:expense_tracker/domain/usecases/filter_expenses.dart';
import 'package:expense_tracker/domain/usecases/aggregate_expenses.dart';
import 'package:expense_tracker/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/presentation/widgets/expense_card.dart';
import 'package:expense_tracker/presentation/widgets/filter_panel.dart';
import 'package:expense_tracker/core/constants/currencies.dart';

class ExpenseListScreen extends ConsumerWidget {
  const ExpenseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncExpenses = ref.watch(expenseProvider);
    final expensesByDate = ref.watch(expensesByDateProvider);
    final filterCriteria = ref.watch(filterCriteriaProvider);
    final hasActiveFilters = !filterCriteria.isEmpty;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          // Filter button
          IconButton(
            icon: Icon(
              hasActiveFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
            ),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                builder: (context) => const FilterPanel(),
              );
            },
          ),
          // Search button
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _showSearchDialog(context, ref);
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
        data: (expenses) {
          if (expensesByDate.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    hasActiveFilters 
                        ? Icons.search_off 
                        : Icons.receipt_long_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    hasActiveFilters 
                        ? 'No matching expenses' 
                        : 'No expenses yet',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  if (hasActiveFilters)
                    TextButton(
                      onPressed: () {
                        ref.read(filterCriteriaProvider.notifier).state = 
                            const FilterCriteria();
                      },
                      child: const Text('Clear Filters'),
                    ),
                ],
              ),
            );
          }
          
          // Calculate totals by currency for filtered expenses
          final filteredExpenses = ref.watch(filteredExpensesProvider);
          final aggregateUseCase = AggregateExpenses();
          final aggregatedData = aggregateUseCase(filteredExpenses);
          
          // Calculate current month filtered expenses
          final monthExpenses = ref.watch(monthExpensesProvider);
          final filteredMonthExpenses = monthExpenses.where((e) {
            if (filterCriteria.currencies != null && filterCriteria.currencies!.isNotEmpty) {
              return filterCriteria.currencies!.contains(e.currency);
            }
            return true;
          }).toList();
          final monthAggregatedData = aggregateUseCase(filteredMonthExpenses);
          
          return Column(
            children: [
              // Total expenses card
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Total Expenses',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${filteredExpenses.length} ${filteredExpenses.length == 1 ? 'item' : 'items'}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // All-time totals
                    Text(
                      'All Time',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...aggregatedData.totalByCurrency.entries.map((entry) {
                      final symbol = Currencies.getSymbol(entry.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              '$symbol${NumberFormat('#,##0.00').format(entry.value)}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    
                    const SizedBox(height: 12),
                    Divider(color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.3)),
                    const SizedBox(height: 12),
                    
                    // Current month totals
                    Text(
                      'This Month',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...monthAggregatedData.totalByCurrency.entries.map((entry) {
                      final symbol = Currencies.getSymbol(entry.key);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 13,
                                color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.9),
                              ),
                            ),
                            Text(
                              '$symbol${NumberFormat('#,##0.00').format(entry.value)}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
              
              // Expense list
              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(expenseProvider);
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: expensesByDate.length,
                    itemBuilder: (context, index) {
                      final date = expensesByDate.keys.elementAt(index);
                      final dayExpenses = expensesByDate[date]!;
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Date header
                          Padding(
                            padding: const EdgeInsets.only(left: 8, top: 8, bottom: 8),
                            child: Text(
                              _formatDateHeader(date),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          
                          // Expenses for this date
                          ...dayExpenses.map((expense) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: ExpenseCard(
                              expense: expense,
                              onTap: () => _editExpense(context, expense),
                              onDelete: () => _deleteExpense(ref, expense.id),
                            ),
                          )),
                          
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddExpenseScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
  
  String _formatDateHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    
    if (date == today) {
      return 'Today - ${DateFormat('MMM dd, yyyy').format(date)}';
    } else if (date == yesterday) {
      return 'Yesterday - ${DateFormat('MMM dd, yyyy').format(date)}';
    } else {
      return DateFormat('EEEE - MMM dd, yyyy').format(date);
    }
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
  
  void _showSearchDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    final currentCriteria = ref.read(filterCriteriaProvider);
    controller.text = currentCriteria.searchQuery ?? '';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Expenses'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Search by title or notes',
            prefixIcon: Icon(Icons.search),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(filterCriteriaProvider.notifier).state = 
                  currentCriteria.copyWith(searchQuery: null);
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () {
              ref.read(filterCriteriaProvider.notifier).state = 
                  currentCriteria.copyWith(searchQuery: controller.text.trim());
              Navigator.pop(context);
            },
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }
}
