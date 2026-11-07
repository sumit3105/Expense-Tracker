import 'package:expense_tracker/domain/entities/expense.dart';
import 'package:expense_tracker/data/models/expense_model.dart';

/// Aggregated expense data for analytics
class AggregatedData {
  final Map<String, double> totalByCurrency;
  final Map<PaymentMethod, double> totalByPaymentMethod;
  final Map<String, double> totalByCategory; // Using emoji as category
  final Map<DateTime, double> dailyTotals;
  final Map<DateTime, double> weeklyTotals; // Week starting date -> total
  final Map<DateTime, double> monthlyTotals;
  
  const AggregatedData({
    required this.totalByCurrency,
    required this.totalByPaymentMethod,
    required this.totalByCategory,
    required this.dailyTotals,
    required this.weeklyTotals,
    required this.monthlyTotals,
  });
}

/// Use case for aggregating expense data for analytics
class AggregateExpenses {
  /// Aggregate expenses for a specific currency
  AggregatedData call(List<Expense> expenses, {String? currency}) {
    // Filter by currency if specified
    var filteredExpenses = expenses;
    if (currency != null) {
      filteredExpenses = expenses.where((e) => e.currency == currency).toList();
    }
    
    return AggregatedData(
      totalByCurrency: _aggregateByCurrency(filteredExpenses),
      totalByPaymentMethod: _aggregateByPaymentMethod(filteredExpenses),
      totalByCategory: _aggregateByCategory(filteredExpenses),
      dailyTotals: _aggregateByDay(filteredExpenses),
      weeklyTotals: _aggregateByWeek(filteredExpenses),
      monthlyTotals: _aggregateByMonth(filteredExpenses),
    );
  }
  
  /// Aggregate total amount by currency
  Map<String, double> _aggregateByCurrency(List<Expense> expenses) {
    final Map<String, double> totals = {};
    
    for (var expense in expenses) {
      totals[expense.currency] = (totals[expense.currency] ?? 0) + expense.amount;
    }
    
    return totals;
  }
  
  /// Aggregate total amount by payment method
  Map<PaymentMethod, double> _aggregateByPaymentMethod(List<Expense> expenses) {
    final Map<PaymentMethod, double> totals = {};
    
    for (var expense in expenses) {
      totals[expense.paymentMethod] = 
          (totals[expense.paymentMethod] ?? 0) + expense.amount;
    }
    
    return totals;
  }
  
  /// Aggregate total amount by category (using emoji as proxy)
  Map<String, double> _aggregateByCategory(List<Expense> expenses) {
    final Map<String, double> totals = {};
    
    for (var expense in expenses) {
      totals[expense.emoji] = (totals[expense.emoji] ?? 0) + expense.amount;
    }
    
    return totals;
  }
  
  /// Aggregate total amount by day
  Map<DateTime, double> _aggregateByDay(List<Expense> expenses) {
    final Map<DateTime, double> totals = {};
    
    for (var expense in expenses) {
      final date = DateTime(
        expense.timestamp.year,
        expense.timestamp.month,
        expense.timestamp.day,
      );
      totals[date] = (totals[date] ?? 0) + expense.amount;
    }
    
    return totals;
  }
  
  /// Aggregate total amount by week (Monday as start of week)
  Map<DateTime, double> _aggregateByWeek(List<Expense> expenses) {
    final Map<DateTime, double> totals = {};
    
    for (var expense in expenses) {
      // Get the Monday of the week containing this expense
      final date = expense.timestamp;
      final daysFromMonday = (date.weekday - DateTime.monday) % 7;
      final weekStart = DateTime(
        date.year,
        date.month,
        date.day - daysFromMonday,
      );
      totals[weekStart] = (totals[weekStart] ?? 0) + expense.amount;
    }
    
    return totals;
  }
  
  /// Aggregate total amount by month
  Map<DateTime, double> _aggregateByMonth(List<Expense> expenses) {
    final Map<DateTime, double> totals = {};
    
    for (var expense in expenses) {
      final month = DateTime(
        expense.timestamp.year,
        expense.timestamp.month,
      );
      totals[month] = (totals[month] ?? 0) + expense.amount;
    }
    
    return totals;
  }
  
  /// Get total amount for a list of expenses
  double getTotalAmount(List<Expense> expenses) {
    return expenses.fold(0, (sum, expense) => sum + expense.amount);
  }
  
  /// Get average expense amount
  double getAverageAmount(List<Expense> expenses) {
    if (expenses.isEmpty) return 0;
    return getTotalAmount(expenses) / expenses.length;
  }
  
  /// Get highest expense
  Expense? getHighestExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => a.amount > b.amount ? a : b);
  }
  
  /// Get lowest expense
  Expense? getLowestExpense(List<Expense> expenses) {
    if (expenses.isEmpty) return null;
    return expenses.reduce((a, b) => a.amount < b.amount ? a : b);
  }
}
