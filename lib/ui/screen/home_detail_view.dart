import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/presentation/provider/post_provider.dart';

class HomeDetailView extends ConsumerStatefulWidget {
  final PostModel? post;
  final List<String>? initialImages;
  final String? initialThumbnail;
  HomeDetailView({this.post, this.initialImages, this.initialThumbnail});

  @override
  ConsumerState<HomeDetailView> createState() => _HomeCreateViewState();
}

class _HomeCreateViewState extends ConsumerState<HomeDetailView> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.post?.pname ?? '');
    _bodyCtrl = TextEditingController(text: widget.post?.pcontentsText ?? '');

    if (widget.initialImages != null && widget.initialImages!.isNotEmpty) {
      Future.microtask(() {
        ref
            .read(imageListProvider.notifier)
            .setImages(widget.initialImages!.cast<dynamic>());

        if (widget.post != null) {
          ref.read(thumbnailIndexProvider.notifier).state =
              widget.post!.pthumbnailIndex;
        } else if (widget.initialThumbnail != null) {
          final idx = widget.initialImages!.indexOf(widget.initialThumbnail!);
          ref.read(thumbnailIndexProvider.notifier).state = idx == -1 ? 0 : idx;
        }
      });
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked == null || picked.isEmpty) return;
    for (final xfile in picked.take(5)) {
      ref.read(imageListProvider.notifier).addImage(File(xfile.path));
    }
    ref.read(thumbnailIndexProvider.notifier).state = 0;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // 이미지 배열 준비 (순서 상관없음. 내가 보낸 배열 그 순서대로 서버가 저장)
    List<dynamic> images = ref.read(imageListProvider);
    int thumbnailIdx = ref.read(thumbnailIndexProvider);

    if (images.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('최소 1개의 이미지를 선택해주세요')));
      return;
    }

    // 이미지("images" 필드) MultipartFile 배열 준비
    List<MultipartFile> multipartFiles = [];
    for (var img in images) {
      if (img is File) {
        final fileName = img.path.split(Platform.pathSeparator).last;
        multipartFiles.add(
          await MultipartFile.fromFile(img.path, filename: fileName),
        );
      }
      // 서버에 있는 기존 이미지는 String(URL)일 수 있으니 복원 필요시 따로 처리
    }

    print('썸네일 인덱스: $thumbnailIdx');
    print('총 이미지 수: ${images.length}');
    print('multipartFiles 수: ${multipartFiles.length}');

    final data = FormData();
    data.fields.add(MapEntry("pname", _titleCtrl.text));
    data.fields.add(MapEntry("pdate", DateTime.now().toIso8601String()));
    data.fields.add(
      MapEntry("pcontents", jsonEncode({"text": _bodyCtrl.text})),
    );
    data.fields.add(MapEntry("pauthor", widget.post?.pauthor ?? "me"));

    // 이미지 추가
    for (final file in multipartFiles) {
      data.files.add(MapEntry("images", file));
    }

    data.fields.add(MapEntry("thumbnail_index", thumbnailIdx.toString()));

    // // 모든 이미지를 images 필드로 전송
    // for (int i = 0; i < multipartFiles.length; i++) {
    //   data.files.add(MapEntry("images", multipartFiles[i]));
    // }

    try {
      final api = ref.read(authApiProvider);
      if (widget.post == null) {
        await api.createPostFormData(data);
      } else {
        await api.updatePostFormData(widget.post!.pid, data);
      }
      if (mounted) Navigator.pop(context, true);
      ref.invalidate(postListProvider);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(imageListProvider);
    final thumbnailIdx = ref.watch(thumbnailIndexProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post == null ? '게시글 작성' : '게시글 수정'),
        actions: [
          TextButton(
            onPressed: _submit,
            child: Text(
              widget.post == null ? '등록' : '수정',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(right: 20, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: _pickImages, // 원하는 함수 연결
              icon: Icon(Icons.add_photo_alternate), // 아이콘 지정
              label: Text('사진추가', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)), // 버튼 텍스트
              style: ElevatedButton.styleFrom(
                // minimumSize: Size(double.infinity, 52), 
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(height: 5,),
            // 메인 썸네일 표시 영역
            Container(
              width: double.infinity,
              height: 350,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!),
              ),
              child:
                  images.isEmpty
                      ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate,
                            size: 50,
                            color: Colors.grey[600],
                          ),
                          SizedBox(height: 8),
                          Text(
                            '이미지 선택',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      )
                      : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child:
                                images[thumbnailIdx] is File
                                    ? Image.file(
                                      images[thumbnailIdx] as File,
                                      width: double.infinity,
                                      height: 350,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.network(
                                      images[thumbnailIdx] as String,
                                      width: double.infinity,
                                      height: 350,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stack) => Container(
                                            color: Colors.grey[300],
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 50,
                                            ),
                                          ),
                                    ),
                          ),
                          // 썸네일 표시 라벨
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    '썸네일',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // 이미지 추가 버튼
                          // Positioned(
                          //   left: 10,
                          //   top: 10,
                          //   child: GestureDetector(
                          //     onTap: _pickImages,
                          //     child: Container(
                          //       padding: EdgeInsets.all(8),
                          //       decoration: BoxDecoration(
                          //         color: Colors.black54,
                          //         borderRadius: BorderRadius.circular(20),
                          //       ),
                          //       child: Icon(
                          //         Icons.add_photo_alternate,
                          //         color: Colors.white,
                          //         size: 20,
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
            ),
            SizedBox(height: 16),

            // 이미지 선택 및 썸네일 설정 영역
            if (images.isNotEmpty) ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 20,
                          color: Colors.grey[600],
                        ),
                        SizedBox(width: 8),
                        Text(
                          '이미지 목록 (탭하여 썸네일 변경)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(
                          images.length,
                          (idx) => GestureDetector(
                            onTap: () {
                              ref.read(thumbnailIndexProvider.notifier).state =
                                  idx;
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('썸네일이 변경되었습니다'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color:
                                      idx == thumbnailIdx
                                          ? Colors.amber
                                          : Colors.grey[400]!,
                                  width: idx == thumbnailIdx ? 3 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(6),
                                    child:
                                        images[idx] is File
                                            ? Image.file(
                                              images[idx] as File,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                            )
                                            : Image.network(
                                              images[idx] as String,
                                              width: 70,
                                              height: 70,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stack) =>
                                                      Container(
                                                        width: 70,
                                                        height: 70,
                                                        color: Colors.grey[300],
                                                        child: Icon(
                                                          Icons.broken_image,
                                                          size: 30,
                                                        ),
                                                      ),
                                            ),
                                  ),
                                  // 썸네일 표시 아이콘
                                  if (idx == thumbnailIdx)
                                    Positioned(
                                      bottom: 2,
                                      right: 2,
                                      child: Container(
                                        padding: EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          color: Colors.amber,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.star,
                                          color: Colors.white,
                                          size: 12,
                                        ),
                                      ),
                                    ),
                                  // 삭제 버튼
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: GestureDetector(
                                      onTap: () {
                                        final imageListNotifier = ref.read(
                                          imageListProvider.notifier,
                                        );
                                        imageListNotifier.removeImage(idx);

                                        final currentImages = ref.read(
                                          imageListProvider,
                                        );
                                        final tIdx = ref.read(
                                          thumbnailIndexProvider,
                                        );

                                        int newThumbIdx = tIdx;

                                        if (currentImages.isEmpty) {
                                          newThumbIdx = 0;
                                        } else if (idx == tIdx) {
                                          if (tIdx >= currentImages.length) {
                                            newThumbIdx =
                                                currentImages.length - 1;
                                          } else {
                                            newThumbIdx = tIdx;
                                          }
                                        } else if (idx < tIdx) {
                                          newThumbIdx = tIdx - 1;
                                        }

                                        ref
                                            .read(
                                              thumbnailIndexProvider.notifier,
                                            )
                                            .state = newThumbIdx;
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],

            // 제목 및 내용 입력 폼
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: '제목',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator:
                        (v) => (v == null || v.isEmpty) ? '제목을 입력하세요' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _bodyCtrl,
                    decoration: InputDecoration(
                      labelText: '내용',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignLabelWithHint: true,
                    ),
                    minLines: 5,
                    maxLines: 8,
                    validator:
                        (v) => (v == null || v.isEmpty) ? '내용을 입력하세요' : null,
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // 저장 버튼
            ElevatedButton(
              onPressed: _submit,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(widget.post == null ? Icons.add : Icons.edit),
                  SizedBox(width: 8),
                  Text(
                    widget.post == null ? '게시글 등록' : '게시글 수정',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
