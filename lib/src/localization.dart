import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'utils.dart';

class TimetableLocalizationsDelegate
    extends LocalizationsDelegate<TimetableLocalizations> {
  @override
  bool isSupported(Locale locale) => _getLocalization(locale) != null;

  @override
  Future<TimetableLocalizations> load(Locale locale) {
    assert(isSupported(locale));
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
}

class TimetableLocalizationDe extends TimetableLocalizations {
  const TimetableLocalizationDe();

  @override
  List<String> weekLabels(WeekInfo weekInfo) {
    final week = weekInfo.weekOfYear;
    return [weekOfYear(weekInfo), 'Woche $week', 'KW $week', '$week'];
  }

  @override
  String weekOfYear(WeekInfo weekInfo) =>
      'Kalenderwoche ${weekInfo.weekOfYear} in ${weekInfo.weekBasedYear}';
}

class TimetableLocalizationEn extends TimetableLocalizations {
  const TimetableLocalizationEn();

  @override
  List<String> weekLabels(WeekInfo weekInfo) {
    final week = weekInfo.weekOfYear;
    return [weekOfYear(weekInfo), 'Week $week', 'W $week', '$week'];
  }

  @override
  String weekOfYear(WeekInfo weekInfo) =>
      'Week ${weekInfo.weekOfYear} in ${weekInfo.weekBasedYear}';
}
