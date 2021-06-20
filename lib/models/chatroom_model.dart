import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sprintf/sprintf.dart';

class ChatroomModel {
  String text, sender;
  Timestamp timeSend;
  List<dynamic> users;

  ChatroomModel(
      {required this.text,
      required this.sender,
      required this.timeSend,
      required this.users});

  factory ChatroomModel.fromJson(Map<String, dynamic>? json) {
    return ChatroomModel(
      text: json?['text'],
      sender: json?['sender'],
      timeSend: json?['timeSend'],
      users: json?['users'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender,
      'timeSend': timeSend,
      'users': users,
    };
  }

  int lastMessageWasDaysAgo() {
    var sendTime = timeSend.toDate();
    return DateTime.now().day - sendTime.day;
  }

  String getLastMessageSendTime() {
    var sendTime = timeSend.toDate();
    return sprintf('%d:%02d', [sendTime.hour, sendTime.minute]);
  }
}
