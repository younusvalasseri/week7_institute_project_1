import 'package:hive/hive.dart';

part 'filter.g.dart';

@HiveType(typeId: 2)
class Filter extends HiveObject {
  @HiveField(0)
  late String type; // "income" or "expense"
}
