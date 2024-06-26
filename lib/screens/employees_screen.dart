import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/employee.dart';
import '../crud_operations.dart';

class EmployeesScreen extends StatelessWidget {
  const EmployeesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
      ),
      body: _buildEmployeeList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEmployeeDialog(context),
        tooltip: 'Add Employee',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmployeeList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Employee>('employees').listenable(),
      builder: (context, Box<Employee> box, _) {
        if (box.values.isEmpty) {
          return const Center(child: Text('No employees yet'));
        }

        return ListView.builder(
          itemCount: box.values.length,
          itemBuilder: (context, index) {
            final employee = box.getAt(index)!;
            return ListTile(
              title: Text(employee.name),
              subtitle: Text('Position: ${employee.position}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditEmployeeDialog(context, employee),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteEmployee(context, employee),
                  ),
                ],
              ),
              onTap: () => _showEmployeeDetails(context, employee),
            );
          },
        );
      },
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String name = '', position = '', phone = '', address = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Employee'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
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
                  _addEmployee(name, position, phone, address);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addEmployee(
      String name, String position, String phone, String address) {
    final newEmployee = Employee()
      ..name = name
      ..position = position
      ..phone = phone
      ..address = address;

    CRUDOperations.createEmployee(newEmployee);
  }

  void _showEditEmployeeDialog(BuildContext context, Employee employee) {
    final formKey = GlobalKey<FormState>();
    String name = employee.name,
        position = employee.position,
        phone = employee.phone,
        address = employee.address;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Employee'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: employee.name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => name = value!,
                  ),
                  TextFormField(
                    initialValue: employee.position,
                    decoration: const InputDecoration(labelText: 'Position'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => position = value!,
                  ),
                  TextFormField(
                    initialValue: employee.phone,
                    decoration: const InputDecoration(labelText: 'Phone'),
                    onSaved: (value) => phone = value!,
                  ),
                  TextFormField(
                    initialValue: employee.address,
                    decoration: const InputDecoration(labelText: 'Address'),
                    onSaved: (value) => address = value!,
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
              child: const Text('Save'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  employee.name = name;
                  employee.position = position;
                  employee.phone = phone;
                  employee.address = address;
                  CRUDOperations.updateEmployee(employee);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteEmployee(BuildContext context, Employee employee) {
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
                CRUDOperations.deleteEmployee(employee);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showEmployeeDetails(BuildContext context, Employee employee) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(employee.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Position: ${employee.position}'),
                Text('Phone: ${employee.phone}'),
                Text('Address: ${employee.address}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('Close'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }
}
