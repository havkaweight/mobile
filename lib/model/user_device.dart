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
      : id = json['id'],
        deviceId = json['device_id'],
        deviceUUID = json['device_uuid'],
        deviceName = json['device_name'],
        userId = json['user_id'];

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'device_id': deviceId,
        'device_uuid': deviceUUID,
        'device_name': deviceName,
        'user_id': userId
      };
}