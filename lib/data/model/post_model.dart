class PostModel {
  final int pid;
  final String pname;
  final List<String> pimages;
  final String pthumbnail;
  final DateTime pdate;
  final String pcontentsText;
  final String pauthor;
  final String? authorName;
  final String? animalName;
  final String? familyName;

  PostModel({
    required this.pid,
    required this.pname,
    required this.pimages,
    required this.pthumbnail,
    required this.pdate,
    required this.pcontentsText,
    required this.pauthor,
    this.authorName,
    this.animalName,
    this.familyName,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    String contentsText = '';
    if (json['pcontents'] != null) {
      if (json['pcontents'] is Map<String, dynamic> &&
          json['pcontents']['text'] != null) {
        contentsText = json['pcontents']['text'] as String;
      }
    }

    return PostModel(
      pid: json['pid'] ?? 0,
      pname: json['pname'] ?? '',
      pimages:
          json['pimages'] is List ? List<String>.from(json['pimages']) : [],
      pthumbnail: json['pthumbnail'] ?? '',
      pdate:
          json['pdate'] != null
              ? DateTime.parse(json['pdate'])
              : DateTime.now(),
      pcontentsText: contentsText,
      pauthor: json['pauthor'] ?? '',
      authorName: json['author_name'] as String?,
      animalName: json['animal_name'] as String?,
      familyName: json['family_name'] as String?,
    );
  }
}
