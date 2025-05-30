import 'package:flutter/material.dart';

import 'package:mocu/pages/welcome.dart';
import 'package:mocu/pages/games.dart';
import 'package:mocu/pages/matching.dart';
import 'package:mocu/pages/yummy_yucky.dart';
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
      // case '/game1':
      //   return _materialRoute(Game1(arguments: arguments));
      // case '/game2':
      //   return _materialRoute(Game2(arguments: arguments));
      // case '/game3':
      //   return _materialRoute(Game3(arguments: arguments));
      // case '/game4':
      //   return _materialRoute(Game4(arguments: arguments));
      // case '/game5':
      //   return _materialRoute(Game5(arguments: arguments));
      // case '/reward':
      //   return _materialRoute(Reward(arguments: arguments));
      default:
        return _materialRoute(const Welcome());
    }
  }

  static Route<dynamic> _materialRoute(Widget view) {
    return MaterialPageRoute(builder: (_) => view);
  }
}