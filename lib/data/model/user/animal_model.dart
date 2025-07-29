class Animal {
  final String aid;
  final String aname;
  final String? aimage;
  final String abirthday;
  final int agender;
  final String species;
  final String abreed;
  final String aintroduction;
  final int focusStatus;

  Animal({
    required this.aid,
    required this.aname,
    this.aimage,
    required this.abirthday,
    required this.agender,
    required this.species,
    required this.abreed,
    required this.aintroduction,
    required this.focusStatus,
  });

  factory Animal.fromMap(Map<String, dynamic> map) {
    return Animal(
      aid: map['aid']?.toString() ?? '',
      aname: map['aname']?.toString() ?? '',
      aimage: map['aimage']?.toString(),
      abirthday: map['abirthday']?.toString() ?? '',
      agender: map['agender'] is int ? map['agender'] as int : int.tryParse(map['agender']?.toString() ?? '0') ?? 0,
      species: map['species']?.toString() ?? '',
      abreed: map['abreed']?.toString() ?? '',
      aintroduction: map['aintroduction']?.toString() ?? '',
      focusStatus: map['focus_status'] is int ? map['focus_status'] as int : int.tryParse(map['focus_status']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'aid': aid,
      'aname': aname,
      'aimage': aimage ?? '',
      'abirthday': abirthday,
      'agender': agender,
      'species': species,
      'abreed': abreed,
      'aintroduction': aintroduction,
      'focus_status': focusStatus.toString(),
    };
  }
} 