import 'dart:io';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:week7_institute_project_1/generated/l10n.dart';
import 'package:week7_institute_project_1/screens/add_students_screen.dart';
import '../models/student.dart';
import '../models/account_transaction.dart';
import 'student_details_screen.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final _studentsBox = Hive.box<Student>('students');
  final _transactionsBox = Hive.box<AccountTransaction>('transactions');
  String _searchQuery = '';

  void _markStudentAsDeleted(int index) {
    final student = _studentsBox.getAt(index);
    student?.isDeleted = true;
    student?.save();
    setState(() {});
  }

  double _calculateCollectedFee(String admNumber) {
    double collectedFee = _transactionsBox.values
        .where((transaction) =>
            transaction.mainCategory == 'Student Fee' &&
            transaction.studentId == admNumber)
        .fold(0.0, (sum, transaction) => sum + transaction.amount);
    return collectedFee;
  }

  double _calculateBalance(Student student) {
    double collectedFee = _calculateCollectedFee(student.admNumber);
    return (student.courseFee ?? 0) - collectedFee;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).Students),
      ),
      body: Column(
        children: [
          _buildSearchBox(),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _studentsBox.listenable(),
              builder: (context, Box<Student> box, _) {
                var students =
                    box.values.where((student) => !student.isDeleted).toList();

                if (_searchQuery.isNotEmpty) {
                  students = students
                      .where((student) => student.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()))
                      .toList();
                }

                students.sort((a, b) => a.name.compareTo(b.name));

                if (students.isEmpty) {
                  return const Center(child: Text('No students yet'));
                }

                return ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final collectedFee =
                        _calculateCollectedFee(student.admNumber);
                    final balance = _calculateBalance(student);

                    return Card(
                      child: InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StudentDetailsScreen(student: student),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  CircleAvatar(
                                    backgroundImage:
                                        student.profilePicture != null
                                            ? FileImage(
                                                File(student.profilePicture!))
                                            : null,
                                    child: student.profilePicture == null
                                        ? Text(student.name[0])
                                        : null,
                                  ),
                                ],
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(student.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(student.admNumber),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Col.: ₹${collectedFee.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.green),
                                  ),
                                  Text(
                                    'Bal.: ₹${balance.toStringAsFixed(2)}',
                                    style: const TextStyle(color: Colors.red),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 20),
                              Column(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AddStudentScreen(
                                            student: student,
                                            index: index,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () =>
                                        _markStudentAsDeleted(index),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddStudentScreen()),
        ),
        tooltip: 'Add Student',
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
}
