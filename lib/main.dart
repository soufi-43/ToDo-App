import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todoapp/auth/login.dart';
import 'package:todoapp/todo/home.dart';

void main() async {
WidgetsFlutterBinding.ensureInitialized();
Widget homeScreen=HomeScreen() ;

FirebaseUser user = await FirebaseAuth.instance.currentUser();

if(user==null){
  homeScreen = LoginScreen();

}

runApp(ToDoApp(homeScreen));


}


class ToDoApp extends StatelessWidget {
  final Widget home ;


  ToDoApp(this.home);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.teal
      ),
      home: home,
    );
  }
}


