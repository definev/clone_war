import 'package:clone_war/utils/challenge_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clone War'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          final data = challengeData[index];

          return ListTile(
            title: Text('${data.id} - ${data.title}'),
            subtitle: Text(data.description),
            onTap: () => GoRouter.of(context).push('/challenge/${data.id}'),
          );
        },
        itemCount: challengeData.length,
      ),
    );
  }
}
