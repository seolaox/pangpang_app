import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pangpang_app/app_router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  // Flutter 바인딩 초기화
  WidgetsFlutterBinding.ensureInitialized();

  // dotenv 로드
  await dotenv.load(fileName: ".env");

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
