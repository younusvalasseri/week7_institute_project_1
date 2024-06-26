import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/account_transaction.dart';
import '../models/category.dart';

class IncomeScreen extends StatelessWidget {
  const IncomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Income'),
      ),
      body: Column(
        children: [
          _buildSummary(),
          Expanded(child: _buildIncomeList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddIncomeDialog(context),
        tooltip: 'Add Income',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSummary() {
    return ValueListenableBuilder(
      valueListenable:
          Hive.box<AccountTransaction>('transactions').listenable(),
      builder: (context, Box<AccountTransaction> box, _) {
        double totalIncome = box.values
            .where((transaction) => transaction.category == 'Income')
            .fold(0, (sum, transaction) => sum + transaction.amount);

        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.green[100],
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Income:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '\$${totalIncome.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildIncomeList() {
    return ValueListenableBuilder(
      valueListenable:
          Hive.box<AccountTransaction>('transactions').listenable(),
      builder: (context, Box<AccountTransaction> box, _) {
        var incomeTransactions = box.values
            .where((transaction) => transaction.category == 'Income')
            .toList();

        if (incomeTransactions.isEmpty) {
          return const Center(child: Text('No income transactions yet'));
        }

        return ListView.builder(
          itemCount: incomeTransactions.length,
          itemBuilder: (context, index) {
            var transaction = incomeTransactions[index];
            return ListTile(
              title: Text(
                  '${transaction.subCategory} - \$${transaction.amount.toStringAsFixed(2)}'),
              subtitle: Text(
                  'Date: ${transaction.entryDate.toString().split(' ')[0]}'),
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

  void _showAddIncomeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String mainCategory = '';
    String subCategory = '';
    double amount = 0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Income'),
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
                      var incomeCategories = box.values
                          .where((category) => category.type == 'Income')
                          .toList();
                      return DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: 'Main Category'),
                        items: incomeCategories.map((Category category) {
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
                    onSaved: (value) => amount = double.parse(value!),
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
                  _addIncomeTransaction(mainCategory, subCategory, amount);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addIncomeTransaction(
      String mainCategory, String subCategory, double amount) {
    final transactionBox = Hive.box<AccountTransaction>('transactions');
    final newTransaction = AccountTransaction()
      ..journalNumber = 'J${transactionBox.length + 1}'
      ..entryNumber = 'E${transactionBox.length + 1}'
      ..entryDate = DateTime.now()
      ..category = 'Income'
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
