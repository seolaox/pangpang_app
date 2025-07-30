import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pangpang_app/data/model/post_model.dart';
import 'package:pangpang_app/presentation/provider/post_provider.dart';

// HomeCreateView Stateful & Riverpod
class HomeCreateView extends ConsumerStatefulWidget {
  final PostModel? post;
  HomeCreateView({this.post});

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

  @override
  Widget build(BuildContext context) {
    final images = ref.watch(imageListProvider);
    final thumbnailIdx = ref.watch(thumbnailIndexProvider);

    return Scaffold(
      appBar: AppBar(title: Text('게시글 작성/수정')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            // 썸네일(= 대표 이미지) 클릭이 곧 이미지 선택
            GestureDetector(
              onTap: () => _pickImages(),
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[400]!),
                ),
                child:
                    images.isEmpty
                        ? Center(
                          child: Text(
                            '이미지 선택',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                images[thumbnailIdx],
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
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
            // 하단 5개 row 형태(썸네일 포함)
            if (images.isNotEmpty)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (idx) => GestureDetector(
                    onTap: () {
                      ref.read(thumbnailIndexProvider.notifier).state = idx;
                      // ref.read(imageListProvider.notifier).moveToThumbnail(idx);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              idx == thumbnailIdx
                                  ? Colors.amber
                                  : Colors.transparent,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Stack(
                        children: [
                          Image.file(
                            images[idx],
                            width: 55,
                            height: 55,
                            fit: BoxFit.cover,
                          ),
                          Positioned(
                            right: 0,
                            top: 0,
                            child: GestureDetector(
                              onTap: () {
                                ref
                                    .read(imageListProvider.notifier)
                                    .removeImage(idx);
                                // 삭제 이후, 인덱스 보정!
                                final currentImages = ref.read(
                                  imageListProvider,
                                );
                                final tIdx = ref.read(thumbnailIndexProvider);
                                if (tIdx >= currentImages.length) {
                                  ref
                                      .read(thumbnailIndexProvider.notifier)
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
            SizedBox(height: 22),

            // 게시글 입력 폼 (제목/내용)
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
            // 등록(수정) 버튼
            ElevatedButton(
              onPressed: () {
                // TODO: 서버 업로드 로직 작성
                // 썸네일: images[0], 첨부: images, 제목/내용: 입력값
              },
              child: Text('등록'),
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
