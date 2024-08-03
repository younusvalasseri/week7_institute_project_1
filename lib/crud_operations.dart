import 'package:hive/hive.dart';
import 'models/account_transaction.dart';
import 'models/category.dart';
import 'models/employee.dart';
import 'models/student.dart';

class CRUDOperations {
  // Transactions - Read
  static List<AccountTransaction> readAllTransactions() {
    final box = Hive.box<AccountTransaction>('transactions');
    return box.values.toList();
  }

  // Transactions - Create
  static Future<void> createTransaction(AccountTransaction transaction) async {
    final box = Hive.box<AccountTransaction>('transactions');
    await box.add(transaction);
  }

  // Transactions - Update
  static Future<void> updateTransactionWithKey(
      int key, AccountTransaction transaction) async {
    final box = Hive.box<AccountTransaction>('transactions');
    await box.put(key, transaction);
  }

  // Transactions - Delete
  static Future<void> deleteTransaction(AccountTransaction transaction) async {
    await transaction.delete();
  }

  // Categories - Read
  static List<Category> readAllCategories() {
    final box = Hive.box<Category>('categories');
    return box.values.toList();
  }

  // Categories - Create
  static Future<void> createCategory(Category category) async {
    final box = Hive.box<Category>('categories');
    await box.add(category);
  }

  // Categories - Delete
  static Future<void> deleteCategory(Category category) async {
    await category.delete();
  }

  // Students - Read
  static List<Student> readAllStudents() {
    final box = Hive.box<Student>('students');
    return box.values.toList();
  }

  // Students - Update
  static Future<void> updateStudent(String admNumber, Student student) async {
    final box = Hive.box<Student>('students');
    await box.put(admNumber, student);
  }

  // Students - Create
  static Future<void> createStudent(Student student) async {
    final box = Hive.box<Student>('students');
    if (box.containsKey(student.admNumber)) {
      throw Exception('Admission number already used!');
    }
    await box.put(student.admNumber, student);
  }

  // Students - Delete
  static Future<void> deleteStudent(Student student) async {
    final box = Hive.box<Student>('students');
    await box.delete(student.admNumber);
  }

  // Employees - Read
  static List<Employee> readAllEmployees() {
    final box = Hive.box<Employee>('employees');
    return box.values.toList();
  }

  // Employees - Update
  static Future<void> updateEmployee(
      String empNumber, Employee employee) async {
    final box = Hive.box<Employee>('employees');
    await box.put(empNumber, employee);
  }

  // Employees - Create
  static Future<void> createEmployee(Employee employee) async {
    final box = Hive.box<Employee>('employees');
    if (box.containsKey(employee.empNumber)) {
      throw Exception('Employee number already used!');
    }
    await box.put(employee.empNumber, employee);
  }

  // Employees - Delete
  static Future<void> deleteEmployee(Employee employee) async {
    final box = Hive.box<Employee>('employees');
    await box.delete(employee.empNumber);
  }
}
