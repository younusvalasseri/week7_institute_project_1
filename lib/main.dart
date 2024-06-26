import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:week7_institute_project_1/models/account_transaction.dart';
import 'package:week7_institute_project_1/models/category.dart';
import 'package:week7_institute_project_1/models/employee.dart';
import 'package:week7_institute_project_1/models/filter.dart';
import 'package:week7_institute_project_1/models/student.dart';
import 'screens/home_screen.dart';
import 'screens/income_screen.dart';
import 'screens/expenses_screen.dart';
import 'screens/employees_screen.dart';
import 'screens/students_screen.dart';
import 'screens/transactions_screen.dart';
import 'screens/categories_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(StudentAdapter());
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(AccountTransactionAdapter());
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(FilterAdapter());
  await Hive.openBox<Student>('students');
  await Hive.openBox<Employee>('employees');
  await Hive.openBox<AccountTransaction>('transactions');
  await Hive.openBox<Category>('categories');
  await Hive.openBox<Filter>('filters');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    const HomeScreen(),
    const IncomeScreen(),
    const ExpensesScreen(),
    const EmployeesScreen(),
    const StudentsScreen(),
    const TransactionsScreen(),
    const CategoriesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Money Management'),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.arrow_back), label: 'Back'),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.menu), label: 'Menu'),
        ],
      ),
    );
  }
}
