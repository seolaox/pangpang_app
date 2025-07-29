import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:pangpang_app/presentation/provider/image_picker_provider.dart';

class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final imageUrls = ref.watch(serverImagesProvider);

    final List<String> imgList = [
      'https://img.freepik.com/premium-photo/adorable-white-pomeranian-puppy-spitz_463999-7.jpg?semt=ais_hybrid&w=740',
      'https://health.chosun.com/site/data/img_dir/2025/04/08/2025040803041_0.jpg',
      'https://m.segye.com/content/image/2022/05/23/20220523519355.jpg',
      'https://images.mypetlife.co.kr/content/uploads/2022/12/16162807/IMG_1666-edited-scaled.jpg',
      'https://image.dongascience.com/Photo/2020/03/5bddba7b6574b95d37b6079c199d7101.jpg',
    ];

    return Scaffold(
      body:
          imgList.isEmpty
              ? Center(child: Text('이미지가 없습니다'))
              : Column(
                children: [
                  Expanded(
                    child: MasonryGridView.count(
                      crossAxisCount: 3,
                      mainAxisSpacing: 3,
                      crossAxisSpacing: 3,
                      itemCount: imgList.length,
                      itemBuilder: (context, index) {
                        return Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                imgList[index],
                                fit: BoxFit.cover,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await context.push('/home_detail');
          // await ref.read(serverImagesProvider.notifier).fetch(); // 
        },
        child: Icon(Icons.image),
      ),
    );
  }
}
