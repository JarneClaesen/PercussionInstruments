import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:dynamic_color/dynamic_color.dart';
import 'package:musical_terms/pages/home_page.dart';

void main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox('mybox'); // moet gebeuren om de hivebox te openen (moet dus niet gebruikt worden)

  runApp(const MyApp());
}


Color brandColor = const Color(0x00b33346);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(builder: (lightDynamic, darkDynamic) {
      var lightColorScheme = lightDynamic != null
          ? lightDynamic.harmonized()
          : ColorScheme.fromSeed(seedColor: brandColor);

      var darkColorScheme = darkDynamic != null
          ? darkDynamic.harmonized()
          : ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.dark);

      return MaterialApp(
        title: 'Musical Terms',
        theme: _buildThemeData(lightColorScheme),
        darkTheme: _buildThemeData(darkColorScheme),
        home: const HomePage(),
      );
    });
  }

  ThemeData _buildThemeData(ColorScheme colorScheme) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.background,
    );
  }
}