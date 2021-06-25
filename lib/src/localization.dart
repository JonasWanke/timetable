import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'week.dart';

/// Provides localized strings for Timetable widgets.
///
/// Supported [Locale.languageCode]s:
///
/// * `de` –German
/// * `en` – English
/// * `ja` – Japanese
/// * `es` – Spanish
/// * `zh_CN` – Chinese(Simplified)
/// * `zh_TW` – Chinese(Traditional)
///
/// By default, this delegate also configures [Intl] whenever Flutter's locale
/// changes. This behavior can be disabled via [setIntlLocale].
///
/// See also:
///
/// * [TimetableLocalizations], which contains all strings for one locale.
class TimetableLocalizationsDelegate
    extends LocalizationsDelegate<TimetableLocalizations> {
  const TimetableLocalizationsDelegate({this.setIntlLocale = true});

  final bool setIntlLocale;

  @override
  bool isSupported(Locale locale) => _getLocalization(locale) != null;

  @override
  Future<TimetableLocalizations> load(Locale locale) {
    assert(isSupported(locale));
    if (setIntlLocale) Intl.defaultLocale = locale.toLanguageTag();
    return SynchronousFuture(_getLocalization(locale)!);
  }

  @override
  bool shouldReload(TimetableLocalizationsDelegate old) => false;

  TimetableLocalizations? _getLocalization(Locale locale) {
    switch (locale.languageCode) {
      case 'de':
        return const TimetableLocalizationDe();
      case 'en':
        return const TimetableLocalizationEn();
      case 'ja':
        return const TimetableLocalizationJa();
      case 'es':
        return const TimetableLocalizationEs();
      case 'zh':
        if (locale.countryCode?.toLowerCase() == 'tw') {
          return const TimetableLocalizationZhTw();
        }
        return const TimetableLocalizationZhCn();
      default:
        return null;
    }
  }
}

// Modified version of `debugCheckHasMaterialLocalizations`.
bool debugCheckHasTimetableLocalizations(BuildContext context) {
  assert(() {
    if (Localizations.of<TimetableLocalizations>(
            context, TimetableLocalizations) ==
        null) {
      throw FlutterError.fromParts(<DiagnosticsNode>[
        ErrorSummary('No TimetableLocalization found.'),
        ErrorDescription(
          '${context.widget.runtimeType} widgets require TimetableLocalization '
          'to be provided by a Localizations widget ancestor.',
        ),
        ErrorDescription(
          'The timetable library uses Localizations to generate messages, '
          'labels, and abbreviations.',
        ),
        ErrorHint(
          'To introduce a TimetableLocalization, add a '
          'TimetableLocalizationsDelegate() to your '
          "Material-/Cupertino-/WidgetApp's localizationsDelegates.",
        ),
        ...context.describeMissingAncestor(
          expectedAncestorType: TimetableLocalizations,
        )
      ]);
    }
    return true;
  }());
  return true;
}

/// Contains localized strings for Timetable widgets in one locale.
///
/// See also:
///
/// * [TimetableLocalizationsDelegate], which makes localization info available
///   to Timetable widgets.
@immutable
abstract class TimetableLocalizations {
  const TimetableLocalizations();

  static TimetableLocalizations of(BuildContext context) {
    assert(debugCheckHasTimetableLocalizations(context));
    return Localizations.of<TimetableLocalizations>(
      context,
      TimetableLocalizations,
    )!;
  }

  List<String> weekLabels(Week week);
  String weekOfYear(Week week);
}

extension BuildContextTimetableLocalizations on BuildContext {
  TimetableLocalizations get timetableLocalizations =>
      TimetableLocalizations.of(this);
  void dependOnTimetableLocalizations() {
    // By accessing the localizations, this widget calling this method will get
    // rebuilt when the locale changes.
    TimetableLocalizations.of(this);
  }
}

class TimetableLocalizationDe extends TimetableLocalizations {
  const TimetableLocalizationDe();

  @override
  List<String> weekLabels(Week week) {
    return [
      weekOfYear(week),
      'Woche ${week.weekOfYear}',
      'KW ${week.weekOfYear}',
      '${week.weekOfYear}',
    ];
  }

  @override
  String weekOfYear(Week week) =>
      'Kalenderwoche ${week.weekOfYear}, ${week.weekBasedYear}';
}

class TimetableLocalizationEn extends TimetableLocalizations {
  const TimetableLocalizationEn();

  @override
  List<String> weekLabels(Week week) {
    return [
      weekOfYear(week),
      'Week ${week.weekOfYear}',
      'W ${week.weekOfYear}',
      '${week.weekOfYear}',
    ];
  }

  @override
  String weekOfYear(Week week) =>
      'Week ${week.weekOfYear}, ${week.weekBasedYear}';
}

class TimetableLocalizationJa extends TimetableLocalizations {
  const TimetableLocalizationJa();

  @override
  List<String> weekLabels(Week week) {
    return [
      weekOfYear(week),
      '第${week.weekOfYear}週',
      '${week.weekOfYear}週',
      '${week.weekOfYear}',
    ];
  }

  @override
  String weekOfYear(Week week) =>
      'Week ${week.weekOfYear}, ${week.weekBasedYear}';
}

class TimetableLocalizationEs extends TimetableLocalizations {
  const TimetableLocalizationEs();

  @override
  List<String> weekLabels(Week week) {
    return [
      weekOfYear(week),
      'Semana ${week.weekOfYear}',
      'S ${week.weekOfYear}',
      '${week.weekOfYear}',
    ];
  }

  @override
  String weekOfYear(Week week) =>
      'Semana ${week.weekOfYear}, ${week.weekBasedYear}';
}

class TimetableLocalizationZhCn extends TimetableLocalizations {
  const TimetableLocalizationZhCn();

  @override
  List<String> weekLabels(Week week) {
    return [
      weekOfYear(week),
      '第${week.weekOfYear}周',
      '${week.weekOfYear}周',
      '${week.weekOfYear}',
    ];
  }

  @override
  String weekOfYear(Week week) =>
      'Week ${week.weekOfYear}, ${week.weekBasedYear}';
}

class TimetableLocalizationZhTw extends TimetableLocalizations {
  const TimetableLocalizationZhTw();

  @override
  List<String> weekLabels(Week week) {
    return [
      weekOfYear(week),
      '第${week.weekOfYear}週',
      '${week.weekOfYear}週',
      '${week.weekOfYear}',
    ];
  }

  @override
  String weekOfYear(Week week) =>
      'Week ${week.weekOfYear}, ${week.weekBasedYear}';
}
