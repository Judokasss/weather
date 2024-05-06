import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:petproject/search.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dictionary.dart';
import 'mywidget.dart';
import 'package:geolocator/geolocator.dart'; // Добавлено для работы с геолокацией

void main() {
  runApp(const WeatherApp());
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String temperature = '';
  String condition = '';
  String iconCode = '';
  String feelsLike = '';
  String pressuremm = '';
  String windSpeed = '';
  String humidity = '';
  List<dynamic> hourlyForecastData = [];
  DateTime adjustedDateTime = DateTime.now();
  String locality = ''; // Переменная для хранения города по координатам
  bool isLoading =
      true; // Добавим переменную для отслеживания состояния загрузки

  @override
  void initState() {
    super.initState();
    //fetchWeather();
    requestLocationPermission(); // Инициируем запрос геолокации при входе в приложение
  }

  // Метод для запроса геолокации
  void requestLocationPermission() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      // Если пользователь отказал в доступе к геолокации, обработайте это здесь
    } else if (permission == LocationPermission.deniedForever) {
      // Если пользователь навсегда запретил доступ к геолокации, обработайте это здесь
    } else {
      // Получаем текущее местоположение
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      // Получаем координаты
      double latitude = position.latitude;
      double longitude = position.longitude;
      // Запрашиваем погоду для текущего местоположения пользователя
      fetchWeather(latitude, longitude);
    }
  }

  Future<void> fetchWeather(double latitude, double longitude) async {
    final accessKey = '2317fee3-f824-4cd2-80b4-1f1601425d43';
    setState(() {
      isLoading =
          true; // Устанавливаем isLoading в true перед началом загрузки данных
    });
    final response = await http.get(
        Uri.parse(
            'https://api.weather.yandex.ru/v2/forecast?lat=$latitude&lon=$longitude&lang=ru_RU'),
        headers: {'X-Yandex-Weather-Key': accessKey});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // Выводим всю полученную информацию в консоль.При обчном выводе непонятные символы мы их преобразуем
      final localityBytes =
          data['geo_object']['locality']['name'].toString().codeUnits;
      setState(() {
        locality = utf8.decode(localityBytes); // Assign to class variable
      });
      print('Населенный пункт: $locality');

      //print(data);
      // Получение времени сервера
      // Получаем текущее время сервера в формате Unixtime
      //final int unixTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      // Извлекаем информацию о часовом поясе из данных API
      final tzinfo = data['info']['tzinfo'];
      //print(tzinfo);
      // Получаем смещение часового пояса из tzinfo
      final int offsetSeconds = tzinfo['offset'];
      // Добавляем смещение к текущему времени сервера
      //final int adjustedUnixTime = unixTime + offsetSeconds;
      // Преобразуем скорректированное время в формат DateTime
      //adjustedDateTime =
      //   DateTime.fromMillisecondsSinceEpoch(adjustedUnixTime * 1000);

      // Выводим скорректированное время
      print('Скорректированное время11: $adjustedDateTime');
      // Получаем время из now_dt и преобразуем его в DateTime
      final String serverTimeString = data['now_dt'];
      final DateTime serverDateTime = DateTime.parse(serverTimeString);
      // Добавляем смещение часового пояса к времени из now_dt
      final DateTime adjustedServerDateTime =
          serverDateTime.add(Duration(seconds: offsetSeconds));
      // Выводим скорректированное время из now_dt
      print('Скорректированное время из now_dt: $adjustedServerDateTime');

      setState(() {
        temperature = data['fact']['temp'].toString(); // Получаем температуру
        condition =
            data['fact']['condition'].toString(); // Получаем состояние погоды
        iconCode = data['fact']['icon'].toString(); // Получаем код иконки
        feelsLike = data['fact']['feels_like'].toString(); // Как ощущается
        pressuremm =
            data['fact']['pressure_mm'].toString(); // Получаем мм.рт.ст
        windSpeed =
            data['fact']['wind_speed'].toString(); // Получаем скорость ветра
        humidity =
            data['fact']['humidity'].toString(); // Получаем влажность воздуха

        final List<dynamic> filteredHourlyForecastData = [];
        for (final hourData in data['forecasts'][0]['hours']) {
          final hourTime = int.parse(hourData['hour']);
          if (hourTime > adjustedServerDateTime.hour) {
            filteredHourlyForecastData.add(hourData);
          }
        }
        hourlyForecastData = filteredHourlyForecastData;
      });
    } else {
      throw Exception('Failed to load weather');
    }
    setState(() {
      isLoading =
          false; // Устанавливаем isLoading в false после завершения загрузки данных
    });
  }

  Future<void> _showSearchPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultsPage()),
    );
    if (result != null) {
      final latitude = result['latitude'];
      final longitude = result['longitude'];
      await fetchWeather(latitude, longitude);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 246, 238, 169),
      appBar: AppBar(
        title: const Text(
          'Прогноз погоды',
          style: TextStyle(
            fontFamily: 'fonts',
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 246, 238, 169),
        centerTitle: true,
        actions: [
          // IconButton(
          //   icon: const Icon(Icons.search),
          //   onPressed: () {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //           builder: (context) => const SearchResultsPage()),
          //     );
          //   },
          // ),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Обработчик нажатия на иконку выбора города
              _showSearchPage();
            },
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.topCenter,
                          child: Container(
                            width: 400,
                            height: 350,
                            margin: const EdgeInsets.only(
                                top: 45, left: 12, right: 12),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(156, 244, 255, 255),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  locality.replaceAll('город ',
                                      ''), // Убираем слово "город" из строки
                                  style: const TextStyle(fontSize: 26),
                                ),
                                SizedBox(
                                  height: 11,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '$temperature°C',
                                      style: const TextStyle(fontSize: 28),
                                    ),
                                    if (iconCode.isNotEmpty)
                                      SvgPicture.network(
                                        'https://yastatic.net/weather/i/icons/funky/dark/$iconCode.svg',
                                        height: 50,
                                        width: 50,
                                        fit: BoxFit.contain,
                                      ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      translations[condition] ?? condition,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Ощущается как: $feelsLike°C',
                                      style: const TextStyle(fontSize: 17),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    SizedBox(height: 10),
                                    SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      child: Row(
                                        children: [
                                          WeatherInfoWidget(
                                            iconPath: 'icons/speed.png',
                                            text: '$windSpeed м/c',
                                          ),
                                          WeatherInfoWidget(
                                            iconPath: 'icons/davl.png',
                                            text: '$pressuremm мм.рт.ст.',
                                          ),
                                          WeatherInfoWidget(
                                            iconPath: 'icons/vlaga.png',
                                            text: '$humidity%',
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 20, left: 12, right: 12),
                                      height: 120,
                                      child: ListView.builder(
                                        scrollDirection: Axis.horizontal,
                                        itemCount: hourlyForecastData.length,
                                        itemBuilder: (context, index) {
                                          dynamic hourData =
                                              hourlyForecastData[index];
                                          String hourIconCode =
                                              hourData['icon'].toString();
                                          String hourTemperature =
                                              hourData['temp'].toString();
                                          String hourTime =
                                              hourData['hour'].toString();
                                          return Row(
                                            children: [
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  HourlyWeatherWidget(
                                                    iconUrl:
                                                        'https://yastatic.net/weather/i/icons/funky/dark/$hourIconCode.svg',
                                                    time: '$hourTime:00',
                                                    temperature:
                                                        '$hourTemperature°C',
                                                  ),
                                                ],
                                              ),
                                              SizedBox(
                                                  width:
                                                      20), // Расстояние между часами
                                            ],
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: FloatingActionButton(
                      backgroundColor: const Color.fromARGB(156, 244, 255, 255),
                      onPressed: () {
                        // Обработчик нажатия на иконку местоположения
                        requestLocationPermission(); // Вызываем метод запроса геолокации
                      },
                      child: const Icon(Icons.location_on),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
