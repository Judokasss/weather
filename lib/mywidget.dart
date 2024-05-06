import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WeatherInfoWidget extends StatelessWidget {
  final String iconPath;
  final String text;

  const WeatherInfoWidget({
    Key? key,
    required this.iconPath,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0), // Смена позиции
      child: Row(
        children: [
          Image.asset(
            iconPath,
            width: 24,
            height: 24,
          ),
          SizedBox(width: 10),
          Text(text, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class HourlyWeatherWidget extends StatelessWidget {
  final String time;
  final String iconUrl;
  final String temperature;

  const HourlyWeatherWidget({
    Key? key,
    required this.time,
    required this.iconUrl,
    required this.temperature,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 10.0), // Смена позиции
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Виджет для отображения времени
          Text(time),
          SizedBox(height: 10),
          // Виджет для отображения иконки
          SvgPicture.network(
            iconUrl,
            width: 42,
            height: 42,
          ),
          SizedBox(height: 10),
          // Виджет для отображения температуры
          Text(temperature, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
