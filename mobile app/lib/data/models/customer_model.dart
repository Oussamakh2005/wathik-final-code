import 'package:hive/hive.dart';
part 'customer_model.g.dart'; // MUST BE EXACTLY THIS
@HiveType(typeId: 1)
class CustomerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String fullName;

  @HiveField(2)
  final String phoneNumber; // Algerian format (e.g., 0555...)

  @HiveField(3)
  final double totalDebt;

  @HiveField(4)
  final int totalInvoices;

  @HiveField(5)
  final int overdueInvoices;
// Add these inside your customer_model.dart
  @HiveField(6)
  int reminderCount;

  @HiveField(7)
  DateTime? lastReminderDate;

// Make sure to update your constructor to initialize them!
  CustomerModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.totalDebt = 0.0,
    this.totalInvoices = 0,
    this.overdueInvoices = 0,
    this.reminderCount = 0,
    this.lastReminderDate = null,
  });
}