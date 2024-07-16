import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:week7_institute_project_1/models/employee.dart';
import 'package:week7_institute_project_1/registration_page.dart';
import 'package:week7_institute_project_1/password_reset_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  String _username = '';
  String _password = '';
  final _employeesBox = Hive.box<Employee>('employees');

  void _login() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        final employee = _employeesBox.values.firstWhere(
            (e) => e.username == _username && e.password == _password);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login successful')),
        );
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: employee,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid username or password')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your username' : null,
                onSaved: (value) => _username = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter your password' : null,
                onSaved: (value) => _password = value!,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _login,
                child: const Text('Login'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PasswordResetPage(),
                    ),
                  );
                },
                child: const Text('Forgot Password?'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegistrationPage(),
                    ),
                  );
                },
                child: const Text('Register'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
