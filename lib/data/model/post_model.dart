class PostModel {
  final String pid;
  final String pname;
  final List<String> pimages;
  final int pthumbnailIndex;
  final DateTime pdate;
  final String pcontentsText;
  final String pauthor;
  final String? authorName;
  final String? animalName;
  final String? familyName;
  final int? paid;  // 추가된 필드
  final int? pfid;  // 추가된 필드

  PostModel({
    required this.pid,
    required this.pname,
    required this.pimages,
    required this.pthumbnailIndex,
    required this.pdate,
    required this.pcontentsText,
    required this.pauthor,
    this.authorName,
    this.animalName,
    this.familyName,
    this.paid,
    this.pfid,
  });

  String get pthumbnail {
    if (pimages.isNotEmpty && pthumbnailIndex >= 0 && pthumbnailIndex < pimages.length) {
      return pimages[pthumbnailIndex];
    }
    return pimages.isNotEmpty ? pimages[0] : '';
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    String contentsText = '';
    if (json['pcontents'] != null) {
      if (json['pcontents'] is Map<String, dynamic> &&
          json['pcontents']['text'] != null) {
        contentsText = json['pcontents']['text'] as String;
      }
    }
    int thumbnailIndex = 0;
    if (json['pthumbnail_index'] != null) {
      if (json['pthumbnail_index'] is int) {
        thumbnailIndex = json['pthumbnail_index'];
      } else if (json['pthumbnail_index'] is String) {
        thumbnailIndex = int.tryParse(json['pthumbnail_index']) ?? 0;
      }
    } else if (json['pthumbnail'] != null && json['pthumbnail'] is String) {
      final thumbnailFileName = json['pthumbnail'] as String;
      final images = json['pimages'] is List ? List<String>.from(json['pimages']) : <String>[];
      thumbnailIndex = images.indexOf(thumbnailFileName);
      if (thumbnailIndex == -1) thumbnailIndex = 0;
    }
    List<String> imagesList = [];
    if (json['pimages'] != null && json['pimages'] is List) {
      imagesList = (json['pimages'] as List)
          .map((item) => item.toString())
          .toList();
    }
    return PostModel(
      pid: json['pid']?.toString() ?? '',
      pname: json['pname'] ?? '',
      pimages: imagesList,
      pthumbnailIndex: thumbnailIndex,
      pdate: json['pdate'] != null
          ? DateTime.parse(json['pdate'])
          : DateTime.now(),
      pcontentsText: contentsText,
      pauthor: json['pauthor'] ?? '',
      authorName: json['author_name'] as String?,
      animalName: json['animal_name'] as String?,
      familyName: json['family_name'] as String?,
      paid: json['paid'] as int?,
      pfid: json['pfid'] as int?,
    );
  }
}
