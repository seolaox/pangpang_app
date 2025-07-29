

import 'package:pangpang_app/data/model/user/animal_model.dart';
import 'package:pangpang_app/data/model/user/family_model.dart';

class UserModel {
  final String uid;
  final String uname;
  final String? uimage;
  final List<FamilyMember> families;
  final List<Animal> animals;

  UserModel({
    required this.uid,
    required this.uname,
    this.uimage,
    this.families = const [],
    this.animals = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String,
      uname: map['uname'] as String,
      uimage: map['uimage'] as String?,
      families: (map['families'] as List<dynamic>?)
          ?.map((e) => FamilyMember.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
      animals: (map['animals'] as List<dynamic>?)
          ?.map((e) => Animal.fromMap(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'uname': uname,
      'uimage': uimage,
      'families': families.map((e) => e.toMap()).toList(),
      'animals': animals.map((e) => e.toMap()).toList(),
    };
  }

  // Add this for state management
  factory UserModel.empty() {
    return UserModel(
      uid: '',
      uname: '',
      uimage: null,
      families: const [],
      animals: const [],
    );
  }

  UserModel copyWith({
    String? uid,
    String? uname,
    String? uimage,
    List<FamilyMember>? families,
    List<Animal>? animals,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      uname: uname ?? this.uname,
      uimage: uimage ?? this.uimage,
      families: families ?? this.families,
      animals: animals ?? this.animals,
    );
  }
}
