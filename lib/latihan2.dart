import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class University {
  // Deklarasi variabel
  final String name;
  final String website;

  University({required this.name, required this.website});// constructor

  // Factory method untuk membuat objek University dari data JSON.
  factory University.fromJson(Map<String, dynamic> json) {
    return University(
      name: json['name'],
      website: json['web_pages'][0],
    );
  }
}

// Kelas yang mengelola daftar univ
class UniversityBloc extends Cubit<List<University>> {
  UniversityBloc() : super([]);

  // Method untuk mengambil daftar univ dari API
  Future<void> fetchUniversities(String country) async {
    final response = await http.get(Uri.parse('http://universities.hipolabs.com/search?country=$country'));
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      List<University> universities = [];
      for (var item in data) {
        universities.add(University.fromJson(item));
      }
      emit(universities);
    } else {
      throw Exception('Failed to load universities');
    }
  }
}

// Kelas utama
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => UniversityBloc(),
        child: const UniversityList(),
      ),
    );
  }
}

class UniversityList extends StatefulWidget {
  const UniversityList({Key? key}) : super(key: key);

  @override
  _UniversityListState createState() => _UniversityListState();
}

// state dari University List
class _UniversityListState extends State<UniversityList> {
  late UniversityBloc universityBloc;
  String selectedCountry = 'Indonesia';
  final List<String> aseanCountries = ['Indonesia', 'Malaysia', 'Singapore'];// Daftar negara

  @override
  void initState() {
    super.initState();
    universityBloc = BlocProvider.of<UniversityBloc>(context);
    universityBloc.fetchUniversities(selectedCountry);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Universitas'),
      ),
      body: Column(
        children: [
          // Dropdown negara
          DropdownButton<String>(
            value: selectedCountry,
            onChanged: (String? newCountry) {
              if (newCountry != null) {
                setState(() {
                  selectedCountry = newCountry;
                });
                universityBloc.fetchUniversities(selectedCountry);
              }
            },
            items: aseanCountries.map((String country) {
              return DropdownMenuItem<String>(
                value: country,
                child: Text(country),
              );
            }).toList(),
          ),
          // Expanded digunakan untuk memastikan ListView mengisi ruang yang tersedia dalam layout.
          Expanded(
            child: BlocBuilder<UniversityBloc, List<University>>(
              builder: (context, universities) {
                // Memeriksa apakah daftar universitas kosong.
                if (universities.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return ListView.separated(
                    itemCount: universities.length,
                    separatorBuilder: (BuildContext context, int index) {
                      return const Divider();
                    },
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(
                          universities[index].name,
                          textAlign: TextAlign.center,
                        ),
                        subtitle: InkWell(
                          child: Text(
                            universities[index].website,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              decoration: TextDecoration.underline,
                              color: Colors.blue,
                            ),
                          ),
                          onTap: () async {
                            final url = universities[index].website;
                            if (await canLaunch(url)) {
                              await launch(url);
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}