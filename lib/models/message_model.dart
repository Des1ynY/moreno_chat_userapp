import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sprintf/sprintf.dart';

class Message {
  String text, sender, id;
  bool isNew;
  Timestamp timeSend;

  Message({
    required this.text,
    required this.sender,
    required this.id,
    required this.timeSend,
    required this.isNew,
  });

  factory Message.fromJson(Map<String, dynamic>? json) {
    return Message(
      id: json?['id'],
      text: json?['text'],
      sender: json?['sender'],
      isNew: json?['isNew'],
      timeSend: json?['timeSend'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender,
      'timeSend': timeSend,
      'isNew': isNew,
    };
  }

  String getSendTime() {
    var sendTime = timeSend.toDate();
    return sprintf('%d:%02d', [sendTime.hour, sendTime.minute]);
  }
}
