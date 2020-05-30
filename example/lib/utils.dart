import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void setTargetPlatformForDesktop() {
  if (Platform.isLinux || Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
  }
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({@required this.child}) : assert(child != null);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable example',
      theme: _createTheme(Brightness.light),
      darkTheme: _createTheme(Brightness.dark),
      home: child,
    );
  }

  ThemeData _createTheme(Brightness brightness) {
    return ThemeData(
      brightness: brightness,
      primaryColor: Colors.blue,
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
