import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:expense_tracker/presentation/providers/filter_provider.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/domain/usecases/filter_expenses.dart';

class FilterPanel extends ConsumerStatefulWidget {
  const FilterPanel({super.key});

  @override
  ConsumerState<FilterPanel> createState() => _FilterPanelState();
}

class _FilterPanelState extends ConsumerState<FilterPanel> {
  late Set<String> _selectedCurrencies;
  late Set<PaymentMethod> _selectedPaymentMethods;
  late Set<String> _selectedEmojis;
  late String _locationFilter;
  DateTime? _startDate;
  DateTime? _endDate;
  
  @override
  void initState() {
    super.initState();
    final currentCriteria = ref.read(filterCriteriaProvider);
    _selectedCurrencies = currentCriteria.currencies?.toSet() ?? {};
    _selectedPaymentMethods = currentCriteria.paymentMethods?.toSet() ?? {};
    _selectedEmojis = currentCriteria.emojis?.toSet() ?? {};
    _locationFilter = currentCriteria.location ?? '';
    _startDate = currentCriteria.startDate;
    _endDate = currentCriteria.endDate;
  }
  
  @override
  Widget build(BuildContext context) {
    final availableCurrencies = ref.watch(availableCurrenciesProvider);
    
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Filter Expenses',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Currency filter
              const Text(
                'Currencies',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (availableCurrencies.isEmpty)
                const Text('No currencies available')
              else
                Wrap(
                  spacing: 8,
                  children: availableCurrencies.map((currency) {
                    final isSelected = _selectedCurrencies.contains(currency);
                    return FilterChip(
                      label: Text(currency),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedCurrencies.add(currency);
                          } else {
                            _selectedCurrencies.remove(currency);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
              
              const SizedBox(height: 24),
              
              // Payment method filter
              const Text(
                'Payment Methods',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                 spacing: 8,
                children: PaymentMethod.values.map((method) {
                  final isSelected = _selectedPaymentMethods.contains(method);
                  return FilterChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(method.icon),
                        const SizedBox(width: 4),
                        Text(method.displayName),
                      ],
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPaymentMethods.add(method);
                        } else {
                          _selectedPaymentMethods.remove(method);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 24),
              
              // Emoji/Category filter
              const Text(
                'Categories (Emoji)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Builder(
                builder: (context) {
                  final availableEmojis = ref.watch(availableEmojisProvider);
                  if (availableEmojis.isEmpty) {
                    return const Text('No categories available');
                  }
                  return Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableEmojis.map((emoji) {
                      final isSelected = _selectedEmojis.contains(emoji);
                      return FilterChip(
                        label: Text(
                          emoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedEmojis.add(emoji);
                            } else {
                              _selectedEmojis.remove(emoji);
                            }
                          });
                        },
                      );
                    }).toList(),
                  );
                },
              ),
              
              const SizedBox(height: 24),
              
              // Location filter
              const Text(
                'Location',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  hintText: 'Filter by location',
                  prefixIcon: Icon(Icons.location_on),
                ),
                controller: TextEditingController(text: _locationFilter),
                onChanged: (value) {
                  _locationFilter = value;
                },
              ),
              
              const SizedBox(height: 24),
              
              // Date range filter
              const Text(
                'Date Range',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _startDate != null 
                            ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                            : 'Start Date',
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = DateTime(date.year, date.month, date.day);
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: Text(
                        _endDate != null 
                            ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                            : 'End Date',
                      ),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate ?? DateTime.now(),
                          firstDate: _startDate ?? DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = DateTime(date.year, date.month, date.day, 23, 59, 59);
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              if (_startDate != null || _endDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: TextButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    child: const Text('Clear Dates'),
                  ),
                ),
              
              const SizedBox(height: 32),
              
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearFilters,
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Apply Filters'),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
  
  void _clearFilters() {
    ref.read(filterCriteriaProvider.notifier).state = const FilterCriteria();
    Navigator.pop(context);
  }
  
  void _applyFilters() {
    final newCriteria = FilterCriteria(
      currencies: _selectedCurrencies.isEmpty ? null : _selectedCurrencies.toList(),
      paymentMethods: _selectedPaymentMethods.isEmpty ? null : _selectedPaymentMethods.toList(),
      emojis: _selectedEmojis.isEmpty ? null : _selectedEmojis.toList(),
      location: _locationFilter.isEmpty ? null : _locationFilter,
      startDate: _startDate,
      endDate: _endDate,
    );
    
    ref.read(filterCriteriaProvider.notifier).state = newCriteria;
    Navigator.pop(context);
  }
}
