import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/presentation/vm/tabbar_vm.dart';

final tabProvider = NotifierProvider<TabbarVM, int>(
  TabbarVM.new
);
