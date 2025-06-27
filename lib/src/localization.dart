import 'package:chrono/chrono.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

/// Provides localized strings for Timetable widgets.
///
/// Supported [Locale.languageCode]s:
///
/// * `de` – German
/// * `da` – Danish
/// * `en` – English
/// * `es` – Spanish
/// * `fr` – French
/// * `hu` – Hungarian
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
/// 1. Copy `TimetableLocalizationEn` from below, rename it (using the
///    UpperCamelCase variant of its
///    [BCP 47 language tag](https://en.wikipedia.org/wiki/IETF_language_tag)),
///    and update it to the new locale. The classes should be ordered
///    alphabetically.
/// 2. Add your class to the `_getLocalization` method below (again, ordered
///    alphabetically).
/// 3. List the new locale in the README (alphabetically).
/// 4. Add the new locale to the list above (alphabetically).
/// 5. Add the locale to `_supportedLocale` in `example/lib/utils.dart`.
/// 6. Open a pull request and you're done 🎉
class TimetableLocalizationsDelegate
    extends LocalizationsDelegate<TimetableLocalizations> {
  const TimetableLocalizationsDelegate({
    this.setIntlLocale = true,
    this.fallbackLocale,
  });

  /// Whether to update `Intl.defaultLocale` when the app's locale changes.
  final bool setIntlLocale;

  /// When localizations for a requested locale are missing, Timetable will
  /// instead use this locale.
  ///
  /// If this is `null` (the default), Timetable widgets depending on
  /// localizations will produce errors.
  ///
  /// If this is set, the locale must be supported by Timetable.
  final Locale? fallbackLocale;

  @override
  bool isSupported(Locale locale) {
    assert(
      fallbackLocale == null || _getLocalization(fallbackLocale!) != null,
      "Timetable doesn't support the `fallbackLocale` \"$fallbackLocale\".",
    );
    return _getLocalization(locale) != null || fallbackLocale != null;
  }

  @override
  Future<TimetableLocalizations> load(Locale locale) {
    assert(isSupported(locale));

    if (setIntlLocale) Intl.defaultLocale = locale.toLanguageTag();

    var localizations = _getLocalization(locale);
    if (fallbackLocale != null) {
      localizations ??= _getLocalization(fallbackLocale!)!;
    }
    return SynchronousFuture(localizations!);
  }

  @override
  bool shouldReload(TimetableLocalizationsDelegate old) => false;

  static TimetableLocalizations? _getLocalization(Locale locale) {
    return switch ((locale.languageCode, locale.countryCode?.toUpperCase())) {
      ('da', _) => const TimetableLocalizationDa(),
      ('de', _) => const TimetableLocalizationDe(),
      ('en', _) => const TimetableLocalizationEn(),
      ('es', _) => const TimetableLocalizationEs(),
      ('fr', _) => const TimetableLocalizationFr(),
      ('hu', _) => const TimetableLocalizationHu(),
      ('it', _) => const TimetableLocalizationIt(),
      ('ja', _) => const TimetableLocalizationJa(),
      ('pt', _) => const TimetableLocalizationPt(),
      ('zh', 'TW') => const TimetableLocalizationZhTw(),
      ('zh', _) => const TimetableLocalizationZhCn(),
      _ => null,
    };
  }
}

// Modified version of `debugCheckHasMaterialLocalizations`.
bool debugCheckHasTimetableLocalizations(BuildContext context) {
  assert(() {
    final localizations = Localizations.of<TimetableLocalizations>(
      context,
      TimetableLocalizations,
    );
    if (localizations == null) {
      throw FlutterError.fromParts([
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

  String allDayOverflow(int overflowCount) => '+$overflowCount';

  List<String> weekLabels(IsoYearWeek yearWeek);
  String weekOfYear(IsoYearWeek yearWeek);
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

class TimetableLocalizationDa extends TimetableLocalizations {
  const TimetableLocalizationDa();

  @override
  List<String> weekLabels(IsoYearWeek yearWeek) {
    return [weekOfYear(yearWeek), 'Uge ${yearWeek.week}', '${yearWeek.week}'];
  }

  @override
  String weekOfYear(IsoYearWeek yearWeek) =>
      'Uge ${yearWeek.week}, ${yearWeek.weekBasedYear}';
}

class TimetableLocalizationDe extends TimetableLocalizations {
  const TimetableLocalizationDe();

  @override
  List<String> weekLabels(IsoYearWeek yearWeek) {
    return [
      weekOfYear(yearWeek),
      'Woche ${yearWeek.week}',
      'KW ${yearWeek.week}',
      '${yearWeek.week}',
    ];
  }

  @override
  String weekOfYear(IsoYearWeek yearWeek) =>
      'Kalenderwoche ${yearWeek.week}, ${yearWeek.weekBasedYear}';
}

class TimetableLocalizationEn extends TimetableLocalizations {
  const TimetableLocalizationEn();

  @override
  List<String> weekLabels(IsoYearWeek yearWeek) {
    return [
      weekOfYear(yearWeek),
      'Week ${yearWeek.week}',
      'W ${yearWeek.week}',
      '${yearWeek.week}',
    ];
  }

  @override
  String weekOfYear(IsoYearWeek yearWeek) =>
      'Week ${yearWeek.week}, ${yearWeek.weekBasedYear}';
}

class TimetableLocalizationEs extends TimetableLocalizations {
  const TimetableLocalizationEs();

  @override
  List<String> weekLabels(IsoYearWeek yearWeek) {
    return [
      weekOfYear(yearWeek),
      'Semana ${yearWeek.week}',
      'S ${yearWeek.week}',
      '${yearWeek.week}',
    ];
  }

  @override
  String weekOfYear(IsoYearWeek yearWeek) =>
      'Semana ${yearWeek.week}, ${yearWeek.weekBasedYear}';
}

class TimetableLocalizationFr extends TimetableLocalizations {
  const TimetableLocalizationFr();

  @override
  List<String> weekLabels(IsoYearWeek yearWeek) {
    return [
      weekOfYear(yearWeek),
      'Semaine ${yearWeek.week}',
      'S ${yearWeek.week}',
      '${yearWeek.week}',
    ];
  }

  @override
  String weekOfYear(IsoYearWeek yearWeek) =>
      'Semaine ${yearWeek.week}, ${yearWeek.weekBasedYear}';
}

class TimetableLocalizationHu extends TimetableLocalizations {
  const TimetableLocalizationHu();

  @override
  List<String> weekLabels(IsoYearWeek yearWeek) =>
      [weekOfYear(yearWeek), '${yearWeek.week}. hét', '${yearWeek.week}'];

  @override
  String weekOfYear(IsoYearWeek yearWeek) =>
      '${yearWeek.week}. hét, ${yearWeek.weekBasedYear}';
}

class TimetableLocalizationIt extends TimetableLocalizations {
  const TimetableLocalizationIt();

  @override
  List<String> weekLabels(IsoYearWeek yearWeek) {
    return [
      weekOfYear(yearWeek),
      'Settimana ${yearWeek.week}',
      'S ${yearWeek.week}',
      '${yearWeek.week}',
    ];
  }

  @override
  String weekOfYear(IsoYearWeek yearWeek) =>
      'Settimana ${yearWeek.week}, ${yearWeek.weekBasedYear}';
}

class TimetableLocalizationJa extends TimetableLocalizations {
  const TimetableLocalizationJa();

  @override
  List<String> weekLabels(IsoYearWeek yearWeek) {
    return [
      weekOfYear(yearWeek),
      '第${yearWeek.week}週',
      '${yearWeek.week}週',
      '${yearWeek.week}',
    ];
  }

  @override
  String weekOfYear(IsoYearWeek yearWeek) =>
      'Week ${yearWeek.week}, ${yearWeek.weekBasedYear}';
}

class TimetableLocalizationPt extends TimetableLocalizations {
  const TimetableLocalizationPt();

  @override
  List<String> weekLabels(IsoYearWeek yearWeek) {
    return [
      weekOfYear(yearWeek),
      'Semana ${yearWeek.week}',
      'S ${yearWeek.week}',
      '${yearWeek.week}',
    ];
  }

  @override
  String weekOfYear(IsoYearWeek yearWeek) =>
      'Semana ${yearWeek.week}, ${yearWeek.weekBasedYear}';
}

class TimetableLocalizationZhCn extends TimetableLocalizations {
  const TimetableLocalizationZhCn();

  @override
  List<String> weekLabels(IsoYearWeek yearWeek) {
    return [
      weekOfYear(yearWeek),
      '第${yearWeek.week}周',
      '${yearWeek.week}周',
      '${yearWeek.week}',
    ];
  }

  @override
  String weekOfYear(IsoYearWeek yearWeek) =>
      'Week ${yearWeek.week}, ${yearWeek.weekBasedYear}';
}

class TimetableLocalizationZhTw extends TimetableLocalizations {
  const TimetableLocalizationZhTw();

  @override
  List<String> weekLabels(IsoYearWeek yearWeek) {
    return [
      weekOfYear(yearWeek),
      '第${yearWeek.week}週',
      '${yearWeek.week}週',
      '${yearWeek.week}',
    ];
  }

  @override
  String weekOfYear(IsoYearWeek yearWeek) =>
      'Week ${yearWeek.week}, ${yearWeek.weekBasedYear}';
}
