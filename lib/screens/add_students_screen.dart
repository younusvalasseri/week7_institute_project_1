import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/student.dart';
import '../models/courses.dart';

class AddStudentScreen extends StatefulWidget {
  final Student? student;
  final int? index;

  const AddStudentScreen({super.key, this.student, this.index});

  @override
  // ignore: library_private_types_in_public_api
  _AddStudentScreenState createState() => _AddStudentScreenState();
}

class _AddStudentScreenState extends State<AddStudentScreen> {
  final _formKey = GlobalKey<FormState>();
  late String admNumber;
  late String name;
  late String course;
  late String batch;
  late String fatherPhone;
  late String motherPhone;
  late String studentPhone;
  late String address;
  late double courseFee;
  final _coursesBox = Hive.box<Courses>('courses');

  @override
  void initState() {
    super.initState();
    final student = widget.student;
    admNumber = student?.admNumber ?? '';
    name = student?.name ?? '';
    course = student?.course ?? '';
    batch = student?.batch ?? '';
    fatherPhone = student?.fatherPhone ?? '';
    motherPhone = student?.motherPhone ?? '';
    studentPhone = student?.studentPhone ?? '';
    address = student?.address ?? '';
    courseFee = student?.courseFee ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Add Student' : 'Edit Student'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  initialValue: admNumber,
                  decoration:
                      const InputDecoration(labelText: 'Admission Number'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => admNumber = value!,
                ),
                TextFormField(
                  initialValue: name,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => name = value!,
                ),
                ValueListenableBuilder(
                  valueListenable: _coursesBox.listenable(),
                  builder: (context, Box<Courses> box, _) {
                    if (box.values.isEmpty) {
                      return const Text('No courses available');
                    }
                    return DropdownButtonFormField<String>(
                      value: course.isEmpty ? null : course,
                      decoration: const InputDecoration(labelText: 'Course'),
                      items: box.values.map((Courses course) {
                        return DropdownMenuItem<String>(
                          value: course.courseName!,
                          child: Text(course.courseName ?? 'No name'),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        course = newValue!;
                      },
                      validator: (value) => value == null ? 'Required' : null,
                      onSaved: (value) => course = value!,
                    );
                  },
                ),
                TextFormField(
                  initialValue: batch,
                  decoration: const InputDecoration(labelText: 'Batch'),
                  onSaved: (value) => batch = value!,
                ),
                TextFormField(
                  initialValue: fatherPhone,
                  decoration:
                      const InputDecoration(labelText: 'Father\'s Phone'),
                  validator: (value) =>
                      value!.isEmpty ? null : _validatePhone(value),
                  onSaved: (value) => fatherPhone = value!,
                ),
                TextFormField(
                  initialValue: motherPhone,
                  decoration:
                      const InputDecoration(labelText: 'Mother\'s Phone'),
                  validator: (value) =>
                      value!.isEmpty ? null : _validatePhone(value),
                  onSaved: (value) => motherPhone = value!,
                ),
                TextFormField(
                  initialValue: studentPhone,
                  decoration:
                      const InputDecoration(labelText: 'Student\'s Phone'),
                  validator: _validatePhone,
                  onSaved: (value) => studentPhone = value!,
                ),
                TextFormField(
                  initialValue: address,
                  decoration: const InputDecoration(labelText: 'Address'),
                  onSaved: (value) => address = value!,
                ),
                TextFormField(
                  initialValue: courseFee != 0 ? courseFee.toString() : '',
                  decoration: const InputDecoration(labelText: 'Course Fee'),
                  keyboardType: TextInputType.number,
                  validator: (value) => value!.isEmpty ? 'Required' : null,
                  onSaved: (value) => courseFee = double.tryParse(value!) ?? 0,
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveStudent,
        child: const Icon(Icons.save),
      ),
    );
  }

  void _saveStudent() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final newStudent = Student()
        ..admNumber = admNumber
        ..name = name
        ..course = course
        ..batch = batch
        ..fatherPhone = fatherPhone
        ..motherPhone = motherPhone
        ..studentPhone = studentPhone
        ..address = address
        ..courseFee = courseFee;

      final studentsBox = Hive.box<Student>('students');

      if (widget.student == null) {
        studentsBox.add(newStudent);
      } else {
        studentsBox.putAt(widget.index!, newStudent);
      }

      Navigator.of(context).pop();
    }
  }

  String? _validatePhone(String? value) {
    final RegExp phoneExp = RegExp(r'^\d{10}$');
    if (value == null || !phoneExp.hasMatch(value)) {
      return 'Enter a valid phone number';
    }
    return null;
  }
}
