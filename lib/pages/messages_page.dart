import 'package:chat_apps/models/models.dart';
import 'package:chat_apps/models/story_data.dart';
import 'package:chat_apps/pages/helpers.dart';
import 'package:chat_apps/screen/chat_screen.dart';
import 'package:chat_apps/theme/theme.dart';
import 'package:chat_apps/widget/display_error_massege.dart';
import 'package:chat_apps/widget/shimmer_loading.dart';
import 'package:chat_apps/widget/widgets.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jiffy/jiffy.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:chat_apps/app.dart';

class MassagesPage extends StatefulWidget {
  const MassagesPage({Key? key}) : super(key: key);

  @override
  _MassagesPageState createState() => _MassagesPageState();
}

class _MassagesPageState extends State<MassagesPage> {
  final channelListController = ChannelListController();

// @override
//   void initState() {
//     super.initState();
//     channelListController.loadData;
//   }

// @override
//   void dispose(){
//     super.dispose();
//     channelListController.loadData;
//   }

  @override
  Widget build(BuildContext context) {
    return ChannelListCore(
        channelListController: channelListController,
        filter: Filter.and(
        [
          Filter.equal('type', 'messaging'),
          Filter.in_('members', [
            StreamChatCore.of(context).currentUser!.id,
          ])
        ],
      ),
        emptyBuilder: (context) => const Center(
              child: Text(
                'Belum ada, \n pesan pada akun anda',
                textAlign: TextAlign.center,
              ),
            ),
        errorBuilder: (context, error) => DisplayErrorMassage(
              error: error,
            ),
        loadingBuilder: (context) =>  SizedBox(
          height: 100,
          
          child: ShimmerCardSkelton(),
        ),
        listBuilder: (context, channels) {
          return CustomScrollView(
            slivers: [
              // const SliverToBoxAdapter(
              //   child: _Stories(),
              // ),
              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  return 
                  _MassegeTitle(
                    channel: channels[index],
                  );
                }, childCount: channels.length),
              )
            ],
          );
        });
    // return CustomScrollView(
    //   slivers: [
    //     // const SliverToBoxAdapter(
    //     //   child: _Stories(),
    //     // ),
    //     SliverList(
    //       delegate: SliverChildBuilderDelegate(
    //         _delegate,
    //       ),
    //     )
    //   ],
    // );
  }
}

class _MassegeTitle extends StatelessWidget {
  const _MassegeTitle({Key? key, required this.channel}) : super(key: key);

  final Channel channel;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(ChatScreen.routeWithChannel(channel));
      },
      child: Container(
        height: 100,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: Colors.grey, width: 0.2))),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(
            children: [
              Padding(
                  padding: const EdgeInsets.all(10),
                  child: Avatar.medium(
                    url: Helpers.getChannelImage(channel, context.currentUser!),
                  )),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Text(
                       Helpers.getChannelName(channel, context.currentUser!),
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                            letterSpacing: 0.2,
                            wordSpacing: 1.5,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                      child: _buildLastMessage(),
                    ),
                  ],
                ),
              ),
             Padding(
                padding: const EdgeInsets.only(right: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(
                      height: 4,
                    ),
                    _buildLastMessageAt(),
                    const SizedBox(
                      height: 8,
                    ),
                    Center(
                      child: UnreadIndicator(
                        channel: channel,
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastMessage() {
    return BetterStreamBuilder<int>(
        stream: channel.state!.unreadCountStream,
        builder: (context, count) {
          return BetterStreamBuilder<Message>(
              stream: channel.state!.lastMessageStream,
              initialData: channel.state!.lastMessage,
              builder: (context, lastMessage) {
                return Text(
                  lastMessage.text ?? '',
                  style: (count > 0)
                      ? GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.secondary)
                      : GoogleFonts.poppins(
                          fontSize: 12, color: AppColors.textFaded),
                );
              });
        });
  }

  Widget _buildLastMessageAt() {
    return BetterStreamBuilder<DateTime>(
        stream: channel.lastMessageAtStream,
        initialData: channel.lastMessageAt,
        builder: (context, data) {
          final lastMessageAt = data.toLocal();
          final now = DateTime.now();
          String stringDate;

          final startOfDay = DateTime(now.year, now.month, now.day);

          if (lastMessageAt.microsecondsSinceEpoch >=
              startOfDay.millisecondsSinceEpoch) {
            stringDate = Jiffy(lastMessageAt.toLocal()).jm;
          } else if (lastMessageAt.microsecondsSinceEpoch >=
              startOfDay
                  .subtract(const Duration(days: 1))
                  .microsecondsSinceEpoch) {
            stringDate = ' YESTERDAY';
          } else if (startOfDay.difference(lastMessageAt).inDays < 7) {
            stringDate = Jiffy(lastMessageAt.toLocal()).EEEE;
          } else {
            stringDate = Jiffy(lastMessageAt.toLocal()).yMd;
          }

          return Text(
            stringDate,
            style: GoogleFonts.poppins(
              fontSize: 11,
              letterSpacing: -0.2,
              fontWeight: FontWeight.w600,
              color: AppColors.textFaded,
            ),
          );
        });
  }
}

class _Stories extends StatelessWidget {
  const _Stories({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.only(top: 10),
      elevation: 0,
      child: SizedBox(
        height: 150,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0, top: 8, bottom: 16.0),
              child: Text(
                'Stories',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: AppColors.textFaded),
              ),
            ),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemBuilder: (contex, index) {
                  final faker = Faker();
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                        width: 60,
                        child: _StoryCard(
                          storyData: StoryData(
                              name: faker.person.name(),
                              url: Helpers.randomPictureUrl()),
                        )),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoryCard extends StatelessWidget {
  const _StoryCard({
    Key? key,
    required this.storyData,
  }) : super(key: key);

  final StoryData storyData;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Avatar.medium(url: storyData.url),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              storyData.name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                letterSpacing: 0.3,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
