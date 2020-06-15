# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).


<!-- Template:
## [NEW](https://github.com/JonasWanke/timetable/compare/vOLD...vNEW) · 2020-xx-xx
### ⚠ BREAKING CHANGES
### 🎉 New Features
### ⚡ Changes
### 🐛 Bug Fixes
### 📜 Documentation updates
### 🏗 Refactoring
### 📦 Build & CI
-->

## [Unreleased](https://github.com/JonasWanke/timetable/compare/v0.2.3...master)


## [0.2.3](https://github.com/JonasWanke/timetable/compare/v0.2.2...v0.2.3) · 2020-06-15

### 🎉 New Features
- Customizable date/weekday format with `TimetableThemeData.weekDayIndicatorPattern`, `.dateIndicatorPattern` & temporary `.totalDateIndicatorHeight` ([#16](https://github.com/JonasWanke/timetable/pull/16)), closes: ([#15](https://github.com/JonasWanke/timetable/issues/15))


## [0.2.2](https://github.com/JonasWanke/timetable/compare/v0.2.1...v0.2.2) · 2020-05-30

### 🎉 New Features
- optional `onTap`-parameter for `BasicEventWidget` & `BasicAllDayEventWidget` ([#12](https://github.com/JonasWanke/timetable/pull/12)), closes: ([#11](https://github.com/JonasWanke/timetable/issues/11))

### 📦 Build & CI
- specify minimum Dart version (v2.7.0) in `pubspec.yaml`


## [0.2.1](https://github.com/JonasWanke/timetable/compare/v0.2.0...v0.2.1) · 2020-05-19

### 🎉 New Features
- All-day events (shown at the top) ([#8](https://github.com/JonasWanke/timetable/pull/8)), closes: ([#5](https://github.com/JonasWanke/timetable/issues/5))
- Theming ([#9](https://github.com/JonasWanke/timetable/pull/9)) — see the README for more information!

### 📦 Build & CI
- specify minimum Flutter version (v1.17.0) in `pubspec.yaml`
- **example:** upload generated APK as artifact


## [0.2.0](https://github.com/JonasWanke/timetable/compare/v0.1.3...v0.2.0) · 2020-05-08

### ⚠ BREAKING CHANGES
- fix week scroll alignment ([#6](https://github.com/JonasWanke/timetable/pull/6))
  - To provide a simpler API the exposed methods of `VisibleRange` were changed slightly. This doesn't affect you if you just instantiate one of the given implementations, but only if you extend it yourself or call one of its methods directly.

### 🐛 Bug Fixes
- support Flutter v1.17.0 ([#4](https://github.com/JonasWanke/timetable/pull/4))


## [0.1.3](https://github.com/JonasWanke/timetable/compare/v0.1.2...v0.1.3) · 2020-05-06

### 🐛 Bug Fixes
- fix time zooming & add testing ([#3](https://github.com/JonasWanke/timetable/pull/3))


## [0.1.2](https://github.com/JonasWanke/timetable/compare/v0.1.1...v0.1.2) · 2020-05-05

### 🎉 New Features
- add `TimetableController.initialTimeRange`, closes: [#1](https://github.com/JonasWanke/timetable/issues/1)

### 🐛 Bug Fixes
- fix week alignment with `WeekVisibleRange`, closes: [#2](https://github.com/JonasWanke/timetable/issues/2)


## [0.1.1](https://github.com/JonasWanke/timetable/compare/v0.1.0...v0.1.1) · 2020-04-02

### 📜 Documentation updates
- fix broken links in README


## 0.1.0 · 2020-04-02

Initial release 🎉
