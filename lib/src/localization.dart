import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'utils.dart';

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

  List<String> weekLabels(WeekInfo weekInfo);
  String weekOfYear(WeekInfo weekInfo);
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
  List<String> weekLabels(WeekInfo weekInfo) {
    final week = weekInfo.weekOfYear + 1;
    return [weekOfYear(weekInfo), 'Woche $week', 'KW $week', '$week'];
  }

  @override
  String weekOfYear(WeekInfo weekInfo) =>
      'Kalenderwoche ${weekInfo.weekOfYear + 1}, ${weekInfo.weekBasedYear}';
}

class TimetableLocalizationEn extends TimetableLocalizations {
  const TimetableLocalizationEn();

  @override
  List<String> weekLabels(WeekInfo weekInfo) {
    final week = weekInfo.weekOfYear + 1;
    return [weekOfYear(weekInfo), 'Week $week', 'W $week', '$week'];
  }

  @override
  String weekOfYear(WeekInfo weekInfo) =>
      'Week ${weekInfo.weekOfYear + 1}, ${weekInfo.weekBasedYear}';
}
