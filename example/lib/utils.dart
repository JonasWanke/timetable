import 'package:black_hole_flutter/black_hole_flutter.dart';
import 'package:debug_overlay/debug_overlay.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:timetable/timetable.dart';

final _mediaOverrideState = ValueNotifier(MediaOverrideState());
final _supportedLocales = [
  const Locale('cs'),
  const Locale('de'),
  const Locale('en'),
  const Locale('es'),
  const Locale('fr'),
  const Locale('hu'),
  const Locale('it'),
  const Locale('ja'),
  const Locale('pt'),
  const Locale('zh', 'CN'),
  const Locale('zh', 'TW'),
];

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
          localizationsDelegates: const [
            TimetableLocalizationsDelegate(),
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: _supportedLocales,
          builder: kIsWeb ? null : DebugOverlay.builder(),
          home: SafeArea(child: Scaffold(body: child)),
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
      snackBarTheme:
          const SnackBarThemeData(behavior: SnackBarBehavior.floating),
    );
    theme = theme.copyWith(
      colorScheme: theme.colorScheme
          .copyWith(onBackground: theme.colorScheme.background.contrastColor),
      textTheme: theme.textTheme.copyWith(
        titleLarge:
            theme.textTheme.titleLarge!.copyWith(fontWeight: FontWeight.normal),
      ),
    );

    // We want to extend Timetable behind the navigation bar.
    SystemChrome.setSystemUIOverlayStyle(
      brightness.contrastSystemUiOverlayStyle
          .copyWith(systemNavigationBarColor: Colors.transparent),
    );
    return theme;
  }
}
