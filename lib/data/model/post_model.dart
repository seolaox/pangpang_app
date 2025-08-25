class PostModel {
  final String pid;
  final String pname;
  final List<String> pimages;
  final String pthumbnail;
  final DateTime pdate;
  final String pcontentsText;
  final Map<String, dynamic>? pcontents;
  final String pauthor;
  final String? authorName;
  final String? animalName;
  final String? familyName;
  final String? paid; 
  final String? pfid;

  final int mediaCount;
  final bool hasVideo;
  final String? representativeMedia;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<PostMedia>? media;

  PostModel({
    required this.pid,
    required this.pname,
    required this.pimages,
    required this.pthumbnail,
    required this.pdate,
    required this.pcontentsText,
    this.pcontents,
    required this.pauthor,
    this.authorName,
    this.animalName,
    this.familyName,
    this.paid,
    this.pfid,
    this.mediaCount = 0,
    this.hasVideo = false,
    this.representativeMedia,
    this.createdAt,
    this.updatedAt,
    this.media,
  });

  // pthumbnailIndex는 이제 pthumbnail 파일명을 기반으로 계산
  int get pthumbnailIndex {
    if (pthumbnail.isNotEmpty && pimages.isNotEmpty) {
      final index = pimages.indexOf(pthumbnail);
      return index >= 0 ? index : 0;
    }
    return 0;
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    String contentsText = '';
    Map<String, dynamic>? contentsMap;
    
    if (json['pcontents'] != null) {
      if (json['pcontents'] is Map<String, dynamic>) {
        contentsMap = json['pcontents'] as Map<String, dynamic>;
        if (contentsMap['text'] != null) {
          contentsText = contentsMap['text'] as String;
        }
      }
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
      pthumbnail: json['pthumbnail']?.toString() ?? '',
      pdate: json['pdate'] != null
          ? DateTime.parse(json['pdate'])
          : DateTime.now(),
      pcontentsText: contentsText,
      pcontents: contentsMap,
      pauthor: json['pauthor'] ?? '',
      authorName: json['author_name'] as String?,
      animalName: json['animal_name'] as String?,
      familyName: json['family_name'] as String?,
      paid: json['paid'] as String?,
      pfid: json['pfid'] as String?,
      mediaCount: json['media_count'] as int? ?? 0,
      hasVideo: json['has_video'] as bool? ?? false,
      representativeMedia: json['representative_media'] as String?,
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : null,
      updatedAt: json['updated_at'] != null 
          ? DateTime.parse(json['updated_at']) 
          : null,
      media: (json['media'] as List<dynamic>?)
          ?.map((mediaJson) => PostMedia.fromJson(mediaJson as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pid': pid,
      'pname': pname,
      'pimages': pimages,
      'pthumbnail': pthumbnail,
      'pdate': pdate.toIso8601String(),
      'pcontents': pcontents,
      'pauthor': pauthor,
      'author_name': authorName,
      'animal_name': animalName,
      'family_name': familyName,
      'paid': paid,
      'pfid': pfid,
      'media_count': mediaCount,
      'has_video': hasVideo,
      'representative_media': representativeMedia,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'media': media?.map((media) => media.toJson()).toList(),
    };
  }
}

// PostMedia 클래스는 이미 정의되어 있으므로 그대로 사용
enum PostMediaType { IMAGE, VIDEO }

class PostMedia {
  final PostMediaType mediaType;
  final String? fileName;
  final String? originalName;
  final int? fileSize;
  final String? filePath;
  final String? thumbnailPath;
  final int? duration;
  final int sortOrder;
  final String? hlsPlaylistPath;
  final int? hlsSegmentCount;
  final int? hlsSegmentDuration;
  final bool hlsEnabled;

  PostMedia({
    required this.mediaType,
    this.fileName,
    this.originalName,
    this.fileSize,
    this.filePath,
    this.thumbnailPath,
    this.duration,
    this.sortOrder = 0,
    this.hlsPlaylistPath,
    this.hlsSegmentCount,
    this.hlsSegmentDuration,
    this.hlsEnabled = false,
  });

  factory PostMedia.fromJson(Map<String, dynamic> json) {
    return PostMedia(
      mediaType: PostMediaType.values.firstWhere(
        (e) => e.toString().split('.').last == json['media_type'],
        orElse: () => PostMediaType.IMAGE,
      ),
      fileName: json['file_name'] as String?,
      originalName: json['original_name'] as String?,
      fileSize: json['file_size'] as int?,
      filePath: json['file_path'] as String?,
      thumbnailPath: json['thumbnail_path'] as String?,
      duration: json['duration'] as int?,
      sortOrder: json['sort_order'] as int? ?? 0,
      hlsPlaylistPath: json['hls_playlist_path'] as String?,
      hlsSegmentCount: json['hls_segment_count'] as int?,
      hlsSegmentDuration: json['hls_segment_duration'] as int?,
      hlsEnabled: json['hls_enabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'media_type': mediaType.toString().split('.').last,
      'file_name': fileName,
      'original_name': originalName,
      'file_size': fileSize,
      'file_path': filePath,
      'thumbnail_path': thumbnailPath,
      'duration': duration,
      'sort_order': sortOrder,
      'hls_playlist_path': hlsPlaylistPath,
      'hls_segment_count': hlsSegmentCount,
      'hls_segment_duration': hlsSegmentDuration,
      'hls_enabled': hlsEnabled,
    };
  }
}