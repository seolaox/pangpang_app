import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/presentation/vm/appbar_vm.dart';

final appBarProvider = NotifierProvider<AppBarVM, AppBarState>(AppBarVM.new);

final isWalkingProvider = NotifierProvider<IsWalkingVM, bool>(IsWalkingVM.new);