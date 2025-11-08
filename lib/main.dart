import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// <<<--- ১. Firebase প্যাকেজগুলো ইম্পোর্ট করুন ---
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart'; // (এটা flutterfire configure থেকে তৈরি হয়েছে)
// ---

import 'screens/notification_provider.dart'; 
import 'screens/login_screen.dart'; 

// <<<--- ২. main() ফাংশনটা আপডেট করুন ---
void main() async { // <-- 'async' যোগ করুন
  
  // <-- এই দুটি লাইন Firebase চালু করার জন্য জরুরি --
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // ---

  runApp(
    ChangeNotifierProvider(
      create: (context) => NotificationProvider(),
      child: const MyApp(), 
    ),
  );
}
// <<<--- main() ফাংশন আপডেট করা শেষ ---


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
