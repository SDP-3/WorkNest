// lib/screens/notification_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NotificationProvider with ChangeNotifier {
  // Ei variable-tai holo apnar 'global' count
  int _unreadCount = 0; // Shurute 0 thakbe

  // Ei function diye amra count-ta baire theke dekhte parbo
  int get unreadCount => _unreadCount;

  // Jokhon app chalu hobe ba backend theke mot sonkhya paben,
  // tokhon ei function call kore mot count set korte parben.
  void setUnreadCount(int count) {
    _unreadCount = count;
    // Shob listener-ke janano hocche je count change hoyeche
    notifyListeners();
  }

  // Jokhon kono ekta notun notification ashbe
  void incrementCount() {
    _unreadCount++;
    // UI-ke janano hocche je variable bodleche, jate she notun sonkhya dekhay
    notifyListeners();
  }

  // Jokhon user notification icon-e click kore shob pore felbe
  void resetCount() {
    _unreadCount = 0;
    // UI-ke janano hocche
    notifyListeners();
  }
}
