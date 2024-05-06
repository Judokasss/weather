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
  List<String> _citySuggestions = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _fetchCitySuggestions(String text) async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl =
        'https://suggest-maps.yandex.ru/v1/suggest?apikey=3a264be4-cbb3-45ec-a2f1-1ec47650415b&text=$text';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results = data['results'];
        final List<String> suggestions = results
            .where((result) =>
                result['tags'] != null &&
                result['tags'].contains('locality') &&
                !result['tags'].contains('area') &&
                !result['tags'].contains('country') &&
                !result['tags'].contains('province'))
            .map((result) {
              final title = result['title']['text'];
              return title;
            })
            .whereType<String>()
            .toList();

        setState(() {
          _citySuggestions = suggestions;
          _isLoading = false;
        });
      } else {
        print('Failed to load city suggestions: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Failed to load city suggestions: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _getCityCoordinates(String city) async {
    setState(() {
      _isLoading = true;
    });

    final String apiUrl =
        'https://geocode-maps.yandex.ru/1.x/?apikey=b8af779f-adb1-4a98-a546-bbde9cf64860&geocode=$city&format=json';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> results =
            data['response']['GeoObjectCollection']['featureMember'];

        if (results.isNotEmpty) {
          final String coordinates = results[0]['GeoObject']['Point']['pos'];
          print('Координаты города д/ш: $coordinates');
          List<String> parts = coordinates.split(' ');
          double latitude = double.parse(parts[1]);
          double longitude = double.parse(parts[0]);
          // Отправляем координаты обратно на MyHomePage
          Navigator.pop(
              context, {'latitude': latitude, 'longitude': longitude});
        } else {
          print('Город не найден');
        }

        setState(() {
          _isLoading = false;
        });
      } else {
        print('Failed to load city coordinates: ${response.statusCode}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (error) {
      print('Failed to load city coordinates: $error');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        title: TextField(
          controller: _textEditingController,
          autofocus: true,
          onChanged: (value) {
            if (value.isNotEmpty) {
              _fetchCitySuggestions(value);
            } else {
              setState(() {
                _citySuggestions.clear();
              });
            }
          },
          decoration: InputDecoration(
            hintText: 'Выберите город',
            hintStyle: TextStyle(color: Color.fromARGB(219, 92, 87, 87)),
            border: InputBorder.none,
          ),
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        backgroundColor: Color.fromARGB(255, 255, 255, 255),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: Colors.grey.withOpacity(0.5),
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Stack(
          children: [
            ListView.builder(
              itemCount: _citySuggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_citySuggestions[index]),
                  onTap: () {
                    setState(() {
                      _textEditingController.text = _citySuggestions[index];
                    });
                    _getCityCoordinates(_citySuggestions[index]);
                  },
                );
              },
            ),
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: Colors.amberAccent,
                ),
              ),
            if (!_isLoading &&
                _citySuggestions.isEmpty &&
                _textEditingController.text.isNotEmpty)
              Center(
                child: Text(
                  'Нет результатов',
                  style: TextStyle(
                    fontSize: 24,
                    color: Color.fromARGB(255, 48, 47, 47),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
