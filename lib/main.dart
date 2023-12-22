import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

//ページ
import 'LoginPage.dart';
import 'KinmuCalendarPage.dart';
import 'database/databasefunc.dart';
// import 'test.dart';

void main() async{
  //日本の時間に設定
  initializeDateFormatting('ja');

  //firebase使うのに必要
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyAXkEfdiQTJllk76kPNAyq8lgQct7DEG40",
        authDomain: "mykintaiapp.firebaseapp.com",
        projectId: "mykintaiapp",
        storageBucket: "mykintaiapp.appspot.com",
        messagingSenderId: "141934888252",
        appId: "1:141934888252:web:d4a686717c4c86db098a39"),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  ///画面上にローディングアニメーションを表示する
  Widget createProgressIndicator() {
    return Container(
      alignment: Alignment.center,
      child: const CircularProgressIndicator(
        color: Colors.green,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.light,
        /* light theme settings */
      ),
      darkTheme: ThemeData(
        useMaterial3: false,
        brightness: Brightness.dark,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.dark, 
      /* ThemeMode.system to follow system theme, 
         ThemeMode.light for light theme, 
         ThemeMode.dark for dark theme
      */
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // スプラッシュ画面などに書き換えても良い
            // return const SizedBox();
            return createProgressIndicator();
          }
          if (snapshot.hasData) {
            // User が null でなない、つまりサインイン済みのホーム画面へ
            return KinmuCalendarPage();
            // return TableMultiExample();
          }
          // User が null である、つまり未サインインのサインイン画面へ
          return LoginPage();
        },
      ),
    );
  }
}