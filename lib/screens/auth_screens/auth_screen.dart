import 'package:flutter/material.dart';

import '/services/auth_services.dart';
import '/components/auth_screens_comps.dart';
import '/screens/auth_screens/password_restore_screen.dart';
import '/theme_data.dart';
import 'reg_screen.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  var authService = AuthServices();
  bool isLoading = false;
  String _email = '', _password = '';
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
                flex: 2,
              ),
              logoTrans(),
              Spacer(
                flex: 5,
              ),
              Form(
                key: formKey,
                child: Column(
                  children: [
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
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 7,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => PasswordRestore())),
                    child: Text(
                      'Забыли пароль?',
                      style: commonText,
                    ),
                  ),
                ],
              ),
              Spacer(
                flex: 4,
              ),
              actionButton(
                text: 'Войти',
                onPress: () => submit(),
                isLoading: isLoading,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                'Еще нет аккаунта?',
                style: commonText,
              ),
              TextButton(
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => SignUp()));
                },
                child: Text(
                  'Зарегистрируйся!',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
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
    var formIsValid = formKey.currentState?.validate() ?? false;

    if (formIsValid) {
      setState(() => isLoading = true);
      authService.signIn(_email, _password).onError((error, stackTrace) {
        setState(() => isLoading = false);
        formKey.currentState?.reset();
        formKey.currentState?.validate();
      });
    }
  }
}
