class Device {
  final int? id;
  final String? name;
  final String? vendor;
  final String? serviceUUID;
  final int? status;

  Device({
    this.id,
    this.name,
    this.vendor,
    this.serviceUUID,
    this.status
  });

  Device.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        name = json['name'] as String,
        vendor = json['vendor'] as String,
        serviceUUID = json['service_uuid'] as String,
        status = json['status'] as int;

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'vendor': vendor,
        'service_uuid': serviceUUID,
        'status': status
      };
}