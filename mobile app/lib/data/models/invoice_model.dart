import 'package:hive/hive.dart';
part 'invoice_model.g.dart'; // MUST BE EXACTLY THIS
@HiveType(typeId: 0)
class InvoiceModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerName;

  @HiveField(2)
  final DateTime date;

  @HiveField(3)
  final DateTime dueDate;

  @HiveField(4)
  final double subTotal;

  @HiveField(5)
  final double taxAmount;

  @HiveField(6)
  final double discount;

  @HiveField(7)
  final double total;

  @HiveField(8)
  final String status; // 'Paid', 'Pending', 'Overdue'

  InvoiceModel({
    required this.id,
    required this.customerName,
    required this.date,
    required this.dueDate,
    required this.subTotal,
    required this.taxAmount,
    required this.discount,
    required this.total,
    required this.status,
  });
}