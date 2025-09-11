import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:go_router/go_router.dart';
import 'package:pangpang_app/presentation/provider/post_provider.dart';
import 'package:pangpang_app/presentation/vm/post_vm.dart';
import 'package:pangpang_app/ui/screen/post_detail_view.dart';
import 'package:pangpang_app/util/get_images.dart';
import 'package:skeletons/skeletons.dart';

class PostView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postListAsync = ref.watch(postListProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          ref.read(thumbnailIndexProvider.notifier).state = 0;
          ref.read(imageListProvider.notifier).clear();
          GoRouter.of(context).push('/post_detail');
          ref.invalidate(postListProvider);
        },
      ),
      body: postListAsync.when(
        loading: () => _buildSkeletonLoading(context),
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

              final allImageUrls =
                  post.pimages
                      .map<String>(
                        (img) =>
                            getImages.getImg(category: 'post', fileName: img),
                      )
                      .toList();

              final otherImageUrls =
                  allImageUrls
                      .where((imgUrl) => imgUrl != thumbnailUrl)
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
                  await context.push(
                    '/post_detail',
                    extra: {
                      'post': post,
                      'initialImages': allImageUrls,
                      'initialThumbnail': thumbnailUrl,
                    },
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
                    final postCrud = ref.read(postCrudProvider.notifier);
                    await postCrud.deletePost(post.pid);
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
                      if (otherImageUrls.isNotEmpty) ...[
                        SizedBox(height: 4),
                        SizedBox(
                          height: 40,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children:
                                otherImageUrls
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

  Widget _buildSkeletonLoading(BuildContext context) {
    final List<double> skeletonHeights = [
      200,
      280,
      220,
      300,
      180,
      250,
      190,
      320,
      240,
      210,
    ];

    return MasonryGridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      padding: EdgeInsets.all(12),
      itemCount: 3,
      itemBuilder: (context, index) {
        final height = skeletonHeights[index % skeletonHeights.length];

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            height: height,
            padding: EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 썸네일 이미지
                Expanded(
                  flex: 3,
                  child: SkeletonAvatar(
                    style: SkeletonAvatarStyle(
                      width: double.infinity,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: List.generate(
                    3,
                    (i) => Padding(
                      padding: EdgeInsets.only(right: 4),
                      child: SkeletonAvatar(
                        style: SkeletonAvatarStyle(
                          width: 30,
                          height: 30,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8),
                // 제목
                SkeletonLine(
                  style: SkeletonLineStyle(
                    height: 16,
                    width: double.infinity,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 4),
                // 내용
                SkeletonParagraph(
                  style: SkeletonParagraphStyle(
                    lines: 2 + (index % 2),
                    spacing: 4,
                    lineStyle: SkeletonLineStyle(
                      height: 12,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
                Spacer(),
                // 하단 작성자/날짜
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 12,
                        width: 80,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    SkeletonLine(
                      style: SkeletonLineStyle(
                        height: 12,
                        width: 50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
