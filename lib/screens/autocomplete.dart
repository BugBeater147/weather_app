import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CitySearch extends StatefulWidget {
  final Function(String) onCitySelected;

  const CitySearch({Key? key, required this.onCitySelected}) : super(key: key);

  @override
  _CitySearchState createState() => _CitySearchState();
}

class _CitySearchState extends State<CitySearch> {
  List<String> citySuggestions = [];

  void searchCity(String query) async {
    if (query.isEmpty) {
      setState(() {
        citySuggestions = [];
      });
      return;
    }

    final response = await http.get(Uri.parse(
        'http://api.geonames.org/searchJSON?q=$query&maxRows=5&username=demo')); // Replace `demo` with a valid Geonames username
    if (response.statusCode == 200) {
      final results = json.decode(response.body)['geonames'];
      setState(() {
        citySuggestions = results.map<String>((city) => city['name']).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextField(
          onChanged: searchCity,
          decoration: InputDecoration(hintText: 'Enter city name'),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: citySuggestions.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(citySuggestions[index]),
                onTap: () {
                  widget.onCitySelected(citySuggestions[index]);
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
