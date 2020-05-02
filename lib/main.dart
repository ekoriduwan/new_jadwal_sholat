import 'package:flutter/material.dart';
import './models/prayer_time.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

void main() {
  runApp(new MaterialApp(
    title: 'Jadwal Sholat',
    home: new Home(),
  ));
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;
  Position userLocation;

  List<String> dummy = [
    "Fajr",
    "Terbit",
    "Duhur",
    "Ashar",
    "Terbenam",
    "Magrib",
    "Isha"
  ];

  List<String> _prayerTimes = [];
  List<String> _prayerNames = [];

  @override
  void initState() {
    super.initState();

    _getLocation().then((position) {
      userLocation = position;
      getPrayerTimes(userLocation.latitude, userLocation.longitude);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal,
      body: SafeArea(
          child: Container(
        child: Column(children: <Widget>[
          SizedBox(height: 30),
          Container(
            width: double.infinity,
            child: Image.asset('assets/img/logo_jadwalsholat.png'),
          ),
          SizedBox(height: 10),
          Container(
              height: MediaQuery.of(context).size.height * 0.45,
              child: ListView.builder(
                  itemCount: _prayerNames.length,
                  itemBuilder: (context, position) {
                    return Container(
                        padding: EdgeInsets.all(5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Container(
                                width: 120,
                                child: Text(_prayerNames[position],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Montserrat',
                                    ))),
                            SizedBox(width: 10),
                            Container(
                              width: 150,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                                color: Colors.teal[50],
                              ),
                              child: Text(
                                _prayerTimes[position],
                                style: TextStyle(
                                    color: Colors.teal,
                                    fontSize: 20,
                                    fontFamily: 'Monserrat',
                                    fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ));
                  })),
          SizedBox(height: 10),
          FlatButton.icon(
              onPressed: () {
                _getLocation().then((value) {
                  setState(() {
                    userLocation = value;
                    getPrayerTimes(
                        userLocation.latitude, userLocation.longitude);
                  });
                });
              },
              icon: Icon(
                Icons.location_on,
                color: Colors.white,
              ),
              label: Text(
                userLocation != null
                    ? "Lokasi: lat : ${userLocation.latitude.toString()} , long: ${userLocation.longitude.toString()}"
                    : "Mencari lokasi ...",
                style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                    fontSize: 14),
              ))
        ]),
      )),
    );
  }

  Future<Position> _getLocation() async {
    var currentLocation;

    try {
      currentLocation = await geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.best);
    } catch (e) {
      currentLocation = null;
    }
    return currentLocation;
  }

  getPrayerTimes(double lat, double long) {
    PrayerTime prayers = new PrayerTime();

    prayers.setTimeFormat(prayers.getTime12());
    prayers.setCalcMethod(prayers.getMWL());
    prayers.setAsrJuristic(prayers.getShafii());
    prayers.setAdjustHighLats(prayers.getAdjustHighLats());

    List<int> offsets = [-6, 0, 3, 2, 0, 3, 6];

    String tmx = "${DateTime.now().timeZoneOffset}";

    var currentTime = DateTime.now();
    var timeZone = double.parse(tmx[0]);

    prayers.tune(offsets);

    setState(() {
      _prayerTimes = prayers.getPrayerTimes(currentTime, lat, long, timeZone);
      _prayerNames = prayers.getTimeNames();
    });
  }
}
