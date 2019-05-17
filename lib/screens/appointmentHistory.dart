import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fast_turtle_v2/dbHelper/searchData.dart';
import 'package:fast_turtle_v2/models/doktorModel.dart';
import 'package:fast_turtle_v2/models/passiveAppoModel.dart';
import 'package:fast_turtle_v2/models/userModel.dart';
import 'package:flutter/material.dart';

class AppointmentHistory extends StatefulWidget {
  final User user;
  AppointmentHistory(this.user);
  @override
  _AppointmentHistoryState createState() => _AppointmentHistoryState(user);
}

class _AppointmentHistoryState extends State<AppointmentHistory> {
  _AppointmentHistoryState(this.user);
  User user;
  Doktor doktor = Doktor();

  String gonder;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Geçmiş Randevularınız"),
      ),
      body: _buildStremBuilder(context),
    );
  }

  _buildStremBuilder(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: Firestore.instance.collection("tblRandevuGecmisi").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return LinearProgressIndicator();
        } else {
          return _buildBody(context, snapshot.data.documents);
        }
      },
    );
  }

  Widget _buildBody(BuildContext context, List<DocumentSnapshot> snapshot) {
    return ListView(
      padding: EdgeInsets.only(top: 15.0),
      children: snapshot
          .map<Widget>((data) => _buildListItem(context, data))
          .toList(),
    );
  }

  _buildListItem(BuildContext context, DocumentSnapshot data) {
    final randevu = PassAppointment.fromSnapshot(data);
    findDoktorName(randevu.doktorTCKN).then((value) {
      setState(() {
        gonder =
            (doktor.adi.toString() + " " + doktor.soyadi.toString()).toString();
      });
    });
    return Padding(
      key: ValueKey(randevu.reference),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.greenAccent,
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(10.0)),
        child: ListTile(
          leading: CircleAvatar(
            child: Icon(Icons.healing),
          ),
          title: Text(
            gonder.toString(),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
          ),
          subtitle: Text(randevu.islemTarihi),
          onTap: () {},
        ),
      ),
    );
  }

  findDoktorName(String sentId) async {
    await SearchService().searchDoctorById(sentId).then((QuerySnapshot docs) {
      doktor = Doktor.fromMap(docs.documents[0].data);
      gonder = (doktor.adi + " " + doktor.soyadi).toString();
    });
  }
}
