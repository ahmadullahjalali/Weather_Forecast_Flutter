// ignore_for_file: unused_local_variable

import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart' hide ModalBottomSheetRoute;
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_focast/components/weather_item.dart';
import 'package:weather_focast/constants.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _cityController = TextEditingController();
  final Constants _constants = Constants();
  // static String API_KEY = "e34a441928fe47ab93f111628222605";
  static String API_KEY = 'e895c165d7af4dd39ec103720232107';

  String location = 'Herat'; //Defult location
  String weatherIcon = 'clear.png';
  int temperature = 0;
  int windSpeed = 0;
  int humidity = 0;
  int cloud = 0;

  List hourlyWeatherForecast = [];
  List dailyWeatherForecast = [];

  String currentWeatherStatus = '';

  // API Call
  String searchWeatherAPI = "https://api.weatherapi.com/v1/forecast.json?key=" +
      API_KEY +
      "&days=7&q=";

  String get currentDate => currentDate;

  void fetchWeatherData(String searchText) async {
    try {
      var searchResult = await http.get(
        Uri.parse(searchWeatherAPI + searchText),
      );

      final weatherData = Map<String, dynamic>.from(
          json.decode(searchResult.body) ?? 'No data');

      var locationData = weatherData["location"];
      var currentWeather = weatherData["current"];

      setState(() {
        location = getShortLocationName(locationData["name"]);

        var parsedDate =
            DateTime.parse(locationData["localtime"].substring(0, 10));
        var newDate = DateFormat('MMMMEEEEd').format(parsedDate);
        var currentDate = newDate;

        // // update the weather

        currentWeatherStatus = currentWeather["condition"]["text"];
        weatherIcon =
            currentWeatherStatus.replaceAll(' ', ' ').toLowerCase() + ".png";
        temperature = currentWeather['temp_c'].toInt();
        humidity = currentWeather['humidity'].toInt();
        windSpeed = currentWeather['wind_kph'].toInt();
        cloud = currentWeather['cloud'].toInt();

        // // Forcast Data
        dailyWeatherForecast = weatherData["forecast"]["forecastday"];
        hourlyWeatherForecast = dailyWeatherForecast[0]["hour"];
      });
    } catch (e) {
      // debugPrint(e):
    }
  }

  static getShortLocationName(String s) {
    List<String> wordList = s.split(" ");

    if (wordList.isNotEmpty) {
      if (wordList.length > 1) {
        return wordList[0] + " " + wordList[1];
      } else {
        return wordList[0];
      }
    } else {
      return " ";
    }
  }

  @override
  void initState() {
    fetchWeatherData(location);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: SystemUiOverlay.values);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: size.width,
        height: size.height,
        padding: const EdgeInsets.only(top: 30, left: 10, right: 10),
        color: _constants.primaryColor.withOpacity(.1),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              height: size.height * .7,
              decoration: BoxDecoration(
                gradient: _constants.LinearGradientBlue,
                boxShadow: [
                  BoxShadow(
                    color: _constants.primaryColor.withOpacity(.5),
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        "images/weather-app.png",
                        width: 40,
                        height: 40,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "images/pin.png",
                            width: 20,
                          ),
                          SizedBox(width: 2),
                          Text(
                            location,
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                          IconButton(
                            onPressed: () {
                              _cityController.clear();
                              showMaterialModalBottomSheet(
                                context: context,
                                builder: (context) => SingleChildScrollView(
                                  controller: ModalScrollController.of(context),
                                  child: Container(
                                    height: size.height * .2,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20),
                                    child: Column(
                                      children: [
                                        SizedBox(
                                          width: 70,
                                          child: Divider(
                                            thickness: 3.5,
                                            color: _constants.primaryColor,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        TextField(
                                          onChanged: (searchText) {
                                            fetchWeatherData(searchText);
                                          },
                                          controller: _cityController,
                                          autofocus: true,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.search,
                                              color: _constants.primaryColor,
                                            ),
                                            suffixIcon: GestureDetector(
                                              onTap: () =>
                                                  _cityController.clear(),
                                              child: Icon(Icons.close,
                                                  color:
                                                      _constants.primaryColor),
                                            ),
                                            hintText: 'Search city e.g. Kabul',
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: BorderSide(
                                                  color:
                                                      _constants.primaryColor),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.asset(
                          "images/profile.png",
                          width: 40,
                          height: 40,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 75,
                    child: Image.asset("images/" + weatherIcon),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          temperature.toString(),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            foreground: Paint()..shader = _constants.shader,
                          ),
                        ),
                      ),
                      Text(
                        'o',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()..shader = _constants.shader,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currentWeatherStatus,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 20.0,
                    ),
                  ),
                  // Text(
                  //   currentDate,
                  //   style: const TextStyle(
                  //     color: Colors.white70,
                  //   ),
                  // ),
                  // Container(
                  //   padding: const EdgeInsets.symmetric(horizontal: 20),
                  //   child: const Divider(
                  //     color: Colors.white70,
                  //   ),
                  // ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 40),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        WeatherItem(
                          imageUrl: "images/windspeed.png",
                          unit: 'km/h',
                          value: windSpeed.toInt(),
                        ),
                        WeatherItem(
                          imageUrl: "images/humidity.png",
                          unit: '%',
                          value: humidity.toInt(),
                        ),
                        WeatherItem(
                          imageUrl: "images/clear.png",
                          unit: '%',
                          value: cloud.toInt(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 10),
              height: size.height * .20,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Today',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20.0,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => print('Tapped'),
                        child: Text(
                          'Forcast',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: _constants.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 8,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 110,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: AlwaysScrollableScrollPhysics(),
                        itemBuilder: (BuildContext context, int index) {
                          String currentTime =
                              DateFormat('HH:mm:ss').format(DateTime.now());
                          String currentHour = currentTime.substring(0, 2);

                          String forcastTime = hourlyWeatherForecast[index]
                                  ["time"]
                              .substring(11, 16);
                          String forcastHour = hourlyWeatherForecast[index]
                                  ["time"]
                              .substring(11, 13);

                          String forcastWeatherName =
                              hourlyWeatherForecast[index]["condition"]["text"];
                          String forcastWeatherIcon = forcastWeatherName
                                  .replaceAll(' ', ' ')
                                  .toLowerCase() +
                              ".png";

                          String forcastTemperature =
                              hourlyWeatherForecast[index]["temp_c"]
                                  .round()
                                  .toString();

                          return Container(
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            margin: const EdgeInsets.only(right: 20),
                            width: 65,
                            decoration: BoxDecoration(
                              color: currentHour == forcastHour
                                  ? Colors.white
                                  : _constants.primaryColor,
                              borderRadius: const BorderRadius.all(
                                Radius.circular(50),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  offset: const Offset(0, 1),
                                  blurRadius: 5,
                                  color:
                                      _constants.primaryColor.withOpacity(.2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  forcastTime,
                                  style: TextStyle(
                                      fontSize: 16,
                                      color: _constants.greyColor,
                                      fontWeight: FontWeight.w500),
                                ),
                                Image.asset(
                                  "images/" + forcastWeatherIcon,
                                  width: 20,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(top: 2.0),
                                      child: Text(
                                        forcastTemperature,
                                        style: TextStyle(
                                            fontSize: 17,
                                            color: _constants.greyColor,
                                            fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                    Text(
                                      'o',
                                      style: TextStyle(
                                        fontSize: 17,
                                        color: _constants.greyColor,
                                        fontWeight: FontWeight.w600,
                                        fontFeatures: const [
                                          FontFeature.enable('sups'),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
