import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '/models/chatroom_model.dart';

import '/models/user_model.dart';
import '/services/database_services.dart';
import '/theme_data.dart';
import '/custom_icons.dart';
import '/screens/chat_screen.dart';
import '/components/general_comps.dart';

String email = '';

class HomeScreen extends StatefulWidget {
  HomeScreen({required String userEmail}) {
    email = userEmail;
  }

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          title: 'Чат',
          icon: CustomIcons.chat_1,
          email: email,
          enableSettings: true,
        ),
        body: ChatsScreen(),
      ),
    );
  }
}

class ChatsScreen extends StatefulWidget {
  const ChatsScreen({Key? key}) : super(key: key);

  @override
  _ChatsScreenState createState() => _ChatsScreenState();
}

class _ChatsScreenState extends State<ChatsScreen> {
  bool isLoaded = false;
  bool isFullyLoaded = false;
  late Stream<QuerySnapshot<Map<String, dynamic>>> chatroomsDB;
  late Stream<QuerySnapshot<Map<String, dynamic>>> usersDB;

  @override
  void initState() {
    onLoad();
    super.initState();
  }

  void onLoad() async {
    chatroomsDB = await ChatsDB().getAllChatRooms(email);
    usersDB = await UsersDB().getUserByEmail('admin@admin.com');
    setState(() {
      isLoaded = true;
      isFullyLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Column(
          children: [
            Expanded(
              child: isLoaded ? chatrooms() : Container(),
            )
          ],
        ),
      ),
    );
  }

  Widget chatrooms() {
    return StreamBuilder(
      stream: chatroomsDB,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  var ds = snapshot.data?.docs.elementAt(index);
                  var chatroomInfo = ds?.data();
                  var chatroom = ChatroomModel.fromJson(chatroomInfo);
                  return isFullyLoaded
                      ? StreamBuilder(
                          stream: usersDB,
                          builder: (context,
                              AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                                  snapshot) {
                            return snapshot.hasData
                                ? chatroomTile(
                                    chatroom,
                                    email,
                                    UserModel.fromJson(
                                        snapshot.data?.docs.first.data()),
                                    context)
                                : Container();
                          },
                        )
                      : Container();
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}

Widget chatroomTile(ChatroomModel chatroom, String userEmail, UserModel friend,
    BuildContext context) {
  return Container(
    width: MediaQuery.of(context).size.width,
    decoration: BoxDecoration(
      border: Border(bottom: BorderSide(color: strokeColor)),
    ),
    child: MaterialButton(
      onPressed: () {
        String chatroomID = getChatRoomID(friend.email, userEmail);

        ChatsDB().enterChatRoom(chatroomID);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              friend: friend,
              userEmail: userEmail,
              chatroomID: chatroomID,
            ),
          ),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(right: 10, top: 12, bottom: 12),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/common_avatar_blue.png'),
              foregroundImage: NetworkImage(friend.avatar),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      displayName(friend.name),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      displayDate(chatroom),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: textColor,
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 5,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      displayMessage(chatroom, userEmail),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: textColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

String displayName(String name) {
  return name.length <= 25 ? name : '${name.substring(0, 23)}...';
}

String displayDate(ChatroomModel chatroom) {
  var daysAgo = chatroom.lastMessageWasDaysAgo();

  if (daysAgo != 0) {
    if (daysAgo >= 5 && daysAgo <= 20) {
      return '$daysAgo дней назад';
    } else if (daysAgo % 10 == 1) {
      return '$daysAgo день назад';
    } else if (daysAgo % 10 >= 2 && daysAgo % 10 <= 4) {
      return '$daysAgo дня назад';
    } else {
      return '$daysAgo дней назад';
    }
  } else {
    return chatroom.getLastMessageSendTime();
  }
}

String displayMessage(ChatroomModel chatroom, String email) {
  if (chatroom.sender == email) {
    return chatroom.text.length <= 25
        ? 'Вы: ${chatroom.text}'
        : 'Вы: ${chatroom.text.substring(0, 23)}...';
  } else {
    return chatroom.text.length <= 28
        ? chatroom.text
        : '${chatroom.text.substring(0, 26)}...';
  }
}

String getChatRoomID(String firstUserEmail, String secondUserEmail) {
  if (firstUserEmail.substring(0, 1).codeUnitAt(0) >
      secondUserEmail.substring(0, 1).codeUnitAt(0)) {
    return '$secondUserEmail\_$firstUserEmail';
  } else {
    return '$firstUserEmail\_$secondUserEmail';
  }
}
