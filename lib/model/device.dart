class Device {
  final int id;
  final String name;
  final String vendor;
  final String serviceUUID;
  final int status;

  Device({
    this.id,
    this.name,
    this.vendor,
    this.serviceUUID,
    this.status
  });

  Device.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        vendor = json['vendor'],
        serviceUUID = json['service_uuid'],
        status = json['status'];

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'vendor': vendor,
        'service_uuid': serviceUUID,
        'status': status
      };
}