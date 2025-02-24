import '../../../domain/entities/device/user_device.dart';

class UserDeviceModel {
  final int? id;
  final int? deviceId;
  final String? serialId;
  final String? macAddress;
  final String? userDeviceName;
  final String? userId;
  final String? firmwareVersion;

  UserDeviceModel({
    this.id,
    this.deviceId,
    this.serialId,
    this.macAddress,
    this.userDeviceName,
    this.userId,
    this.firmwareVersion,
  });

  factory UserDeviceModel.fromJson(Map<String, dynamic> json) {
    return UserDeviceModel(
      id: json['id'],
      deviceId: json['device_id'],
      serialId: json['serial_id'],
      macAddress: json['macaddr'],
      userDeviceName: json['user_device_name'],
      userId: json['user_id'],
      firmwareVersion: json['firmware_version'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'serial_id': serialId,
      'macaddr': macAddress,
      'user_device_name': userDeviceName,
      'user_id': userId,
      'firmware_version': firmwareVersion
    };
  }

  static UserDeviceModel fromDomain(UserDevice userDevice) {
    return UserDeviceModel(
      id: userDevice.id,
      deviceId: userDevice.deviceId,
      serialId: userDevice.serialId,
      macAddress: userDevice.macAddress,
    );
  }

  UserDevice toDomain() {
    return UserDevice(
      id: id,
      deviceId: deviceId,
      serialId: serialId,
      macAddress: macAddress,
      userDeviceName: userDeviceName,
    );
  }
}
