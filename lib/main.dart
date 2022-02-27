import 'package:flutter/material.dart';
import 'constants/colors.dart';
import 'constants/strings.dart';
import 'screens/HomeScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: kString.appName,
      theme: ThemeData(
        primarySwatch: kColors.primaryColor,
      ),
      home: HomeScreen(),
    );
  }
}
