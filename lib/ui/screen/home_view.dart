import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pangpang_app/presentation/provider/post_provider.dart';
import 'package:pangpang_app/ui/screen/home_create_view.dart';
import 'package:pangpang_app/util/get_images.dart';

class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? baseUrl = dotenv.env['baseurl'];
    if (baseUrl != null && !baseUrl.endsWith('/')) {
      baseUrl = '$baseUrl/';
    }

    final postListAsync = ref.watch(postListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          ref.read(thumbnailIndexProvider.notifier).state = 0; // 썸네일 인덱스 초기화
          ref.read(imageListProvider.notifier).clear();
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => HomeCreateView()),
          );
          ref.invalidate(postListProvider);
        },
      ),
      body: postListAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러 발생: $err')),
        data: (posts) {
          if (posts.isEmpty) return Center(child: Text('게시글이 없습니다.'));

          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            padding: EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              final getImages = GetImages();
              final thumbnailUrl = getImages.getImg(
                category: 'post',
                fileName: post.pthumbnail,
              );
              final pimageUrls =
                  post.pimages
                      .map(
                        (img) =>
                            getImages.getImg(category: 'post', fileName: img),
                      )
                      .toList();
              String dateStr;
              if (post.pdate is DateTime) {
                dateStr =
                    "${post.pdate.month.toString().padLeft(2, '0')}/${post.pdate.day.toString().padLeft(2, '0')}  ${post.pdate.hour.toString().padLeft(2, '0')}:${post.pdate.minute.toString().padLeft(2, '0')}";
              } else {
                dateStr = post.pdate.toString();
              }

              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => HomeCreateView(
                            post: post,
                            initialImages: pimageUrls,
                            initialThumbnail: thumbnailUrl,
                          ),
                    ),
                  );
                  ref.invalidate(postListProvider);
                },
                onDoubleTap: () async {
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder:
                        (_) => AlertDialog(
                          title: Text('삭제 확인'),
                          content: Text('이 글을 삭제할까요?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: Text('삭제'),
                            ),
                          ],
                        ),
                  );

                  if (confirmed == true) {
                    final authApi = ref.read(authApiProvider);
                    await authApi.deletePost(post.pid);
                    ref.invalidate(postListProvider);
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (post.pthumbnail.isNotEmpty)
                        ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 230),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              thumbnailUrl,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: 60),
                            ),
                          ),
                        ),

                      if (post.pimages.isNotEmpty) ...[
                        SizedBox(height: 4),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children:
                                pimageUrls
                                    .map(
                                      (imgUrl) => Padding(
                                        padding: EdgeInsets.only(left: 6),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                          child: Image.network(
                                            imgUrl,
                                            width: 40,
                                            height: 40,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) =>
                                                    Icon(
                                                      Icons.broken_image,
                                                      size: 24,
                                                    ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                          ),
                        ),
                      ],
                      Divider(),
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          post.pname,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 4),
                      Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          post.pcontentsText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(height: 6),
                      Padding(
                        padding: const EdgeInsets.only(left: 6, right: 6),
                        child: Row(
                          children: [
                            // Icon(
                            //   Icons.person,
                            //   size: 18,
                            //   color: const Color.fromARGB(255, 29, 29, 29),
                            // ),
                            Text(
                              'by ${post.authorName ?? post.pauthor}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            Spacer(),
                            Text(
                              dateStr,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
