import 'package:flutter/material.dart';
import 'package:pangpang_app/ui/widget/home_card.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return const HomeCard();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}