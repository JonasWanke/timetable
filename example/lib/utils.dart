import 'package:flutter/material.dart';

class ExampleApp extends StatelessWidget {
  const ExampleApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable example',
      theme: _createTheme(Brightness.light),
      darkTheme: _createTheme(Brightness.dark),
      // themeMode: ThemeMode.dark,
      home: child,
    );
  }

  ThemeData _createTheme(Brightness brightness) {
    var theme = ThemeData(
      brightness: brightness,
      applyElevationOverlayColor: true,
      primaryColor: Colors.blue,
      primarySwatch: Colors.blue,
      snackBarTheme: SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
    theme = theme.copyWith(
      textTheme: theme.textTheme.copyWith(
        headline6:
            theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.normal),
      ),
      // appBarTheme: theme.appBarTheme.copyWith(
      //   // backgroundColor: brightness.isDark ? Color(0xFF30313F) : Colors.white,
      //   foregroundColor: brightness.mediumEmphasisOnColor,
      //   titleTextStyle:
      //       theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.normal),
      // ),
    );
    return theme;
  }
}
