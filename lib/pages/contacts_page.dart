import 'package:chat_apps/screen/chat_screen.dart';
import 'package:chat_apps/widget/avatar.dart';
import 'package:chat_apps/widget/display_error_massege.dart';
import 'package:flutter/material.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:chat_apps/app.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return UserListCore(
      limit: 20,
      filter: Filter.notEqual('id', context.currentUser!.id),
      emptyBuilder: (context) {
        return const Center(
          child: Text('Disini tidak ada user'),
        );
      },
      loadingBuilder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error) {
        return DisplayErrorMassage(
          error: error,
        );
      },
      listBuilder: (context, item) {
        return Scrollbar(
          child: ListView.builder(
            itemCount: item.length,
            itemBuilder: (context, index) {
              return item[index].when(
                  headerItem: (_) => const SizedBox.shrink(),
                  userItem: (user) => _ContactTile(user: user));
            },
          ),
        );
      },
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({required this.user, Key? key}) : super(key: key);

  final User user;

  Future<void> createChannel(BuildContext context) async {
    final core = StreamChatCore.of(context);
    final channel = core.client.channel('messaging', extraData: {
      'members': [
        core.currentUser!.id,
        user.id,
       ]
    });
    await channel.watch();
    Navigator.of(context).push(ChatScreen.routeWithChannel(channel));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        createChannel(context);
      },
      child: ListTile(
        leading: Avatar.small(
          url: user.image,
        ),
        title: Text(user.name),
      ),
    );
  }
}
