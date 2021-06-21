import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

var textColor = Color(0xff999999);
var strokeColor = Color(0xFFE1E1E1);

DocumentReference firebaseDoc(String email) =>
    FirebaseFirestore.instance.collection('users').doc(email);

var mainGradient = LinearGradient(
  begin: Alignment.bottomLeft,
  end: Alignment.topRight,
  colors: [
    Color(0xFF70C0F8),
    Color(0xFF5CE27F),
  ],
);

var commonText = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: Color(0xff999999),
);

var headingText = TextStyle(
  fontSize: 26,
  color: Colors.white,
  fontWeight: FontWeight.w900,
);

class GradientMask extends StatelessWidget {
  GradientMask({this.child});
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      shaderCallback: (bounds) => mainGradient.createShader(bounds),
      child: child,
    );
  }
}
