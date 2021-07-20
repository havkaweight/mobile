class UserDevice {
  final int id;
  final int deviceId;
  final String deviceUUID;
  final String deviceName;
  final String userId;

  UserDevice({
    this.id,
    this.deviceId,
    this.deviceUUID,
    this.deviceName,
    this.userId
  });

  UserDevice.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        deviceId = json['device_id'] as int,
        deviceUUID = json['device_uuid'] as String,
        deviceName = json['device_name'] as String,
        userId = json['user_id'] as String;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'device_id': deviceId,
        'device_uuid': deviceUUID,
        'device_name': deviceName,
        'user_id': userId
      };
}

class UserDeviceCreate {
  final String serviceUUID;
  final String deviceUUID;

  UserDeviceCreate({
    this.serviceUUID,
    this.deviceUUID,
  });

  Map<String, dynamic> toJson() =>
      {
        'service_uuid': serviceUUID,
        'device_uuid': deviceUUID,
      };
}
