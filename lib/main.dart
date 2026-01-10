import 'package:directionay_english_khmer/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(
    GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: [GetPage(name: '/login', page: () => LoginScreen()),],
      initialRoute: '/login',
    ),
  );
}

