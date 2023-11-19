import 'package:clone_war/06_custom_render_object/timestamp_chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:intl/intl.dart';

class CustomRenderObjectView extends HookWidget {
  const CustomRenderObjectView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textController = useTextEditingController();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            width: 300,
            color: theme.colorScheme.secondaryContainer,
            padding: const EdgeInsets.all(16),
            child: ListenableBuilder(
              listenable: textController,
              builder: (context, child) => TimestampedChatMessage(
                text: textController.text,
                sentAt: DateFormat.Hm().format(DateTime.now()),
                textStyle: theme.textTheme.bodyMedium!,
                sentAtTextStyle: theme.textTheme.bodyMedium!.copyWith(
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          TextField(
            controller: textController,
            decoration: const InputDecoration(
              hintText: 'Enter a message',
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }
}
