import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:week7_institute_project_1/models/account_transaction.dart';
import 'package:week7_institute_project_1/models/student.dart';

class StudentDetailsIncomeScreen extends StatelessWidget {
  final Student student;

  const StudentDetailsIncomeScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final transactionsBox = Hive.box<AccountTransaction>('transactions');
    final studentTransactions = transactionsBox.values
        .where((transaction) => transaction.studentId == student.admNumber)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('${student.name} - Transactions'),
      ),
      body: ListView.builder(
        itemCount: studentTransactions.length,
        itemBuilder: (context, index) {
          final transaction = studentTransactions[index];
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
