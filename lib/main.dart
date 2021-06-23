import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'theme_data.dart';
import 'screens/auth_screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'services/auth_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
    [DeviceOrientation.portraitUp],
  );
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<AuthServices>(
          create: (_) => AuthServices(),
        ),
        StreamProvider(
            initialData: null,
            create: (context) =>
                context.read<AuthServices>().authStateChanges()),
      ],
      child: MaterialApp(
        builder: (context, child) {
          return ScrollConfiguration(
              behavior: NoGlowScrollEffect(), child: child ?? Container());
        },
        title: 'MORENO',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white,
        ),
        home: AuthChecker(),
      ),
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var currentUser = context.watch<User?>();

    if (currentUser != null) {
      return HomeScreen(userEmail: currentUser.email ?? '');
    } else {
      return SignIn();
    }
  }
}
