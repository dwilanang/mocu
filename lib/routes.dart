import 'package:flutter/material.dart';

import 'package:mocu/pages/welcome.dart';


// import 'package:matching/models/screen.dart';

class AppRoutes {
  static Route onGenerateRoutes(RouteSettings settings) {
   
    // ScreenArguments? arguments = settings.arguments as ScreenArguments?;
    
    switch (settings.name) {
      // case '/register':
      //   return _materialRoute(const Register());
      // case '/home':
      //   return _materialRoute(Home(arguments: arguments));
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