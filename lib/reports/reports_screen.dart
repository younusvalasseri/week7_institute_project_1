import 'package:flutter/material.dart';
import 'students_collection_vs_pending_report.dart'; // Placeholder page
import 'income_vs_expense_report.dart'; // Placeholder page
import 'student_fee_collection_report.dart'; // New page

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: Column(
        children: [
          _buildCard(
            context,
            'Fee Collection Chart',
            Icons.bar_chart,
            const StudentsCollectionVsPendingReport(),
          ),
          _buildCard(
            context,
            'Income vs Expense Report',
            Icons.pie_chart,
            const IncomeVsExpenseReport(),
          ),
          _buildCard(
            context,
            'Fee Collection Report',
            Icons.school,
            const StudentFeeCollectionReport(),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, Widget screen) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: ListTile(
        leading: Icon(icon, size: 48),
        title: Text(title, style: const TextStyle(fontSize: 20)),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
      ),
    );
  }
}
