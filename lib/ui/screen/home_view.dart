import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:pangpang_app/presentation/provider/post_provider.dart';
import 'package:pangpang_app/ui/screen/home_create_view.dart';

class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? baseUrl = dotenv.env['baseurl'];
    final postListAsync = ref.watch(postListProvider);

    return Scaffold(
      appBar: AppBar(title: Text('게시글 목록')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
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
              final thumbnailUrl = '$baseUrl/images/post/${post.pthumbnail}';
              final pimageUrls =
                  post.pimages
                      .map((img) => '$baseUrl/images/post/$img')
                      .toList();
              String dateStr;
              if (post.pdate is DateTime) {
                dateStr =
                    "${post.pdate.year}-${post.pdate.month.toString().padLeft(2, '0')}-${post.pdate.day.toString().padLeft(2, '0')}  ${post.pdate.hour.toString().padLeft(2, '0')}:${post.pdate.minute.toString().padLeft(2, '0')}";
              } else {
                dateStr = post.pdate.toString();
              }

              return GestureDetector(
                onTap: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HomeCreateView(post: post),
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
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 18,
                              color: const Color.fromARGB(255, 29, 29, 29),
                            ),
                            Text(
                              post.authorName ?? post.pauthor,
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
                        Divider(),
                        // 썸네일
                        if (post.pthumbnail.isNotEmpty)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              thumbnailUrl,
                              height: 140,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) =>
                                      Icon(Icons.broken_image, size: 60),
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
                                          padding: EdgeInsets.only(right: 6.0),
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
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Icon(
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
                        Text(
                          post.pname,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 4),
                        Text(
                          post.pcontentsText,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[800],
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 6),
                        
                      ],
                    ),
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
