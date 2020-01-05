import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

class MainPageState extends State<MainPage> {
  var title = 'Scan QR Absensi', indexMenu = 0, idqr, nip;
  String result = "Selamat Datang di SENSASIQ APP";


  Future <List<Jadwal>> _getJadwal() async {
    var jadwalRespon = await http.post('http://192.168.1.8/sensasiq/api/jadwal/jadwal', body: {
      "nim": widget.nimnya
    });
    var dataJadwal = json.decode(jadwalRespon.body);

    List<Jadwal> jadwals = [];
    for (var j in dataJadwal) {
      Jadwal jadwal = Jadwal(j["waktu"], j["nama_matkul"], j["nama_dosen"]);
      jadwals.add(jadwal);
    }
    print(jadwals.length);

    return jadwals;
  }

  Future <List<Riwayat>> _getRiwayat() async {
    var riwayatRespon = await http.post('http://192.168.1.8/sensasiq/api/absen/absen', body: {
      "nim": widget.nimnya
    });
    var dataRiwayat = json.decode(riwayatRespon.body);

    List<Riwayat> riwayats = [];
    for (var r in dataRiwayat) {
      Riwayat riwayat = Riwayat(r["waktu"], r["nama_matkul"], r["nama_dosen"]);
      riwayats.add(riwayat);
    }
    print(riwayats.length);

    return riwayats;
  }

  Drawer _buildDrawer(context) {
    return new Drawer(
      child: new ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountName: new Text('${widget.namamahasiswa}'),
            accountEmail: new Text('${widget.nimnya}'),
            currentAccountPicture: new GestureDetector(
              child: new CircleAvatar(
                backgroundColor: Colors.lightBlue,
                child: new Icon(Icons.person,color: Colors.white,),
              ),
            ),
            decoration: new BoxDecoration(
              image: new DecorationImage(
                image: new AssetImage('assets/bg_profil.png'),
                fit: BoxFit.fill,
              )
            ),
          ),
          new ListTile(
            leading: new Icon(Icons.camera_alt),
            title: new Text('Scan QR Absensi'),
            onTap: (){
              setState(() {
                this.title = 'QR Scanner';
                this.indexMenu = 1;
                this.result = "Tekan Scan Untuk Memindai QR Code";
              });
              Navigator.pop(context);
            },
          ),
          new ListTile(
            leading: new Icon(Icons.calendar_today),
            title: new Text('Jadwal Kuliah'),
            onTap: (){
              setState(() {
                this.title = 'Jadwal Kuliah';
                this.indexMenu = 2;
                this.result = "Ini halaman Jadwal";
              });
              Navigator.pop(context);
            },
          ),
          new ListTile(
            leading: new Icon(Icons.history),
            title: new Text('Riwayat Absensi'),
            onTap: (){
              setState(() {
                this.title = 'Riwayat Absensi';
                this.indexMenu = 3;
                this.result = "Ini halaman Riwayat";
              });
              Navigator.pop(context);
            },
          ),
          new ListTile(
            leading: new Icon(Icons.settings_applications),
            title: new Text('Pengaturan Akun'),
            onTap: (){
              setState(() {
                this.title = 'Pengaturan Akun';
                this.indexMenu = 4;
                this.result = "Ini halaman Pengaturan";
              });
              Navigator.pop(context);
            },
          ),
          new Divider(
            color: Colors.black12,
            indent: 15.0,
          ),
          new ListTile(
            title: new Text('Bantuan'),
            onTap: (){
              setState(() {
                this.title = 'Bantuan';
                this.indexMenu = 5;
                this.result = "Ini halaman Bantuan";
              });
              Navigator.pop(context);
            },
          ),
          new ListTile(
            title: new Text('Tentang'),
            onTap: (){
              setState(() {
                this.title = 'Tentang';
                this.indexMenu = 6;
                this.result = "Ini halaman Tentang";
              });
              Navigator.pop(context);
            },
          )
        ],
      ),
    );
  }
  @override
  

  Widget build(BuildContext context) {
    Future _scanQR() async {
      try {
        String qrResult = await BarcodeScanner.scan();
        this.result = qrResult;
          this.indexMenu = 1;
          final response = await http.post("http://192.168.1.8/sensasiq/api/qr/cocok", body: {
           "qr": result,
          });
          var datauser = json.decode(response.body);
          if((datauser['error']) || (datauser['qr'][0]['qr']!=result)){
            setState(() {
              result = "Kode QR tidak valid!";
            });
          } else {
            this.indexMenu = null;
            nip = datauser['qr'][0]['nip'];
            final hasil = await http.post("http://192.168.1.8/sensasiq/api/absen/add", body: {
              "id_jadwal": datauser['qr'][0]['qr'].split('-')[0],
              "id_qr": datauser['qr'][0]['id_qr'],
              "nim": widget.nimnya
            });
            json.decode(hasil.body);
            setState(() {
              result = "Berhasil Scan QR! Absen Berhasil!";
            });
          }
      } on FormatException {
        setState(() {
          this.result = "Anda menekan tombol kembali sebelum memindai apa pun";
        });
      } catch (ex) {
        setState(() {
          this.result = "Unknown Error $ex";
        });
      }
    }

    switch (this.indexMenu) {
      case 1:
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(this.title),
            centerTitle: true,
          ),
          // KONTEN
          body: Center(
            child: Text(
              result,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            icon: Icon(Icons.camera_alt),
            label: Text("Scan",style: new TextStyle(fontWeight: FontWeight.bold)),
            onPressed: _scanQR,
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
          drawer: _buildDrawer(context),
        );
        break;
      case 2:
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(this.title),
            centerTitle: true,
          ),
          // KONTEN
          body: Container(
            child: FutureBuilder(
              future: _getJadwal(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.data == null){
                  return Container(
                    child: Center(
                      child: Text("Memuat...")
                    )
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index){
                      return ListTile(
                        title: Text("Mata Kuliah : "+snapshot.data[index].namamatkul ?? ''),
                        subtitle: Text(snapshot.data[index].waktu+"\n Dosen : "+snapshot.data[index].namadosen ?? ''),.
                      );
                    },
                  );
                }
              },
            ),
          ),
          drawer: _buildDrawer(context),
        );
        break;
      case 3:
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(this.title),
            centerTitle: true,
          ),
          // KONTEN
          body: Container(
            child: FutureBuilder(
              future: _getRiwayat(),
              builder: (BuildContext context, AsyncSnapshot snapshot){
                if(snapshot.data == null){
                  return Container(
                    child: Center(
                      child: Text("Memuat...")
                    )
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (BuildContext context, int index){
                      return ListTile(
                        title: Text(snapshot.data[index].riwayatwaktu ?? ''),
                        subtitle: Text(snapshot.data[index].riwayatmatkul+"\n Dosen : "+snapshot.data[index].riwayatdosen ?? ''),
                      );
                    },
                  );
                }
              },
            ),
          ),
          drawer: _buildDrawer(context),
        );
        break;
      case 4:
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(this.title),
            centerTitle: true,
          ),
          // KONTEN
          body: Center(
            child: Text(
              result,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          drawer: _buildDrawer(context),
        );
        break;
      case 5:
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(this.title),
            centerTitle: true,
          ),
          // KONTEN
          body: Center(
            child: Text(
              result,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          drawer: _buildDrawer(context),
        );
        break;
      case 6:
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(this.title),
            centerTitle: true,
          ),
          // KONTEN
          body: Center(
            child: Text(
              result,
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          drawer: _buildDrawer(context),
        );
        break;
      default:
        return new Scaffold(
          appBar: new AppBar(
            title: new Text(this.title),
            centerTitle: true,
          ),
          // KONTEN
          body: Center(
            child: Text(
              result,
              style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ),
          drawer: _buildDrawer(context),
        );
        break;
    }
  }
}

class MainPage extends StatefulWidget {
  final String namamahasiswa, nimnya, kelasnya, deviceidnya, passwordnya;
  MainPage({
    Key key,
    this.namamahasiswa,
    this.nimnya,
    this.kelasnya,
    this.deviceidnya,
    this.passwordnya
    }
  ) : super(key: key);
  
  @override
  State<StatefulWidget> createState() {
    return new MainPageState();
  }
}

class Jadwal {
  final String namamatkul, waktu, namadosen;
  Jadwal(this.namamatkul, this.waktu, this.namadosen);
}

class Riwayat {
  final String riwayatmatkul, riwayatwaktu, riwayatdosen;
  Riwayat(this.riwayatwaktu, this.riwayatmatkul, this.riwayatdosen);
}