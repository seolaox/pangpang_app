class Family {
  final String fid;
  final String fname;
  final String leader_uid;

  Family({
    required this.fid,
    required this.fname,
    required this.leader_uid,
  });

  factory Family.fromMap(Map<String, dynamic> map) {
    return Family(
      fid: map['fid'] as String,
      fname: map['fname'] as String,
      leader_uid: map['leader_uid'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fid': fid,
      'fname': fname,
      'leader_uid': leader_uid,
    };
  }
}

class FamilyMember {
  final Family family;
  final String status;

  FamilyMember({
    required this.family,
    required this.status,
  });

  factory FamilyMember.fromMap(Map<String, dynamic> map) {
    return FamilyMember(
      family: Family.fromMap(map['family'] as Map<String, dynamic>),
      status: map['status'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'family': family.toMap(),
      'status': status,
    };
  }
} 