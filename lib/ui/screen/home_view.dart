import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/presentation/provider/post_provider.dart';

class HomeView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String? baseUrl = dotenv.env['baseurl'];
    // String imageBaseUrl = baseUrl!.replaceAll('/api', '');

    final postListAsync = ref.watch(postListProvider);

    return Scaffold(
      body: 
      postListAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러 발생: $err')),
        data: (posts) {
          if (posts.isEmpty) {
            return Center(child: Text('게시글이 없습니다.'));
          }
          return MasonryGridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            padding: EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              // 썸네일 URL 직접 조립
              final thumbnailUrl = '$baseUrl/images/post/${post.pthumbnail}';
              // 첨부 이미지들 URL 리스트
              final pimageUrls = (post.pimages as List)
                  .map<String>((img) => '$baseUrl/images/post/$img')
                  .toList();

              String dateStr;
              if (post.pdate is DateTime) {
                dateStr =
                    "${post.pdate.year}-${post.pdate.month.toString().padLeft(2, '0')}-${post.pdate.day.toString().padLeft(2, '0')}  ${post.pdate.hour.toString().padLeft(2, '0')}:${post.pdate.minute.toString().padLeft(2, '0')}";
              } else {
                dateStr = post.pdate.toString();
              }

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 썸네일
                      post.pthumbnail != null && post.pthumbnail.isNotEmpty
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                thumbnailUrl,
                                height:140,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) =>
                                    Icon(Icons.broken_image, size: 60),
                              ),
                            )
                          : SizedBox(),
                      SizedBox(height: 8),
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
                        style: TextStyle(fontSize: 14, color: Colors.grey[800]),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.person, size: 15, color: Colors.grey[600]),
                          SizedBox(width: 3),
                          Text(
                            '${post.authorName ?? post.pauthor}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.calendar_today,
                            size: 13,
                            color: Colors.grey[600],
                          ),
                          SizedBox(width: 3),
                          Text(
                            dateStr,
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      if (post.familyName != null)
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            '가족: ${post.familyName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                      if (post.animalName != null)
                        Padding(
                          padding: EdgeInsets.only(top: 2),
                          child: Text(
                            '동물: ${post.animalName}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[700],
                            ),
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
