import 'package:hive/hive.dart';

part 'user_model.g.dart'; // THIS LINE IS MANDATORY@HiveType(typeId: 2) // ID 0=Invoice, ID 1=Customer
class UserModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String phone;

  @HiveField(4)
  final String password; // In a real app, never store plain text. This is for local mock auth.

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.password,
  });
}