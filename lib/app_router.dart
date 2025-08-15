import 'package:go_router/go_router.dart';
import 'package:pangpang_app/data/model/user/user_model.dart';
import 'package:pangpang_app/ui/components/app_tabbar.dart';
import 'package:pangpang_app/ui/screen/food_view.dart';
import 'package:pangpang_app/ui/screen/home_detail_view.dart';
import 'package:pangpang_app/ui/screen/home_view.dart';
import 'package:pangpang_app/ui/screen/login_view.dart';
import 'package:pangpang_app/ui/screen/profile_view.dart';
import 'package:pangpang_app/ui/screen/splash_view.dart';
import 'package:pangpang_app/ui/screen/user_view.dart';

class AppRouter {
  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (context, state) => const SplashView()),
      GoRoute(path: '/login', builder: (context, state) => const LoginView()),
      // GoRoute(
      //   path: '/',
      //   builder: (context, state) => const LoginView(),
      // ),
      GoRoute(
        path: '/first_view',
        builder: (context, state) => const AppTabbar(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) =>  HomeView(),
      ),
      GoRoute(
        path: '/food',
        builder: (context, state) => const FoodView(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: '/home_detail',
        builder: (context, state) =>  HomeDetailView(),
      ),
      GoRoute(
        path: '/user',
        builder: (context, state) => UserView(),
      ),
    ]
  );
}