import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uas_ez_rent/providers/auth_provider.dart';
import 'package:uas_ez_rent/screens/auth/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:uas_ez_rent/screens/home_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      child: MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      )
    );
  }
}
