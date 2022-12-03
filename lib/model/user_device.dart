class UserDevice {
  final int? id;
  final int? deviceId;
  final String? serialId;
  final String? macAddress;
  final String? userDeviceName;
  final String? userId;
  final String? firmwareVersion;

  UserDevice({
    this.id,
    this.deviceId,
    this.serialId,
    this.macAddress,
    this.userDeviceName,
    this.userId,
    this.firmwareVersion
  });

  UserDevice.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        deviceId = json['device_id'] as int,
        serialId = json['serial_id'] as String,
        macAddress = json['macaddr'] as String,
        userDeviceName = json['user_device_name'] as String,
        userId = json['user_id'] as String,
        firmwareVersion = json['firmware_version'] as String;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'device_id': deviceId,
        'serial_id': serialId,
        'macaddr': macAddress,
        'user_device_name': userDeviceName,
        'user_id': userId,
        'firmware_version': firmwareVersion
      };

  Map<String, dynamic> createdDataToJson() =>
      {
        'serial_id': serialId,
      };
}