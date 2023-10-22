import 'package:clone_war/05_spring_card/spring_card.dart';
import 'package:flutter/material.dart';

class SpringCardView extends StatelessWidget {
  const SpringCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: SpringCard(),
      ),
    );
  }
}