import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vecna_app/view/pages/details.dart';
import 'package:vecna_app/view/pages/main_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Vecna',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: 'home',
      routes: {
        'home': (BuildContext _context) => MainPage(),
        'details': (BuildContext _context) => DetailsPage()
      },
    );
  }
}
