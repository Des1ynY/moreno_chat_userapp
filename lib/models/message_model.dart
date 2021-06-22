import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:sprintf/sprintf.dart';

class Message {
  String text, sender;
  Timestamp timeSend;

  Message({
    required this.text,
    required this.sender,
    required this.timeSend,
  });

  factory Message.fromJson(Map<String, dynamic>? json) {
    return Message(
      text: json?['text'],
      sender: json?['sender'],
      timeSend: json?['timeSend'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender,
      'timeSend': timeSend,
    };
  }

  String getSendTime() {
    var sendTime = timeSend.toDate();
    return sprintf('%d:%02d', [sendTime.hour, sendTime.minute]);
  }
}
