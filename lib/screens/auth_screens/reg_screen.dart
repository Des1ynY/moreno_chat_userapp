import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '/models/user_model.dart';
import '/screens/home_screen.dart';
import '/services/database_services.dart';
import '/services/auth_services.dart';
import '/components/auth_screens_comps.dart';

class SignUp extends StatefulWidget {
  const SignUp({Key? key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  var authService = AuthServices();
  var dbServices = UsersDB();
  bool isLoading = false;
  String _email = '', _password = '', _name = '';
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        padding: EdgeInsets.all(40),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Spacer(
              flex: 2,
            ),
            logoTrans(),
            Spacer(
              flex: 3,
            ),
            Form(
              key: formKey,
              child: Column(
                children: [
                  label(text: 'Имя'),
                  Container(
                    width: double.infinity,
                    child: TextFormField(
                      keyboardType: TextInputType.name,
                      onChanged: (value) => _name = value,
                      validator: (value) =>
                          value?.length != 0 ? null : 'Введите имя',
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  label(text: 'Почта'),
                  Container(
                    width: double.infinity,
                    child: TextFormField(
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => _email = value,
                      validator: (value) =>
                          isValidEmail(value) ? null : 'Неверная почта',
                    ),
                  ),
                  SizedBox(
                    height: 7,
                  ),
                  label(text: 'Пароль'),
                  Container(
                    width: double.infinity,
                    child: TextFormField(
                      obscureText: true,
                      onChanged: (value) => _password = value,
                      validator: (value) =>
                          isValidPassword(value) ? null : 'Неверный пароль',
                    ),
                  ),
                ],
              ),
            ),
            Spacer(
              flex: 4,
            ),
            actionButton(
              text: 'Зарегистрироваться',
              fontSize: 20,
              onPress: () => submit(),
              isLoading: isLoading,
            ),
            Spacer(
              flex: 7,
            ),
          ],
        ),
      ),
    );
  }

  void submit() {
    var formIsValid = formKey.currentState?.validate() ?? false;

    if (formIsValid) {
      setState(() => isLoading = true);
      authService.signUp(_email, _password);
      var dbUser = UserModel(
        email: _email,
        name: _name,
        avatar:
            'https://firebasestorage.googleapis.com/v0/b/chat-app-22c94.appspot.com/o/common_avatar_blue.png?alt=media&token=e9f86dc4-6638-47fe-8fa8-496bffdbdfdc',
      );
      dbServices.addUserToDB(dbUser);

      String chatroomID = getChatRoomID('admin@admin.com', _email);
      var chatRoomInfo = <String, dynamic>{
        'users': ['admin@admin.com', _email],
        'sender': 'admin@admin.com',
        'text': 'Рад приветствовать!',
        'timeSend': Timestamp.now()
      };

      ChatsDB().enterChatRoom(chatroomID, chatRoomInfo: chatRoomInfo);

      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              userEmail: _email,
            ),
          ),
          (route) => false);
    }
  }
}
