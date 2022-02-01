import 'package:chat_apps/pages/calls_page.dart';
import 'package:chat_apps/pages/contacts_page.dart';
import 'package:chat_apps/pages/helpers.dart';
import 'package:chat_apps/pages/messages_page.dart';
import 'package:chat_apps/pages/messeges_test.dart';
import 'package:chat_apps/pages/notifications_page.dart';
import 'package:chat_apps/screen/profile_screen.dart';
import 'package:chat_apps/theme/theme.dart';
import 'package:chat_apps/widget/avatar.dart';
import 'package:chat_apps/widget/glowing_action_button.dart';
import 'package:chat_apps/widget/widgets.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';
import 'package:chat_apps/app.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);

  final ValueNotifier<int> pageIndex = ValueNotifier(0);
  final ValueNotifier<String> title = ValueNotifier('Pesan');
  final pages = const [
    MassagesPage(),
    //MessagesPage(),
    NotificationPage(),
    CallsPage(),
    ContactPage(),
  ];

  final pageTitles = const [
    'Pesan',
    'Notifikasi',
    'Panggilan',
    'Kontak',
  ];
  void onNavigationItemSelected(index) {
    title.value = pageTitles[index];
    pageIndex.value = index;
  }

  @override
  Widget build(BuildContext context) {
    // StreamChatCore.of(context).client.
    return Scaffold(
      appBar: AppBar(
        iconTheme: Theme.of(context).iconTheme,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: title,
          builder: (BuildContext context, String value, _) {
            return Text(
              value,
              style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold, fontSize: 16),
            );
          },
        ),
        leadingWidth: 54,
        leading: Align(
          alignment: Alignment.centerRight,
          child: IconBackground(
            icon: Icons.search,
            onTap: () {
              print('Search');
            },
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 24.0),
            child: Hero(
              tag: 'hero-profile-picture',
              child: Avatar.small(
                url: context.currentUserImage,
                onTap: () {
                  Navigator.of(context).push(ProfileScreen.route);
                },
              ),
            ),
          )
        ],
      ),
      body: ValueListenableBuilder(
        valueListenable: pageIndex,
        builder: (BuildContext context, dynamic value, _) {
          return pages[value];
        },
      ),
      bottomNavigationBar: _BottomNavigationBar(
        onItemSelected: onNavigationItemSelected,
      ),
    );
  }
}

//class yang menampung bottom button action
class _BottomNavigationBar extends StatefulWidget {
  const _BottomNavigationBar({
    required this.onItemSelected,
    Key? key,
  }) : super(key: key);
  final ValueChanged<int> onItemSelected;

  @override
  __BottomNavigationBarState createState() => __BottomNavigationBarState();
}

class __BottomNavigationBarState extends State<_BottomNavigationBar> {
  var selectedIndex = 0;
  void handleItemSelected(int index) {
    setState(() {
      selectedIndex = index;
    });
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return Card(
      color: (brightness == Brightness.light) ? Colors.transparent : null,
      elevation: 0,
      child: SafeArea(
        top: false,
        bottom: true,
        child: Padding(
          padding: const EdgeInsets.only(top: 16, left: 8, right: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavigationBarItem(
                onTap: handleItemSelected,
                index: 0,
                lable: 'Pesan',
                icon: CupertinoIcons.bubble_left_bubble_right_fill,
                isSelected: (selectedIndex == 0),
              ),
              _NavigationBarItem(
                onTap: handleItemSelected,
                index: 1,
                lable: 'Notification',
                icon: CupertinoIcons.bell_solid,
                isSelected: (selectedIndex == 1),
              ),
              Padding(
                padding:
                    const EdgeInsets.only(right: 8.0, left: 8.0, bottom: 8.0),
                child: GlowingActionButton(
                    color: AppColors.secondary,
                    icon: CupertinoIcons.chat_bubble_2,
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => Container(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              
                              Container(
                                width: 20,
                                height: 10,
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(10)),
                              ),

                              const SizedBox(
                                height: 200,
                                child: ContactPage(),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('Kembali'),
                              ),
                            ],
                          ),
                        ),
                      );
                      // showDialog(
                      //     context: context,
                      //     builder: (context) => const Dialog(
                      //           child: AspectRatio(
                      //             aspectRatio: 8 / 7,
                      //             child: ContactPage(),
                      //           ),
                      //         ));
                    }),
              ),
              _NavigationBarItem(
                onTap: handleItemSelected,
                index: 2,
                lable: 'Calls',
                icon: CupertinoIcons.phone_fill,
                isSelected: (selectedIndex == 2),
              ),
              _NavigationBarItem(
                onTap: handleItemSelected,
                index: 3,
                lable: 'Contact',
                icon: CupertinoIcons.person_2_fill,
                isSelected: (selectedIndex == 3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

//button untuk navigationnya
class _NavigationBarItem extends StatelessWidget {
  const _NavigationBarItem(
      {Key? key,
      required this.index,
      this.isSelected = false,
      required this.icon,
      required this.lable,
      required this.onTap})
      : super(key: key);

  final int index;
  final String lable;
  final IconData icon;
  final bool isSelected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        //behavior: HitTestBehavior.opaque,
        onTap: () {
          onTap(index);
        },
        child: SizedBox(
          width: 70,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  size: 23, color: isSelected ? AppColors.secondary : null),
              const SizedBox(height: 8),
              Text(lable,
                  style: isSelected
                      ? GoogleFonts.poppins(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.secondary)
                      : GoogleFonts.poppins(fontSize: 8)),
            ],
          ),
        ),
      ),
    );
  }
}
