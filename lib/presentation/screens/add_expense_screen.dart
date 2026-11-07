import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:expense_tracker/domain/entities/expense.dart';
import 'package:expense_tracker/data/models/expense_model.dart';
import 'package:expense_tracker/presentation/providers/expense_provider.dart';
import 'package:expense_tracker/core/constants/currencies.dart';
import 'package:expense_tracker/core/constants/emoji_mappings.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  final Expense? expense; // null for new, non-null for edit
  
  const AddExpenseScreen({super.key, this.expense});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;
  late final TextEditingController _locationController;
  late final TextEditingController _notesController;
  
  late String _selectedCurrency;
  late PaymentMethod _selectedPaymentMethod;
  late DateTime _selectedDateTime;
  late String _selectedEmoji;
  bool _isEditMode = false;
  
  @override
  void initState() {
    super.initState();
    _isEditMode = widget.expense != null;
    
    if (_isEditMode) {
      final expense = widget.expense!;
      _titleController = TextEditingController(text: expense.title);
      _amountController = TextEditingController(text: expense.amount.toString());
      _locationController = TextEditingController(text: expense.location ?? '');
      _notesController = TextEditingController(text: expense.notes ?? '');
      _selectedCurrency = expense.currency;
      _selectedPaymentMethod = expense.paymentMethod;
      _selectedDateTime = expense.timestamp;
      _selectedEmoji = expense.emoji;
    } else {
      _titleController = TextEditingController();
      _amountController = TextEditingController();
      _locationController = TextEditingController();
      _notesController = TextEditingController();
      _selectedCurrency = Currencies.defaultCurrency;
      _selectedPaymentMethod = PaymentMethod.cash;
      _selectedDateTime = DateTime.now();
      _selectedEmoji = EmojiMappings.defaultEmoji;
    }
    
    // Listen to title changes to auto-update emoji
    _titleController.addListener(_updateEmojiFromTitle);
  }
  
  void _updateEmojiFromTitle() {
    if (!_isEditMode || _titleController.text != widget.expense?.title) {
      setState(() {
        _selectedEmoji = EmojiMappings.getEmoji(_titleController.text);
      });
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    super.dispose();
  }
  
  Future<void> _saveExpense() async {
    if (_formKey.currentState!.validate()) {
      if (_isEditMode) {
        final updatedExpense = widget.expense!.copyWith(
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          currency: _selectedCurrency,
          paymentMethod: _selectedPaymentMethod,
          location: _locationController.text.trim().isEmpty 
              ? null 
              : _locationController.text.trim(),
          timestamp: _selectedDateTime,
          emoji: _selectedEmoji,
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
        );
        
        await ref.read(expenseProvider.notifier).updateExpense(updatedExpense);
      } else {
        await ref.read(expenseProvider.notifier).addExpense(
          title: _titleController.text.trim(),
          amount: double.parse(_amountController.text.trim()),
          currency: _selectedCurrency,
          paymentMethod: _selectedPaymentMethod,
          location: _locationController.text.trim().isEmpty 
              ? null 
              : _locationController.text.trim(),
          timestamp: _selectedDateTime,
          emoji: _selectedEmoji,
          notes: _notesController.text.trim().isEmpty 
              ? null 
              : _notesController.text.trim(),
        );
      }
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Expense' : 'Add Expense'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Emoji preview
            Center(
              child: GestureDetector(
                onTap: _showEmojiPicker,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: Center(
                    child: Text(
                      _selectedEmoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: _showEmojiPicker,
                child: const Text('Change Emoji'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title field
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title *',
                hintText: 'e.g., Lunch, Uber, Shopping',
                prefixIcon: Icon(Icons.title),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            
            const SizedBox(height: 16),
            
            // Amount and Currency
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _amountController,
                    decoration: const InputDecoration(
                      labelText: 'Amount *',
                      hintText: '0.00',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Enter amount';
                      }
                      final amount = double.tryParse(value.trim());
                      if (amount == null || amount <= 0) {
                        return 'Invalid amount';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedCurrency,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                    ),
                    items: Currencies.getAllCodes().map((code) {
                      return DropdownMenuItem(
                        value: code,
                        child: Text(code),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCurrency = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Payment method
            const Text(
              'Payment Method *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            SegmentedButton<PaymentMethod>(
              segments: PaymentMethod.values.map((method) {
                return ButtonSegment(
                  value: method,
                  label: Text(method.displayName),
                  icon: Text(method.icon),
                );
              }).toList(),
              selected: {_selectedPaymentMethod},
              onSelectionChanged: (set) {
                setState(() {
                  _selectedPaymentMethod = set.first;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Date and Time
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.calendar_today),
              title: const Text('Date & Time'),
              subtitle: Text(
                DateFormat('MMM dd, yyyy - hh:mm a').format(_selectedDateTime),
              ),
              trailing: const Icon(Icons.edit),
              onTap: _selectDateTime,
            ),
            
            const SizedBox(height: 16),
            
            // Location field
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: 'Location (Optional)',
                hintText: 'e.g., Starbucks, Mall',
                prefixIcon: Icon(Icons.location_on),
              ),
              textInputAction: TextInputAction.next,
            ),
            
            const SizedBox(height: 16),
            
            // Notes field
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                hintText: 'Add any additional details',
                prefixIcon: Icon(Icons.note),
              ),
              maxLines: 3,
              textInputAction: TextInputAction.done,
            ),
            
            const SizedBox(height: 32),
            
            // Save button
            ElevatedButton(
              onPressed: _saveExpense,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _isEditMode ? 'Update Expense' : 'Save Expense',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    
    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      );
      
      if (time != null) {
        setState(() {
          _selectedDateTime = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }
  
  void _showEmojiPicker() {
    final emojis = EmojiMappings.getAllEmojis();
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Emoji',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 6,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: emojis.length,
                itemBuilder: (context, index) {
                  final emoji = emojis[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedEmoji = emoji;
                      });
                      Navigator.pop(context);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: _selectedEmoji == emoji 
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
