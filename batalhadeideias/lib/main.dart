import 'package:device_preview/device_preview.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/ideias_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
    if (FirebaseAuth.instance.currentUser == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
    runApp(DevicePreview(
        enabled: !kReleaseMode, builder: (_) => const BatalhaApp()));
  } catch (error) {
    runApp(MaterialApp(
        home: Scaffold(
            body: Center(
                child: Padding(
      padding: const EdgeInsets.all(24),
      child: SelectableText('Não foi possível conectar ao Firebase.\n'
          'Confira firebase_options.dart, a internet e o login anônimo.\n\n$error'),
    )))));
  }
}

class BatalhaApp extends StatelessWidget {
  const BatalhaApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Batalha de Ideias',
        debugShowCheckedModeBanner: false,
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6750A4)),
          scaffoldBackgroundColor: const Color(0xFFF7F5FA),
          inputDecorationTheme:
              const InputDecorationTheme(border: OutlineInputBorder()),
        ),
        home: const IdeiasPage(),
      );
}
