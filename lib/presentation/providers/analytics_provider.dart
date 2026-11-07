import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/domain/entities/expense.dart';
import 'package:expense_tracker/domain/usecases/aggregate_expenses.dart';
import 'package:expense_tracker/presentation/providers/filter_provider.dart';

// Aggregation use case provider
final aggregateExpensesUseCaseProvider = Provider<AggregateExpenses>((ref) {
  return AggregateExpenses();
});

// Aggregated data provider for all expenses
final aggregatedDataProvider = Provider<AggregatedData>((ref) {
  final expenses = ref.watch(filteredExpensesProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);
  final aggregateUseCase = ref.watch(aggregateExpensesUseCaseProvider);
  
  return aggregateUseCase(expenses, currency: selectedCurrency);
});

// Total amount provider (for selected currency or all)
final totalAmountProvider = Provider<double>((ref) {
  final expenses = ref.watch(filteredExpensesProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);
  final aggregateUseCase = ref.watch(aggregateExpensesUseCaseProvider);
  
  var filteredByCurrency = expenses;
  if (selectedCurrency != null) {
    filteredByCurrency = expenses.where((e) => e.currency == selectedCurrency).toList();
  }
  
  return aggregateUseCase.getTotalAmount(filteredByCurrency);
});

// Average expense provider
final averageExpenseProvider = Provider<double>((ref) {
  final expenses = ref.watch(filteredExpensesProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);
  final aggregateUseCase = ref.watch(aggregateExpensesUseCaseProvider);
  
  var filteredByCurrency = expenses;
  if (selectedCurrency != null) {
    filteredByCurrency = expenses.where((e) => e.currency == selectedCurrency).toList();
  }
  
  return aggregateUseCase.getAverageAmount(filteredByCurrency);
});

// Highest expense provider
final highestExpenseProvider = Provider<Expense?>((ref) {
  final expenses = ref.watch(filteredExpensesProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);
  final aggregateUseCase = ref.watch(aggregateExpensesUseCaseProvider);
  
  var filteredByCurrency = expenses;
  if (selectedCurrency != null) {
    filteredByCurrency = expenses.where((e) => e.currency == selectedCurrency).toList();
  }
  
  return aggregateUseCase.getHighestExpense(filteredByCurrency);
});

// Lowest expense provider
final lowestExpenseProvider = Provider<Expense?>((ref) {
  final expenses = ref.watch(filteredExpensesProvider);
  final selectedCurrency = ref.watch(selectedCurrencyProvider);
  final aggregateUseCase = ref.watch(aggregateExpensesUseCaseProvider);
  
  var filteredByCurrency = expenses;
  if (selectedCurrency != null) {
    filteredByCurrency = expenses.where((e) => e.currency == selectedCurrency).toList();
  }
  
  return aggregateUseCase.getLowestExpense(filteredByCurrency);
});

// Expense count provider
final expenseCountProvider = Provider<int>((ref) {
  final expenses = ref.watch(filteredExpensesProvider);
  return expenses.length;
});
