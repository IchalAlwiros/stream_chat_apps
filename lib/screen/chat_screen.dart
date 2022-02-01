import 'dart:async';

import 'package:chat_apps/models/message_data.dart';
import 'package:chat_apps/pages/helpers.dart';
import 'package:chat_apps/theme/theme.dart';
import 'package:chat_apps/widget/display_error_massege.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:chat_apps/widget/glowing_action_button.dart';
import 'package:chat_apps/widget/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:chat_apps/app.dart';

class ChatScreen extends StatefulWidget {
  static Route routeWithChannel(Channel channel) {
    return MaterialPageRoute(
      builder: (context) => StreamChannel(
        channel: channel,
        child: const ChatScreen(),
      ),
    );
  }

  const ChatScreen({
    Key? key,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late StreamSubscription<int> unreadCountSubscription;

  @override
  void initState() {
    super.initState();

   unreadCountSubscription = StreamChannel.of(context)
        .channel
        .state!
        .unreadCountStream
        .listen(_unreadCountHandler);
  }

  Future<void> _unreadCountHandler (int count) async {
    if (count >0){
      await StreamChannel.of(context).channel.markRead();
    }
  }

  @override
  void dispose(){
    unreadCountSubscription.cancel();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconBackground(
            icon: CupertinoIcons.back,
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        title: const _AppBarTitle(),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Center(
              child: IconBorder(
                icon: CupertinoIcons.video_camera_solid,
                onTap: () {},
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: IconBorder(
                icon: CupertinoIcons.phone_solid,
                onTap: () {},
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: //_DemoMassageList(),
                MessageListCore(
              loadingBuilder: (context) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              emptyBuilder: (context) => const SizedBox.shrink(),
              messageListBuilder: (context, messages) =>
                  _MessageList(messages: messages),
              errorBuilder: (context, error) => DisplayErrorMassage(
                error: error,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: _ActionBar(),
          )
        ],
      ),
    );
  }
}

class _MessageList extends StatelessWidget {
  const _MessageList({required this.messages, Key? key}) : super(key: key);
  final List<Message> messages;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView.separated(
        itemCount: messages.length +1,
        reverse: true,
        separatorBuilder: (context, index) {
          if (index == messages.length - 1) {
            return _DateLable(dataTime: messages[index].createdAt);
          } else if (index <= messages.length) {
            final message = messages[index];
            final nextMessage = messages[index + 1];
            if (!Jiffy(message.createdAt.toLocal())
                .isSame(nextMessage.createdAt.toLocal(), Units.DAY)) {
              return _DateLable(dataTime: message.createdAt);
            } else {
              return const SizedBox.shrink();
            }
          } else {
            return const SizedBox.shrink();
          }
        },
        itemBuilder: (context, index) {
          if (index < messages.length) {
            final message = messages[index];
            if (message.user?.id == context.currentUser?.id) {
              return _MessageOwnTile(message: message);
            } else {
              return _MessageTile(message: message);
            }
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
    );
  }
}

class _AppBarTitle extends StatelessWidget {
  const _AppBarTitle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    return Row(
      children: [
        Avatar.small(
          url: Helpers.getChannelImage(channel, context.currentUser!),
        ),
        const SizedBox(width: 16),
        Expanded(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${Helpers.getChannelName(channel, context.currentUser!)}',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(
              height: 2,
            ),
            // Text(
            //   'Online',
            //   style: GoogleFonts.poppins(
            //       fontSize: 10,
            //       fontWeight: FontWeight.bold,
            //       color: Colors.green),
            // ),
            BetterStreamBuilder<List<Member>>(
                stream: channel.state!.membersStream,
                initialData: channel.state!.members,
                builder: (context, data) => ConnectionStatusBuilder(
                      statusBuilder: (context, status) {
                        switch (status) {
                          case ConnectionStatus.connected:
                            return _buildConnectedTitleState(context, data);
                          case ConnectionStatus.connecting:
                            return Text('Connecting',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ));
                          case ConnectionStatus.disconnected:
                            return Text('Offline',
                                style: GoogleFonts.poppins(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ));

                          default:
                            return const SizedBox.shrink();
                        }
                      },
                    )),
          ],
        ))
      ],
    );
  }

  Widget _buildConnectedTitleState(
      BuildContext context, List<Member>? members) {
    Widget? alternatifeWidget;
    final channel = StreamChannel.of(context).channel;
    final memberCount = channel.memberCount;
    if (memberCount != null && memberCount > 2) {
      var text = 'Members $memberCount';
      final watcherCount = channel.state?.watcherCount ?? 0;
      if (watcherCount > 0) {
        text = 'watchers $watcherCount';
      }
      alternatifeWidget = Text(text);
    } else {
      final userId = StreamChatCore.of(context).currentUser!.id;
      final otherMember = members?.firstWhereOrNull(
        (element) => element.userId != userId,
      );
      if (otherMember != null) {
        if (otherMember.user!.online == true) {
          alternatifeWidget = Text(
            'Online',
            style: GoogleFonts.poppins(),
          );
        } else {
          alternatifeWidget = Text(
            'Last Online ${Jiffy(otherMember.user!.lastActive).fromNow()}',
            style:
                GoogleFonts.poppins(fontSize: 10, fontWeight: FontWeight.bold),
          );
        }
      }
    }
    return TypingIndicator(alternatifeWidget: alternatifeWidget);
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({required this.alternatifeWidget, Key? key})
      : super(key: key);

  final Widget? alternatifeWidget;
  @override
  Widget build(BuildContext context) {
    final channelState = StreamChannel.of(context).channel.state!;
    final altWidget = alternatifeWidget ?? const SizedBox.shrink();

    return BetterStreamBuilder<Iterable<User>>(
        initialData: channelState.typingEvents.keys,
        stream: channelState.typingEventsStream
            .map((typing) => typing.entries.map((e) => e.key)),
        builder: (context, data) {
          return Align(
            alignment: Alignment.centerLeft,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: data.isNotEmpty == true
                  ? Align(
                      alignment: Alignment.centerLeft,
                      key: const ValueKey('Typing text'),
                      child: Text(
                        'Typing Message',
                        maxLines: 1,
                        style: GoogleFonts.poppins(
                            fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    )
                  : Align(
                      alignment: Alignment.centerLeft,
                      key: const ValueKey('altWidget'),
                      child: altWidget,
                    ),
            ),
          );
        });
  }
}

class ConnectionStatusBuilder extends StatelessWidget {
  const ConnectionStatusBuilder(
      {Key? key,
      this.connectionStatusStream,
      this.errorBuilder,
      this.loadingBuilder,
      required this.statusBuilder})
      : super(key: key);

  final Stream<ConnectionStatus>? connectionStatusStream;
  final Widget Function(BuildContext context, Object? error)? errorBuilder;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, ConnectionStatus status)
      statusBuilder;

  @override
  Widget build(BuildContext context) {
    final stream = connectionStatusStream ??
        StreamChatCore.of(context).client.wsConnectionStatusStream;
    final client = StreamChatCore.of(context).client;
    return BetterStreamBuilder<ConnectionStatus>(
        initialData: client.wsConnectionStatus,
        stream: stream,
        noDataBuilder: loadingBuilder,
        errorBuilder: (context, error) {
          if (errorBuilder != null) {
            return errorBuilder!(context, error);
          }
          return const Offstage();
        },
        builder: statusBuilder);
  }
}

class _DateLable extends StatefulWidget {
  const _DateLable({Key? key, required this.dataTime}) : super(key: key);
  //final String lable;
  final DateTime dataTime;

  @override
  __DateLableState createState() => __DateLableState();
}

class __DateLableState extends State<_DateLable> {
  late String dayInfo;

  @override
  void initState() {
    final now = DateTime.now();
    final createdAt = Jiffy(widget.dataTime);

    if (Jiffy(createdAt).isSame(now, Units.DAY)) {
      dayInfo = 'TODAY';
    } else if (Jiffy(createdAt)
        .isSame(now.subtract(const Duration(days: 1)), Units.DAY)) {
      dayInfo = 'YESTERDAY';
    } else if (Jiffy(createdAt)
        .isAfter(now.subtract(const Duration(days: 2)), Units.DAY)) {
      dayInfo = createdAt.EEEE;
    } else if (Jiffy(createdAt).isAfter(
      Jiffy(now).subtract(years: 1),
      Units.DAY,
    )) {
      dayInfo = createdAt.MMMd;
    } else {
      dayInfo = createdAt.MMMd;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12),
            child: Text(
              dayInfo,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textFaded,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

//Class Untuk Menampung Chat Message
class _DemoMassageList extends StatelessWidget {
  const _DemoMassageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(
        children: const [
          // _DateLable(lable: 'Kemarin'),
          // _MessageTile(
          //     message: 'Ini adalah isi dari chatnya', messageDate: '12.00PM'),
          // _MessageOwnTile(message: 'Pie iki ', messageDate: '12.00PM')
        ],
      ),
    );
  }
}

//Class Yang menampung chat dari user
class _MessageTile extends StatelessWidget {
  const _MessageTile({
    Key? key,
    required this.message,
  }) : super(key: key);

  //final String? message, messageDate;
  final Message message;
  static const _borderRadius = 26.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  topRight: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, ),
                child: Text(
                  message.text!,
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textFaded,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                message.createdAt.toLocal().toString(),
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textFaded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//class yang menampung chat dari lawan
class _MessageOwnTile extends StatelessWidget {
  const _MessageOwnTile({
    Key? key,
    required this.message,
  }) : super(key: key);

  final Message message;
  // final String? message, messageDate;
  static const _borderRadius = 26.0;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Align(
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(_borderRadius),
                  bottomRight: Radius.circular(_borderRadius),
                  bottomLeft: Radius.circular(_borderRadius),
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 12.0),
                child: Text(
                  message.text ?? '',
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textLigth,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                Jiffy(message.createdAt.toLocal()).jm,
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textFaded,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//class untuk menngirim pesan
class _ActionBar extends StatefulWidget {
  const _ActionBar({Key? key}) : super(key: key);

  @override
  __ActionBarState createState() => __ActionBarState();
}

class __ActionBarState extends State<_ActionBar> {
  final TextEditingController controller = TextEditingController();

  Future<void> _sendMessage() async {
    if (controller.text.isNotEmpty) {
      StreamChannel.of(context)
          .channel
          .sendMessage(Message(text: controller.text));
      controller.clear();
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: true,
      top: false,
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
                border: Border(
                    right: BorderSide(
                        width: 2, color: Theme.of(context).dividerColor))),
            child: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Icon(CupertinoIcons.camera_fill),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: TextField(
                style: GoogleFonts.poppins(fontSize: 14),
                controller: controller,
                onChanged: (val) {
                  StreamChannel.of(context).channel.keyStroke();
                },
                decoration: const InputDecoration(
                    hintText: 'Tulis Pesan', border: InputBorder.none),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, right: 24.0),
            child: GlowingActionButton(
              color: AppColors.accent,
              icon: Icons.send_rounded,
              onPressed:_sendMessage,
            ),
          ),
        ],
      ),
    );
  }
}
