# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


<!-- Template:
## NEW · 2023-xx-xx

### ⚠️ BREAKING CHANGES
### 🎉 New Features
### ⚡ Changes
### 🐛 Bug Fixes
### 📜 Documentation updates
### 🏗️ Refactoring
### 📦 Build & CI
-->

## 1.0.0-alpha.11 · 2023-01-24

### ⚠️ BREAKING CHANGES
* Add `DateScrollActivity` and subclasses. `dateController.value.activity` tells you the current activity and even the target when currently animating between dates. This is breaking because `dateController.value` now stores a `DatePageValueWithScrollActivity` instead of a `DatePageValue` ([`59b0eb4`](https://github.com/JonasWanke/timetable/commit/59b0eb48506cfe25aa5cda0de3bade261d502f43)), closes: [#110](https://github.com/JonasWanke/timetable/issues/110)

### 🎉 New Features
* add `DateDiagnosticsProperty` ([`469a0de`](https://github.com/JonasWanke/timetable/commit/469a0ded6acab100ad5deaae8eab0bf6b29a7544))
* implement `Diagnosticable` for `VisibleDateRange` and `DatePageValue` ([`8855d85`](https://github.com/JonasWanke/timetable/commit/8855d85690ef9f5b497fb27b28c1d9bf37734df9))

### 🐛 Bug Fixes
* cancel ongoing animations when jumping in `DateController`/`TimeController` ([`c0167c2`](https://github.com/JonasWanke/timetable/commit/c0167c24100fdd607ffb8a8d5ed9094a536e5848)), closes: [#135](https://github.com/JonasWanke/timetable/issues/135)
* honor maximum constraints in `WeekIndicator`  ([`8e0315c`](https://github.com/JonasWanke/timetable/commit/8e0315cb4169b1a0d3c04c5411b2132ce0f2ce71)), closes: [#131](https://github.com/JonasWanke/timetable/issues/131)
* fix `MonthPageView`'s shrink-wrapped height when jumping to far-away date ([`763661e`](https://github.com/JonasWanke/timetable/commit/763661eeae0a84ab1d2af3d2cd0b05277f62c044))
* fix `allDayEventBorder.toString()` ([`b35b240`](https://github.com/JonasWanke/timetable/commit/b35b24032919a231d3d817e9afbeb816ef9a768d))

### 📦 Build & CI
* upgrade to Flutter: `>=3.3.0`, Dart `>=2.18.0 <3.0.0` ([`ed2d0a0`](https://github.com/JonasWanke/timetable/commit/ed2d0a0aeb6a57741b808088be847a430fecae6a))
* update `black_hole_flutter` to `^1.0.0` ([`40f1b67`](https://github.com/JonasWanke/timetable/commit/40f1b6764bf2e5fb7df9a95ea448c9a7071832a8))

## 1.0.0-alpha.10 · 2022-08-19

### 📜 Documentation updates
* add `multiDateContentGeometry.resolveOffset(…)` to README

## 1.0.0-alpha.9 · 2022-08-19

### ⚠️ BREAKING CHANGES
* remove `DateTimeTimetable.interval` in favor of `.fullDayInterval` ([`bee93d7`](https://github.com/JonasWanke/timetable/commit/bee93d73f7fa1c0ef9b51db7f1ab561793b27e35))
* `TimetableThemeData.raw(…)` takes a new required parameter `MultiDateTimetableStyle multiDateTimetableStyle` ([`1fef623`](https://github.com/JonasWanke/timetable/commit/1fef623c05ebbe51327c99c3148115e1b5e7d6df))

### 🎉 New Features
* `MultiDateEventHeader` supports limiting the number of rows to display events in. If there are more events in parallel, overflow indicators are displayed.
  * add `multiDateEventHeaderStyle.maxEventRows` ([`0ea6549`](https://github.com/JonasWanke/timetable/commit/0ea654907542a294729f962a9622f7ecd12cbe6c)) and `multiDateTimetableStyle.maxHeaderFraction` ([`1fef623`](https://github.com/JonasWanke/timetable/commit/1fef623c05ebbe51327c99c3148115e1b5e7d6df)), closes: [#89](https://github.com/JonasWanke/timetable/issues/89)
  * coerce `multiDateEventHeaderStyle.maxEventRows` to fit available height ([`0009716`](https://github.com/JonasWanke/timetable/commit/0009716a96743473535731d38e3a5a561f980719)), closes: [#63](https://github.com/JonasWanke/timetable/issues/63)
  * add `timetableCallbacks.onMultiDateHeaderOverflowTap` ([`ec18ef1`](https://github.com/JonasWanke/timetable/commit/ec18ef191b38c81b42afa5c8942062263d675362))
* add `timeController.minDayHeight` to ensure that labels and events have enough space available when zooming out ([`8dafaa5`](https://github.com/JonasWanke/timetable/commit/8dafaa5e577349f896b0cb1fb17857685bdd2269)), closes: [#76](https://github.com/JonasWanke/timetable/issues/76)
* enable dragging widgets into timetable content ([`b54154d`](https://github.com/JonasWanke/timetable/commit/b54154dc249e8e7f2ac882af5572a7f47232cf01)), closes: [#124](https://github.com/JonasWanke/timetable/issues/124)
  * add `contentGeometryKey` to `MultiDateTimetable` and `MultiDateTimetableHeader` constructors ([`caf9ef9`](https://github.com/JonasWanke/timetable/commit/caf9ef9563ef650484bf14b8ce591a7ba620a5e7))
* complete remaining `Event`'s and `BasicEvent`'s `debugFillProperties(…)` ([`c3a15e9`](https://github.com/JonasWanke/timetable/commit/c3a15e90c42bf36bf21c47f6b06d33eb070cfb86))
* add `.raw` constructors for `MultiDateTimetable`, `MultiDateTimetableHeader`, and `MultiDateTimetableContent` ([`bb7767e`](https://github.com/JonasWanke/timetable/commit/bb7767e755a503a100479978c1e46c81ee628262))

### 🐛 Bug Fixes
* honor initial vertical pointer alignment while dragging events ([`b54154d`](https://github.com/JonasWanke/timetable/commit/b54154dc249e8e7f2ac882af5572a7f47232cf01))

### 📜 Documentation updates
* add detailed error messages for `isValidTimetable…` assertions ([`3b6f115`](https://github.com/JonasWanke/timetable/commit/3b6f115ba00593f36d7977503c63b37cd5785c03)), closes: [#127](https://github.com/JonasWanke/timetable/issues/127)

## 1.0.0-alpha.8 · 2022-06-08

### ⚠️ BREAKING CHANGES
* `DatePageValue.date` now rounds the raw page value instead of flooring it ([`9d17622`](https://github.com/JonasWanke/timetable/commit/9d17622c5e13294232e6e17255caf734330f0937))

### 📦 Build & CI
* update to Flutter 3 ([#122](https://github.com/JonasWanke/timetable/pull/122)). Thanks to [@ThexXTURBOXx](https://github.com/ThexXTURBOXx)!

## 1.0.0-alpha.7 · 2022-04-23

### 🎉 New Features
* add `dateController.visibleDates `, `datePageValue.visibleDates`, `.firstVisibleDate`, `.firstVisiblePage`,`.lastVisibleDate`, and `.lastVisiblePage` ([`74df510`](https://github.com/JonasWanke/timetable/commit/74df51089d1c51187146c36736be05a58ede64da)), closes: [#119](https://github.com/JonasWanke/timetable/issues/119)
* support scrolling with a `Scrollbar` in `TimeZoom` ([`e196576`](https://github.com/JonasWanke/timetable/commit/e1965764279eb25b12538052f593141d6989898a))
* support mouse scrolling in `TimeZoom` ([`1a286f2`](https://github.com/JonasWanke/timetable/commit/1a286f2e80178efddaa5ce3cc44aaf9e7df5b55c)), closes: [#115](https://github.com/JonasWanke/timetable/issues/115)

### ⚡ Changes
* `WeekIndicator` no longer uses a `LayoutBuilder` internally ([`a8d04ee`](https://github.com/JonasWanke/timetable/commit/a8d04ee29b7e688aea619176b3561f5a09c4a145))

### 🐛 Bug Fixes
* remove scrollbar for default time indicators ([`47cb162`](https://github.com/JonasWanke/timetable/commit/47cb162aee378e76c7af544de71d491354a00f15)), closes: [#116](https://github.com/JonasWanke/timetable/issues/116)

## 1.0.0-alpha.6 · 2021-09-29

### 🎉 New Features
* add Hungarian localization ([#112](https://github.com/JonasWanke/timetable/pull/112)). Thanks to [@bmxbandita](https://github.com/bmxbandita)!

### 🐛 Bug Fixes
* show missing dates in `MonthWidget` and `MonthPageView` ([`0937dea`](https://github.com/JonasWanke/timetable/commit/0937dea588ab85747762507530f443eea9effd8f)), closes: [#101](https://github.com/JonasWanke/timetable/issues/101)
* support the new `computeHitSlop(…)` ([`f7bf2c0`](https://github.com/JonasWanke/timetable/commit/f7bf2c00efb63a1214868a05e3cff9e992c1bfed)), closes: [#105](https://github.com/JonasWanke/timetable/issues/105)

## 1.0.0-alpha.5 · 2021-08-07

### 🎉 New Features
* add French and Portuguese localization ([#94](https://github.com/JonasWanke/timetable/pull/94)). Thanks to [@simo9900](https://github.com/simo9900)!
* add `timeRange.maxDuration` ([`be77146`](https://github.com/JonasWanke/timetable/commit/be7714630d40ad1a5cee4293a8ea1eb400b18216)), closes: [#95](https://github.com/JonasWanke/timetable/issues/95)
* add `timetableLocalizationsDelegate.fallbackLocale` ([`b65fa1b`](https://github.com/JonasWanke/timetable/commit/b65fa1b068610308e44a615cf3ec1f206dd91a5e))

### 🐛 Bug Fixes
* keep `TimeZoom`'s position after layout change ([`0beaf7d`](https://github.com/JonasWanke/timetable/commit/0beaf7d4b868712b967ca44e8525d4e31bf3c5c8)), closes: [#78](https://github.com/JonasWanke/timetable/issues/78)

## 1.0.0-alpha.4 · 2021-08-06

### 🐛 Bug Fixes
* avoid "Unsupported operation: Infinity or NaN toInt" during time scale gesture ([`82abaa5`](https://github.com/JonasWanke/timetable/commit/82abaa5e2c745a5d2869fd7f41628f5fb63911ca)), closes: [#92](https://github.com/JonasWanke/timetable/issues/92)
* avoid showing superfluous dates when `maxDate` is set in `VisibleDateRange.days` ([`e864409`](https://github.com/JonasWanke/timetable/commit/e86440978babea5c5c5e9b870772359f8bea452f)), closes: [#93](https://github.com/JonasWanke/timetable/issues/93)

## 1.0.0-alpha.3 · 2021-08-02

### 🎉 New Features
* add Spanish localization ([#84](https://github.com/JonasWanke/timetable/pull/84)). Thanks to [@paolovalerdi](https://github.com/paolovalerdi)!
* add missing exports for `DateContent`, `TimeOverlays`, `EventBuilder<E>`, and `DefaultEventBuilder<E>` ([`3877220`](https://github.com/JonasWanke/timetable/commit/3877220782bc0534a3186916502be3c4380c5dbe))

### 🐛 Bug Fixes
* support scrolling when inside a `ScrollView` ([`b4ffeee`](https://github.com/JonasWanke/timetable/commit/b4ffeeeafa854578b825c80b93ba0a546bda807b)), closes: [#80](https://github.com/JonasWanke/timetable/issues/80)
* avoid unsafe calls to `DefaultTimeController.of(…)` in `TimeZoom` ([`7bd6447`](https://github.com/JonasWanke/timetable/commit/7bd64472769829e99da3a9539bc21dd3023c4671)), closes: [#90](https://github.com/JonasWanke/timetable/issues/90). Thanks to [@paolovalerdi](https://github.com/paolovalerdi) for investigating the cause!

### 📜 Documentation updates
* document how to support a new locale ([`d2f369c`](https://github.com/JonasWanke/timetable/commit/d2f369cfba913023c8ecee6d21d462811f15a739))

## 1.0.0-alpha.2 · 2021-07-15

### ⚠️ BREAKING CHANGES
* `TimeIndicators`' factories no longer accept an `AlignmentGeometry`, but only an `Alignment` ([`8d8985d`](https://github.com/JonasWanke/timetable/commit/8d8985dba4571215cb0b30221b7e3c289eaecd0c))

### 🎉 New Features
* add Japanese and Chinese localizations ([#82](https://github.com/JonasWanke/timetable/pull/82)). Thanks to [@MasterHiei](https://github.com/MasterHiei)!
* add Italian localization ([#88](https://github.com/JonasWanke/timetable/pull/88)). Thanks to [@mircoboschi](https://github.com/mircoboschi)!
* add `alwaysUse24HourFormat` to `TimeIndicatorStyle`'s constructor ([#82](https://github.com/JonasWanke/timetable/pull/82)). Thanks to [@MasterHiei](https://github.com/MasterHiei)!
* add `partDayDraggableEvent.onDragCanceled` ([#82](https://github.com/JonasWanke/timetable/pull/82)). Thanks to [@MasterHiei](https://github.com/MasterHiei)!
* `TimeIndicators`' factories now accept additional parameters for the first and last hour / half hour and whether to align the outer labels inside ([`8d8985d`](https://github.com/JonasWanke/timetable/commit/8d8985dba4571215cb0b30221b7e3c289eaecd0c)), closes: [#77](https://github.com/JonasWanke/timetable/issues/77)
* `MultiDateTimetable`'s constructor now allows you to override only the `contentLeading` widget ([`8e65964`](https://github.com/JonasWanke/timetable/commit/8e6596480b4ffa194c920c8a2652230d3012e680))

### 🐛 Bug Fixes
* use the correct date for `DateTimeTimetable.today()` ([#87](https://github.com/JonasWanke/timetable/pull/87)), closes: [#81](https://github.com/JonasWanke/timetable/issues/81). Thanks to [@paolovalerdi](https://github.com/paolovalerdi)!
* avoid `double` precision errors ([`998926f`](https://github.com/JonasWanke/timetable/commit/998926f27b31039b66c4bac77ed17e9659fa1b9e)), closes: [#79](https://github.com/JonasWanke/timetable/issues/79), [#86](https://github.com/JonasWanke/timetable/issues/86)

## 1.0.0-alpha.1 · 2021-06-09

### 🐛 Bug Fixes
* repaint `NowIndicator` only when its position changes noticeably, ([`c5291d1`](https://github.com/JonasWanke/timetable/commit/1bbac5c9384036a90d77f123daf955b107ac6602)), closes: [#72](https://github.com/JonasWanke/timetable/issues/72)

### 📦 Build & CI
* remove unused <kbd>rxdart</kbd> dependency, ([`c5291d1`](https://github.com/JonasWanke/timetable/commit/33d0118a64405a116f1e8a3c7ccb41c804166cc2)), closes: [#71](https://github.com/JonasWanke/timetable/issues/71)
* upgrade dependencies

## 1.0.0-alpha.0 · 2021-06-06

### ⚠️ BREAKING CHANGES
- Almost a rewrite of this package to create a modular architecture with support for different layouts ([#69](https://github.com/JonasWanke/timetable/pull/69)), closing [#17](https://github.com/JonasWanke/timetable/issues/17), [#21](https://github.com/JonasWanke/timetable/issues/21), [#23](https://github.com/JonasWanke/timetable/issues/23), [#25](https://github.com/JonasWanke/timetable/issues/25), [#26](https://github.com/JonasWanke/timetable/issues/26), [#33](https://github.com/JonasWanke/timetable/issues/33), [#36](https://github.com/JonasWanke/timetable/issues/36), [#38](https://github.com/JonasWanke/timetable/issues/38), [#41](https://github.com/JonasWanke/timetable/issues/41), [#46](https://github.com/JonasWanke/timetable/issues/46), [#51](https://github.com/JonasWanke/timetable/issues/51), [#52](https://github.com/JonasWanke/timetable/issues/52), [#56](https://github.com/JonasWanke/timetable/issues/56), [#58](https://github.com/JonasWanke/timetable/issues/58), [#60](https://github.com/JonasWanke/timetable/issues/60), [#61](https://github.com/JonasWanke/timetable/issues/61), and [#64](https://github.com/JonasWanke/timetable/issues/64). Please have a look at the new README as the API was changed significantly.

## 0.2.9 · 2020-10-26

### 🐛 Bug Fixes
- Compatibility with Flutter v1.23 ([#57](https://github.com/JonasWanke/timetable/pull/57)), closes: [#55](https://github.com/JonasWanke/timetable/issues/55) (for Flutter `^1.23.0-13.0.pre`)


## 0.2.8 · 2020-09-18

### 🐛 Bug Fixes
- Allow full-height `leadingHeaderBuilder`s ([#50](https://github.com/JonasWanke/timetable/pull/50)), closes: [#49](https://github.com/JonasWanke/timetable/issues/49)

## 0.2.7 · 2020-09-02

### 🎉 New Features
- add `TimetableThemeData.minimumHourZoom` & `.maximumHourZoom`, closes: [#40](https://github.com/JonasWanke/timetable/issues/40) and [#45](https://github.com/JonasWanke/timetable/issues/45)

### 🐛 Bug Fixes
- support null values in `InitialTimeRange.range`

### 📦 Build & CI
- update <kbd>dartx</kbd> to `^0.5.0`


## 0.2.6 · 2020-07-12

### 🎉 New Features
- add custom builders for date header and leading area of the header (usually a week indicator) ([#28](https://github.com/JonasWanke/timetable/pull/28)), closes: [#27](https://github.com/JonasWanke/timetable/issues/27). Thanks to [@TatsuUkraine](https://github.com/TatsuUkraine)!
- add theme properties for disabling event stacking and configuring the minimum overlap ([#34](https://github.com/JonasWanke/timetable/pull/34)), closes: [#31](https://github.com/JonasWanke/timetable/issues/31)

### 🐛 Bug Fixes
- Expand part-day events to fill empty columns ([#30](https://github.com/JonasWanke/timetable/pull/30)), closes: [#29](https://github.com/JonasWanke/timetable/issues/29)


## 0.2.5 · 2020-07-06

### 📜 Documentation updates
- add Localization section to the README

### 📦 Build & CI
- update <kbd>dartx</kbd> to `^0.4.0`


## 0.2.4 · 2020-06-25

### 🎉 New Features
- `Timetable.onEventBackgroundTap`: called when tapping the background, e.g. for creating an event ([#20](https://github.com/JonasWanke/timetable/pull/20)), closes: [#18](https://github.com/JonasWanke/timetable/issues/18). Thanks to [@raLaaaa](https://github.com/raLaaaa)!
- add `EventProvider.simpleStream` as a simpler interface than `EventProvider.stream` ([e63bfb4](https://github.com/JonasWanke/timetable/commit/e63bfb4f974ce5319fd6f6bb12ebb561d8c5143c))

### 📜 Documentation updates
- improve streaming `EventProvider` documentation ([e63bfb4](https://github.com/JonasWanke/timetable/commit/e63bfb4f974ce5319fd6f6bb12ebb561d8c5143c)), fixes: [#19](https://github.com/JonasWanke/timetable/issues/19)


## 0.2.3 · 2020-06-15

### 🎉 New Features
- Customizable date/weekday format with `TimetableThemeData.weekDayIndicatorPattern`, `.dateIndicatorPattern` & temporary `.totalDateIndicatorHeight` ([#16](https://github.com/JonasWanke/timetable/pull/16)), closes: [#15](https://github.com/JonasWanke/timetable/issues/15)


## 0.2.2 · 2020-05-30

### 🎉 New Features
- optional `onTap`-parameter for `BasicEventWidget` & `BasicAllDayEventWidget` ([#12](https://github.com/JonasWanke/timetable/pull/12)), closes: [#11](https://github.com/JonasWanke/timetable/issues/11)

### 📦 Build & CI
- specify minimum Dart version (v2.7.0) in `pubspec.yaml`


## 0.2.1 · 2020-05-19

### 🎉 New Features
- All-day events (shown at the top) ([#8](https://github.com/JonasWanke/timetable/pull/8)), closes: [#5](https://github.com/JonasWanke/timetable/issues/5)
- Theming ([#9](https://github.com/JonasWanke/timetable/pull/9)) — see the README for more information!

### 📦 Build & CI
- specify minimum Flutter version (v1.17.0) in `pubspec.yaml`
- **example:** upload generated APK as artifact


## 0.2.0 · 2020-05-08

### ⚠️ BREAKING CHANGES
- fix week scroll alignment ([#6](https://github.com/JonasWanke/timetable/pull/6))
  - To provide a simpler API the exposed methods of `VisibleRange` were changed slightly. This doesn't affect you if you just instantiate one of the given implementations, but only if you extend it yourself or call one of its methods directly.

### 🐛 Bug Fixes
- support Flutter v1.17.0 ([#4](https://github.com/JonasWanke/timetable/pull/4))


## 0.1.3 · 2020-05-06

### 🐛 Bug Fixes
- fix time zooming & add testing ([#3](https://github.com/JonasWanke/timetable/pull/3))


## 0.1.2 · 2020-05-05

### 🎉 New Features
- add `TimetableController.initialTimeRange`, closes: [#1](https://github.com/JonasWanke/timetable/issues/1)

### 🐛 Bug Fixes
- fix week alignment with `WeekVisibleRange`, closes: [#2](https://github.com/JonasWanke/timetable/issues/2)


## 0.1.1 · 2020-04-02

### 📜 Documentation updates
- fix broken links in README


## 0.1.0 · 2020-04-02

Initial release 🎉
