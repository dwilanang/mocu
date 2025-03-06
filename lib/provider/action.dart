import 'package:flutter/material.dart';

class ActionProvider extends ChangeNotifier {
  //define
  final Map<String, bool> _execAction = {};

  //get
  Map<String, bool> get execAction => _execAction;

  //set
  void setExecAction(String name, bool status) {
      _execAction[name] = status;
      notifyListeners();
  }
}