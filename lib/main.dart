import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:test2app/Classes/weather.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const String weatherAPI = "16735a4cce59537122a4ded9ccf7a23d";
  static const String url =
      'https://api.openweathermap.org/data/2.5/weather?q=london&appid=16735a4cce59537122a4ded9ccf7a23d';
  bool isShown = false;
  static String address = '';
  Weather weatherMain = new Weather({}, [], {}, {});
  Future<String> getLocation() {
    final Geolocator geoLocator = Geolocator();
    geoLocator.checkGeolocationPermissionStatus();
    geoLocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.best)
        .then((response) {
      geoLocator
          .placemarkFromCoordinates(response.latitude, response.longitude)
          .then((data) {
        data.take(1).forEach((el) {
          print(el);
          getWeather(el.locality);
          address = el.locality + ", " + el.country;
        });
      });
    });
    print(address);
  }

  Future<dynamic> getWeather(location) {
    final String url =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=16735a4cce59537122a4ded9ccf7a23d&units=metric';
    http.get(url).then((response) {
      print(response.body);
      var res = json.decode(response.body);
      print(res["coord"]);
      setState(() {
        weatherMain =
            new Weather(res["coord"], res["weather"], res["main"], res["wind"]);
      });

      // weather.setCoords(res["coord"]);
      // weather.coords = res["coord"];
      // weather.weather = res["weather"];
      // weather.wind = res["wind"];
      // weather.visibility = res["visibility"];

      // print("weather is : "+ weather.toString());
    });
  }

  getData() {
    setState(() {
      isShown = true;
    });
    http.get(url).then((response) {
      print(response.body);
      setState(() {
        isShown = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.title),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 50,
                  ),
                  Center(
                    child: Text(
                      address,
                      style: TextStyle(fontSize: 24, letterSpacing: 1.5),
                    ),
                  ),
                 
                ],
              ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                 ListWeather(weatherMain)
                ],
              ),
            )
            ],
          ),
        ) // This trailing comma makes auto-formatting nicer for build methods.
        );
  }

  @override
  didChangeDependencies() {
    print("didChangeDependencies");
    getLocation();
    super.didChangeDependencies();
  }
}
//  ListWeather(weatherMain)
class ListWeather extends StatefulWidget {
  Weather newWeather;
  ListWeather(this.newWeather);
  @override
  _ListWeatherState createState() => _ListWeatherState();
}

class _ListWeatherState extends State<ListWeather> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text(widget.newWeather.main["temp"].toString()),
    );
  }
}
