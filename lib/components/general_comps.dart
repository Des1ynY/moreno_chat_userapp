import 'package:flutter/material.dart';
import 'package:moreno_chat_userapp/screens/settings_screen.dart';
import 'package:moreno_chat_userapp/theme_data.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({
    Key? key,
    required this.title,
    required this.icon,
    required this.email,
    this.enableSettings = false,
    this.enableBack = false,
  }) : super(key: key);

  final bool enableSettings, enableBack;
  final String title, email;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Color(0xFF64C6E1),
            Color(0xFF5ED7B3),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: enableBack ? 5 : 20,
                    ),
                    enableBack
                        ? Container(
                            child: IconButton(
                              icon: Icon(Icons.keyboard_arrow_left),
                              iconSize: 35,
                              color: Colors.white,
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          )
                        : Container(),
                    Text(title, style: headingText),
                    SizedBox(
                      width: 10,
                    ),
                    Icon(
                      icon,
                      color: Colors.white,
                      size: 35,
                    ),
                  ],
                ),
              ),
              enableSettings
                  ? Container(
                      margin: EdgeInsets.only(right: 5),
                      child: IconButton(
                          icon: Icon(Icons.settings),
                          iconSize: 35,
                          color: Colors.white,
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        SettingsScreen(email)));
                          }),
                    )
                  : Container(),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(71);
}
