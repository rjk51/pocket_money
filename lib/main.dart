import 'package:flutter/material.dart';
import 'package:pocket_money/core/themes.dart';
import 'package:pocket_money/src/presentation/screens/form/form.dart';
import 'package:pocket_money/src/presentation/screens/splash_page.dart';
import 'package:pocket_money/src/presentation/screens/home/the_og_home_page.dart';


void main() {
   
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Money',
      debugShowCheckedModeBanner: false,
      theme: lightMode,
      home: const SplashPage(),
    );
  }
}
