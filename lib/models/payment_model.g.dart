// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PaymentAdapter extends TypeAdapter<Payment> {
  @override
  final int typeId = 20;

  @override
  Payment read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Payment(
      id: fields[0] as String,
      tenant: fields[1] as PaymentTenant,
      property: fields[2] as PaymentProperty,
      amount: fields[3] as double,
      paymentDate: fields[4] as DateTime,
      dueDate: fields[5] as DateTime,
      method: fields[6] as String,
      status: fields[7] as String,
      description: fields[8] as String?,
      notes: fields[9] as String?,
      lateFee: fields[10] as double,
      discount: fields[11] as double,
      processedBy: fields[12] as PaymentProcessor?,
      createdAt: fields[13] as DateTime,
      updatedAt: fields[14] as DateTime,
      totalAmount: fields[15] as double,
      isLate: fields[16] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Payment obj) {
    writer
      ..writeByte(17)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.tenant)
      ..writeByte(2)
      ..write(obj.property)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.paymentDate)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.method)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.description)
      ..writeByte(9)
      ..write(obj.notes)
      ..writeByte(10)
      ..write(obj.lateFee)
      ..writeByte(11)
      ..write(obj.discount)
      ..writeByte(12)
      ..write(obj.processedBy)
      ..writeByte(13)
      ..write(obj.createdAt)
      ..writeByte(14)
      ..write(obj.updatedAt)
      ..writeByte(15)
      ..write(obj.totalAmount)
      ..writeByte(16)
      ..write(obj.isLate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentTenantAdapter extends TypeAdapter<PaymentTenant> {
  @override
  final int typeId = 21;

  @override
  PaymentTenant read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentTenant(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      email: fields[3] as String,
      phone: fields[4] as String?,
      unit: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentTenant obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.email)
      ..writeByte(4)
      ..write(obj.phone)
      ..writeByte(5)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentTenantAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentPropertyAdapter extends TypeAdapter<PaymentProperty> {
  @override
  final int typeId = 22;

  @override
  PaymentProperty read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentProperty(
      id: fields[0] as String,
      name: fields[1] as String,
      address: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentProperty obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentPropertyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PaymentProcessorAdapter extends TypeAdapter<PaymentProcessor> {
  @override
  final int typeId = 23;

  @override
  PaymentProcessor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PaymentProcessor(
      id: fields[0] as String,
      firstName: fields[1] as String,
      lastName: fields[2] as String,
      email: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PaymentProcessor obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.firstName)
      ..writeByte(2)
      ..write(obj.lastName)
      ..writeByte(3)
      ..write(obj.email);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PaymentProcessorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
