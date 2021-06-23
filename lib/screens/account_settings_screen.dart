import 'package:flutter/material.dart';

import '/services/auth_services.dart';
import '/models/user_model.dart';
import '/services/database_services.dart';
import '/theme_data.dart';
import '/custom_icons.dart';

late UserModel user;
late String avatar, name;

class AccountSettingsScreen extends StatefulWidget {
  AccountSettingsScreen(UserModel userModel) {
    user = userModel;
    avatar = user.avatar;
    name = user.name;
  }

  @override
  _AccountSettingsScreenState createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AccountScreenAppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            AccountSettingsOption(
              'Фото профиля',
              Center(
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/common_avatar_blue.png'),
                  foregroundImage: NetworkImage(avatar),
                ),
              ),
              true,
            ),
            AccountSettingsOption(
              'Логин',
              Text(
                name,
                style: TextStyle(
                    fontWeight: FontWeight.w300,
                    fontSize: 16,
                    color: textColor),
              ),
              false,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 30),
              width: MediaQuery.of(context).size.width,
              height: 70,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: strokeColor)),
              ),
              child: TextButton(
                onPressed: () {
                  AuthServices().resetPassword(email: user.email);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      contentPadding:
                          EdgeInsets.only(top: 20, left: 20, right: 20),
                      content: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'На электронный адрес ',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            TextSpan(
                              text: '${user.email}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue.shade400,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            TextSpan(
                              text: ' было отправлено письмо для сброса пароля',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('ОК'),
                        )
                      ],
                    ),
                  );
                },
                child: Text(
                  'Сбросить пароль',
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFFF85656),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AccountSettingsOption extends StatefulWidget {
  AccountSettingsOption(this.label, this.field, this.editingField);

  final bool editingField;
  final String label;
  final Widget field;

  @override
  _AccountSettingsOptionState createState() =>
      _AccountSettingsOptionState(label, field, editingField);
}

class _AccountSettingsOptionState extends State<AccountSettingsOption> {
  _AccountSettingsOptionState(this.label, this.field, this.editingField);

  String label;
  Widget field;
  bool editingField;
  bool editing = false;
  TextEditingController textControl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 8, bottom: editing ? 9 : 20, left: 40, right: 40),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: strokeColor)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () {
                  textControl.text = '';
                  setState(() => editing = !editing);
                },
                child: Text(
                  editing ? 'Отменить' : 'Изменить',
                  style: TextStyle(
                    color: Colors.blue.shade200,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ],
          ),
          editing
              ? Container(
                  child: TextFormField(
                    decoration: InputDecoration(
                        counterText: '',
                        hintText: hintText(),
                        hintStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: textColor.withOpacity(0.5)),
                        border: InputBorder.none),
                    controller: textControl,
                    keyboardType:
                        editingField ? TextInputType.url : TextInputType.name,
                    autofocus: true,
                    minLines: 1,
                    maxLines: 10,
                    maxLength: editingField ? 300 : 25,
                    style: TextStyle(
                      color: editingField ? Colors.blue.shade300 : Colors.black,
                      decoration: editingField
                          ? TextDecoration.underline
                          : TextDecoration.none,
                      fontSize: 16,
                      fontWeight: FontWeight.w300,
                    ),
                    onFieldSubmitted: (val) {
                      submit();
                      setState(() {
                        editing = false;
                        editingField ? avatar = val : name = val;
                      });
                    },
                  ),
                )
              : showCurrentState(editingField ? avatar : name),
        ],
      ),
    );
  }

  submit() async {
    if (editingField) {
      user.avatar = textControl.text.trim();
      textControl.text = '';
      await UsersDB().addUserToDB(user);
    } else {
      user.name = textControl.text.trim();
      textControl.text = '';
      await UsersDB().addUserToDB(user);
    }
  }

  String hintText() {
    return editingField ? 'Вставь ссылку на картинку' : user.name;
  }

  Widget showCurrentState(String value) {
    return editingField
        ? Center(
            child: CircleAvatar(
              radius: 80,
              backgroundColor: Colors.white,
              backgroundImage: AssetImage('assets/common_avatar_blue.png'),
              foregroundImage: NetworkImage(avatar),
            ),
          )
        : Text(
            name,
            style: TextStyle(
                fontWeight: FontWeight.w300, fontSize: 16, color: textColor),
          );
  }
}

class AccountScreenAppBar extends StatelessWidget
    implements PreferredSizeWidget {
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
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                width: 5,
              ),
              Container(
                child: IconButton(
                  icon: Icon(Icons.keyboard_arrow_left),
                  iconSize: 35,
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Text(
                'Аккаунт',
                style: TextStyle(
                  fontSize: 24,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 10),
                child: Icon(CustomIcons.users_1, size: 35, color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(71);
}
