import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/data/repositories/expense_repository.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/domain/entities/expense.dart';
import 'package:expense_tracker/core/constants/emoji_mappings.dart';
import 'package:uuid/uuid.dart';

// Repository provider
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) {
  return ExpenseRepository();
});

// UUID generator provider
final uuidProvider = Provider<Uuid>((ref) => const Uuid());

/// Expense state notifier
class ExpenseNotifier extends StateNotifier<AsyncValue<List<Expense>>> {
  final ExpenseRepository _repository;
  final Uuid _uuid;
  
  ExpenseNotifier(this._repository, this._uuid) : super(const AsyncValue.loading()) {
    loadExpenses();
  }
  
  /// Load all expenses from repository
  Future<void> loadExpenses() async {
    state = const AsyncValue.loading();
    try {
      final models = _repository.getExpensesSorted();
      final expenses = models.map((m) => Expense.fromModel(m)).toList();
      state = AsyncValue.data(expenses);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Add a new expense
  Future<void> addExpense({
    required String title,
    required double amount,
    required String currency,
    required PaymentMethod paymentMethod,
    String? location,
    DateTime? timestamp,
    String? emoji,
    String? notes,
  }) async {
    try {
      final id = _uuid.v4();
      final expenseEmoji = emoji ?? EmojiMappings.getEmoji(title);
      final expenseTime = timestamp ?? DateTime.now();
      
      final model = ExpenseModel(
        id: id,
        title: title,
        amount: amount,
        currency: currency,
        paymentMethod: paymentMethod,
        location: location,
        timestamp: expenseTime,
        emoji: expenseEmoji,
        notes: notes,
      );
      
      await _repository.addExpense(model);
      await loadExpenses();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Update an existing expense
  Future<void> updateExpense(Expense expense) async {
    try {
      await _repository.updateExpense(expense.toModel());
      await loadExpenses();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Delete an expense
  Future<void> deleteExpense(String id) async {
    try {
      await _repository.deleteExpense(id);
      await loadExpenses();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  /// Get expense by ID
  Expense? getExpenseById(String id) {
    return state.value?.firstWhere(
      (e) => e.id == id,
      orElse: () => throw Exception('Expense not found'),
    );
  }
}

// Expense provider
final expenseProvider = StateNotifierProvider<ExpenseNotifier, AsyncValue<List<Expense>>>((ref) {
  final repository = ref.watch(expenseRepositoryProvider);
  final uuid = ref.watch(uuidProvider);
  return ExpenseNotifier(repository, uuid);
});

// Provider for expenses list (unwrapped)
final expensesListProvider = Provider<List<Expense>>((ref) {
  final asyncExpenses = ref.watch(expenseProvider);
  return asyncExpenses.value ?? [];
});
