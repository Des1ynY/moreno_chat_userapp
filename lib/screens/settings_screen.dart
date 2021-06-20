import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/components/general_comps.dart';
import '/theme_data.dart';
import '/custom_icons.dart';
import '/models/user_model.dart';
import '/services/auth_services.dart';
import '/services/database_services.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen(this.email);

  final String email;

  @override
  _SettingsScreenState createState() => _SettingsScreenState(email);
}

class _SettingsScreenState extends State<SettingsScreen> {
  _SettingsScreenState(this.email);

  String email;
  bool isOn = false;
  late Stream<QuerySnapshot<Map<String, dynamic>>> userDB;

  @override
  void initState() {
    isLoaded();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: CustomAppBar(
          email: email,
          enableBack: true,
          title: 'Настройки',
          icon: Icons.settings,
        ),
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
                ),
                () => null),
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

  void isLoaded() async {
    userDB = await UsersDB().getUserByEmail(email);
    setState(() {
      isOn = true;
    });
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
                  var user = ds?.data();
                  return userInfoDisplay(UserModel.fromJson(user));
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              );
      },
    );
  }

  Widget settingsOption(String label, Widget icon, VoidCallback onPress) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
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
}

Widget userInfoDisplay(UserModel user) {
  return Container(
    child: Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white,
              foregroundImage: NetworkImage(user.avatar),
            ),
            Container(
              alignment: Alignment.centerLeft,
              width: 35,
              height: 35,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 2,
                    blurRadius: 10,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: RawMaterialButton(
                hoverElevation: 10,
                onPressed: () => null,
                child: Icon(
                  Icons.camera_alt,
                  size: 25,
                  color: Color(0xFF5DD7B2),
                ),
              ),
            ),
          ],
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
