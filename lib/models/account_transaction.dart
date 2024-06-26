import 'package:hive/hive.dart';

part 'account_transaction.g.dart';

@HiveType(typeId: 4)
class AccountTransaction extends HiveObject {
  @HiveField(0)
  late String journalNumber;

  @HiveField(1)
  late String entryNumber;

  @HiveField(2)
  late DateTime entryDate;

  @HiveField(3)
  late String category;

  @HiveField(4)
  late String mainCategory;

  @HiveField(5)
  late String subCategory;

  @HiveField(6)
  late double amount;

  @HiveField(7)
  String? studentId;

  @HiveField(8)
  String? employeeId;
}
