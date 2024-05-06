import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class SearchResultsPage extends StatefulWidget {
  const SearchResultsPage({Key? key}) : super(key: key);

  @override
  _SearchResultsPageState createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  TextEditingController _textEditingController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _fetchCityCoordinates(String text) async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl =
        'https://geocode-maps.yandex.ru/1.x/?apikey=3a264be4-cbb3-45ec-a2f1-1ec47650415b&geocode=$text&format=json';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final pos = data['response']['GeoObjectCollection']['featureMember'][0]
            ['GeoObject']['Point']['pos'];
        final coordinates =
            pos.split(' ').map((coord) => double.parse(coord)).toList();

        // Вывод координат города в консоль
        print('Координаты города $text: ${coordinates[1]}, ${coordinates[0]}');

        setState(() {
          _isLoading = false;
        });
      } else {
        print('Failed to fetch city coordinates: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Failed to fetch city coordinates: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _textEditingController,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _fetchCityCoordinates(value);
            } else {
              setState(() {
                _isLoading = false;
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Введите название города',
          ),
        ),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator()
            : Text('Введите название города в поле выше и нажмите Enter'),
      ),
    );
  }
}
