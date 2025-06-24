import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/data/model/segment_model.dart';
import 'package:pangpang_app/presentation/vm/segment_vm.dart';

final segmentProvider = NotifierProvider<SegmentVM, Settings>(
  SegmentVM.new
);