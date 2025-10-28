import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; 

import 'screens/notification_provider.dart'; 
import 'screens/login_screen.dart'; 

void main() {
  runApp(
    
    ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
      child: const MyApp(), 
    ),
  );
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worknest App', 
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false, 
      home: const LoginScreen(), 
    );
  }
}