import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 2)
class Employee extends HiveObject {
  @HiveField(0)
  late String empNumber;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String position;

  @HiveField(3)
  late String phone;

  @HiveField(4)
  late String address;

  @HiveField(5)
  String? password;

  @HiveField(6)
  late String role;

  @HiveField(7)
  late bool isActive;

  @HiveField(8)
  String? profilePicture;

  @HiveField(9)
  String? username;

  @HiveField(10)
  double? previousSalary;

  @HiveField(11)
  double? currentSalary;

  Employee() {
    empNumber = '';
    name = '';
    position = '';
    phone = '';
    address = '';
    password = null;
    role = 'General';
    isActive = true; // Ensure isActive is set to true by default
    username = null;
    profilePicture = null;
    previousSalary = 0.0;
    currentSalary = 0.0;
  }
}
