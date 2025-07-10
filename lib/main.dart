import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qrzone/screens/home_screen.dart';
import 'package:qrzone/bindings/network_binding.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: 'DM Sans',
        textTheme: TextTheme(
          headlineLarge: TextStyle(fontWeight: FontWeight.bold),
          // bodyMedium: TextStyle(fontSize: 16),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        // dialogTheme: const DialogTheme(
        //   backgroundColor: Colors.black,
        //   titleTextStyle: TextStyle(
        //     color: Colors.white,
        //     fontSize: 20,
        //     fontWeight: FontWeight.bold,
        //   ),
        //   contentTextStyle: TextStyle(color: Colors.white70, fontSize: 16),
        //   shape: RoundedRectangleBorder(
        //     borderRadius: BorderRadius.all(Radius.circular(10)),
        //     side: BorderSide(color: Colors.green, width: 2),
        //   ),
        // ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.black,
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const HomeScreen(),
      initialBinding: NetworkBinding(),
    );
  }
}
