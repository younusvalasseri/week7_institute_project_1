import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:week7_institute_project_1/custom_date_range_picker.dart';
import 'package:week7_institute_project_1/generated/l10n.dart';
import 'package:week7_institute_project_1/models/employee.dart';
import '../models/account_transaction.dart';
import 'add_transaction.dart';
import '../crud_operations.dart';

class TransactionsScreen extends StatefulWidget {
  final Employee currentUser;
  const TransactionsScreen({super.key, required this.currentUser});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
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
        title: Text(S.of(context).Transaction),
      ),
      body: Column(
        children: [
          _buildSummary(),
          _buildDateFilter(),
          Expanded(child: _buildList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => AddTransactionScreen(
                    currentUser: widget.currentUser,
                  )),
        ),
        tooltip: 'Add Transaction',
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
        var filteredExpenseTransactions = box.values.where((transaction) {
          if (transaction.category != 'Expense') {
            return false;
          }
          if (_selectedDateRange == null) {
            return true;
          }
          return !transaction.entryDate.isBefore(_selectedDateRange!.start) &&
              !transaction.entryDate.isAfter(_selectedDateRange!.end);
        }).toList();
        var filteredIncomeTransactions = box.values.where((transaction) {
          if (transaction.category != 'Incomes') {
            return false;
          }
          if (_selectedDateRange == null) {
            return true;
          }
          return !transaction.entryDate.isBefore(_selectedDateRange!.start) &&
              !transaction.entryDate.isAfter(_selectedDateRange!.end);
        }).toList();
        double totalExpenses = filteredExpenseTransactions.fold(
            0, (sum, transaction) => sum + transaction.amount);
        double totalIncomes = filteredIncomeTransactions.fold(
            0, (sum, transaction) => sum + transaction.amount);

        double balance = totalIncomes - totalExpenses;
        Color balanceColor =
            balance > 0 ? Colors.green[100]! : Colors.red[100]!;

        return Container(
          padding: const EdgeInsets.all(16),
          color: balanceColor,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'The Balance Amount:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹ ${balance.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable:
          Hive.box<AccountTransaction>('transactions').listenable(),
      builder: (context, Box<AccountTransaction> box, _) {
        var filteredTransactions = box.values.where((transaction) {
          if (_selectedDateRange == null) {
            return true;
          }
          return !transaction.entryDate.isBefore(_selectedDateRange!.start) &&
              !transaction.entryDate.isAfter(_selectedDateRange!.end);
        }).toList();

        if (filteredTransactions.isEmpty) {
          return const Center(child: Text('No transactions yet'));
        }

        return ListView.builder(
          itemCount: filteredTransactions.length,
          itemBuilder: (context, index) {
            var transaction = filteredTransactions[index];
            bool isIncome = transaction.category == 'Incomes';
            return ListTile(
              leading: Icon(
                isIncome ? Icons.arrow_upward : Icons.arrow_downward,
                color: isIncome ? Colors.green : Colors.red,
              ),
              title: Text(
                  '${transaction.mainCategory} - ${transaction.subCategory}'),
              subtitle: Text(
                  'Date: ${DateFormat('dd-MMM-yyyy').format(transaction.entryDate)}'),
              trailing: SizedBox(
                width: 100, // Set a fixed width to avoid overflow
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '₹ ${transaction.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AddTransactionScreen(
                                  transaction: transaction,
                                  index: index,
                                  currentUser: widget.currentUser,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                _deleteTransaction(context, transaction),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
          content: const Text('Are you sure you want to delete this entry?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                CRUDOperations.deleteTransaction(transaction);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
