import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pangpang_app/data/source/remote/auth/auth_api.dart';
import 'package:pangpang_app/presentation/provider/image_picker_provider.dart';

class HomeDetailView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedImages = ref.watch(selectedImagesProvider);

    Future<void> pickImages() async {
      final picker = ImagePicker();
      List<XFile>? picked = await picker.pickMultiImage();
      if (picked != null) {
        ref.read(selectedImagesProvider.notifier).addImages(picked);
      }
    }

    Future<void> uploadImages(WidgetRef ref) async {
      final images = ref.read(selectedImagesProvider);
      await AuthApi().uploadImages(images, 'your_imgtype');
      ref.read(selectedImagesProvider.notifier).clear();
      Navigator.pop(context);
    }

    return Scaffold(
      appBar: AppBar(title: Text('이미지 선택 및 업로드')),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton.icon(
                icon: Icon(Icons.photo_library),
                label: Text("앨범"),
                onPressed: pickImages,
              ),
            ],
          ),
          Expanded(
            child: MasonryGridView.count(
              crossAxisCount: 3,
              mainAxisSpacing: 3,
              crossAxisSpacing: 3,
              itemCount: selectedImages.length,
              itemBuilder: (context, idx) {
                final x = selectedImages[idx];
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(File(x.path), fit: BoxFit.cover),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: InkWell(
                        onTap: () {
                          ref
                              .read(selectedImagesProvider.notifier)
                              .removeAt(idx);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed:
                selectedImages.isEmpty
                    ? null
                    : () async {
                      for (final img in selectedImages) {
                        String ext = img.path.split('.').last.toLowerCase();
                        String imgtype =
                            (ext == 'jpg' || ext == 'jpeg')
                                ? 'jpeg'
                                : (ext == 'png')
                                ? 'png'
                                : 'etc';
                        await AuthApi().uploadImages([img], imgtype);
                      }

                      ref.read(selectedImagesProvider.notifier).clear();
                      Navigator.pop(context);
                    },
            child: Text('확인(업로드)'),
          ),
        ],
      ),
    );
  }
}
