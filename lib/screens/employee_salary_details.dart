import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:week7_institute_project_1/models/account_transaction.dart';
import 'package:week7_institute_project_1/models/employee.dart';

//this is a new screen in this week
class EmployeeSalaryDetails extends StatelessWidget {
  final Employee employee;

  const EmployeeSalaryDetails({super.key, required this.employee});

  @override
  Widget build(BuildContext context) {
    final transactionsBox = Hive.box<AccountTransaction>('transactions');
    final employeeTransactions = transactionsBox.values
        .where((transaction) =>
            transaction.employeeId == employee.empNumber &&
            transaction.mainCategory == 'Salary')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${employee.name} - Salary Transactions'),
      ),
      body: ListView.builder(
        itemCount: employeeTransactions.length,
        itemBuilder: (context, index) {
          final transaction = employeeTransactions[index];
          return Card(
            margin: const EdgeInsets.all(8.0),
            child: ListTile(
              title: Text(transaction.mainCategory),
              subtitle: Text(
                'Date: ${transaction.entryDate.toLocal().toString().split(' ')[0]}',
              ),
              trailing: Text(
                '₹ ${transaction.amount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
