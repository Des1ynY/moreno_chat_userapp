import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:random_string/random_string.dart';
import 'package:sprintf/sprintf.dart';

import '/models/user_model.dart';
import '/models/message_model.dart';
import '/services/database_services.dart';
import '/theme_data.dart';

String messageID = '';
String email = '';
String chatID = '';
ChatAppBar? appBar;

class ChatScreen extends StatefulWidget {
  ChatScreen({
    required this.friend,
    required String userEmail,
    required String chatroomID,
    Key? key,
  }) {
    email = userEmail;
    chatID = chatroomID;
    appBar = ChatAppBar(friend.name, friend.avatar);
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
        appBar: appBar,
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

                  return MessageTile(
                      text: messageInfo?['text'],
                      time: messageInfo?['timeSend'],
                      yours: messageInfo?['sender'] == email);
                })
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}

class MessageTile extends StatefulWidget {
  MessageTile({required this.text, required this.time, required this.yours});

  final String text;
  final Timestamp time;
  final bool yours;

  @override
  _MessageTileState createState() => _MessageTileState();
}

class _MessageTileState extends State<MessageTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 7, left: widget.yours ? 60 : 20, right: widget.yours ? 20 : 60),
      child: Column(
        crossAxisAlignment:
            widget.yours ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment:
                widget.yours ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Flexible(
                child: RawMaterialButton(
                  constraints: BoxConstraints(minWidth: 0),
                  onPressed: () {},
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: widget.text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        duration: Duration(seconds: 1),
                        content: Text('Текст скопирован!'),
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: widget.yours
                          ? mainGradient
                          : LinearGradient(
                              colors: [
                                Color(0xFFEFEFEF),
                                Color(0xFFEFEFEF),
                              ],
                            ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                        bottomLeft: widget.yours
                            ? Radius.circular(20)
                            : Radius.circular(0),
                        bottomRight: widget.yours
                            ? Radius.circular(0)
                            : Radius.circular(20),
                      ),
                    ),
                    child: Container(
                      child: Text(
                        widget.text,
                        style: TextStyle(
                          color:
                              widget.yours ? Colors.white : Color(0xFF1A1A1A),
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment:
                widget.yours ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              Container(
                margin: EdgeInsets.only(top: 3),
                child: Text(
                  getTimeInString(widget.time.toDate()),
                  style: TextStyle(
                    color: textColor,
                    fontSize: 12,
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  String getTimeInString(DateTime time) =>
      sprintf('%d:%02d', [time.hour, time.minute]);
}

class ChatAppBar extends StatefulWidget implements PreferredSizeWidget {
  ChatAppBar(this.name, this.avatar);

  final String name, avatar;

  @override
  _ChatAppBarState createState() => _ChatAppBarState();

  @override
  Size get preferredSize => Size.fromHeight(80);
}

class _ChatAppBarState extends State<ChatAppBar> {
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              SizedBox(
                width: 20,
              ),
              CircleAvatar(
                radius: 30,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/common_avatar_blue.png'),
                foregroundImage: NetworkImage(widget.avatar),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                widget.name,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
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
          Flexible(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 15),
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
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                cursorColor: Color(0xFF5CE27F),
                controller: textControl,
                minLines: 1,
                maxLines: 20,
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
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        border: Border.all(
          color: Color(0xffE1E1E1),
        ),
      ),
      child: GradientMask(
        child: IconButton(
          icon: Icon(icon),
          iconSize: 30,
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
