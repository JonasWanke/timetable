import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:debug_overlay/debug_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timetable/timetable.dart';

final _mediaOverrideState = ValueNotifier(MediaOverrideState());
final _supportedLocales = [const Locale('de'), const Locale('en')];

void initDebugOverlay() {
  // https://pub.dev/packages/debug_overlay
  DebugOverlay.helpers.value = [
    MediaOverrideDebugHelper(
      _mediaOverrideState,
      supportedLocales: _supportedLocales,
    )
  ];
}

class ExampleApp extends StatelessWidget {
  const ExampleApp({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<MediaOverrideState>(
      valueListenable: _mediaOverrideState,
      builder: (context, overrideState, _) {
        return MaterialApp(
          title: 'Timetable example',
          theme: _createTheme(Brightness.light),
          darkTheme: _createTheme(Brightness.dark),
          themeMode: overrideState.themeMode,
          locale: overrideState.locale,
          localizationsDelegates: [
            TimetableLocalizationsDelegate(),
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: _supportedLocales,
          builder: DebugOverlay.builder(),
          home: Scaffold(body: child),
        );
      },
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
      colorScheme: theme.colorScheme
          .copyWith(onBackground: theme.colorScheme.background.contrastColor),
      textTheme: theme.textTheme.copyWith(
        headline6:
            theme.textTheme.headline6!.copyWith(fontWeight: FontWeight.normal),
      ),
      appBarTheme: theme.appBarTheme.copyWith(backwardsCompatibility: false),
    );

    // We want to extend Timetable behind the navigation bar.
    SystemChrome.setSystemUIOverlayStyle(
      brightness.contrastSystemUiOverlayStyle
          .copyWith(systemNavigationBarColor: Colors.transparent),
    );
    return theme;
  }
}
