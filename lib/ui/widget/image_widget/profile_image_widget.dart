import 'package:cached_network_image/cached_network_image.dart';
import 'package:pangpang_app/util/get_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 프로필 이미지 위젯
Widget profileImageWidget({
  required BuildContext context,
  double? height,
  double? width,
  double? size,
  required String? profileImg,
  required String category,
}) {
  final image = GetImages();
  return Padding(
    padding: EdgeInsets.all(5.0.r),
    child: Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(10.0.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.onPrimaryContainer.withOpacity(0.2),
            spreadRadius: 2.r,
            blurRadius: 5.r,
            offset: Offset(0.r, 3.r), // 그림자의 위치
          ),
        ],
      ),
      child:
          profileImg == '' || profileImg == null
              ? Icon(
                Icons.person,
                size: size,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              )
              : ClipRRect(
                borderRadius: BorderRadius.circular(5.0),
                child: CachedNetworkImage(
                  imageUrl: image.getImg(
                    category: category,
                    fileName: profileImg,
                  ),
                  width: width,
                  height: height,
                  fit: BoxFit.cover,
                  fadeInDuration: Duration.zero,
                  fadeOutDuration: Duration.zero,
                  placeholderFadeInDuration: Duration.zero,
                  errorWidget:
                      (context, url, error) =>
                          Icon(Icons.error, color: Colors.red, size: size),
                ),
              ),
    ),
  );
}
