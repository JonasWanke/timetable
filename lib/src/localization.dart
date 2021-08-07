import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'week.dart';

/// Provides localized strings for Timetable widgets.
///
/// Supported [Locale.languageCode]s:
///
/// * `de` – German
/// * `en` – English
/// * `es` – Spanish
/// * `fr` – French
/// * `it` – Italian
/// * `ja` – Japanese
/// * `pt` – Portuguese
/// * `zh_CN` – Chinese (Simplified)
/// * `zh_TW` – Chinese (Traditional)
///
/// By default, this delegate also configures [Intl] whenever Flutter's locale
/// changes. This behavior can be disabled via [setIntlLocale].
///
/// See also:
///
/// * [TimetableLocalizations], which contains all strings for one locale.
///
/// ## Supporting a new locale
///
/// 1. Copy `TimetableLocalizationsEn` from below, rename it (using the
///    UpperCamelCase variant of its
///    [BCP 47 language tag](https://en.wikipedia.org/wiki/IETF_language_tag)),
///    and update it to the new locale. The classes should be ordered
///    alphabetically.
/// 2. Add your class to the `_getLocalization` method below (again, ordered
///    alphabetically).
/// 3. List the new locale in the README.
/// 4. Add the locale to `_supportedLocale` in `example/lib/utils.dart`.
/// 5. Open a pull request and you're done 🎉
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
      case 'es':
        return const TimetableLocalizationEs();
      case 'fr':
        return const TimetableLocalizationFr();
      case 'it':
        return const TimetableLocalizationIt();
      case 'ja':
        return const TimetableLocalizationJa();
      case 'pt':
        return const TimetableLocalizationPt();
      case 'zh':
        if (locale.countryCode?.toLowerCase() == 'tw') {
          return const TimetableLocalizationZhTw();
        }
        return const TimetableLocalizationZhCn();
      default:
        assert(() {
          throw FlutterError.fromParts(<DiagnosticsNode>[
            ErrorSummary(
              "Timetable doesn't support the requested locale \"$locale\".",
            ),
            ErrorHint(
              'You can open an issue for Timetable to support this locale, or, '
              'preferably, create a pull request. The steps for adding support '
              'for a new locale are listed in the doc comment of '
              '[TimetableLocalizationsDelegate]',
            ),
          ]);
        }());
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
        ),
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

// You want to contribute a new localization? Awesome! Please follow the steps
// listed in the doc comment of [TimetableLocalizationsDelegate] above.

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

class TimetableLocalizationFr extends TimetableLocalizations {
  const TimetableLocalizationFr();

  @override
  List<String> weekLabels(Week week) {
    return [
      weekOfYear(week),
      'Semaine ${week.weekOfYear}',
      'S ${week.weekOfYear}',
      '${week.weekOfYear}',
    ];
  }

  @override
  String weekOfYear(Week week) =>
      'Semaine ${week.weekOfYear}, ${week.weekBasedYear}';
}

class TimetableLocalizationIt extends TimetableLocalizations {
  const TimetableLocalizationIt();

  @override
  List<String> weekLabels(Week week) {
    return [
      weekOfYear(week),
      'Settimana ${week.weekOfYear}',
      'S ${week.weekOfYear}',
      '${week.weekOfYear}',
    ];
  }

  @override
  String weekOfYear(Week week) =>
      'Settimana ${week.weekOfYear}, ${week.weekBasedYear}';
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

class TimetableLocalizationPt extends TimetableLocalizations {
  const TimetableLocalizationPt();

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

