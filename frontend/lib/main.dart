import 'package:flutter/material.dart';
import 'screens/login_screen.dart'; // Verifica que esta ruta sea correcta

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color azulUSM = Color(0xFF2B27A1);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema Biblioteca USM',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: azulUSM),
        useMaterial3: true,
      ),
      // Aquí es donde empieza la magia
      home: const PantallaLogin(),
    );
  }
}
