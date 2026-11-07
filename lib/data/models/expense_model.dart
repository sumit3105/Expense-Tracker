import 'package:hive/hive.dart';

part 'expense_model.g.dart';

/// Payment method enum for expenses
@HiveType(typeId: 1)
enum PaymentMethod {
  @HiveField(0)
  cash,
  
  @HiveField(1)
  upi,
  
  @HiveField(2)
  atmCard;
  
  /// Display name for UI
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.upi:
        return 'UPI';
      case PaymentMethod.atmCard:
        return 'ATM/Card';
    }
  }
  
  /// Icon for the payment method
  String get icon {
    switch (this) {
      case PaymentMethod.cash:
        return '💵';
      case PaymentMethod.upi:
        return '📱';
      case PaymentMethod.atmCard:
        return '💳';
    }
  }
}

/// Expense model for Hive storage
@HiveType(typeId: 0)
class ExpenseModel extends HiveObject {
  @HiveField(0)
  late String id;
  
  @HiveField(1)
  late String title;
  
  @HiveField(2)
  late double amount;
  
  @HiveField(3)
  late String currency;
  
  @HiveField(4)
  late PaymentMethod paymentMethod;
  
  @HiveField(5)
  String? location;
  
  @HiveField(6)
  late DateTime timestamp;
  
  @HiveField(7)
  late String emoji;
  
  @HiveField(8)
  String? notes;
  
  ExpenseModel({
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
  
  /// Create a copy with some fields updated
  ExpenseModel copyWith({
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
    return ExpenseModel(
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
  String toString() {
    return 'ExpenseModel(id: $id, title: $title, amount: $amount, currency: $currency, paymentMethod: $paymentMethod, location: $location, timestamp: $timestamp, emoji: $emoji, notes: $notes)';
  }
}
