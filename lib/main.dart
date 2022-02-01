import 'package:chat_apps/app.dart';
import 'package:chat_apps/screen/screens.dart';
import 'package:chat_apps/screen/select_user_screen.dart';
import 'package:chat_apps/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

void main() {
  final client = StreamChatClient(streamKey);
  runApp(
    MyApp(
      client: client,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({required this.client, Key? key}) : super(key: key);

  final StreamChatClient client;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      title: 'Chatter',
      builder: (context, child) {
        return StreamChatCore(
          client: client,
          child: ChannelsBloc(child: UsersBloc(child: child!)),
        );
      },
      home: const SelectUserScreen(),
    );
  }
}
