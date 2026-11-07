import 'package:expense_tracker/data/models/expense_model.dart';

/// Domain entity for Expense (immutable, UI-friendly)
class Expense {
  final String id;
  final String title;
  final double amount;
  final String currency;
  final PaymentMethod paymentMethod;
  final String? location;
  final DateTime timestamp;
  final String emoji;
  final String? notes;
  
  const Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.currency,
    required this.paymentMethod,
    this.location,
    required this.timestamp,
    required this.emoji,
    this.notes,
  });
  
  /// Create from ExpenseModel
  factory Expense.fromModel(ExpenseModel model) {
    return Expense(
      id: model.id,
      title: model.title,
      amount: model.amount,
      currency: model.currency,
      paymentMethod: model.paymentMethod,
      location: model.location,
      timestamp: model.timestamp,
      emoji: model.emoji,
      notes: model.notes,
    );
  }
  
  /// Convert to ExpenseModel
  ExpenseModel toModel() {
    return ExpenseModel(
      id: id,
      title: title,
      amount: amount,
      currency: currency,
      paymentMethod: paymentMethod,
      location: location,
      timestamp: timestamp,
      emoji: emoji,
      notes: notes,
    );
  }
  
  /// Create a copy with some fields updated
  Expense copyWith({
    String? id,
    String? title,
    double? amount,
    String? currency,
    PaymentMethod? paymentMethod,
    String? location,
    DateTime? timestamp,
    String? emoji,
    String? notes,
  }) {
    return Expense(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      emoji: emoji ?? this.emoji,
      notes: notes ?? this.notes,
    );
  }
  
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    
    return other is Expense &&
        other.id == id &&
        other.title == title &&
        other.amount == amount &&
        other.currency == currency &&
        other.paymentMethod == paymentMethod &&
        other.location == location &&
        other.timestamp == timestamp &&
        other.emoji == emoji &&
        other.notes == notes;
  }
  
  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        amount.hashCode ^
        currency.hashCode ^
        paymentMethod.hashCode ^
        (location?.hashCode ?? 0) ^
        timestamp.hashCode ^
        emoji.hashCode ^
        (notes?.hashCode ?? 0);
  }
  
  @override
  String toString() {
    return 'Expense(id: $id, title: $title, amount: $amount, currency: $currency, paymentMethod: $paymentMethod, location: $location, timestamp: $timestamp, emoji: $emoji, notes: $notes)';
  }
}
