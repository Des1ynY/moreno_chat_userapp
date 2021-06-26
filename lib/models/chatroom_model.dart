import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sprintf/sprintf.dart';

class ChatroomModel {
  String text, sender, id;
  bool isNew;
  Timestamp timeSend;
  List<dynamic> users;

  ChatroomModel({
    required this.text,
    required this.sender,
    required this.timeSend,
    required this.users,
    required this.isNew,
    required this.id,
  });

  factory ChatroomModel.fromJson(Map<String, dynamic>? json) {
    return ChatroomModel(
      id: json?['id'],
      text: json?['text'],
      sender: json?['sender'],
      timeSend: json?['timeSend'],
      users: json?['users'],
      isNew: json?['isNew'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'timeSend': timeSend,
      'users': users,
      'isNew': isNew,
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
