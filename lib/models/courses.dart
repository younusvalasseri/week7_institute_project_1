import 'package:hive/hive.dart';

part 'courses.g.dart';

@HiveType(typeId: 5)
class Courses extends HiveObject {
  @HiveField(0)
  String? courseName;

  @HiveField(1)
  String? courseDescription;
}
