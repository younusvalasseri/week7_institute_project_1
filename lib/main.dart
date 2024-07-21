import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:week7_institute_project_1/models/courses.dart';
import 'package:week7_institute_project_1/models/student.dart';
import 'package:week7_institute_project_1/models/employee.dart';
import 'package:week7_institute_project_1/models/account_transaction.dart';
import 'package:week7_institute_project_1/models/category.dart';
import 'package:week7_institute_project_1/login_page.dart';
import 'package:week7_institute_project_1/registration_page.dart';
import 'package:week7_institute_project_1/password_reset_page.dart';
import 'package:week7_institute_project_1/home_screen.dart';
import 'package:week7_institute_project_1/reports/reports_screen.dart';
import 'package:week7_institute_project_1/settings_screen.dart';
import 'package:week7_institute_project_1/splash_screen.dart';
import 'generated/l10n.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // Register all adapters
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(AccountTransactionAdapter());
  Hive.registerAdapter(CoursesAdapter());
  Hive.registerAdapter(EmployeeAdapter());
  Hive.registerAdapter(StudentAdapter());

  // Open the boxes
  await Hive.openBox<Category>('categories');
  await Hive.openBox<AccountTransaction>('transactions');
  await Hive.openBox<Courses>('courses');
  await Hive.openBox<Employee>('employees');
  await Hive.openBox<Student>('students');

  // Ensure the admin user exists
  var employeesBox = Hive.box<Employee>('employees');
  if (employeesBox.values
      .where((e) => e.username == 'admin' && e.password == 'admin')
      .isEmpty) {
    employeesBox.add(Employee()
      ..empNumber = '1'
      ..name = 'Administrator'
      ..position = 'Admin'
      ..phone = '1234567890'
      ..address = 'Admin Address'
      ..password = 'admin'
      ..role = 'Admin'
      ..isActive = true
      ..username = 'admin'
      ..profilePicture = 'assets/iat_logo.jpg');
  }

  // Update existing users with default username
  await updateExistingUsersWithDefaultUsername();
  runApp(const MyApp());
}

Future<void> updateExistingUsersWithDefaultUsername() async {
  final employeesBox = await Hive.openBox<Employee>('employees');

  for (var employee in employeesBox.values) {
    if (employee.username == null || employee.username!.isEmpty) {
      employee.username =
          'default_${employee.empNumber}'; // Example: default_001
      await employee.save();
    }
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  Locale _locale = const Locale('en');

  void _toggleTheme(bool isDark) {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Institute Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      themeMode: _themeMode,
      locale: _locale,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) {
          final employee =
              ModalRoute.of(context)?.settings.arguments as Employee?;
          if (employee == null) {
            // Handle the case where the employee is not passed correctly
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.pushReplacementNamed(context, '/login');
            });
            return const SizedBox.shrink();
          }
          return MainScreen(
            onThemeChanged: _toggleTheme,
            onLanguageChanged: _changeLanguage,
            currentUser: employee,
          );
        },
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegistrationPage(),
        '/reset-password': (context) => const PasswordResetPage(),
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  final ValueChanged<bool> onThemeChanged;
  final ValueChanged<String> onLanguageChanged;
  final Employee currentUser;

  const MainScreen({
    super.key,
    required this.onThemeChanged,
    required this.onLanguageChanged,
    required this.currentUser,
  });

  @override
  // ignore: library_private_types_in_public_api
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      HomeScreen(currentUser: widget.currentUser),
      const ReportsScreen(),
      SettingsScreen(
        onThemeChanged: widget.onThemeChanged,
        onLanguageChanged: widget.onLanguageChanged,
      ),
    ];

    void onItemTapped(int index) {
      setState(() {
        _selectedIndex = index;
      });
    }

    void logout() {
      Navigator.pushReplacementNamed(context, '/login');
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        title: Text(S.of(context).appTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.amber,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey[700],
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: S.of(context).home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.bar_chart),
            label: S.of(context).reports,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
            label: S.of(context).settings,
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: onItemTapped,
      ),
    );
  }
}

class StudentCollectionPendingReportScreen extends StatelessWidget {
  const StudentCollectionPendingReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).reports),
      ),
      body: Center(
        child: Text(S.of(context).reports),
      ),
    );
  }
}
