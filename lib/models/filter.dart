import 'package:hive/hive.dart';

part 'filter.g.dart';

@HiveType(typeId: 6) // Ensure this ID is unique
class Filter extends HiveObject {
  @HiveField(0)
  late String name;

  @HiveField(1)
  late String criteria;
}
