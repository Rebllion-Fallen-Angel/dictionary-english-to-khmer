import 'package:directionay_english_khmer/home.dart';
import 'package:directionay_english_khmer/login.dart';
import 'package:directionay_english_khmer/register.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.cupertino,
      transitionDuration: Duration(milliseconds: 500),
      getPages: [
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/register', page: () => Register()),
        GetPage(name: '/home', page: () => HomeScreen()),
      ],
      initialRoute: '/login',
    ),
  );
}
