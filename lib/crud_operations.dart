import 'package:hive/hive.dart';
import 'models/account_transaction.dart';
import 'models/category.dart';
import 'models/employee.dart';
import 'models/student.dart';

class CRUDOperations {
  // Transactions
  static Future<void> createTransaction(AccountTransaction transaction) async {
    final box = await Hive.openBox<AccountTransaction>('transactions');
    await box.add(transaction);
  }

  static List<AccountTransaction> readAllTransactions() {
    final box = Hive.box<AccountTransaction>('transactions');
    return box.values.toList();
  }

  static Future<void> updateTransaction(AccountTransaction transaction) async {
    await transaction.save();
  }

  static Future<void> deleteTransaction(AccountTransaction transaction) async {
    await transaction.delete();
  }

  // Categories
  static Future<void> createCategory(Category category) async {
    final box = await Hive.openBox<Category>('categories');
    await box.add(category);
  }

  static List<Category> readAllCategories() {
    final box = Hive.box<Category>('categories');
    return box.values.toList();
  }

  static Future<void> updateCategory(Category category) async {
    await category.save();
  }

  static Future<void> deleteCategory(Category category) async {
    await category.delete();
  }

  // Students
  static Future<void> createStudent(Student student) async {
    final box = await Hive.openBox<Student>('students');
    await box.add(student);
  }

  static List<Student> readAllStudents() {
    final box = Hive.box<Student>('students');
    return box.values.toList();
  }

  static Future<void> updateStudent(Student student) async {
    await student.save();
  }

  static Future<void> deleteStudent(Student student) async {
    await student.delete();
  }

  // Employees
  static Future<void> createEmployee(Employee employee) async {
    final box = await Hive.openBox<Employee>('employees');
    await box.add(employee);
  }

  static List<Employee> readAllEmployees() {
    final box = Hive.box<Employee>('employees');
    return box.values.toList();
  }

  static Future<void> updateEmployee(Employee employee) async {
    await employee.save();
  }

  static Future<void> deleteEmployee(Employee employee) async {
    await employee.delete();
  }
}
