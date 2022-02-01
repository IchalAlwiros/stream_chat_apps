// import 'package:chatter/app.dart';
// import 'package:chatter/screens/screens.dart';
// import 'package:chatter/widgets/widgets.dart';
// import 'package:firebase_auth/firebase_auth.dart' as firebase;

import 'package:chat_apps/screen/select_user_screen.dart';
import 'package:chat_apps/theme/theme.dart';
import 'package:chat_apps/widget/widgets.dart';
import 'package:chat_apps/app.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

class ProfileScreen extends StatelessWidget {
  static Route get route =>
      MaterialPageRoute(builder: (context) => const ProfileScreen());

  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = context.currentUser;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          children: [
            // Hero(
            //   tag: 'hero-profile=picture',
            //   child: Avatar.large(url: user?.image),
            // ),
            Avatar.large(url: user?.image),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(user?.name ?? 'No Name'),
            ),
            const Divider(),
            const _SignOutButton()
          ],
        ),
      ),
    );
  }
}

class _SignOutButton extends StatefulWidget {
  const _SignOutButton({
    Key? key,
  }) : super(key: key);

  @override
  __SignOutButtonState createState() => __SignOutButtonState();
}

class __SignOutButtonState extends State<_SignOutButton> {
  bool _loading = false;

  Future<void> _signOut() async {
    setState(() {
      _loading = true;
    });

    try {
      await StreamChatCore.of(context).client.disconnectUser();

      Navigator.of(context).push(SelectUserScreen.route);
    } on Exception catch (e, st) {
      logger.e('Could not sign out', e, st);
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _loading
        ? const CircularProgressIndicator()
        : ClipRRect(
            child: Material(
              child: InkWell(
                onTap: _signOut,
                highlightColor: Colors.greenAccent.withOpacity(0.3),
                splashColor: Colors.green.withOpacity(0.5),
                child: Ink(
                  height: 55,
                  width: MediaQuery.of(context).size.width,
                  decoration: const BoxDecoration(
                    color: Colors.redAccent,
                  ),
                  child: Center(
                    child: Text(
                      'Sign Out',
                      style: GoogleFonts.poppins(
                        color: AppColors.cardLight,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
  }
}
