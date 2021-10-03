class UserProductWeighting {
  final int id;
  final int userProductId;
  final String userProductName;
  final String userProductBrand;
  final int userDeviceId;
  final String userId;
  final double userProductWeight;
  final String userProductUnit;
  final DateTime createdAt;

  UserProductWeighting({
    this.id,
    this.userProductId,
    this.userProductName,
    this.userProductBrand,
    this.userDeviceId,
    this.userId,
    this.userProductWeight,
    this.userProductUnit,
    this.createdAt
  });

  UserProductWeighting.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        userProductId = json['user_product_id'] as int,
        userProductName = json['user_product_name'] as String,
        userProductBrand = json['user_product_brand'] as String,
        userDeviceId = json['user_device_id'] as int,
        userId = json['user_id'] as String,
        userProductWeight = json['weight'] as double,
        userProductUnit = json['unit'] as String,
        createdAt = DateTime.parse(json['created_at'] as String);

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'user_product_id': userProductId,
        'user_product_name': userProductName,
        'user_product_brand': userProductBrand,
        'user_device_id': userDeviceId,
        'user_id': userId,
        'weight': userProductWeight,
        'unit': userProductUnit,
        'created_at': createdAt.toString()
      };
}