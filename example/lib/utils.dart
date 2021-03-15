import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timetable/timetable.dart';

class ExampleApp extends StatelessWidget {
  const ExampleApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Timetable example',
      theme: _createTheme(Brightness.light),
      darkTheme: _createTheme(Brightness.dark),
      localizationsDelegates: [
        TimetableLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [const Locale('de'), const Locale('en')],
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

    // We want to extend Timetable behind the navigation bar.
    SystemChrome.setSystemUIOverlayStyle(
      brightness.contrastSystemUiOverlayStyle
          .copyWith(systemNavigationBarColor: Colors.transparent),
    );
    return theme;
  }
}
