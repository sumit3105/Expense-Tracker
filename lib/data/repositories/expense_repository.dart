import 'package:hive/hive.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/data/storage/hive_storage.dart';

/// Repository for expense CRUD operations
class ExpenseRepository {
  late final Box<ExpenseModel> _box;
  
  ExpenseRepository() {
    _box = HiveStorage.expensesBox;
  }
  
  /// Add a new expense
  /// Returns the expense ID
  Future<String> addExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
    return expense.id;
  }
  
  /// Update an existing expense
  Future<void> updateExpense(ExpenseModel expense) async {
    await _box.put(expense.id, expense);
  }
  
  /// Delete an expense by ID
  Future<void> deleteExpense(String id) async {
    await _box.delete(id);
  }
  
  /// Get a single expense by ID
  ExpenseModel? getExpense(String id) {
    return _box.get(id);
  }
  
  /// Get all expenses
  List<ExpenseModel> getAllExpenses() {
    return _box.values.toList();
  }
  
  /// Get expenses sorted by timestamp (newest first)
  List<ExpenseModel> getExpensesSorted() {
    final expenses = getAllExpenses();
    expenses.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return expenses;
  }
  
  /// Get expenses filtered by payment method
  List<ExpenseModel> getExpensesByPaymentMethod(PaymentMethod method) {
    return _box.values
        .where((expense) => expense.paymentMethod == method)
        .toList();
  }
  
  /// Get expenses filtered by currency
  List<ExpenseModel> getExpensesByCurrency(String currency) {
    return _box.values
        .where((expense) => expense.currency == currency)
        .toList();
  }
  
  /// Get expenses filtered by location
  List<ExpenseModel> getExpensesByLocation(String location) {
    return _box.values
        .where((expense) => 
            expense.location != null && 
            expense.location!.toLowerCase().contains(location.toLowerCase()))
        .toList();
  }
  
  /// Get expenses within a date range
  List<ExpenseModel> getExpensesByDateRange(DateTime start, DateTime end) {
    return _box.values
        .where((expense) => 
            expense.timestamp.isAfter(start) && 
            expense.timestamp.isBefore(end))
        .toList();
  }
  
  /// Get total expense count
  int getExpenseCount() {
    return _box.length;
  }
  
  /// Clear all expenses (for testing/reset)
  Future<void> clearAll() async {
    await _box.clear();
  }
  
  /// Watch for changes in the expenses box
  Stream<BoxEvent> watchExpenses() {
    return _box.watch();
  }
}
