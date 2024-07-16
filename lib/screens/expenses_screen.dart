import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:week7_institute_project_1/custom_date_range_picker.dart';
import 'package:week7_institute_project_1/generated/l10n.dart';
import '../models/account_transaction.dart';
import 'add_expenses_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  DateTimeRange? _selectedDateRange;

  void _pickDateRange(BuildContext context) async {
    DateTimeRange? picked = await showDialog<DateTimeRange>(
      context: context,
      builder: (BuildContext context) {
        return CustomDateRangePicker(initialDateRange: _selectedDateRange);
      },
    );

    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
    }
  }

  void _clearDateRange() {
    setState(() {
      _selectedDateRange = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).Expenses),
      ),
      body: Column(
        children: [
          _buildSummary(),
          _buildDateFilter(),
          Expanded(child: _buildExpensesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddExpensesScreen()),
        ),
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildDateFilter() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => _pickDateRange(context),
            child: const Text('Select Date Range'),
          ),
          if (_selectedDateRange != null)
            Wrap(
              spacing: 8.0,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '${DateFormat('dd/MMM/yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd/MMM/yyyy').format(_selectedDateRange!.end)}',
                  style: const TextStyle(fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearDateRange,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return ValueListenableBuilder(
      valueListenable:
          Hive.box<AccountTransaction>('transactions').listenable(),
      builder: (context, Box<AccountTransaction> box, _) {
        var filteredTransactions = box.values.where((transaction) {
          if (transaction.category != 'Expense') {
            return false;
          }
          if (_selectedDateRange == null) {
            return true;
          }
          return !transaction.entryDate.isBefore(_selectedDateRange!.start) &&
              !transaction.entryDate.isAfter(_selectedDateRange!.end);
        }).toList();
        double totalExpenses = filteredTransactions.fold(
            0, (sum, transaction) => sum + transaction.amount);

        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.red[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Expenses:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹ ${totalExpenses.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExpensesList() {
    return ValueListenableBuilder(
      valueListenable:
          Hive.box<AccountTransaction>('transactions').listenable(),
      builder: (context, Box<AccountTransaction> box, _) {
        var expenseTransactions = box.values.where((transaction) {
          if (transaction.category != 'Expense') {
            return false;
          }
          if (_selectedDateRange == null) {
            return true;
          }
          return !transaction.entryDate.isBefore(_selectedDateRange!.start) &&
              !transaction.entryDate.isAfter(_selectedDateRange!.end);
        }).toList();

        if (expenseTransactions.isEmpty) {
          return const Center(child: Text('No Expense transactions yet'));
        }

        return ListView.builder(
          itemCount: expenseTransactions.length,
          itemBuilder: (context, index) {
            var transaction = expenseTransactions[index];
            return ListTile(
              title: Text(
                  '${transaction.mainCategory} - ${transaction.subCategory}'),
              subtitle: Text(
                  'Date: ${DateFormat('dd-MMM-yyyy').format(transaction.entryDate)}'),
              trailing: Text(
                '₹ ${transaction.amount.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              leading: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteTransaction(context, transaction),
              ),
            );
          },
        );
      },
    );
  }

  void _deleteTransaction(
      BuildContext context, AccountTransaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this expense entry?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                transaction.delete();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
