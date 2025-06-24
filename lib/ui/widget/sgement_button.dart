import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pangpang_app/data/model/segment_model.dart';
import 'package:pangpang_app/presentation/provider/segment_provider.dart';

class BasicSegmentedButton extends ConsumerWidget {
  const BasicSegmentedButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SegmentedButton<Settings>(
      segments: const <ButtonSegment<Settings>>[
        ButtonSegment<Settings>(
          value: Settings.all,
          label: Text('전체'),
          icon: Icon(Icons.all_inclusive),
        ),
        ButtonSegment<Settings>(
          value: Settings.snack,
          label: Text('간식'),
          icon: Icon(Icons.cookie),
        ),
        ButtonSegment<Settings>(
          value: Settings.supplement,
          label: Text('영양제'),
          icon: Icon(Icons.health_and_safety_sharp),
        ),
        ButtonSegment<Settings>(
          value: Settings.medicine,
          label: Text('약품'),
          icon: Icon(Icons.medication_outlined),
        ),
      ],
      selected: <Settings>{ref.watch(segmentProvider)},
      showSelectedIcon: false,
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.grey[200],
        selectedForegroundColor: Colors.white,
        selectedBackgroundColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      onSelectionChanged: (Set<Settings> newSelection) {
        ref.read(segmentProvider.notifier).changeSegment(newSelection.first);
      },
    );
  }
}
