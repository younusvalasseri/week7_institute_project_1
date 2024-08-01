import 'package:flutter/material.dart';
import '../models/account_transaction.dart';
import '../models/category.dart';
import '../models/student.dart';
import '../models/employee.dart';
import '../crud_operations.dart';

class AddExpensesScreen extends StatefulWidget {
  final AccountTransaction? transaction;
  final int? index;
  final Employee currentUser;
  const AddExpensesScreen(
      {super.key, this.transaction, this.index, required this.currentUser});

  @override
  // ignore: library_private_types_in_public_api
  _AddExpensesScreenState createState() => _AddExpensesScreenState();
}

class _AddExpensesScreenState extends State<AddExpensesScreen> {
  final formKey = GlobalKey<FormState>();
  late String journalNumber;
  late String entryNumber;
  late DateTime entryDate;
  late String mainCategory;
  late String subCategory;
  late double amount;
  late String? note;
  late String? studentId;
  late String? employeeId;

  @override
  void initState() {
    super.initState();
    final transaction = widget.transaction;
    journalNumber = transaction?.journalNumber ?? '';
    entryNumber = transaction?.entryNumber ?? '';
    entryDate = transaction?.entryDate ?? DateTime.now();
    mainCategory = transaction?.mainCategory ?? '';
    subCategory = transaction?.subCategory ?? '';
    amount = transaction?.amount ?? 0;
    note = transaction?.note ?? '';
    studentId = transaction?.studentId ?? 'Select Item';
    employeeId = transaction?.employeeId ?? 'Select Item';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text(widget.transaction == null ? 'Add Expense' : 'Edit Expense'),
      ),
      body: Form(
        key: formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              buildTextFormField(
                labelText: 'Journal Number',
                initialValue: journalNumber,
                onSaved: (value) => journalNumber = value!,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              buildTextFormField(
                labelText: 'Entry Number',
                initialValue: entryNumber,
                onSaved: (value) => entryNumber = value!,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              buildDatePickerField(
                labelText: 'Entry Date',
                selectedDate: entryDate,
                onDateChanged: (pickedDate) {
                  if (pickedDate != null && pickedDate != entryDate) {
                    setState(() {
                      entryDate = pickedDate;
                    });
                  }
                },
              ),
              buildDropdownButtonFormField<Category>(
                labelText: 'Main Category',
                value: mainCategory.isEmpty ? null : mainCategory,
                items: CRUDOperations.readAllCategories()
                    .where((category) => category.type == 'Expense')
                    .map((category) => DropdownMenuItem<String>(
                          value: category.description,
                          child: Text(category.description),
                        ))
                    .toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    mainCategory = newValue!;
                  });
                },
                validator: (value) => value == null ? 'Required' : null,
              ),
              buildTextFormField(
                labelText: 'Sub Category',
                initialValue: subCategory,
                onSaved: (value) => subCategory = value!,
              ),
              buildTextFormField(
                labelText: 'Amount',
                initialValue: amount != 0 ? amount.toString() : '',
                keyboardType: TextInputType.number,
                onSaved: (value) => amount = double.tryParse(value!) ?? 0,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              buildTextFormField(
                labelText: 'Note',
                initialValue: note ?? '',
                onSaved: (value) => note = value,
              ),
              buildStudentDropdown(),
              buildDropdownButtonFormField<Employee>(
                labelText: 'Employee',
                value: employeeId,
                items: [
                  const DropdownMenuItem(
                    value: 'Select Item',
                    child: Text('Select Item'),
                  ),
                  ...CRUDOperations.readAllEmployees()
                      .where((employee) => employee.isActive)
                      .map((employee) => DropdownMenuItem<String>(
                            value: employee.key.toString(),
                            child: Text(employee.name),
                          )),
                ],
                onChanged: (String? newValue) {
                  setState(() {
                    employeeId = newValue!;
                  });
                },
                onSaved: (value) => employeeId = value,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveExpense,
        child: const Icon(Icons.save),
      ),
    );
  }

  Widget buildTextFormField({
    required String labelText,
    required String initialValue,
    required Function(String?) onSaved,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(labelText: labelText),
      keyboardType: keyboardType,
      validator: validator,
      onSaved: onSaved,
    );
  }

  Widget buildDatePickerField({
    required String labelText,
    required DateTime selectedDate,
    required Function(DateTime?) onDateChanged,
  }) {
    return InkWell(
      onTap: () async {
        DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        onDateChanged(pickedDate);
      },
      child: InputDecorator(
        decoration: InputDecoration(labelText: labelText),
        child: Text(
          "${selectedDate.toLocal()}".split(' ')[0],
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  Widget buildDropdownButtonFormField<T>({
    required String labelText,
    required String? value,
    required List<DropdownMenuItem<String>> items,
    required Function(String?) onChanged,
    Function(String?)? onSaved,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: labelText),
      items: items,
      onChanged: onChanged,
      onSaved: onSaved,
      validator: validator,
    );
  }

  Widget buildStudentDropdown() {
    List<Student> students = CRUDOperations.readAllStudents()
        .where((student) => !student.isDeleted)
        .toList();
    // Added new
    if (widget.currentUser.position == 'Faculty') {
      students = students
          .where(
              (student) => student.classTeacher == widget.currentUser.empNumber)
          .toList();
    }

    return buildDropdownButtonFormField<Student>(
      labelText: 'Student',
      value: studentId,
      items: [
        const DropdownMenuItem(
          value: 'Select Item',
          child: Text('Select Item'),
        ),
        ...students.map((student) => DropdownMenuItem<String>(
              value: student.admNumber,
              child: Text(student.name),
            )),
      ],
      onChanged: (String? newValue) {
        setState(() {
          studentId = newValue!;
        });
      },
      onSaved: (value) => studentId = value,
    );
  }

  void _saveExpense() {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      final newTransaction = AccountTransaction()
        ..journalNumber = journalNumber
        ..entryNumber = entryNumber
        ..entryDate = entryDate
        ..category = 'Expense'
        ..mainCategory = mainCategory
        ..subCategory = subCategory
        ..amount = amount
        ..note = note
        ..studentId = studentId != 'Select Item' ? studentId : null
        ..employeeId = employeeId != 'Select Item' ? employeeId : null;

      if (widget.transaction == null) {
        CRUDOperations.createTransaction(newTransaction);
      } else {
        CRUDOperations.updateTransactionWithKey(
            widget.transaction!.key as int, newTransaction);
      }

      Navigator.of(context).pop();
    }
  }
}
