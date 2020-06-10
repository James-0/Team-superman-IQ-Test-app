
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    _LoginPageState CreateState() => _LoginPageState();
  }

}
TextStyle style = TextStyle(fontFamily: "consolas", fontSize: 20.0);

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    final userName = TextField(
      obscureText: false,
      style: style,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Username",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );
    final passwordField = TextField(
      obscureText: true,
      style: style,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0))
      ),
    );
    final loginButton = Material(
      elevation: 5.0,
      borderRadius: BorderRadius.circular(30.0),
      color: Color(0xff01A0C7),
      child: MaterialButton(
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {

        },
        child: Text("Login",
        textAlign: TextAlign.center,
            style: style.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold
            )),
      ),
    );
    home: Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 25.0,
              ),
              userName,
              SizedBox(
                height: 25.0,
              ),
              passwordField,
              SizedBox(
                height: 35.0,
              ),
              loginButton,
              SizedBox(
                height: 15.0,
              )
            ],
          ),
        ),
      ),
    );
  }
}