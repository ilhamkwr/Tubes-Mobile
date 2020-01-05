import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:sensasiq/login_page.dart';

class LauncherPage extends StatefulWidget {
  @override
  _LauncherPageState createState() => new _LauncherPageState();
}

class _LauncherPageState extends State<LauncherPage> {
  @override
  
  void initState() {
    super.initState();
    startLaunching();
  }

  startLaunching() async {
    var duration = const Duration(seconds: 5);
    return new Timer(
      duration, () {
        Navigator.of(context).pushReplacement(
          new MaterialPageRoute(
            builder: (_) {
              return new LoginPage();
            }
          )
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new Center(
        child: ListView(
          shrinkWrap: true,
          children: <Widget>[
            new Image.asset(
              "assets/tentang.png",
              height: 300.0,
              width: 300.0,
            ),
            SizedBox(height: 40.0),
            new Text(
              "SENSASIQ APP",
              style: TextStyle(
                fontSize: 50.0, fontWeight: FontWeight.w100
              ),
              textAlign: TextAlign.center,
            ),
           ,
          ] 
        ),
      ),
    );
  }
}