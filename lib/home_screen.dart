import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:week7_institute_project_1/generated/l10n.dart';
import 'package:week7_institute_project_1/screens/admin_screen.dart';
import 'package:week7_institute_project_1/screens/employees_screen.dart';
import 'package:week7_institute_project_1/screens/expenses_screen.dart';
import 'package:week7_institute_project_1/screens/income_screen.dart';
import 'package:week7_institute_project_1/screens/students_screen.dart';
import 'package:week7_institute_project_1/screens/transactions_screen.dart';
import 'models/account_transaction.dart';
import 'models/employee.dart';

class HomeScreen extends StatefulWidget {
  final Employee currentUser;
  const HomeScreen({super.key, required this.currentUser});

  @override
  // ignore: library_private_types_in_public_api
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20)),
                ),
                height: 150,
              ),
              Positioned(
                child: _buildHeader(),
              )
            ],
          ),
          _buildListView(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: SizedBox(
        height: 200,
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          color: const Color.fromARGB(255, 214, 188, 111),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Institute of Automobile Technology',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: widget.currentUser.profilePicture != null
                          ? FileImage(File(widget.currentUser.profilePicture!))
                          : const AssetImage('assets/iat_logo.jpg'),
                    ),
                    const CircleAvatar(
                      radius: 30,
                      backgroundImage: AssetImage('assets/iat_logo.jpg'),
                    ),
                  ],
                ),
                ValueListenableBuilder(
                  valueListenable:
                      Hive.box<AccountTransaction>('transactions').listenable(),
                  builder: (context, Box<AccountTransaction> box, _) {
                    double totalIncome = box.values
                        .where(
                            (transaction) => transaction.category == 'Incomes')
                        .fold(
                            0, (sum, transaction) => sum + transaction.amount);
                    double totalExpense = box.values
                        .where(
                            (transaction) => transaction.category == 'Expense')
                        .fold(
                            0, (sum, transaction) => sum + transaction.amount);
                    double balance = totalIncome - totalExpense;

                    return Expanded(
                      child: Column(
                        children: [
                          Text(
                            'User: ${widget.currentUser.name}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                              'Total Balance: ₹ ${balance.toStringAsFixed(2)}'),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildCard(context, S.of(context).Income, Icons.arrow_upward,
                IncomeScreen(currentUser: widget.currentUser),
                color: Colors.green),
            const SizedBox(height: 15),
            _buildCard(context, S.of(context).Expenses, Icons.arrow_downward,
                ExpensesScreen(currentUser: widget.currentUser),
                color: Colors.red),
            const SizedBox(height: 15),
            _buildCard(
                context,
                S.of(context).Employees,
                Icons.people,
                EmployeesScreen(
                    currentUser: widget.currentUser), // Pass the currentUser
                color: Colors.amber),
            const SizedBox(height: 15),
            _buildCard(context, S.of(context).Students, Icons.school,
                const StudentsScreen(),
                color: Colors.blue),
            const SizedBox(height: 15),
            _buildCard(context, S.of(context).Transaction, Icons.receipt_long,
                const TransactionsScreen(),
                color: Colors.amber),
            const SizedBox(height: 15),
            if (widget.currentUser.username == 'admin') // Show only for admin
              _buildCard(
                  context,
                  S.of(context).adminPanel,
                  Icons.admin_panel_settings,
                  AdminScreen(currentUser: widget.currentUser),
                  color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(
    BuildContext context,
    String title,
    IconData icon,
    Widget screen, {
    Color color = Colors.black,
  }) {
    return Card(
      margin: const EdgeInsets.all(2.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => screen));
        },
        child: ListTile(
          leading: Icon(
            icon,
            size: 30,
            color: color,
          ),
          title: Text(
            title,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
