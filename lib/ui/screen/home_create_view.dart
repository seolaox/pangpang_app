import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/presentation/provider/post_provider.dart';

class HomeCreateView extends ConsumerStatefulWidget {
  final PostModel? post;
  final List<dynamic>? initialImages;
  final String? initialThumbnail;
  HomeCreateView({this.post, this.initialImages, this.initialThumbnail});

  @override
  ConsumerState<HomeCreateView> createState() => _HomeCreateViewState();
}

class _HomeCreateViewState extends ConsumerState<HomeCreateView> {
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
        ref.read(imageListProvider.notifier).setImages(widget.initialImages!);
        if (widget.initialThumbnail != null) {
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
    if (picked == null) return;
    ref.read(imageListProvider.notifier).clear();
    for (final xfile in picked.take(5)) {
      ref.read(imageListProvider.notifier).addImage(File(xfile.path));
    }
    ref.read(thumbnailIndexProvider.notifier).state = 0;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final images = ref.read(imageListProvider);
    final thumbnailIdx = ref.read(thumbnailIndexProvider);

    List<MultipartFile> multipartFiles = [];
    for (var img in images) {
      if (img is File) {
        final fileName = img.path.split(Platform.pathSeparator).last;
        multipartFiles.add(await MultipartFile.fromFile(img.path, filename: fileName));
      }
    }

    MultipartFile? thumbnailFile;
    if (images.isNotEmpty && images[thumbnailIdx] is File) {
      final file = images[thumbnailIdx] as File;
      final fileName = file.path.split(Platform.pathSeparator).last;
      thumbnailFile = await MultipartFile.fromFile(file.path, filename: fileName);
    } else {
      thumbnailFile = null;
    }

    print("pname: ${_titleCtrl.text} ");
    print("pimages: ${multipartFiles} ");
    print("pthumbnail: ${thumbnailFile} ");
    print("pdate: ${DateTime.now().toIso8601String()} ");
    print("pcontents: ${ _bodyCtrl.text} ");
    print("pauthor: ${widget.post?.pauthor} ");


    final data = FormData.fromMap({
      "pname": _titleCtrl.text,
      "pimages": multipartFiles,
      "pthumbnail": thumbnailFile,
      "pdate": DateTime.now().toIso8601String(),
      "pcontents": jsonEncode({"text": _bodyCtrl.text}),
      "pauthor": widget.post?.pauthor ?? "me",
    });

    print("최종 전송 데이터(FormData): $data");

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
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('저장 실패: $e')));
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(imageListProvider);
    final thumbnailIdx = ref.watch(thumbnailIndexProvider);

    return Scaffold(
      appBar: AppBar(title: Text(widget.post == null ? '게시글 작성' : '게시글 수정')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child: images.isEmpty
                    ? Center(child: Text('이미지 선택'))
                    : Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: images[thumbnailIdx] is File
                                ? Image.file(
                                    images[thumbnailIdx] as File,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    images[thumbnailIdx] as String,
                                    width: double.infinity,
                                    height: 200,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        Icon(Icons.broken_image),
                                  ),
                          ),
                          Positioned(
                            right: 10,
                            top: 10,
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black38,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '썸네일',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
            SizedBox(height: 13),
            if (images.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    images.length,
                    (idx) => GestureDetector(
                      onTap: () {
                        ref.read(thumbnailIndexProvider.notifier).state = idx;
                      },
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: idx == thumbnailIdx
                                ? Colors.amber
                                : Colors.transparent,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            images[idx] is File
                                ? Image.file(
                                    images[idx] as File,
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.cover,
                                  )
                                : Image.network(
                                    images[idx] as String,
                                    width: 55,
                                    height: 55,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stack) =>
                                        Icon(Icons.broken_image, size: 28),
                                  ),
                            Positioned(
                              right: 0,
                              top: 0,
                              child: GestureDetector(
                                onTap: () {
                                  ref
                                      .read(imageListProvider.notifier)
                                      .removeImage(idx);
                                  final currentImages =
                                      ref.read(imageListProvider);
                                  final tIdx =
                                      ref.read(thumbnailIndexProvider);
                                  if (tIdx >= currentImages.length) {
                                    ref
                                        .read(
                                            thumbnailIndexProvider.notifier)
                                        .state = currentImages.isEmpty
                                            ? 0
                                            : currentImages.length - 1;
                                  }
                                },
                                child: CircleAvatar(
                                  radius: 11,
                                  backgroundColor: Colors.red,
                                  child: Icon(
                                    Icons.close,
                                    size: 15,
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
            SizedBox(height: 22),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _titleCtrl,
                    decoration: InputDecoration(
                      labelText: '제목',
                      border: OutlineInputBorder(),
                    ),
                    validator:
                        (v) => (v == null || v.isEmpty) ? '제목을 입력하세요' : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _bodyCtrl,
                    decoration: InputDecoration(
                      labelText: '내용',
                      border: OutlineInputBorder(),
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
            ElevatedButton(
              onPressed: _submit,
              child: Text(widget.post == null ? '등록' : '수정'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }
}