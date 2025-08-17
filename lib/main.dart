import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'screens/ingredients_page.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await Permission.camera.request();
  await Permission.storage.request();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove(); // Remove splash screen when app is ready
    return MaterialApp(
      title: 'Tasty Ingredients App',
      theme: ThemeData(
        textTheme: GoogleFonts.quicksandTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.quicksandTextTheme(
          ThemeData.dark().textTheme,
        ),
      ),
      themeMode: ThemeMode.system,
      home: IngredientsPage(),
    );
  }
}
