import '../../../domain/entities/device/device.dart';

class DeviceModel {
  final int? id;
  final String? name;
  final String? vendor;
  final String? serviceUUID;
  final int? status;

  DeviceModel({
    this.id,
    this.name,
    this.vendor,
    this.serviceUUID,
    this.status,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'],
      name: json['name'],
      vendor: json['vendor'],
      serviceUUID: json['service_uuid'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'vendor': vendor,
      'service_uuid': serviceUUID,
      'status': status
    };
  }

  static DeviceModel fromDomain(Device device) {
    return DeviceModel(
      id: device.id,
      name: device.name,
      vendor: device.vendor,
      serviceUUID: device.serviceUUID,
      status: device.status,
    );
  }

  Device toDomain() {
    return Device(
      id: id,
      name: name,
      vendor: vendor,
      serviceUUID: serviceUUID,
      status: status,
    );
  }
}
