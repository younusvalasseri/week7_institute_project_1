import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:week7_institute_project_1/generated/l10n.dart';
import 'package:week7_institute_project_1/screens/add_employee_screen.dart';
import '../models/employee.dart';
import 'employee_details_screen.dart';

class EmployeesScreen extends StatefulWidget {
  final Employee currentUser;

  const EmployeesScreen({super.key, required this.currentUser});

  @override
  State<EmployeesScreen> createState() => _EmployeesScreenState();
}

class _EmployeesScreenState extends State<EmployeesScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).Employees),
        actions: widget.currentUser.username == 'admin'
            ? [
                IconButton(
                  icon: const Icon(Icons.delete_forever),
                  onPressed: _clearHiveData,
                ),
              ]
            : null,
      ),
      body: Column(
        children: [
          _buildSearchBox(),
          Expanded(child: _buildEmployeeList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddEmployeeScreen(),
          ),
        ),
        tooltip: 'Add Employee',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: const InputDecoration(
          labelText: 'Search by name',
          border: OutlineInputBorder(),
        ),
        onChanged: (query) {
          setState(() {
            _searchQuery = query;
          });
        },
      ),
    );
  }

  Widget _buildEmployeeList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Employee>('employees').listenable(),
      builder: (context, Box<Employee> box, _) {
        List<Employee> employees;
        if (widget.currentUser.username == 'admin') {
          employees = box.values.toList();
        } else {
          employees = box.values
              .where((employee) =>
                  employee.isActive && employee.name != 'Administrator')
              .toList();
        }

        if (_searchQuery.isNotEmpty) {
          employees.retainWhere((employee) =>
              employee.name.toLowerCase().contains(_searchQuery.toLowerCase()));
        }

        if (employees.isEmpty) {
          return const Center(child: Text('No employees yet'));
        }

        return ListView.builder(
          itemCount: employees.length,
          itemBuilder: (context, index) {
            final employee = employees[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: employee.profilePicture != null
                    ? FileImage(File(employee.profilePicture!))
                    : null,
                child: employee.profilePicture == null
                    ? Text(employee.name[0])
                    : null,
              ),
              title: Text(employee.name),
              subtitle: employee.isActive
                  ? Text('Position: ${employee.position}')
                  : RichText(
                      text: TextSpan(
                        text: 'Position: ${employee.position} ',
                        style: DefaultTextStyle.of(context).style,
                        children: const <TextSpan>[
                          TextSpan(
                            text: '(Deleted)',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddEmployeeScreen(
                          employee: employee,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _softDeleteEmployee(context, employee),
                  ),
                ],
              ),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EmployeeDetailsScreen(
                    employee: employee,
                    currentUser: widget.currentUser,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _softDeleteEmployee(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this employee?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                setState(() {
                  employee.isActive = false;
                  employee.save();
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _clearHiveData() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Clear All Data'),
          content: const Text('Are you sure you want to clear all Hive data?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Clear Data'),
              onPressed: () async {
                Navigator.of(context).pop(); // Close the dialog first
                await _clearAllHiveData();
                if (mounted) {
                  _showSnackBar('All Hive data cleared');
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _clearAllHiveData() async {
    await Hive.box<Employee>('employees').clear();
  }

  void _showSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }
}
