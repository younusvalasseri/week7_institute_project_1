import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:week7_institute_project_1/crud_operations.dart';
import '../models/student.dart';

class StudentsScreen extends StatelessWidget {
  const StudentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      body: _buildStudentList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddStudentDialog(context),
        tooltip: 'Add Student',
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildStudentList() {
    return ValueListenableBuilder(
      valueListenable: Hive.box<Student>('students').listenable(),
      builder: (context, Box<Student> box, _) {
        if (box.values.isEmpty) {
          return const Center(child: Text('No students yet'));
        }

        return ListView.builder(
          itemCount: box.values.length,
          itemBuilder: (context, index) {
            final student = box.getAt(index)!;
            return ListTile(
              title: Text(student.name),
              subtitle:
                  Text('Adm: ${student.admNumber} | Course: ${student.course}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => _showEditStudentDialog(context, student),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteStudent(context, student),
                  ),
                ],
              ),
              onTap: () => _showStudentDetails(context, student),
            );
          },
        );
      },
    );
  }

  void _showAddStudentDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    String admNumber = '', name = '', course = '', batch = '';
    String fatherPhone = '', motherPhone = '', studentPhone = '', address = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add Student'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Admission Number'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => admNumber = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => name = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Course'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => course = value!,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(labelText: 'Batch'),
                    onSaved: (value) => batch = value!,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Father\'s Phone'),
                    onSaved: (value) => fatherPhone = value!,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Mother\'s Phone'),
                    onSaved: (value) => motherPhone = value!,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Student\'s Phone'),
                    onSaved: (value) => studentPhone = value!,
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
                  _addStudent(admNumber, name, course, batch, fatherPhone,
                      motherPhone, studentPhone, address);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _addStudent(
      String admNumber,
      String name,
      String course,
      String batch,
      String fatherPhone,
      String motherPhone,
      String studentPhone,
      String address) {
    final newStudent = Student()
      ..admNumber = admNumber
      ..name = name
      ..course = course
      ..batch = batch
      ..fatherPhone = fatherPhone
      ..motherPhone = motherPhone
      ..studentPhone = studentPhone
      ..address = address;

    CRUDOperations.createStudent(newStudent);
  }

  void _showEditStudentDialog(BuildContext context, Student student) {
    final formKey = GlobalKey<FormState>();
    String admNumber = student.admNumber,
        name = student.name,
        course = student.course,
        batch = student.batch;
    String fatherPhone = student.fatherPhone,
        motherPhone = student.motherPhone,
        studentPhone = student.studentPhone,
        address = student.address;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Student'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    initialValue: student.admNumber,
                    decoration:
                        const InputDecoration(labelText: 'Admission Number'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => admNumber = value!,
                  ),
                  TextFormField(
                    initialValue: student.name,
                    decoration: const InputDecoration(labelText: 'Name'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => name = value!,
                  ),
                  TextFormField(
                    initialValue: student.course,
                    decoration: const InputDecoration(labelText: 'Course'),
                    validator: (value) => value!.isEmpty ? 'Required' : null,
                    onSaved: (value) => course = value!,
                  ),
                  TextFormField(
                    initialValue: student.batch,
                    decoration: const InputDecoration(labelText: 'Batch'),
                    onSaved: (value) => batch = value!,
                  ),
                  TextFormField(
                    initialValue: student.fatherPhone,
                    decoration:
                        const InputDecoration(labelText: 'Father\'s Phone'),
                    onSaved: (value) => fatherPhone = value!,
                  ),
                  TextFormField(
                    initialValue: student.motherPhone,
                    decoration:
                        const InputDecoration(labelText: 'Mother\'s Phone'),
                    onSaved: (value) => motherPhone = value!,
                  ),
                  TextFormField(
                    initialValue: student.studentPhone,
                    decoration:
                        const InputDecoration(labelText: 'Student\'s Phone'),
                    onSaved: (value) => studentPhone = value!,
                  ),
                  TextFormField(
                    initialValue: student.address,
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
                  student.admNumber = admNumber;
                  student.name = name;
                  student.course = course;
                  student.batch = batch;
                  student.fatherPhone = fatherPhone;
                  student.motherPhone = motherPhone;
                  student.studentPhone = studentPhone;
                  student.address = address;
                  student.save();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteStudent(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this student?'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                CRUDOperations.deleteStudent(student);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showStudentDetails(BuildContext context, Student student) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(student.name),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Admission Number: ${student.admNumber}'),
                Text('Course: ${student.course}'),
                Text('Batch: ${student.batch}'),
                Text('Father\'s Phone: ${student.fatherPhone}'),
                Text('Mother\'s Phone: ${student.motherPhone}'),
                Text('Student\'s Phone: ${student.studentPhone}'),
                Text('Address: ${student.address}'),
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
