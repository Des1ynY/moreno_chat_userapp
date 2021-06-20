import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:random_string/random_string.dart';
import 'package:sprintf/sprintf.dart';

import '/models/user_model.dart';
import '/models/message_model.dart';
import '/services/database_services.dart';
import '/theme_data.dart';

String messageID = '';
String email = '';
String chatID = '';

class ChatScreen extends StatefulWidget {
  ChatScreen({
    required this.friend,
    required String userEmail,
    required String chatroomID,
    Key? key,
  }) {
    email = userEmail;
    chatID = chatroomID;
  }

  final UserModel friend;

  @override
  _ChatScreenState createState() => _ChatScreenState(friend);
}

class _ChatScreenState extends State<ChatScreen> {
  _ChatScreenState(this.friend);

  UserModel friend;
  bool messagesLoaded = false;
  late Stream<QuerySnapshot<Map<String, dynamic>>> messages;

  @override
  void initState() {
    onLoad();
    super.initState();
  }

  void onLoad() async {
    messages = await ChatsDB().getAllMessages(chatID);
    setState(() {
      messagesLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: ChatAppBar(friend.name, friend.avatar),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                child: messagesLoaded ? chatMessages() : Container(),
              ),
            ),
            ChatBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget chatMessages() {
    return StreamBuilder(
      stream: messages,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                shrinkWrap: true,
                reverse: true,
                itemCount: snapshot.data?.docs.length,
                itemBuilder: (context, index) {
                  var ds = snapshot.data?.docs.elementAt(index);
                  var messageInfo = ds?.data();
                  return messageTile(
                      text: messageInfo?['text'],
                      time: messageInfo?['timeSend'],
                      yours: messageInfo?['sender'] == email);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget messageTile({
    required String text,
    required Timestamp time,
    required bool yours,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment:
              yours ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Flexible(
              child: Container(
                padding: EdgeInsets.all(10),
                margin: EdgeInsets.only(
                    top: 7, left: yours ? 60 : 20, right: yours ? 20 : 60),
                decoration: BoxDecoration(
                  gradient: yours
                      ? mainGradient
                      : LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.bottomLeft,
                          colors: [
                            Color(0xFFEFEFEF),
                            Color(0xFFEFEFEF),
                          ],
                        ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft:
                        yours ? Radius.circular(20) : Radius.circular(0),
                    bottomRight:
                        yours ? Radius.circular(0) : Radius.circular(20),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        child: Text(
                          text,
                          style: TextStyle(
                            color: yours ? Colors.white : Color(0xFF1A1A1A),
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
        Row(
          mainAxisAlignment:
              yours ? MainAxisAlignment.end : MainAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
              child: Text(
                sprintf('%d:%02d', [time.toDate().hour, time.toDate().minute]),
                style: TextStyle(
                  color: textColor,
                  fontSize: 12,
                ),
              ),
            )
          ],
        )
      ],
    );
  }
}

class ChatAppBar extends StatelessWidget implements PreferredSizeWidget {
  const ChatAppBar(this.name, this.avatar, {Key? key}) : super(key: key);

  final String name, avatar;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 80,
      decoration: BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(
            color: Color(0xffEFEFEF),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 20,
          ),
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage('assets/common_avatar_blue.png'),
            foregroundImage: NetworkImage(avatar),
          ),
          SizedBox(
            width: 10,
          ),
          Text(
            name,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class ChatBottomBar extends StatelessWidget {
  final TextEditingController textControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(15),
      width: MediaQuery.of(context).size.width,
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
              height: 43,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50),
                border: Border.all(
                  color: Color(0xffE1E1E1),
                ),
              ),
              child: TextField(
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Пиши...',
                  hintStyle: TextStyle(
                    color: textColor,
                  ),
                ),
                keyboardType: TextInputType.text,
                cursorColor: Color(0xFF5CE27F),
                controller: textControl,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.black.withOpacity(0.8),
                ),
              ),
            ),
          ),
          SizedBox(
            width: 7,
          ),
          bottomBarButton(Icons.send, () => sendMessage()),
        ],
      ),
    );
  }

  Widget bottomBarButton(IconData icon, VoidCallback onPress) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Color(0xffE1E1E1),
        ),
      ),
      child: GradientMask(
        child: IconButton(
          icon: Icon(icon),
          color: Colors.white,
          onPressed: onPress,
        ),
      ),
    );
  }

  void sendMessage() {
    if (textControl.text != '') {
      if (messageID == '') {
        messageID = randomAlphaNumeric(12);
      }

      var timeSend = Timestamp.now();

      var message = Message(
        text: textControl.text,
        sender: email,
        timeSend: timeSend,
      );

      ChatsDB().addMessage(chatID, messageID, message).then((value) {
        ChatsDB().updateLastMessage(chatID, message);

        textControl.text = '';
        messageID = '';
      });
    }
  }
}
