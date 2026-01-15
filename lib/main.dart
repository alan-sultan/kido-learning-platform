import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'services/data_seed_service.dart';
import 'services/navigation_service.dart';
import 'services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await PreferencesService.configure();
  await DataSeedService().seedInitialContent();
  runApp(const KidoApp());
}

class KidoApp extends StatelessWidget {
  const KidoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KIDO',
      debugShowCheckedModeBanner: false,
      navigatorKey: NavigationService.navigatorKey,
      scaffoldMessengerKey: NavigationService.messengerKey,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        fontFamily: 'Roboto',
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}















