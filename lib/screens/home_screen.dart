import 'package:flutter/material.dart';
import 'package:week7_institute_project_1/screens/categories_screen.dart';
import 'package:week7_institute_project_1/screens/employees_screen.dart';
import 'package:week7_institute_project_1/screens/expenses_screen.dart';
import 'package:week7_institute_project_1/screens/income_screen.dart';
import 'package:week7_institute_project_1/screens/students_screen.dart';
import 'package:week7_institute_project_1/screens/transactions_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          _buildHeader(),
          _buildGridView(context), // Pass context here
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundImage: AssetImage('assets/Younus_1.jpg'),
          ),
          const Column(
            children: [
              Text(
                'User Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text('Total Balance: \$10,000'),
            ],
          ),
          Image.asset('assets/iat_logo.jpg', width: 60, height: 60),
        ],
      ),
    );
  }

  Widget _buildGridView(BuildContext context) {
    // Accept context as a parameter
    return Expanded(
      child: SingleChildScrollView(
        // crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(
                context, 'Income', Icons.arrow_upward, const IncomeScreen(),
                color: Colors.green),
            _buildCard(context, 'Expenses', Icons.arrow_downward,
                const ExpensesScreen(),
                color: Colors.red),
            _buildCard(
                context, 'Employees', Icons.people, const EmployeesScreen(),
                color: Colors.amber),
            _buildCard(
                context, 'Students', Icons.school, const StudentsScreen(),
                color: Colors.blue),
            _buildCard(context, 'Transactions', Icons.receipt_long,
                const TransactionsScreen()),
            _buildCard(context, 'Categories', Icons.category,
                const CategoriesScreen()),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
      BuildContext context, String title, IconData icon, Widget screen,
      {Color color = Colors.black, Color backgroundColor = Colors.white}) {
    return Card(
      margin: const EdgeInsets.all(4.0),
      color: backgroundColor, // Set the background color
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => screen));
        },
        child: ListTile(
          leading: Icon(icon, size: 48, color: color),
          subtitle: Text(title, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );
  }
}
