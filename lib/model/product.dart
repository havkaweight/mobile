import 'package:intl/intl.dart';

class ProductImages {
  final String? small;
  final String? original;

  const ProductImages({
    this.small,
    this.original,
  });

  ProductImages.fromJson(Map<dynamic, dynamic> json)
      : small = json['menu'] == null
            ? null
            : json['menu'].replaceAll('?', '%3F') as String?,
        original = json['original'] == null
            ? null
            : json['original'].replaceAll('?', '%3F') as String?;

  Map<dynamic, dynamic> toJson() => {
        'small': small,
        'original': original,
      };
}

class Protein {
  final double? total;

  const Protein({
    this.total,
  });

  Protein.fromJson(Map<String, dynamic> json)
    : total = json["total"];

  Map<String, dynamic> toJson() => {
    "total": total,
  };
}


class Fat {
  final double? monounsaturated;
  final double? polyunsaturated;
  final double? saturated;
  final double? total;
  final double? trans;

  const Fat({
    this.monounsaturated,
    this.polyunsaturated,
    this.saturated,
    this.total,
    this.trans,
  });

  Fat.fromJson(Map<String, dynamic> json)
      : monounsaturated = json["monounsaturated"],
        polyunsaturated = json["polyunsaturated"],
        saturated = json["saturated"],
        total = json["total"],
        trans = json["trans"];

  Map<String, dynamic> toJson() => {
    "monounsaturated": monounsaturated,
    "polyunsaturated": polyunsaturated,
    "saturated": saturated,
    "total": total,
    "trans": trans,
  };
}


class Carbs {
  final double? dietaryFiber;
  final double? sugars;
  final double? total;

  const Carbs({
    this.dietaryFiber,
    this.sugars,
    this.total,
  });

  Carbs.fromJson(Map<String, dynamic> json)
      : dietaryFiber = json["dietary_fiber"],
        sugars = json["sugars"],
        total = json["total"];

  Map<String, dynamic> toJson() => {
    "dietary_fiber": dietaryFiber,
    "sugars": sugars,
    "total": total,
  };
}


class Energy {
  final double? kcal;
  final double? kJ;

  const Energy({
    this.kcal,
    this.kJ,
  });

  Energy.fromJson(Map<String, dynamic> json)
      : kcal = json["kcal"],
        kJ = json["kj"];

  Map<String, dynamic> toJson() => {
    "kcal": kcal,
    "kj": kJ,
  };
}

class Serving {
  final String name;
  final double valueInBaseUnit;

  const Serving({
    required this.name,
    required this.valueInBaseUnit,
  });

  @override
  bool operator == (Object other) {
    if(other is Serving) {
      return name == other.name && valueInBaseUnit == other.valueInBaseUnit;
    }
    return false;
  }

  @override
  toString() {
    return toJson().toString();
  }

  Serving.fromJson(Map<String, dynamic> json)
      : name = json["name"],
        valueInBaseUnit = json["value_in_base_unit"];

  Map<String, dynamic> toJson() => {
    "name": name,
    "value_in_base_unit": valueInBaseUnit,
  };
}


class Package {
  final String? unit;
  final double? value;

  const Package({
    this.unit,
    this.value,
  });

  Package.fromJson(Map<String, dynamic> json)
      : unit = json["unit"],
        value = json["value"];

  Map<String, dynamic> toJson() => {
    "unit": unit,
    "value": value,
  };
}


class ProductNutrition {
  final Protein? protein;
  final Fat? fat;
  final Carbs? carbs;
  final Energy? energy;
  final String? unit;
  final double? valuePerInBaseUnit;

  const ProductNutrition({
    this.protein,
    this.fat,
    this.carbs,
    this.energy,
    this.unit,
    this.valuePerInBaseUnit,
  });

  ProductNutrition.fromJson(Map<dynamic, dynamic> json)
      : protein = json['protein'] == null
        ? null
        : Protein.fromJson(json['protein']),
        fat = json['fat'] == null
            ? null
            : Fat.fromJson(json['fat']),
        carbs = json['carbs'] == null
            ? null
            : Carbs.fromJson(json['carbs']),
        energy = json['energy'] == null
            ? null
            : Energy.fromJson(json['energy']),
        unit = json["unit"],
        valuePerInBaseUnit = json["value_per_in_base_unit"];

  Map<dynamic, dynamic> toJson() => {
        'protein': protein?.toJson() ?? null,
        'fat': fat?.toJson() ?? null,
        'carbs': carbs?.toJson() ?? null,
        'energy': energy?.toJson() ?? null,
        'unit': unit,
        'value_per_in_base_unit': valuePerInBaseUnit,
      };
}

class Brand {
  final name;
  final type;

  const Brand({
    this.name,
    this.type,
  });

  Brand.fromJson(Map<dynamic, dynamic> json)
      : name = json['name'] as String?,
        type = json['type'] as String?;

  Map<dynamic, dynamic> toJson() => {'name': name, 'type': type};
}

class Product {
  final String? id;
  String? name;
  Brand? brand;
  ProductNutrition? nutrition;
  List<Serving> serving;
  String? barcode;
  String? baseUnit;
  Package? package;
  ProductImages? images;
  String? countryCode;
  DateTime createdAt;
  DateTime updatedAt;

  Product({
    this.id,
    this.name,
    this.brand,
    this.nutrition,
    required this.serving,
    this.barcode,
    this.baseUnit,
    this.package,
    this.images,
    this.countryCode,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) :
        this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  @override
  String toString() {
    return toJson().toString();
  }

  Product.fromJson(Map<String, dynamic> json)
      : id = json['_id'] as String?,
        name = json['name'] as String,
        brand = json['brand'] == null ? null : Brand.fromJson(json['brand']),
        nutrition = json['nutrition'] == null
            ? null
            : ProductNutrition.fromJson(
                json['nutrition'],
              ),
        serving = (json["serving"] as Iterable).map((servingJson) => Serving.fromJson(servingJson)).toList(),
        baseUnit = json['base_unit'] as String,
        barcode = json['barcode'] as String?,
        package = json['package'] == null
            ? null
            : Package.fromJson(json['package']),
        images = json['imgs'] == null
            ? null
            : json['imgs']['foody'] == null
                ? null
                : ProductImages.fromJson(json['imgs']['foody']),
        countryCode = json["country_code"],
        createdAt = DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(json['created_at'] as String, true)
            .toLocal(),
        updatedAt = DateFormat('yyyy-MM-ddTHH:mm:ss')
            .parse(json['updated_at'] as String, true)
            .toLocal();

  Map<String, dynamic> toJson() => {
        if (id != null) '_id': id,
        'name': name,
        'brand': brand == null ? null : brand!.toJson(),
        'nutrition': nutrition == null ? null : nutrition!.toJson(),
        'serving': List.generate(serving.length, (index) => serving[index].toJson()),
        'base_unit': baseUnit,
        'barcode': barcode,
        'package': package == null ? null : package!.toJson(),
        'imgs': images == null ? null : {'foody': images!.toJson()},
        'country_code': countryCode,
        'created_at': DateFormat('yyyy-MM-ddTHH:mm:ss').format(createdAt.toUtc()),
        'updated_at': DateFormat('yyyy-MM-ddTHH:mm:ss').format(updatedAt.toUtc()),
      };

  set(Product p) {
    this.name = p.name;
    this.brand = p.brand;
    this.nutrition = p.nutrition;
    this.baseUnit = p.baseUnit;
    this.package = p.package;
    this.barcode = p.barcode;
    this.countryCode = p.countryCode;
  }
}
