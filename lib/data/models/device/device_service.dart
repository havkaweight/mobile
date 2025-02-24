class DeviceService {
  final int? id;
  final int? deviceCatalogId;
  final String? serviceUuid;
  final String? serviceName;
  final String? characteristicUuid;
  final String? characteristicName;

  DeviceService({
    this.id,
    this.deviceCatalogId,
    this.serviceUuid,
    this.serviceName,
    this.characteristicUuid,
    this.characteristicName,
  });

  DeviceService.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        deviceCatalogId = json['device_catalog_id'] as int,
        serviceUuid = json['service_uuid'] as String,
        serviceName = json['service_name'] as String,
        characteristicUuid = json['characteristic_uuid'] as String,
        characteristicName = json['characteristic_name'] as String;

  Map<String, dynamic> toJson() => {
        'id': id,
        'device_catalog_id': deviceCatalogId,
        'service_uuid': serviceUuid,
        'service_name': serviceName,
        'characteristic_uuid': characteristicUuid,
        'characteristic_name': characteristicName
      };
}
