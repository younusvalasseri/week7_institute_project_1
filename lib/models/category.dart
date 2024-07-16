import 'package:hive/hive.dart';

part 'category.g.dart';

@HiveType(typeId: 4)
class Category extends HiveObject {
  @HiveField(0)
  late String description;

  @HiveField(1)
  late String type; // "income" or "expense"

  @HiveField(2)
  late bool isTaxable;
}
