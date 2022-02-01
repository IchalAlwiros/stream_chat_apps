import 'package:meta/meta.dart';


@immutable
class MessageData {
  final String senderName, message, dateMessage, profilePicture;
  final DateTime? messageDate;

 const MessageData(
      {required this.senderName,
      required this.message,
      required this.dateMessage,
      required this.profilePicture,
       this.messageDate});
}
