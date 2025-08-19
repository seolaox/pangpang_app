
import 'package:pangpang_app/place/domain/entity/place_entity.dart';

class PlaceModel extends PlaceEntity {
  const PlaceModel({
    super.id,
    required super.pname,
    required super.pphone,
    required super.paddress,
    required super.latitude,
    required super.longitude,
    super.createdAt,
  });

  factory PlaceModel.fromJson(Map<String, dynamic> json) {
    return PlaceModel(
      id: json['id'] as int?,
      pname: json['pname'] as String? ?? '',
      pphone: json['pphone'] as String? ?? '',
      paddress: json['paddress'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'pname': pname,
      'pphone': pphone,
      'paddress': paddress,
      'latitude': latitude,
      'longitude': longitude,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

Map<String, dynamic> toCreateJson() {  
  final json = {
    'pname': pname,
    'pphone': pphone,
    'paddress': paddress,
    'latitude': latitude,
    'longitude': longitude,
  };
  return json;
}
  factory PlaceModel.fromEntity(PlaceEntity entity) {
    return PlaceModel(
      id: entity.id,
      pname: entity.pname,
      pphone: entity.pphone,
      paddress: entity.paddress,
      latitude: entity.latitude,
      longitude: entity.longitude,
      createdAt: entity.createdAt,
    );
  }
}