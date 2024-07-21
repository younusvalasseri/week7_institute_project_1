import 'package:hive/hive.dart';

part 'student.g.dart';

@HiveType(typeId: 1)
class Student extends HiveObject {
  @HiveField(0)
  late String admNumber;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late String fatherPhone;

  @HiveField(3)
  late String motherPhone;

  @HiveField(4)
  late String studentPhone;

  @HiveField(5)
  late String course;

  @HiveField(6)
  late String batch;

  @HiveField(7)
  late String address;

  @HiveField(8)
  String? profilePicture;

  @HiveField(9)
  double? courseFee = 0;

  @HiveField(10)
  bool isDeleted = false;

  @HiveField(11)
  String? classTeacher; // Added field
}
