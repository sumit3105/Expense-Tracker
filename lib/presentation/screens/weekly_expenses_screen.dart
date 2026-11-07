import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/presentation/providers/expense_provider.dart';
import 'package:expense_tracker/domain/entities/expense.dart';
import 'package:expense_tracker/presentation/widgets/expense_card.dart';
import 'package:expense_tracker/presentation/screens/add_expense_screen.dart';
import 'package:expense_tracker/core/constants/currencies.dart';

// Provider for tracking week offset (0 = current week, -1 = last week, +1 = next week)
final weekOffsetProvider = StateProvider<int>((ref) => 0);

class WeeklyExpensesScreen extends ConsumerStatefulWidget {
  const WeeklyExpensesScreen({super.key});

  @override
  ConsumerState<WeeklyExpensesScreen> createState() => _WeeklyExpensesScreenState();
}

class _WeeklyExpensesScreenState extends ConsumerState<WeeklyExpensesScreen> {
  final PageController _pageController = PageController(initialPage: 1000);
  int _currentPage = 1000; // Start at middle to allow infinite scrolling

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _getWeekStart(int offset) {
    final now = DateTime.now();
    final currentWeekStart = now.subtract(Duration(days: now.weekday - 1));
    return currentWeekStart.add(Duration(days: offset * 7));
  }

  DateTime _getWeekEnd(int offset) {
    final weekStart = _getWeekStart(offset);
    return weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
  }

  List<Expense> _getExpensesForDay(List<Expense> allExpenses, DateTime day) {
    return allExpenses.where((e) {
      final expenseDate = DateTime(e.timestamp.year, e.timestamp.month, e.timestamp.day);
      final targetDate = DateTime(day.year, day.month, day.day);
      return expenseDate.isAtSameMomentAs(targetDate);
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  double _getTotalForDay(List<Expense> dayExpenses, String currency) {
    return dayExpenses
        .where((e) => e.currency == currency)
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  @override
  Widget build(BuildContext context) {
    final allExpenses = ref.watch(expensesListProvider);
    final weekOffset = ref.watch(weekOffsetProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Expenses'),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            tooltip: 'Current Week',
            onPressed: () {
              ref.read(weekOffsetProvider.notifier).state = 0;
              _pageController.jumpToPage(1000);
            },
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (page) {
          setState(() {
            _currentPage = page;
          });
          final newOffset = page - 1000;
          ref.read(weekOffsetProvider.notifier).state = newOffset;
        },
        itemBuilder: (context, pageIndex) {
          final offset = pageIndex - 1000;
          return _buildWeekView(context, allExpenses, offset);
        },
      ),
    );
  }

  Widget _buildWeekView(BuildContext context, List<Expense> allExpenses, int offset) {
    final weekStart = _getWeekStart(offset);
    final weekEnd = _getWeekEnd(offset);

    // Filter expenses for this week
    final weekExpenses = allExpenses.where((e) {
      return !e.timestamp.isBefore(weekStart) && !e.timestamp.isAfter(weekEnd);
    }).toList();

    // Get unique currencies in this week
    final currencies = weekExpenses.map((e) => e.currency).toSet().toList()..sort();

    return Column(
      children: [
        // Week header with navigation
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () {
                  _pageController.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              Column(
                children: [
                  Text(
                    offset == 0 ? 'This Week' : offset == -1 ? 'Last Week' : 
                    offset < 0 ? '${-offset} weeks ago' : '${offset} weeks ahead',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d, yyyy').format(weekEnd)}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () {
                  _pageController.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  );
                },
              ),
            ],
          ),
        ),

        // Week total
        if (weekExpenses.isNotEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Week Total',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    ...currencies.map((currency) {
                      final total = weekExpenses
                          .where((e) => e.currency == currency)
                          .fold(0.0, (sum, e) => sum + e.amount);
                      final symbol = Currencies.getSymbol(currency);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(currency),
                            Text(
                              '$symbol${NumberFormat('#,##0.00').format(total)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ),

        // Day-wise expenses list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 7,
            itemBuilder: (context, index) {
              final day = weekStart.add(Duration(days: index));
              final dayExpenses = _getExpensesForDay(allExpenses, day);
              final isToday = DateTime.now().difference(day).inDays.abs() == 0 &&
                  day.day == DateTime.now().day;

              return _buildDaySection(context, day, dayExpenses, currencies, isToday);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDaySection(
    BuildContext context,
    DateTime day,
    List<Expense> dayExpenses,
    List<String> weekCurrencies,
    bool isToday,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Day header
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isToday 
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isToday
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      DateFormat('EEE, MMM d').format(day),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isToday ? Colors.white : null,
                      ),
                    ),
                    if (isToday) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Today',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Day total
              if (dayExpenses.isNotEmpty)
                Expanded(
                  child: Text(
                    weekCurrencies.map((currency) {
                      final total = _getTotalForDay(dayExpenses, currency);
                      if (total == 0) return null;
                      final symbol = Currencies.getSymbol(currency);
                      return '$symbol${NumberFormat('#,##0.00').format(total)}';
                    }).where((e) => e != null).join(' | '),
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),

        // Day expenses or empty state
        if (dayExpenses.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No expenses',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[500],
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...dayExpenses.map((expense) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ExpenseCard(
              expense: expense,
              onTap: () => _editExpense(context, expense),
              onDelete: () => _deleteExpense(expense.id),
            ),
          )),
      ],
    );
  }

  void _editExpense(BuildContext context, Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExpenseScreen(expense: expense),
      ),
    );
  }

  void _deleteExpense(String id) {
    ref.read(expenseProvider.notifier).deleteExpense(id);
  }
}
