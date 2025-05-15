import 'package:flutter/material.dart';

import 'package:mocu/pages/welcome.dart';
import 'package:mocu/pages/games.dart';
import 'package:mocu/pages/matching.dart';
import 'package:mocu/pages/yummy_yucky.dart';
import 'package:mocu/pages/memory.dart';
import 'package:mocu/pages/aboutdino.dart';
import 'package:mocu/pages/crackegg.dart';
// import 'package:matching/models/screen.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
   
    // ScreenArguments? arguments = settings.arguments as ScreenArguments?;
    
    switch (settings.name) {
      case '/games':
        return _materialRoute(const Games());
      case '/matching':
        return _materialRoute(const Matching());
      case '/yummy-yucky':
        return _materialRoute(const YummyYucky());
      case '/memory':
        return _materialRoute(const Memory());
       case '/crack-egg':
        return _materialRoute(const CrackEgg());
      case '/about-dino':
        return _materialRoute(const AboutDino());
      default:
        return _materialRoute(const Welcome());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}