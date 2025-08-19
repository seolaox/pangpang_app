
import 'package:pangpang_app/place/domain/entity/hospital_entity.dart';

class AnimalHospitalModel extends AnimalHospitalEntity {
  const AnimalHospitalModel({
    required super.name,
    required super.phone,
    required super.address,
    required super.latitude,
    required super.longitude,
    super.isFavorite,
  });

factory AnimalHospitalModel.fromJson(Map<String, dynamic> json) {
  final model = AnimalHospitalModel(
    name: json['pname'] as String? ?? '',
    phone: json['pphone'] as String? ?? '',
    address: json['paddress'] as String? ?? '',
    latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
    longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
    isFavorite: json['isFavorite'] as bool? ?? false,
  );
  
  return model;
}

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'isFavorite': isFavorite,
    };
  }

  factory AnimalHospitalModel.fromEntity(AnimalHospitalEntity entity) {
    return AnimalHospitalModel(
      name: entity.name,
      phone: entity.phone,
      address: entity.address,
      latitude: entity.latitude,
      longitude: entity.longitude,
      isFavorite: entity.isFavorite,
    );
  }
}