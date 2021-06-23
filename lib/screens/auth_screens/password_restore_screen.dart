import 'package:flutter/material.dart';
import 'package:moreno_chat_userapp/screens/auth_screens/auth_screen.dart';

import '/services/auth_services.dart';
import '/components/auth_screens_comps.dart';

class PasswordRestore extends StatefulWidget {
  @override
  _PasswordRestoreState createState() => _PasswordRestoreState();
}

class _PasswordRestoreState extends State<PasswordRestore> {
  var authServices = AuthServices();
  bool isLoading = false;
  String _email = '';
  GlobalKey<FormState> formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
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
                flex: 1,
              ),
              logoTrans(),
              Spacer(
                flex: 4,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
                    label(text: 'Введите почту для сброса пароля'),
                    Container(
                      width: double.infinity,
                      child: TextFormField(
                        keyboardType: TextInputType.emailAddress,
                        onChanged: (value) => _email = value,
                        validator: (value) =>
                            isValidEmail(value) ? null : 'Неверная почта',
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(
                flex: 4,
              ),
              actionButton(
                text: 'Сбросить пароль',
                onPress: () => submit(),
                isLoading: isLoading,
              ),
              Spacer(
                flex: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void submit() {
    var isValidForm = formKey.currentState?.validate() ?? false;

    if (isValidForm) {
      setState(() => isLoading = true);
      authServices.resetPassword(email: _email);
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          contentPadding: EdgeInsets.only(top: 20, left: 20, right: 20),
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
                  text: '$_email',
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
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => SignIn()),
                    (route) => false);
              },
              child: Text('ОК'),
            )
          ],
        ),
      );
    }
  }
}
