import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mocu/pages/welcome.dart';
import 'package:mocu/routes.dart';
import 'package:mocu/constant.dart';
import 'package:mocu/provider/action.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ActionProvider()),
        // Tambahkan provider lain di sini jika diperlukan
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'play mocu',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: skyBlue),
        useMaterial3: true,
      ),
      onGenerateRoute: AppRoutes.onGenerateRoutes,
      debugShowCheckedModeBanner: false,
      home: const Welcome(),
    );
  }
}