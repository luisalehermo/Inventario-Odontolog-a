import 'package:flutter/material.dart';
import 'screens/menu_principal_screen.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'dart:io' show Platform;

// Notificador global para el cambio de tema
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.system);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Tema Minimalista Monocromático
    const Color colorPrimario = Color(0xFF111827); // Negro profundo (Gray 900)

    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Inventory Dashboard',
          themeMode: currentMode,
          // TEMA CLARO
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: colorPrimario,
              primary: colorPrimario,
              onPrimary: Colors.white,
              brightness: Brightness.light,
              surface: Colors.white,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFFF9FAFB), // Fondo gris muy claro (Gray 50)
            dividerColor: const Color(0xFFE5E7EB), // Gray 200
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: Color(0xFFE5E7EB)), // Gray 200
              ),
              color: Colors.white,
            ),
          ),
          // TEMA OSCURO
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.white,
              brightness: Brightness.dark,
              primary: Colors.white,
              onPrimary: Colors.black,
            ),
            useMaterial3: true,
            scaffoldBackgroundColor: const Color(0xFF111827),
          ),
          home: const PantallaMenuPrincipal(),
        );
      },
    );
  }
}
