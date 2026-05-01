// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class InvoiceModelAdapter extends TypeAdapter<InvoiceModel> {
  @override
  final int typeId = 0;

  @override
  InvoiceModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InvoiceModel(
      id: fields[0] as String,
      customerName: fields[1] as String,
      date: fields[2] as DateTime,
      dueDate: fields[3] as DateTime,
      subTotal: fields[4] as double,
      taxAmount: fields[5] as double,
      discount: fields[6] as double,
      total: fields[7] as double,
      status: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InvoiceModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerName)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.subTotal)
      ..writeByte(5)
      ..write(obj.taxAmount)
      ..writeByte(6)
      ..write(obj.discount)
      ..writeByte(7)
      ..write(obj.total)
      ..writeByte(8)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InvoiceModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
