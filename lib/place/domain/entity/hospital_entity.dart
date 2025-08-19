class AnimalHospitalEntity {
  final String name;
  final String phone;
  final String address;
  final double latitude;
  final double longitude;
  final bool isFavorite;

  const AnimalHospitalEntity({
    required this.name,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.isFavorite = false,
  });

  AnimalHospitalEntity copyWith({
    String? name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    bool? isFavorite,
  }) {
    return AnimalHospitalEntity(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AnimalHospitalEntity &&
        other.name == name &&
        other.phone == phone &&
        other.address == address &&
        other.latitude == latitude &&
        other.longitude == longitude &&
        other.isFavorite == isFavorite;
  }

  @override
  int get hashCode {
    return Object.hash(name, phone, address, latitude, longitude, isFavorite);
  }

  @override
  String toString() {
    return 'AnimalHospitalEntity(name: $name, phone: $phone, address: $address, latitude: $latitude, longitude: $longitude, isFavorite: $isFavorite)';
  }
}