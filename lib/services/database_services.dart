import 'package:cloud_firestore/cloud_firestore.dart';

import '/models/message_model.dart';
import '/models/user_model.dart';

class UsersDB {
  var _usersRef = FirebaseFirestore.instance.collection('users');

  addUserToDB(UserModel user) async {
    await _usersRef.doc(user.email).set(user.toMap(), SetOptions(merge: true));
  }

  getUserByName(String name) async {
    return _usersRef.where('name', isEqualTo: name).snapshots();
  }

  getUserByEmail(String email) async {
    return _usersRef.where('email', isEqualTo: email).snapshots();
  }

  getAllUsers() async {
    return _usersRef.snapshots();
  }
}

class ChatsDB {
  var _chatsRef = FirebaseFirestore.instance.collection('chatrooms');

  addMessage(String chatRoomID, String messageID, Message message) async {
    return _chatsRef
        .doc(chatRoomID)
        .collection('chat')
        .doc(messageID)
        .set(message.toMap());
  }

  updateLastMessage(String chatRoomID, Message lastMessage) async {
    return _chatsRef.doc(chatRoomID).update(lastMessage.toMap());
  }

  getAllMessages(String chatRoomID) {
    return _chatsRef
        .doc(chatRoomID)
        .collection('chat')
        .orderBy('timeSend', descending: true)
        .snapshots();
  }

  getAllChatRooms(String user) async {
    return _chatsRef
        .where('users', arrayContains: user)
        .orderBy('timeSend', descending: true)
        .snapshots();
  }

  enterChatRoom(String chatRoomID, {Map<String, dynamic>? chatRoomInfo}) async {
    final snapshot = await _chatsRef.doc(chatRoomID).get();

    if (snapshot.exists) {
      return true;
    } else {
      return _chatsRef.doc(chatRoomID).set(chatRoomInfo ?? {});
    }
  }
}
