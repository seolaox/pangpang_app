import 'package:go_router/go_router.dart';
import 'package:pangpang_app/ui/components/app_tabbar.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppTabbar(),
      ),
    ]
  );
}