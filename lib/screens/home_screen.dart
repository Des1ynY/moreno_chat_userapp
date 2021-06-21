import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/screens/account_settings_screen.dart';
import '/screens/chat_screen.dart';
import '/theme_data.dart';
import '/services/auth_services.dart';
import '/models/user_model.dart';
import '/services/database_services.dart';
import '/custom_icons.dart';
import '/components/general_comps.dart';

String email = '';
late UserModel user;

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
          title: 'MORENO',
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
  bool isOn = false;
  late Stream<QuerySnapshot<Map<String, dynamic>>> chatroomsDB;
  late Stream<QuerySnapshot<Map<String, dynamic>>> usersDB;
  late Stream<QuerySnapshot<Map<String, dynamic>>> userDB;

  @override
  void initState() {
    onLoad();
    super.initState();
  }

  void onLoad() async {
    chatroomsDB = await ChatsDB().getAllChatRooms(email);
    userDB = await UsersDB().getUserByEmail(email);
    usersDB = await UsersDB().getUserByEmail('admin@admin.com');
    setState(() {
      isOn = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE1E1E1))),
              ),
              child: isOn ? thisUserInfo() : Container(),
            ),
            settingsOption(
                'Аккаунт',
                CircleAvatar(
                  radius: 17,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/common_avatar_blue.png'),
                ), () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AccountSettingsScreen(user)));
            }),
            isOn ? enterTheChatRoom() : Container(),
            settingsOption(
              'Выйти из аккаунта',
              Icon(
                CustomIcons.logout,
                size: 30,
                color: Color(0xFFF96868),
              ),
              () => AuthServices().signOut(),
            ),
          ],
        ),
      ),
    );
  }

  Widget enterTheChatRoom() {
    return StreamBuilder(
      stream: chatroomsDB,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        return snapshot.hasData
            ? StreamBuilder(
                stream: usersDB,
                builder: (context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  var ds = snapshot.data?.docs.first;
                  return snapshot.hasData
                      ? settingsOption(
                          'Войти в чат',
                          Icon(CustomIcons.chat_1,
                              size: 30, color: Color(0xFF5ED6B6)),
                          () {
                            String chatID =
                                getChatRoomID('admin@admin.com', email);
                            ChatsDB().enterChatRoom(chatID);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  friend: UserModel.fromJson(ds?.data()),
                                  userEmail: email,
                                  chatroomID: chatID,
                                ),
                              ),
                            );
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

  Widget thisUserInfo() {
    return StreamBuilder(
      stream: userDB,
      builder: (context,
          AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
        return snapshot.hasData
            ? ListView.builder(
                itemCount: 1,
                shrinkWrap: true,
                itemBuilder: (context, index) {
                  var ds = snapshot.data?.docs.first;
                  user = UserModel.fromJson(ds?.data());
                  return userInfoDisplay(user);
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }
}

Widget userInfoDisplay(UserModel user) {
  return Container(
    child: Column(
      children: [
        CircleAvatar(
          radius: 80,
          backgroundColor: Colors.white,
          backgroundImage: AssetImage('assets/common_avatar_blue.png'),
          foregroundImage: NetworkImage(user.avatar),
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          user.name,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w400,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(
          user.email,
          style: TextStyle(
            color: textColor,
          ),
        ),
      ],
    ),
  );
}

Widget settingsOption(String label, Widget icon, VoidCallback onPress) {
  return Container(
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Color(0xFFE1E1E1)),
      ),
    ),
    child: MaterialButton(
      onPressed: onPress,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin: EdgeInsets.only(left: 20, top: 20, bottom: 20),
            child: Row(
              children: [
                icon,
                SizedBox(
                  width: 10,
                ),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.keyboard_arrow_right,
            size: 50,
            color: Color(0xFFD4D4D4).withOpacity(0.5),
          ),
        ],
      ),
    ),
  );
}

String getChatRoomID(String firstUserEmail, String secondUserEmail) {
  if (firstUserEmail.substring(0, 1).codeUnitAt(0) >
      secondUserEmail.substring(0, 1).codeUnitAt(0)) {
    return '$secondUserEmail\_$firstUserEmail';
  } else {
    return '$firstUserEmail\_$secondUserEmail';
  }
}
