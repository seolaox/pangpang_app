import 'package:go_router/go_router.dart';
import 'package:pangpang_app/ui/components/app_tabbar.dart';
import 'package:pangpang_app/ui/screen/food_view.dart';
import 'package:pangpang_app/ui/screen/home_view.dart';
import 'package:pangpang_app/ui/screen/profile_view.dart';

class AppRouter {
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AppTabbar(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeView(),
      ),
      GoRoute(
        path: '/food',
        builder: (context, state) => const FoodView(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
    ]
  );
}