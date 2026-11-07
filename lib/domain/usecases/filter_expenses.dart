import 'package:expense_tracker/domain/entities/expense.dart';
import 'package:expense_tracker/data/models/expense_model.dart';

/// Filter criteria for expenses
class FilterCriteria {
  final List<String>? currencies;
  final List<PaymentMethod>? paymentMethods;
  final List<String>? emojis; // Filter by emoji/category
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  
  const FilterCriteria({
    this.currencies,
    this.paymentMethods,
    this.emojis,
    this.location,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });
  
  /// Check if filter is empty
  bool get isEmpty {
    return currencies == null &&
        paymentMethods == null &&
        emojis == null &&
        location == null &&
        startDate == null &&
        endDate == null &&
        searchQuery == null;
  }
  
  /// Copy with updated fields
  FilterCriteria copyWith({
    List<String>? currencies,
    List<PaymentMethod>? paymentMethods,
    List<String>? emojis,
    String? location,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
  }) {
    return FilterCriteria(
      currencies: currencies ?? this.currencies,
      paymentMethods: paymentMethods ?? this.paymentMethods,
      emojis: emojis ?? this.emojis,
      location: location ?? this.location,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
  
  /// Clear all filters
  FilterCriteria clear() {
    return const FilterCriteria();
  }
}

/// Use case for filtering expenses
class FilterExpenses {
  /// Apply filter criteria to a list of expenses
  List<Expense> call(List<Expense> expenses, FilterCriteria criteria) {
    if (criteria.isEmpty) return expenses;
    
    var filtered = expenses;
    
    // Filter by currencies
    if (criteria.currencies != null && criteria.currencies!.isNotEmpty) {
      filtered = filtered
          .where((e) => criteria.currencies!.contains(e.currency))
          .toList();
    }
    
    // Filter by payment methods
    if (criteria.paymentMethods != null && criteria.paymentMethods!.isNotEmpty) {
      filtered = filtered
          .where((e) => criteria.paymentMethods!.contains(e.paymentMethod))
          .toList();
    }
    
    // Filter by emojis/categories
    if (criteria.emojis != null && criteria.emojis!.isNotEmpty) {
      filtered = filtered
          .where((e) => criteria.emojis!.contains(e.emoji))
          .toList();
    }
    
    // Filter by location
    if (criteria.location != null && criteria.location!.isNotEmpty) {
      filtered = filtered
          .where((e) => 
              e.location != null &&
              e.location!.toLowerCase().contains(criteria.location!.toLowerCase()))
          .toList();
    }
    
    // Filter by date range
    if (criteria.startDate != null) {
      filtered = filtered
          .where((e) => e.timestamp.isAfter(criteria.startDate!) || 
                       e.timestamp.isAtSameMomentAs(criteria.startDate!))
          .toList();
    }
    
    if (criteria.endDate != null) {
      filtered = filtered
          .where((e) => e.timestamp.isBefore(criteria.endDate!) ||
                       e.timestamp.isAtSameMomentAs(criteria.endDate!))
          .toList();
    }
    
    // Filter by search query (title or notes)
    if (criteria.searchQuery != null && criteria.searchQuery!.isNotEmpty) {
      final query = criteria.searchQuery!.toLowerCase();
      filtered = filtered
          .where((e) => 
              e.title.toLowerCase().contains(query) ||
              (e.notes?.toLowerCase().contains(query) ?? false))
          .toList();
    }
    
    return filtered;
  }
  
  /// Get expenses for today
  List<Expense> getToday(List<Expense> expenses) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return call(
      expenses,
      FilterCriteria(startDate: startOfDay, endDate: endOfDay),
    );
  }
  
  /// Get expenses for this month
  List<Expense> getThisMonth(List<Expense> expenses) {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    
    return call(
      expenses,
      FilterCriteria(startDate: startOfMonth, endDate: endOfMonth),
    );
  }
  
  /// Get expenses for this week
  List<Expense> getThisWeek(List<Expense> expenses) {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    final endOfWeek = startOfWeekDay.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    
    return call(
      expenses,
      FilterCriteria(startDate: startOfWeekDay, endDate: endOfWeek),
    );
  }
}
