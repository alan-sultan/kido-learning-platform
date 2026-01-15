import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'screens/auth_gate.dart';
import 'screens/splash_screen.dart';
import 'services/data_seed_service.dart';
import 'services/navigation_service.dart';
import 'services/preferences_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KidoApp());
}

class KidoApp extends StatefulWidget {
  const KidoApp({super.key});

  @override
  State<KidoApp> createState() => _KidoAppState();
}

class _KidoAppState extends State<KidoApp> {
  late Future<void> _bootstrapFuture;

  @override
  void initState() {
    super.initState();
    _bootstrapFuture = _createBootstrapFuture();
  }

  Future<void> _initializeCoreServices() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await PreferencesService.configure();
    await DataSeedService().seedInitialContent();
  }

  Future<void> _createBootstrapFuture() async {
    await Future.wait([
      _initializeCoreServices(),
      Future.delayed(const Duration(seconds: 3)),
    ]);
  }

  void _retryBootstrap() {
    setState(() {
      _bootstrapFuture = _createBootstrapFuture();
    });
  }

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
      home: FutureBuilder<void>(
        future: _bootstrapFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SplashScreen();
          }
          if (snapshot.hasError) {
            return _BootstrapErrorView(
              error: snapshot.error,
              onRetry: _retryBootstrap,
            );
          }
          return const AuthGate();
        },
      ),
    );
  }
}

class _BootstrapErrorView extends StatelessWidget {
  const _BootstrapErrorView({required this.error, required this.onRetry});

  final Object? error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2CC0D),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.cloud_off, size: 64, color: Color(0xFFB45309)),
              const SizedBox(height: 16),
              const Text(
                'We could not get things ready.',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1C190D),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Reason: ${error ?? 'unknown'}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6B5B2A),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C190D),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: const Text(
                  'Try Again',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}















