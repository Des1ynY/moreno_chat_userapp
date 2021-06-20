import 'package:flutter/material.dart';

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
                flex: 5,
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
      Navigator.pop(context);
    }
  }
}
