import 'package:hive/hive.dart';

part 'employee.g.dart';

@HiveType(typeId: 0)
class Employee extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String position;

  @HiveField(2)
  late String phone;

  @HiveField(3)
  late String address;
}
