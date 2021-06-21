import 'package:flutter/material.dart';

import '/theme_data.dart';

Container logoTrans() {
  return Container(
    height: 200,
    child: Image.asset('assets/logo_trans.png'),
  );
}

Container label({required String text}) {
  return Container(
    width: double.infinity,
    child: Text(
      text,
      style: TextStyle(
        color: textColor,
        fontSize: 15,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}

Container actionButton(
    {required String text,
    required onPress(),
    required bool isLoading,
    double? fontSize = 24}) {
  return Container(
    height: 50,
    width: 260,
    decoration: BoxDecoration(
      gradient: mainGradient,
      borderRadius: BorderRadius.circular(10),
    ),
    child: isLoading
        ? Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          )
        : MaterialButton(
            onPressed: () => onPress(),
            child: Text(
              text,
              style: TextStyle(
                fontSize: fontSize,
                color: Colors.white,
              ),
            ),
          ),
  );
}

bool isValidEmail(String? value) {
  if (value != null) {
    return RegExp(
            r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
  } else {
    return false;
  }
}

bool isValidPassword(String? value) {
  if (value != null) {
    if (value.length >= 6) {
      return RegExp(r"^[a-zA-Z0-9]+").hasMatch(value);
    } else {
      return false;
    }
  } else {
    return false;
  }
}
