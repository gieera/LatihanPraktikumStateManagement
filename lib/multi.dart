import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

// Model untuk data UMKM
class Umkm {
  final String id;
  final String jenis;
  final String nama;

  Umkm({required this.id, required this.nama, required this.jenis});
}

// Model untuk data detil UMKM
class DetilUmkmModel {
  final String id;
  final String jenis;
  final String nama;
  final String omzet;
  final String lamaUsaha;
  final String memberSejak;
  final String jumPinjamanSukses;

  DetilUmkmModel({
    required this.id,
    required this.nama,
    required this.jenis,
    required this.omzet,
    required this.jumPinjamanSukses,
    required this.lamaUsaha,
    required this.memberSejak,
  });
}

// Cubit untuk mengelola daftar UMKM
class UmkmCubit extends Cubit<List<Umkm>> {
  // URL API untuk daftar UMKM
  final String apiUrl = "http://178.128.17.76:8000/daftar_umkm";

  UmkmCubit() : super([]);

  // Fungsi untuk mengambil data daftar UMKM dari URL API
  void fetchData() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final umkmList = (jsonData['data'] as List)
          .map((item) => Umkm(
                id: item['id'],
                nama: item['nama'],
                jenis: item['jenis'],
              ))
          .toList();
      emit(umkmList);
    } else {
      throw Exception('Gagal load data UMKM');
    }
  }
}

// Cubit untuk mengelola detil UMKM
class DetilUmkmCubit extends Cubit<DetilUmkmModel> {
  // URL API untuk detil UMKM
  final String apiUrl = "http://178.128.17.76:8000/detil_umkm/";

  DetilUmkmCubit()
      : super(DetilUmkmModel(
            id: '',
            nama: '',
            jenis: '',
            omzet: '',
            jumPinjamanSukses: '',
            lamaUsaha: '',
            memberSejak: ''));

  // Fungsi untuk mengambil data detil UMKM dari URL API
  void fetchDataDetil(String id) async {
    final response = await http.get(Uri.parse("$apiUrl$id"));
    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      final detilUmkm = DetilUmkmModel(
        id: jsonData['id'],
        nama: jsonData['nama'],
        jenis: jsonData['jenis'],
        omzet: jsonData['omzet_bulan'],
        jumPinjamanSukses: jsonData['jumlah_pinjaman_sukses'],
        lamaUsaha: jsonData['lama_usaha'],
        memberSejak: jsonData['member_sejak'],
      );
      emit(detilUmkm);
    } else {
      throw Exception('Gagal load detil UMKM');
    }
  }
}

// Screen untuk menampilkan detil UMKM
class ScreenDetil extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detil UMKM'),
      ),
      body: BlocBuilder<DetilUmkmCubit, DetilUmkmModel>(
        builder: (context, detilUmkm) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nama: ${detilUmkm.nama}"),
              Text("Detil: ${detilUmkm.jenis}"),
              Text("Member Sejak: ${detilUmkm.memberSejak}"),
              Text("Omzet per bulan: ${detilUmkm.omzet}"),
              Text("Lama usaha: ${detilUmkm.lamaUsaha}"),
              Text("Jumlah pinjaman sukses: ${detilUmkm.jumPinjamanSukses}"),
            ],
          );
        },
      ),
    );
  }
}

// Screen utama untuk menampilkan daftar UMKM
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MultiBlocProvider(
        providers: [
          BlocProvider<UmkmCubit>(
            create: (context) => UmkmCubit(),
          ),
          BlocProvider<DetilUmkmCubit>(
            create: (context) => DetilUmkmCubit(),
          ),
        ],
        child: HalamanUtama(),
      ),
    );
  }
}

class HalamanUtama extends StatelessWidget {
  const HalamanUtama({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar UMKM'),
      ),
      body: Center(
        child: BlocBuilder<UmkmCubit, List<Umkm>>(
          builder: (context, listUmkm) {
            return Column(
              children: [
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    context.read<UmkmCubit>().fetchData();
                  },
                  child: const Text("Reload Daftar UMKM"),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: listUmkm.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(listUmkm[index].nama),
                        subtitle: Text(listUmkm[index].jenis),
                        onTap: () {
                          context
                              .read<DetilUmkmCubit>()
                              .fetchDataDetil(listUmkm[index].id);
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) {
                              return ScreenDetil();
                            }),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
