import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:week7_institute_project_1/crud_operations.dart';
import 'package:week7_institute_project_1/models/category.dart';
import 'package:week7_institute_project_1/models/employee.dart';
import 'package:week7_institute_project_1/models/student.dart';
import '../models/account_transaction.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
      ),
      body: Column(
        children: [
          _buildSummary(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        tooltip: 'Add Transaction',
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
        double totalExpense = box.values
            .where((transaction) => transaction.category == 'Expense')
            .fold(0, (sum, transaction) => sum + transaction.amount);
        double balance = totalIncome - totalExpense;

        return Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[200],
          child: Column(
            children: [
              Text(
                'Balance: \$${balance.toStringAsFixed(2)}',
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Income: \$${totalIncome.toStringAsFixed(2)}'),
                  Text('Expense: \$${totalExpense.toStringAsFixed(2)}'),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTransactionList() {
    return ValueListenableBuilder(
      valueListenable:
          Hive.box<AccountTransaction>('transactions').listenable(),
      builder: (context, Box<AccountTransaction> box, _) {
        if (box.values.isEmpty) {
          return const Center(child: Text('No transactions yet'));
        }

        return ListView.builder(
          itemCount: box.values.length,
          itemBuilder: (context, index) {
            final transaction = box.getAt(index)!;
            return ListTile(
              leading: Icon(
                transaction.category == 'Income'
                    ? Icons.arrow_upward
                    : Icons.arrow_downward,
                color: transaction.category == 'Income'
                    ? Colors.green
                    : Colors.red,
              ),
              title: Text(
                  '${transaction.mainCategory} - ${transaction.subCategory}'),
              subtitle: Text(
                  'Amount: \$${transaction.amount.toStringAsFixed(2)}\nDate: ${transaction.entryDate.toString().split(' ')[0]}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteTransaction(context, transaction),
              ),
              onTap: () => _showTransactionDetails(context, transaction),
            );
          },
        );
      },
    );
  }

  void _showAddTransactionDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String category = 'Income';
    String mainCategory = '';
    String subCategory = '';
    double amount = 0;
    String entryNumber = '';
    DateTime entryDate = DateTime.now();
    String? studentId;
    String? employeeId;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Transaction'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      DropdownButtonFormField<String>(
                        value: category,
                        items: ['Income', 'Expense'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            category = newValue!;
                            mainCategory = '';
                          });
                        },
                        decoration:
                            const InputDecoration(labelText: 'Category'),
                      ),
                      ValueListenableBuilder(
                        valueListenable:
                            Hive.box<Student>('students').listenable(),
                        builder: (context, Box<Student> studentBox, _) {
                          List<Student> students = studentBox.values.toList();
                          return DropdownButtonFormField<String>(
                            value: studentId,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('No Student'),
                              ),
                              ...students.map((Student student) {
                                return DropdownMenuItem<String>(
                                  value: student.admNumber,
                                  child: Text(student.name),
                                );
                              }),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                studentId = newValue;
                              });
                            },
                            decoration:
                                const InputDecoration(labelText: 'Student'),
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable:
                            Hive.box<Employee>('employees').listenable(),
                        builder: (context, Box<Employee> employeeBox, _) {
                          List<Employee> employees =
                              employeeBox.values.toList();
                          return DropdownButtonFormField<String>(
                            value: employeeId,
                            items: [
                              const DropdownMenuItem<String>(
                                value: null,
                                child: Text('No Employee'),
                              ),
                              ...employees.map((Employee employee) {
                                return DropdownMenuItem<String>(
                                  value: employee.key.toString(),
                                  child: Text(employee.name),
                                );
                              }),
                            ],
                            onChanged: (String? newValue) {
                              setState(() {
                                employeeId = newValue;
                              });
                            },
                            decoration:
                                const InputDecoration(labelText: 'Employee'),
                          );
                        },
                      ),
                      ValueListenableBuilder(
                        valueListenable:
                            Hive.box<Category>('categories').listenable(),
                        builder: (context, Box<Category> box, _) {
                          var categories = box.values
                              .where((cat) => cat.type == category)
                              .toList();
                          return DropdownButtonFormField<String>(
                            value: mainCategory.isNotEmpty
                                ? mainCategory
                                : (categories.isNotEmpty
                                    ? categories.first.description
                                    : null),
                            items: categories.map((Category cat) {
                              return DropdownMenuItem<String>(
                                value: cat.description,
                                child: Text(cat.description),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                mainCategory = newValue!;
                              });
                            },
                            decoration: const InputDecoration(
                                labelText: 'Main Category'),
                          );
                        },
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Sub Category'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        onSaved: (value) => subCategory = value!,
                      ),
                      TextFormField(
                        decoration: const InputDecoration(labelText: 'Amount'),
                        keyboardType: TextInputType.number,
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        onSaved: (value) => amount = double.parse(value!),
                      ),
                      TextFormField(
                        decoration:
                            const InputDecoration(labelText: 'Entry Number'),
                        validator: (value) =>
                            value!.isEmpty ? 'Required' : null,
                        onSaved: (value) => entryNumber = value!,
                      ),
                      InkWell(
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: entryDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null && picked != entryDate) {
                            setState(() {
                              entryDate = picked;
                            });
                          }
                        },
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Entry Date',
                          ),
                          child: Text(
                            '${entryDate.toLocal()}'.split(' ')[0],
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
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
                      _addTransaction(
                          category,
                          mainCategory,
                          subCategory,
                          amount,
                          entryNumber,
                          entryDate,
                          studentId,
                          employeeId);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addTransaction(
      String category,
      String mainCategory,
      String subCategory,
      double amount,
      String entryNumber,
      DateTime entryDate,
      String? studentId,
      String? employeeId) {
    final transactionBox = Hive.box<AccountTransaction>('transactions');
    final newTransaction = AccountTransaction()
      ..journalNumber = 'J${transactionBox.length + 1}'
      ..entryNumber = entryNumber
      ..entryDate = entryDate
      ..category = category
      ..mainCategory = mainCategory
      ..subCategory = subCategory
      ..amount = amount
      ..studentId = studentId
      ..employeeId = employeeId;

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
              const Text('Are you sure you want to delete this transaction?'),
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

  void _showTransactionDetails(
      BuildContext context, AccountTransaction transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Transaction Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Journal Number: ${transaction.journalNumber}'),
                Text('Entry Number: ${transaction.entryNumber}'),
                Text('Date: ${transaction.entryDate.toString().split(' ')[0]}'),
                Text('Category: ${transaction.category}'),
                Text('Main Category: ${transaction.mainCategory}'),
                Text('Sub Category: ${transaction.subCategory}'),
                Text('Amount: \$${transaction.amount.toStringAsFixed(2)}'),
                if (transaction.studentId != null)
                  Text('Student ID: ${transaction.studentId}'),
                if (transaction.employeeId != null)
                  Text('Employee ID: ${transaction.employeeId}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
