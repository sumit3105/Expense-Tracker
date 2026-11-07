import 'package:hive_flutter/hive_flutter.dart';
import 'package:expense_tracker/data/models/expense_model.dart';

/// Hive storage initialization and configuration
class HiveStorage {
  static const String expensesBoxName = 'expenses';
  
  /// Initialize Hive and register adapters
  static Future<void> init() async {
    // Initialize Hive for Flutter
    await Hive.initFlutter();
    
    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(ExpenseModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(PaymentMethodAdapter());
    }
    
    // Open boxes
    await Hive.openBox<ExpenseModel>(expensesBoxName);
  }
  
  /// Get the expenses box
  static Box<ExpenseModel> get expensesBox {
    return Hive.box<ExpenseModel>(expensesBoxName);
  }
  
  /// Close all boxes (call on app dispose)
  static Future<void> close() async {
    await Hive.close();
  }
}
