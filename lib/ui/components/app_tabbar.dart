import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/presentation/provider/tabbar_provider.dart';
import 'package:pangpang_app/ui/components/app_appbar.dart';
import 'package:pangpang_app/ui/screen/food_view.dart';
import 'package:pangpang_app/ui/screen/home_view.dart';
import 'package:pangpang_app/ui/screen/profile_view.dart';
import 'package:pangpang_app/ui/screen/record_view.dart';
import 'package:pangpang_app/util/style/image_to_icon.dart';
import 'package:pangpang_app/util/theme/tabbar_theme.dart';

class AppTabbar extends ConsumerStatefulWidget {
  const AppTabbar({super.key});

  @override
  ConsumerState<AppTabbar> createState() => _AppTabbarState();
}

class _AppTabbarState extends ConsumerState<AppTabbar>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  // 탭 변경 완료를 추적하기 위한 Completer
  Completer? _tabChangeCompleter;

  @override
  void initState() {
    super.initState();
    // Provider의 현재 상태로 초기화
    _tabController = TabController(
      length: 4,
      vsync: this,
      initialIndex: ref.read(tabProvider),
    );

    // TabController의 변경을 Provider에 반영
    _tabController.addListener(() {
      if (ref.read(tabProvider) != _tabController.index) {
        ref.read(tabProvider.notifier).changeTab(_tabController.index);
      }
      // 탭 변경이 완료되면 Completer 완료
      if (!_tabController.indexIsChanging &&
          _tabChangeCompleter?.isCompleted == false) {
        _tabChangeCompleter?.complete();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(
      tabProvider,
    ); // 현재 탭 인덱스로 나중에 탭 변경 로직시 사용하면 됨

    // Provider 상태가 변경되면 TabController 업데이트
    if (_tabController.index != currentIndex) {
      _tabChangeCompleter = Completer();
      _tabController.animateTo(currentIndex);
    }

    return Scaffold(
      appBar: AppAppBar(),
      body: TabBarView(
        controller: _tabController,
        children: [const HomeView(), const FoodView(), const RecordView(), const ProfileView()],
      ),
      bottomNavigationBar: _buildTab(context),
    );
  }

  Container _buildTab(BuildContext context) {
    return Container(
      decoration: AppTabBarTheme.decoration,
      height: AppTabBarTheme.height,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTabBarTheme.selectedColor,
        onTap: (index) {
          ref.read(tabProvider.notifier).changeTab(index);
        },
        tabs: [
          Tab(icon: Icon(Icons.home, size: AppTabBarTheme.iconSize), text: '홈'),
          Tab(
            icon: imageToIcon(
              context,
              'assets/images/bone.png',
              AppTabBarTheme.iconSize,
              ref.read(tabProvider) == 1
                  ? Colors.blue
                  : Colors.black,
            ),
            text: '식사관리',
          ),
          Tab(
            icon: Icon(Icons.medical_information, size: AppTabBarTheme.iconSize),
            text: '건강기록',
          ),
          Tab(
            icon: Icon(Icons.pets, size: AppTabBarTheme.iconSize),
            text: '프로필',
          ),
        ],
      ),
    );
  }
}
