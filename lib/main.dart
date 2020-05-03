import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:test2app/Classes/weather.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flare_flutter/flare_actor.dart';
import 'package:geopoint/geopoint.dart';
import 'package:geopoint_location/geopoint_location.dart';

void main() => runApp(MyApp());
enum light { Day, Night }

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
      routes: {'forecast': (context) => Forecast()},
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key) {}

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    // this.getLocation;
    initializeDateFormatting();
    new Timer(const Duration(milliseconds: 2000), getLocation);
    super.initState();
  }

  static const String weatherAPI = "16735a4cce59537122a4ded9ccf7a23d";
  static const String url =
      'https://api.openweathermap.org/data/2.5/weather?q=london&appid=16735a4cce59537122a4ded9ccf7a23d';

  bool isReady = false;
  static String address = '';
  Weather weatherMain = new Weather({}, [], {}, {}, {});
  void getLocation() async {
    print("getloca");
    print("ddd");
    GeoPoint geoPoint = await geoPointFromLocation(
        name: "Current position",
        withAddress: true,
        locationAccuracy: LocationAccuracy.best);

    address = geoPoint.locality + ", " + geoPoint.country;
    getWeather(geoPoint.locality);
    print("Finishgetlocation");
  }

  Future<dynamic> getWeather(location) async {
    print("getWeather");

    final String url =
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=16735a4cce59537122a4ded9ccf7a23d&units=metric';
    await http.get(url).then((response) {
      print(response.body);
      var res = json.decode(response.body);
      print(res["coord"]);
      setState(() {
        weatherMain = new Weather(
            res["coord"], res["weather"], res["main"], res["wind"], res["sys"]);
      });

      print("Finish Getweather");
      setState(() {
        print("READY");

        this.isReady = true;
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
    http.get(url).then((response) {
      print(response.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    print("Build");
    if (isReady == false) {
      return Scaffold(
        body: Center(
          child: Column(
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: Stack(
                  children: <Widget>[
                    FlareActor(
                      "images/Clouds3.flr", // You can find the example project here: https://www.2dimensions.com/a/castor/files/flare/change-color-example
                      fit: BoxFit.contain,
                      animation: "fade",
                    ),
                    Center(
                        child: Text(
                      "Loading...",
                      style: TextStyle(fontSize: 20),
                    )),
                  ],
                ),
              )
            ],
          ),
        ),
      );
    } else {
      double currTemp = weatherMain.main["temp"];
      PanelController _pc = new PanelController();
      double border = 0.0;
      int now = new DateTime.now().hour;
      bool isNight =
          (now > 18 && now <= 23) || (now >= 00 && now <= 10) ? true : false;
      int tmp = currTemp.toInt();
      String imageURL =
          "http://openweathermap.org/img/wn/${weatherMain.weather[0]["icon"]}@2x.png";

      BorderRadiusGeometry radius = BorderRadius.only(
        topLeft: Radius.circular(24.0),
        topRight: Radius.circular(24.0),
      );

      setBorder() {
        print("setBorder");
        setState(() {
          border = 20;
        });
      }

      return Scaffold(
          body: SlidingUpPanel(
        controller: _pc,
        borderRadius: radius,
        backdropEnabled: true,
        onPanelOpened: setBorder,
        panel: ListWeather(weatherMain),
        body: Container(
          decoration: BoxDecoration(
            border: Border.all(width: border),
            image: DecorationImage(
              image: AssetImage(
                  MainWallpaper(weatherMain.weather[0]["description"])),
              fit: BoxFit.cover,
            ),
          ),
          height: 400,
          child: Center(
            child: !isReady
                ? Text("Loading...")
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Center(
                                child: Row(
                                  children: <Widget>[
                                    Icon(
                                      Icons.location_on,
                                      color:
                                          isNight ? Colors.white : Colors.black,
                                    ),
                                    Text(
                                      address,
                                      style: TextStyle(
                                          fontSize: 24,
                                          letterSpacing: 1.5,
                                          color: isNight
                                              ? Colors.white
                                              : Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                weatherMain.weather[0]["description"],
                                style: TextStyle(
                                    fontSize: 20,
                                    color:
                                        isNight ? Colors.white : Colors.black),
                              ),
                              GestureDetector(
                                child: Hero(
                                    tag: 'hero-anim',
                                    child: Image.network(imageURL)),
                                onTap: () => Navigator.of(context).pushNamed(
                                    'forecast',
                                    arguments: [weatherMain.coords, imageURL]),
                              ),
                              Text(
                                "${tmp.toString()}°",
                                style: TextStyle(
                                    fontSize: 70,
                                    color:
                                        isNight ? Colors.white : Colors.black),
                              ),
                              SizedBox(
                                height: 200,
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
        ),
      ) // This trailing comma makes auto-formatting nicer for build methods.
          );
    }

    // @override
    // didChangeDependencies() {
    //   print("didChangeDependencies");
    //   getLocation();
    //   super.didChangeDependencies();
    // }
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
    // int tmp = currTemp.toInt();
    return Column(
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Text("More",
                    style: TextStyle(fontSize: 20, letterSpacing: 2)),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
              alignment: Alignment.center,
              height: 200,
              width: 300,
              child: Center(
                child: GridView.count(
                  crossAxisCount: 3,
                  crossAxisSpacing: 1,
                  mainAxisSpacing: 1,
                  childAspectRatio: MediaQuery.of(context).size.width /
                      (MediaQuery.of(context).size.height / 5),
                  children: <Widget>[
                    Item("Wind"),
                    Image.asset("images/wind.png"),
                    Item("${widget.newWeather.wind["speed"].toString()} m/s"),
                    Item("Humadity"),
                    Image.asset("images/humidity.png"),
                    Item("${widget.newWeather.main["humidity"]}%".toString()),
                    Item("Pressure"),
                    Image.asset("images/pressure.png"),
                    Item(
                        "${widget.newWeather.main["pressure"]} hPa".toString()),
                    Item("Sea level"),
                    Image.asset("images/sea.png"),
                    Item(widget.newWeather.main["sea_level"].toString()),
                    Item("Sunrise"),
                    Image.asset("images/sunrise.png"),
                    ItemTime(widget.newWeather.sys["sunrise"]),
                    Item("Sunset"),
                    Image.asset("images/sunset.png"),
                    ItemTime(widget.newWeather.sys["sunset"]),
                  ],
                ),
              )),
        )
      ],
    );
  }
}

class Item extends StatelessWidget {
  String title;

  Item(@required this.title) {}

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18),
    );
  }
}

class ItemTime extends StatelessWidget {
  int time;

  ItemTime(@required this.time) {}
  @override
  Widget build(BuildContext context) {
    var newTime = new DateTime.fromMillisecondsSinceEpoch(time * 1000);
    String formattedDate = DateFormat('HH:mm').format(newTime);
    return Text(
      formattedDate.toString(),
      textAlign: TextAlign.center,
      style: TextStyle(fontSize: 18),
    );
  }
}

class MainBackground extends StatelessWidget {
  String weather;
  MainBackground(@required this.weather) {}
  static int now = new DateTime.now().hour;
  light dayTime = now > 18 && now < 6 ? light.Night : light.Day;
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

String MainWallpaper(String weather) {
  DateTime n = new DateTime.now();
  String hr = new DateFormat('HH').format(n);
  var format = new DateFormat.Hm();

  String formattedDate = format.format(DateTime.now());
  int now = int.parse(hr);
  String path = "";
  light dayTime = (now >= 18 && now <= 23) || (now >= 00 && now <= 10)
      ? light.Night
      : light.Day;

  print("dayTime " + dayTime.toString());
  print("NOWWW " + now.toString());

  weather = weather.replaceAll(" ", "_");
  print("weee " + weather);

  switch (dayTime) {
    case light.Night:
      path = "images/${weather}_night.jpg";
      break;
    case light.Day:
      path = "images/$weather.jpg";
      break;
  }
  print("PATHHH " + path);
  return path;
}

class Forecast extends StatefulWidget {
  @override
  _ForecastState createState() => _ForecastState();
}

class _ForecastState extends State<Forecast> {
  List forecast = [];
  bool isInit = false;
  Future getForecast() async {
    print("in foreeeeecast");
    List data = ModalRoute.of(context).settings.arguments;
    print("data " + data.toString());
    final String url =
        'https://api.openweathermap.org/data/2.5/forecast?lat=${data[0]["lat"]}&lon=${data[0]["lon"]}&appid=16735a4cce59537122a4ded9ccf7a23d&cnt=16&units=metric';

    print("url " + url);
    await http.get(url).then((response) {
      setState(() {
        this.forecast = json.decode(response.body)["list"];
      });
      print("forecast " + this.forecast.toString());
    });
  }

  didChangeDependencies() {
    if (!isInit) {
      isInit = true;
      getForecast();
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    List args = ModalRoute.of(context).settings.arguments;

    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("images/forecast.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  SizedBox(
                    height: 60,
                  ),
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Icon(Icons.arrow_back),
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Hero(
                        tag: "hero-anim",
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.network(
                            args[1],
                            height: 120,
                            width: 120,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: <Widget>[
                      Text("Next 5 days...",
                          style: TextStyle(fontSize: 25, letterSpacing: 3))
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    width: 300,
                    height: 550,
                    child: ListView.builder(
                        itemCount: this.forecast.length,
                        itemBuilder: (ctx, i) {
                          return Container(
                            child: Card(
                              elevation: 3,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: <Widget>[
                                    TimeConv(this.forecast[i]["dt"]),
                                    Container(
                                      height: 50,
                                      width: 50,
                                      child: Image.network(
                                        "http://openweathermap.org/img/wn/${this.forecast[i]["weather"][0]["icon"]}@2x.png",
                                        height: 120,
                                        width: 120,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                    Text(this.forecast[i]["weather"][0]["main"])
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

class TimeConv extends StatelessWidget {
  int time;
  TimeConv(@required int this.time);

  @override
  Widget build(BuildContext context) {
    var newTime = new DateTime.fromMillisecondsSinceEpoch(time * 1000);
    String formattedDate = DateFormat('MM/dd HH:00').format(newTime);
    return Text(formattedDate);
  }
}
