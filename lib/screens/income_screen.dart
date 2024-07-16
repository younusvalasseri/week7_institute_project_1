import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:week7_institute_project_1/custom_date_range_picker.dart';
import 'package:week7_institute_project_1/generated/l10n.dart';
import 'package:week7_institute_project_1/models/account_transaction.dart';
import 'package:week7_institute_project_1/screens/add_income_screen.dart';

class IncomeScreen extends StatefulWidget {
  const IncomeScreen({super.key});

  @override
  State<IncomeScreen> createState() => _IncomeScreenState();
}

class _IncomeScreenState extends State<IncomeScreen> {
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
        title: Text(S.of(context).Income),
      ),
      body: Column(
        children: [
          _buildSummary(),
          _buildDateFilter(),
          Expanded(child: _buildIncomesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddIncomeScreen(),
          ),
        ),
        tooltip: 'Add Income',
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
                  '${DateFormat('dd-MM-yyyy').format(_selectedDateRange!.start)} - ${DateFormat('dd-MM-yyyy').format(_selectedDateRange!.end)}',
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
          if (transaction.category != 'Incomes') {
            return false;
          }
          if (_selectedDateRange == null) {
            return true;
          }
          return !transaction.entryDate.isBefore(_selectedDateRange!.start) &&
              !transaction.entryDate.isAfter(_selectedDateRange!.end);
        }).toList();

        double totalIncomes = filteredTransactions.fold(
            0, (sum, transaction) => sum + transaction.amount);

        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Incomes:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹ ${totalIncomes.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncomesList() {
    return ValueListenableBuilder(
      valueListenable:
          Hive.box<AccountTransaction>('transactions').listenable(),
      builder: (context, Box<AccountTransaction> box, _) {
        var incomeTransactions = box.values.where((transaction) {
          if (transaction.category != 'Incomes') {
            return false;
          }
          if (_selectedDateRange == null) {
            return true;
          }
          return !transaction.entryDate.isBefore(_selectedDateRange!.start) &&
              !transaction.entryDate.isAfter(_selectedDateRange!.end);
        }).toList();

        if (incomeTransactions.isEmpty) {
          return const Center(child: Text('No income transactions yet'));
        }

        return ListView.builder(
          itemCount: incomeTransactions.length,
          itemBuilder: (context, index) {
            var transaction = incomeTransactions[index];
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
              const Text('Are you sure you want to delete this income entry?'),
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
