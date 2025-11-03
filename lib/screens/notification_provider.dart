// lib/screens/notification_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NotificationProvider with ChangeNotifier {
  int _unreadCount = 0;

  int get unreadCount => _unreadCount;

  void setUnreadCount(int count) {
    _unreadCount = count;
    notifyListeners();
  }

  void incrementCount() {
    _unreadCount++;
    notifyListeners();
  }

  void resetCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}
