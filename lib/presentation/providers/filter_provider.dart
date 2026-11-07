import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/domain/entities/expense.dart';
import 'package:expense_tracker/domain/usecases/filter_expenses.dart';
import 'package:expense_tracker/presentation/providers/expense_provider.dart';

// Filter criteria provider
final filterCriteriaProvider = StateProvider<FilterCriteria>((ref) {
  return const FilterCriteria();
});

// Filter use case provider
final filterExpensesUseCaseProvider = Provider<FilterExpenses>((ref) {
  return FilterExpenses();
});

// Filtered expenses provider (computed)
final filteredExpensesProvider = Provider<List<Expense>>((ref) {
  final allExpenses = ref.watch(expensesListProvider);
  final filterCriteria = ref.watch(filterCriteriaProvider);
  final filterUseCase = ref.watch(filterExpensesUseCaseProvider);
  
  return filterUseCase(allExpenses, filterCriteria);
});

// Provider for expenses grouped by date
final expensesByDateProvider = Provider<Map<DateTime, List<Expense>>>((ref) {
  final expenses = ref.watch(filteredExpensesProvider);
  final Map<DateTime, List<Expense>> grouped = {};
  
  for (var expense in expenses) {
    final date = DateTime(
      expense.timestamp.year,
      expense.timestamp.month,
      expense.timestamp.day,
    );
    
    if (!grouped.containsKey(date)) {
      grouped[date] = [];
    }
    grouped[date]!.add(expense);
  }
  
  // Sort each day's expenses by time (newest first)
  for (var key in grouped.keys) {
    grouped[key]!.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }
  
  return grouped;
});

// Provider for today's expenses
final todayExpensesProvider = Provider<List<Expense>>((ref) {
  final allExpenses = ref.watch(expensesListProvider);
  final filterUseCase = ref.watch(filterExpensesUseCaseProvider);
  return filterUseCase.getToday(allExpenses);
});

// Provider for this week's expenses
final weekExpensesProvider = Provider<List<Expense>>((ref) {
  final allExpenses = ref.watch(expensesListProvider);
  final filterUseCase = ref.watch(filterExpensesUseCaseProvider);
  return filterUseCase.getThisWeek(allExpenses);
});

// Provider for this month's expenses
final monthExpensesProvider = Provider<List<Expense>>((ref) {
  final allExpenses = ref.watch(expensesListProvider);
  final filterUseCase = ref.watch(filterExpensesUseCaseProvider);
  return filterUseCase.getThisMonth(allExpenses);
});

// Provider for unique currencies in expenses
final availableCurrenciesProvider = Provider<List<String>>((ref) {
  final expenses = ref.watch(expensesListProvider);
  final currencies = expenses.map((e) => e.currency).toSet().toList();
  currencies.sort();
  return currencies;
});

// Available emojis provider
final availableEmojisProvider = Provider<List<String>>((ref) {
  final expenses = ref.watch(expensesListProvider);
  final emojis = expenses.map((e) => e.emoji).toSet().toList();
  emojis.sort();
  return emojis;
});

// Provider for selected currency (for charts)
final selectedCurrencyProvider = StateProvider<String?>((ref) => null);
