import 'package:flutter/material.dart';

@immutable
class DemoUser {
  final String id;
  final String name;
  final String image;

  const DemoUser({
    required this.id,
    required this.name,
    required this.image,
  });
}
const users = [
  userAdi,
  userBowo,
  userIchal,

];

const userAdi = DemoUser(
  id: 'adi',
  name: 'Adi Prabowo',
  image:
      'https://pbs.twimg.com/profile_images/1262058845192335360/Ys_-zu6W_400x400.jpg',
);

const userBowo = DemoUser(
  id: 'bowo',
  name: 'Bowo',
  image:
      'https://pbs.twimg.com/profile_images/1252869649349238787/cKVPSIyG_400x400.jpg',
);

const userIchal = DemoUser(
  id: 'ichal',
  name: 'Ichal Wira',
  image:
      'https://pbs.twimg.com/profile_images/1199684106193375232/IxA9XLuN_400x400.jpg',
);



