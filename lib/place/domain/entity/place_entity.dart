class PlaceEntity {
  final int? id;
  final String pname;
  final String pphone;
  final String paddress;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;

  const PlaceEntity({
    this.id,
    required this.pname,
    required this.pphone,
    required this.paddress,
    required this.latitude,
    required this.longitude,
    this.createdAt,
  });

  PlaceEntity copyWith({
    int? id,
    String? pname,
    String? pphone,
    String? paddress,
    double? latitude,
    double? longitude,
    DateTime? createdAt,
  }) {
    return PlaceEntity(
      id: id ?? this.id,
      pname: pname ?? this.pname,
      pphone: pphone ?? this.pphone,
      paddress: paddress ?? this.paddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PlaceEntity &&
        other.id == id &&
        other.pname == pname &&
        other.pphone == pphone &&
        other.paddress == paddress &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, pname, pphone, paddress, latitude, longitude, createdAt);
  }

  @override
  String toString() {
    return 'PlaceEntity(id: $id, pname: $pname, pphone: $pphone, paddress: $paddress, latitude: $latitude, longitude: $longitude, createdAt: $createdAt)';
  }
}