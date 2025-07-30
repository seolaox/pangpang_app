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
    // pcontents 의 text 필드를 꺼내기
    String contentsText = '';
    if (json['pcontents'] != null && json['pcontents']['text'] != null) {
      contentsText = json['pcontents']['text'];
    }
    
    return PostModel(
      pid: json['pid'],
      pname: json['pname'],
      pimages: List<String>.from(json['pimages'] ?? []),
      pthumbnail: json['pthumbnail'],
      pdate: DateTime.parse(json['pdate']),
      pcontentsText: contentsText,
      pauthor: json['pauthor'],
      authorName: json['author_name'],
      animalName: json['animal_name'],
      familyName: json['family_name'],
    );
  }
}
