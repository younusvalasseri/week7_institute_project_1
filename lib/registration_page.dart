import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:week7_institute_project_1/models/employee.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  String _selectedEmployee = '';
  String _username = '';
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _employeesBox = Hive.box<Employee>('employees');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Select Employee'),
                items: _employeesBox.values
                    .where((employee) => employee.role == 'User')
                    .map((employee) {
                  return DropdownMenuItem<String>(
                    value: employee.username,
                    child: Text(employee.name),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedEmployee = newValue!;
                  });
                },
                validator: (value) =>
                    value == null ? 'Please select an employee' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a username' : null,
                onSaved: (value) => _username = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
                validator: (value) =>
                    value!.isEmpty ? 'Please enter a password' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                decoration:
                    const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please confirm your password';
                  } else if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Save registration details to Hive box or other logic
                    var employee = _employeesBox.values
                        .firstWhere((e) => e.username == _selectedEmployee);
                    employee.username = _username; // Set the username
                    employee.password =
                        _passwordController.text; // Set the password
                    _employeesBox.put(employee.key, employee);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Registration successful')),
                    );

                    Navigator.of(context)
                        .pop(); // Go back to the previous screen
                  }
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
