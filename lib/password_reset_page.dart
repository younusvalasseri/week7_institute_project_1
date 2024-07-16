import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/employee.dart';

class PasswordResetPage extends StatelessWidget {
  const PasswordResetPage({super.key});

  void _resetPassword(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        String username = '';
        String newPassword = '';

        return AlertDialog(
          title: const Text('Reset User Password'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Username'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => username = value!,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'New Password'),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => newPassword = value!,
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
              child: const Text('Reset'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  var employeesBox = Hive.box<Employee>('employees');
                  try {
                    var employee = employeesBox.values
                        .firstWhere((e) => e.username == username);
                    employee.password = newPassword;
                    employeesBox.put(employee.key, employee);
                    Navigator.of(context).pop();
                  } catch (e) {
                    // Handle case where employee is not found
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not found')),
                    );
                  }
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset Password'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _resetPassword(context),
          child: const Text('Reset Password'),
        ),
      ),
    );
  }
}
