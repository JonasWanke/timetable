📅 Customizable, animated calendar widget including day & week views.


|                                           Event positioning demo                                           |                                                            Zoomed in                                                            |                                                                    Dark mode & custom range                                                                    |
| :--------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| ![Screenshot of timetable](https://github.com/JonasWanke/timetable/raw/master/doc/screenshot.jpg?raw=true) | ![Screenshot of timetable while zoomed in](https://github.com/JonasWanke/timetable/raw/master/doc/screenshot-zoom.jpg?raw=true) | ![Screenshot of timetable in dark mode with only three visible days](https://github.com/JonasWanke/timetable/raw/master/doc/screenshot-3day-dark.jpg?raw=true) |


- [Getting started](#getting-started)
  - [1. Initialize <kbd>time_machine</kbd>](#1-initialize-kbdtimemachinekbd)
  - [2. Define your `Event`s](#2-define-your-events)
  - [3. Create an `EventProvider`](#3-create-an-eventprovider)
  - [4. Create a `TimetableController`](#4-create-a-timetablecontroller)
- [Features & Coming soon](#features--coming-soon)

## Getting started

### 1. Initialize [<kbd>time_machine</kbd>]

This package uses [<kbd>time_machine</kbd>] for handling date and time, which you first have to initialize.

Add this to your `pubspec.yaml`:
```yaml
flutter:
  assets:
    - packages/time_machine/data/cultures/cultures.bin
    - packages/time_machine/data/tzdb/tzdb.bin
```

Modify your `main.dart`'s `main()`:
```dart
import 'package:flutter/services.dart';
import 'package:time_machine/time_machine.dart';

void main() async {
  // Call these two functions before `runApp()`.
  WidgetsFlutterBinding.ensureInitialized();
  await TimeMachine.initialize({'rootBundle': rootBundle});

  runApp(MyApp());
}
```
<sup>Source: https://pub.dev/packages/time_machine#flutter-specific-notes</sup>


### 2. Define your [`Event`]s

Events are provided as instances of [`Event`]. To get you started, there's the subclass [`BasicEvent`], which you can instantiate directly. If you want to be more specific, you can also implement your own class extending [`Event`].

> **Note:** Most classes of <kbd>timetable</kbd> accept a type-parameter `E extends Event`. Please set it to your chosen [`Event`]-subclass (e.g. [`BasicEvent`]) to avoid runtime exceptions.

In addition, you also need a [`Widget`] to display your events. When using [`BasicEvent`], this can simply be [`BasicEventWidget`].


### 3. Create an [`EventProvider`]

As the name suggests, you use [`EventProvider`] to provide [`Event`]s to <kbd>timetable</kbd>. There are currently two [`EventProvider`]s to choose from:
- [`EventProvider.list(List<E> events)`][`EventProvider.list`]: Use this provider if you have a fixed list of events.
- [`EventProvider.stream({StreamedEventGetter<E> eventGetter})`][`EventProvider.stream`]: Use this provider if your events can change or you have many events and only want to load the relevant subset.

```dart
final myEventProvider = EventProvider.list([
  BasicEvent(
    id: 0,
    title: 'My Event',
    color: Colors.blue,
    start: LocalDate.today().at(LocalTime(13, 0, 0)),
    end: LocalDate.today().at(LocalTime(15, 0, 0)),
  ),
]);
```
> See the [example][example/main.dart] for more [`EventProvider`] samples!


### 4. Create a [`TimetableController`]

Similar to a [`ScrollController`] or a [`TabController`], a [`TimetableController`] is reponsible for interacting with a [`Timetable`] and managing its state. You can instantiate it with your [`EventProvider`]:
```dart
_controller = TimetableController(
  eventProvider: myEventProvider,
  // Optional parameters with their default values:
  initialDate: LocalDate.today(),
  visibleRange: VisibleRange.week(),
  firstDayOfWeek: DayOfWeek.monday,
);
```

> Don't forget to [`dispose`][`TimetableController.dispose`] your controller, e.g. in [`State.dispose`]!


## Features & Coming soon

- [x] Smartly arrange overlapping events
- [x] Zooming
- [x] Selectable [`VisibleRange`]s
- [ ] Animate between different [`VisibleRange`]s
- [ ] Display all-day events at the top
- [ ] Month-view, Agenda-view
- [ ] Listener when tapping the background (e.g. for creating an event)
- [ ] Support for event resizing



[example/main.dart]: https://github.com/JonasWanke/timetable/blob/master/example/lib/main.dart
[<kbd>time_machine</kbd>]: https://pub.dev/packages/time_machine
<!-- Flutter -->
[`TabController`]: https://api.flutter.dev/flutter/material/TabController-class.html
[`ScrollController`]: https://api.flutter.dev/flutter/widgets/ScrollController-class.html
[`State.dispose`]: https://api.flutter.dev/flutter/widgets/State/dispose.html
[`Widget`]: https://api.flutter.dev/flutter/widgets/Widget-class.html
<!-- timetable -->
[`BasicEvent`]: https://pub.dev/documentation/timetable/latest/timetable/BasicEvent-class.html
[`BasicEventWidget`]: https://pub.dev/documentation/timetable/latest/timetable/BasicEventWidget-class.html
[`Event`]: https://pub.dev/documentation/timetable/latest/timetable/Event-class.html
[`EventProvider`]: https://pub.dev/documentation/timetable/latest/timetable/EventProvider-class.html
[`EventProvider.list`]: https://pub.dev/documentation/timetable/latest/timetable/EventProvider/EventProvider.list.html
[`EventProvider.stream`]: https://pub.dev/documentation/timetable/latest/timetable/EventProvider/EventProvider.stream.html
[`Timetable`]: https://pub.dev/documentation/timetable/latest/timetable/Timetable-class.html
[`TimetableController`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableController-class.html
[`TimetableController.dispose`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableController/dispose.html
[`VisibleRange`]: https://pub.dev/documentation/timetable/latest/timetable/VisibleRange-class.html
