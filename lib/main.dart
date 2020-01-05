import 'package:flutter/material.dart';
//import 'package:sensasiq/login_page.dart';
import 'package:sensasiq/launcher_view.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SENSASIQ-',
      theme: new ThemeData(
       
      ),
      home: new LauncherPage(),
    );
  }
}