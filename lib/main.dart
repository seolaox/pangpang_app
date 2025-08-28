import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pangpang_app/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:pangpang_app/data/source/remote/dio_client.dart';


void main() async {


  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

    FlutterError.onError = (FlutterErrorDetails details) {
    debugPrint('Flutter 에러 발생: ${details.exception}');
    debugPrint('스택트레이스: ${details.stack}');
  };

  // dotenv 로드
  await dotenv.load(fileName: ".env");

  final baseUrl = dotenv.env['baseurl']!;

  DioClient().init(baseUrl: baseUrl);


    await FlutterNaverMap().init(
          clientId: 'pidwn5ggyx',
          onAuthFailed: (ex) {
            switch (ex) {
              case NQuotaExceededException(:final message):
                print("사용량 초과 (message: $message)");
                break;
              case NUnauthorizedClientException() ||
              NClientUnspecifiedException() ||
              NAnotherAuthFailedException():
                print("인증 실패: $ex");
                break;
            }
          });

  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(402, 874), // IPhone 16 Pro Size
      builder:
          (context, child) => MaterialApp.router(
            // Localization
            localizationsDelegates: const [
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [Locale('ko', '')],
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            theme: ThemeData(fontFamily: 'omyu-pretty'),
          ),
    );
  }
}
