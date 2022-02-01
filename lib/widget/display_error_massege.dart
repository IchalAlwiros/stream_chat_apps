import 'package:flutter/material.dart';

class DisplayErrorMassage extends StatelessWidget {
  const DisplayErrorMassage({this.error, Key? key}) : super(key: key);

  final Object? error;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('wooo enek sing error, cek en nde configmu. $error'),
    );
  }
}
