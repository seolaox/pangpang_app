import 'package:flutter/material.dart';
import 'package:pangpang_app/ui/components/app_appbar.dart';

class HomeDetailView extends StatelessWidget {
  const HomeDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppAppBar(),
      body: Center(
        child: Text('Home Detail'),
      ),
    );
  }
}