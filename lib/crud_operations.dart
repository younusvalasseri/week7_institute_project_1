import 'package:hive/hive.dart';
import 'models/account_transaction.dart';
import 'models/category.dart';
import 'models/employee.dart';
import 'models/student.dart';

class CRUDOperations {
  // transactions - Read
  static List<AccountTransaction> readAllTransactions() {
    final box = Hive.box<AccountTransaction>('transactions');
    return box.values.toList();
  }

  // transactions - add-new line - Update
  static Future<void> createTransaction(AccountTransaction transaction) async {
    final box = Hive.box<AccountTransaction>('transactions');
    await box.add(transaction);
  }

//transactions - Edit current line - Update
  static Future<void> updateTransactionWithKey(
      int key, AccountTransaction transaction) async {
    final box = Hive.box<AccountTransaction>('transactions');
    await box.put(key, transaction);
  }

  // transactions - Delete
  static Future<void> deleteTransaction(AccountTransaction transaction) async {
    await transaction.delete();
  }

  // Categories - Read
  static List<Category> readAllCategories() {
    final box = Hive.box<Category>('categories');
    return box.values.toList();
  }

  // Categories - add - new line - Update
  static Future<void> createCategory(Category category) async {
    final box = Hive.box<Category>('categories');
    await box.add(category);
  }

  // Categories - Delete
  static Future<void> deleteCategory(Category category) async {
    await category.delete();
  }

  // Students- Read
  static List<Student> readAllStudents() {
    final box = Hive.box<Student>('students');
    return box.values.toList();
  }

  // Students - Update
  static Future<void> updateStudents(int key, Student students) async {
    final box = Hive.box<Student>('students');
    await box.put(key, students);
  }

  // Students- Add new line
  static Future<void> createStudent(Student student) async {
    final box = Hive.box<Student>('students');
    await box.add(student);
  }

  // Students - Delete
  static Future<void> deleteStudent(Student student) async {
    await student.delete();
  }

  // Employees - read
  static List<Employee> readAllEmployees() {
    final box = Hive.box<Employee>('employees');
    return box.values.toList();
  }

  // Employees - Update
  static Future<void> updateEmployee(int key, Employee employee) async {
    final box = Hive.box<Employee>('employees');
    await box.put(key, employee);
  }

  // Employees - Add new line
  static Future<void> createEmployee(Employee employee) async {
    final box = Hive.box<Employee>('employees');
    await box.add(employee);
  }

// Employees - Delete
  static Future<void> deleteEmployee(Employee employee) async {
    await employee.delete();
  }
}
