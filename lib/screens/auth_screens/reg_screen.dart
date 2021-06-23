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
  bool _isLoading = false;
  String _email = '', _password = '', _name = '';
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusNode _loginNode = FocusNode(),
      _emailNode = FocusNode(),
      _passwordNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: ClampingScrollPhysics(),
        child: Container(
          padding: EdgeInsets.all(40),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
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
                    label(text: 'Логин'),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        focusNode: _loginNode,
                        keyboardType: TextInputType.name,
                        onChanged: (value) => _name = value,
                        validator: (value) =>
                            value?.length != 0 ? null : 'Введите логин',
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(_emailNode);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    label(text: 'Почта'),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        focusNode: _emailNode,
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => _email = value,
                        validator: (value) =>
                            isValidEmail(value) ? null : 'Неверная почта',
                        onFieldSubmitted: (val) {
                          FocusScope.of(context).requestFocus(_passwordNode);
                        },
                      ),
                    ),
                    SizedBox(
                      height: 7,
                    ),
                    label(text: 'Пароль'),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      child: TextFormField(
                        focusNode: _passwordNode,
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
                isLoading: _isLoading,
              ),
              Spacer(
                flex: 7,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit() {
    var formIsValid = formKey.currentState?.validate() ?? false;

    if (formIsValid) {
      setState(() => _isLoading = true);
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

      authService.signIn(_email, _password);

      Navigator.pop(context);
    }
  }
}
