import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:week7_institute_project_1/models/category.dart';
import '../models/account_transaction.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
      ),
      body: Column(
        children: [
          _buildSummary(),
          Expanded(child: _buildExpensesList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddExpenseDialog(context),
        tooltip: 'Add Expense',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummary() {
    return ValueListenableBuilder(
      valueListenable:
          Hive.box<AccountTransaction>('transactions').listenable(),
      builder: (context, Box<AccountTransaction> box, _) {
        double totalExpenses = box.values
            .where((transaction) => transaction.category == 'Expense')
            .fold(0, (sum, transaction) => sum + transaction.amount);

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
                '\$${totalExpenses.toStringAsFixed(2)}',
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
        var expenseTransactions = box.values
            .where((transaction) => transaction.category == 'Expense')
            .toList();

        if (expenseTransactions.isEmpty) {
          return const Center(child: Text('No expense transactions yet'));
        }

        return ListView.builder(
          itemCount: expenseTransactions.length,
          itemBuilder: (context, index) {
            var transaction = expenseTransactions[index];
            return ListTile(
              title: Text(
                  '${transaction.mainCategory} - ${transaction.subCategory}'),
              subtitle: Text(
                  'Amount: \$${transaction.amount.toStringAsFixed(2)}\nDate: ${transaction.entryDate.toString().split(' ')[0]}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteTransaction(context, transaction),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddExpenseDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String mainCategory = '';
    String subCategory = '';
    double amount = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Expense'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ValueListenableBuilder(
                    valueListenable:
                        Hive.box<Category>('categories').listenable(),
                    builder: (context, Box<Category> box, _) {
                      var expenseCategories = box.values
                          .where((category) => category.type == 'Expense')
                          .toList();
                      return DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Main Category'),
                        items: expenseCategories.map((Category category) {
                          return DropdownMenuItem<String>(
                            value: category.description,
                            child: Text(category.description),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          mainCategory = newValue!;
                        },
                        validator: (value) => value == null ? 'Required' : null,
                      );
                    },
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Sub Category'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => subCategory = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Amount'),
                    keyboardType: TextInputType.number,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => amount = double.tryParse(value!) ?? 0,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Add'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  if (mainCategory.isNotEmpty && amount > 0) {
                    _addExpenseTransaction(mainCategory, subCategory, amount);
                    Navigator.of(context).pop();
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addExpenseTransaction(
      String mainCategory, String subCategory, double amount) {
    final transactionBox = Hive.box<AccountTransaction>('transactions');
    final newTransaction = AccountTransaction()
      ..journalNumber = 'J${transactionBox.length + 1}'
      ..entryNumber = 'E${transactionBox.length + 1}'
      ..entryDate = DateTime.now()
      ..category = 'Expense'
      ..mainCategory = mainCategory
      ..subCategory = subCategory
      ..amount = amount;

    transactionBox.add(newTransaction);
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
