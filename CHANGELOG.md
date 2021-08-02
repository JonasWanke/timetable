# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).


<!-- Template:
## NEW · 2021-xx-xx
### ⚠️ BREAKING CHANGES
### 🎉 New Features
### ⚡ Changes
### 🐛 Bug Fixes
### 📜 Documentation updates
### 🏗️ Refactoring
### 📦 Build & CI
-->

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
