import 'dart:async';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sensasiq/mainPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => new _LoginPageState();
}

String generateMd5(String input) {
  return md5.convert(utf8.encode(input)).toString();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController nim = new TextEditingController();
  TextEditingController pass = new TextEditingController();

  var namamahasiswa, nimnya, passwordnya, deviceidnya, kelasnya;

  Future<List> _login() async {
    final response = await http.post("http://192.168.43.207/sensasiq/api/mahasiswa", body: {
      "nim": nim.text,
    });

    var datauser = json.decode(response.body);

    if (datauser['error']) {
      showDialog(
          context: context,
          barrierDismissible: false,
          // ignore: deprecated_member_use
          child: new CupertinoAlertDialog(
            title: new Text("Gagal Masuk"),
            content: new Text(
              "Pengguna Tidak Ditemukan",
              style: new TextStyle(fontSize: 16.0),
            ),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: new Text("OK"))
            ],
          ));
    } else {
      if (datauser['mahasiswa'][0]['password'] != generateMd5(pass.text) || datauser['mahasiswa'][0]['nim'] != nim.text) {
        showDialog(
            context: context,
            barrierDismissible: false,
            // ignore: deprecated_member_use
            child: new CupertinoAlertDialog(
              title: new Text("Gagal Masuk"),
              content: new Text(
                "Harap Periksa NIM\natau Kata Sandi Anda",
                style: new TextStyle(fontSize: 16.0),
              ),
              actions: <Widget>[
                new FlatButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: new Text("OK"))
              ],
            ));
      } else {
        var route = new MaterialPageRoute(
          builder: (BuildContext context) => new MainPage(namamahasiswa: namamahasiswa, nimnya: nimnya, passwordnya: passwordnya, deviceidnya: deviceidnya, kelasnya: kelasnya),
        );
        Navigator.of(context).pushReplacement(route);
        setState(() {
          namamahasiswa = datauser['mahasiswa'][0]['nama_mahasiswa'];
          nimnya = datauser['mahasiswa'][0]['nim'];
          passwordnya = datauser['mahasiswa'][0]['password'];
          deviceidnya = datauser['mahasiswa'][0]['device_id'];
          kelasnya = datauser['mahasiswa'][0]['kelas'];
        });
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final logo = Hero(
      tag: 'hero',
      child: CircleAvatar(
        backgroundColor: Colors.transparent,
        radius: 48.0,
        child: Image.asset('assets/logo.png'),
      ),
    );

    final email = TextFormField(
      controller: nim,
      keyboardType: TextInputType.number,
      autofocus: false,
      decoration: InputDecoration(
        hintText: 'Nomor Induk Mahasiswa',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final password = TextFormField(
      controller: pass,
      autofocus: false,
      obscureText: true,
      decoration: InputDecoration(
        hintText: 'Kata Sandi',
        contentPadding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(32.0)),
      ),
    );

    final loginButton = Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: RaisedButton(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        onPressed: () {
          _login();
        },
        padding: EdgeInsets.all(12),
        color: Colors.lightBlueAccent,
        child: Text('Masuk', style: TextStyle(color: Colors.red)),
      ),
    );

    final forgotLabel = FlatButton(
      child: Text(
        'Lupa Sandi?',
        style: TextStyle(color: Colors.black54),
      ),
      onPressed: () {},
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: EdgeInsets.only(left: 24.0, right: 24.0),
          children: <Widget>[
            logo,
            SizedBox(height: 48.0),
            email,
            SizedBox(height: 8.0),
            password,
            SizedBox(height: 24.0),
            loginButton,
            forgotLabel
          ],
        ),
      ),
    );
  }
}
