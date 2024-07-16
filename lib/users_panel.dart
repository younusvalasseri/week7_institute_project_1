import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'models/employee.dart';

class UsersPanel extends StatefulWidget {
  const UsersPanel({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UsersPanelState createState() => _UsersPanelState();
}

class _UsersPanelState extends State<UsersPanel> {
  final _employeesBox = Hive.box<Employee>('employees');

  void _addUser() {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        String name = '';
        String position = '';
        String phone = '';
        String address = '';
        String password = '';
        String role = 'General'; // Default role
        bool isActive = true;

        return AlertDialog(
          title: const Text('Add User'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => name = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Position'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => position = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Phone'),
                    onSaved: (value) => phone = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Address'),
                    onSaved: (value) => address = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => password = value!,
                  ),
                  DropdownButtonFormField<String>(
                    value: role,
                    items: ['Admin', 'User', 'General'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      role = newValue!;
                    },
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                  SwitchListTile(
                    title: const Text('Active'),
                    value: isActive,
                    onChanged: (bool value) {
                      isActive = value;
                    },
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
              child: const Text('Add'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final newEmployee = Employee()
                    ..name = name
                    ..position = position
                    ..phone = phone
                    ..address = address
                    ..password = password
                    ..role = role
                    ..isActive = isActive;

                  _employeesBox.add(newEmployee);
                  Navigator.of(context).pop();
                  setState(() {});
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(int index) {
    _employeesBox.deleteAt(index);
    setState(() {});
  }

  void _resetPassword(int index) {
    showDialog(
      context: context,
      builder: (context) {
        final formKey = GlobalKey<FormState>();
        String newPassword = '';

        return AlertDialog(
          title: const Text('Reset Password'),
          content: Form(
            key: formKey,
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'New Password'),
              validator: (value) => value!.isEmpty ? 'Required' : null,
              onSaved: (value) => newPassword = value!,
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
                  var employee = _employeesBox.getAt(index);
                  if (employee != null) {
                    employee.password = newPassword;
                    _employeesBox.putAt(index, employee);
                    setState(() {});
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _updateUser(int index, Employee updatedEmployee) {
    _employeesBox.putAt(index, updatedEmployee);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Panel'),
      ),
      body: ValueListenableBuilder(
        valueListenable: _employeesBox.listenable(),
        builder: (context, Box<Employee> box, _) {
          if (box.values.isEmpty) {
            return const Center(child: Text('No users yet'));
          }

          return ListView.builder(
            itemCount: box.length,
            itemBuilder: (context, index) {
              final employee = box.getAt(index);
              if (employee == null) {
                return const SizedBox.shrink();
              }
              return ListTile(
                title: Text(employee.name),
                subtitle: Text('Role: ${employee.role}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    DropdownButton<String>(
                      value: employee.role,
                      items: ['Admin', 'User', 'General', 'Add Item']
                          .map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          employee.role =
                              newValue == 'Add Item' ? 'General' : newValue;
                          _updateUser(index, employee);
                        }
                      },
                    ),
                    Switch(
                      value: employee.isActive,
                      onChanged: (bool value) {
                        employee.isActive = value;
                        _updateUser(index, employee);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.lock_reset),
                      onPressed: () => _resetPassword(index),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () => _deleteUser(index),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        tooltip: 'Add User',
        child: const Icon(Icons.add),
      ),
    );
  }
}
