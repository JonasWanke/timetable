📅 Customizable, animated calendar widget including day & week views.


|                                        Event positioning demo                                        |                                                                    Dark mode & custom range                                                                    |
| :--------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| ![Screenshot of timetable](https://github.com/JonasWanke/timetable/raw/master/doc/demo.gif?raw=true) | ![Screenshot of timetable in dark mode with only three visible days](https://github.com/JonasWanke/timetable/raw/master/doc/screenshot-3day-dark.jpg?raw=true) |


- [Getting started](#getting-started)
  - [1. Initialize <kbd>time_machine</kbd>](#1-initialize-time_machine)
  - [2. Define your `Event`s](#2-define-your-events)
  - [3. Create an `EventProvider`](#3-create-an-eventprovider)
  - [4. Create a `TimetableController`](#4-create-a-timetablecontroller)
  - [5. Create your `Timetable`](#5-create-your-timetable)
- [Theming](#theming)
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

- [`EventProvider.list(List<E> events)`][`EventProvider.list`]: If you have a non-changing list of events.
- [`EventProvider.simpleStream(Stream<List<E>> eventStream)`][`EventProvider.simpleStream`]: If you have a limited, changing list of events.
- [`EventProvider.stream({StreamedEventGetter<E> eventGetter})`][`EventProvider.stream`]: If your events can change or you have many events and only want to load the relevant subset.

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

For trying out the behavior of changing events, you can create a `StreamController<List<E>>` and `add()` different lists of events, e.g. in `Future.delayed()`:

```dart
final eventController = StreamController<List<BasicEvent>>()..add([]);
final provider = EventProvider.simpleStream(eventController.stream);
Future.delayed(Duration(seconds: 5), () => eventController.add(/* some events */));

// Don't forget to close the stream controller when you're done, e.g. in `dispose`:
eventController.close();
```

> See the [example][example/main.dart] for more [`EventProvider`] samples!


### 4. Create a [`TimetableController`]

Similar to a [`ScrollController`] or a [`TabController`], a [`TimetableController`] is responsible for interacting with a [`Timetable`] and managing its state. You can instantiate it with your [`EventProvider`]:

```dart
final myController = TimetableController(
  eventProvider: myEventProvider,
  // Optional parameters with their default values:
  initialTimeRange: InitialTimeRange.range(
    startTime: LocalTime(8, 0, 0),
    endTime: LocalTime(20, 0, 0),
  ),
  initialDate: LocalDate.today(),
  visibleRange: VisibleRange.week(),
  firstDayOfWeek: DayOfWeek.monday,
);
```

> Don't forget to [`dispose`][`TimetableController.dispose`] your controller, e.g. in [`State.dispose`]!


### 5. Create your [`Timetable`]

Using your [`TimetableController`], you can now create a [`Timetable`] widget:

```dart
Timetable<BasicEvent>(
  controller: myController,
  eventBuilder: (event) => BasicEventWidget(event),
  allDayEventBuilder: (context, event, info) =>
      BasicAllDayEventWidget(event, info: info),
)
```

And you're done 🎉


## Theming

For a full list of visual properties that can be tweaked, see [`TimetableThemeData`].

To apply a theme, specify it in the [`Timetable`] constructor:

```dart
Timetable<BasicEvent>(
  controller: /* ... */,
  theme: TimetableThemeData(
    primaryColor: Colors.teal,
    partDayEventMinimumDuration: Period(minutes: 30),
    // ...and many more!
  ),
),
```


## Localization

[<kbd>time_machine</kbd>] is used internally for date & time formatting. By default, it uses `en_US` as its locale (managed by the [`Culture`] class) and doesn't know about Flutter's locale. To change the locale, set [`Culture.current`] after the call to [`TimeMachine.initialize`]:

```dart
// Supported cultures: https://github.com/Dana-Ferguson/time_machine/tree/master/lib/data/cultures
Culture.current = await Cultures.getCulture('de');
```

To automatically react to locale changes of the app, see [Dana-Ferguson/time_machine#28].

> **Note:** A better solution for Localization is already planned.


## Features & Coming soon

- [x] Smartly arrange overlapping events
- [x] Zooming
- [x] Selectable [`VisibleRange`]s
- [x] Display all-day events at the top
- [x] Theming
- [ ] Animate between different [`VisibleRange`]s: see [#17]
- [ ] Month-view, Agenda-view: see [#17]
- [x] Listener when tapping the background (e.g. for creating an event)
- [ ] Support for event resizing



[example/main.dart]: https://github.com/JonasWanke/timetable/blob/master/example/lib/main.dart
<!-- Flutter -->
[`TabController`]: https://api.flutter.dev/flutter/material/TabController-class.html
[`ScrollController`]: https://api.flutter.dev/flutter/widgets/ScrollController-class.html
[`State.dispose`]: https://api.flutter.dev/flutter/widgets/State/dispose.html
[`Widget`]: https://api.flutter.dev/flutter/widgets/Widget-class.html
<!-- timetable -->
[`BasicEvent`]: https://pub.dev/documentation/timetable/latest/timetable/BasicEvent-class.html
[`BasicEventWidget`]: https://pub.dev/documentation/timetable/latest/timetable/BasicEventWidget-class.html
[`Event`]: https://pub.dev/documentation/timetable/latest/timetable/Event-class.html
[`EventBuilder`]: https://pub.dev/documentation/timetable/latest/timetable/EventBuilder-class.html
[`EventProvider`]: https://pub.dev/documentation/timetable/latest/timetable/EventProvider-class.html
[`EventProvider.list`]: https://pub.dev/documentation/timetable/latest/timetable/EventProvider/EventProvider.list.html
[`EventProvider.simpleStream`]: https://pub.dev/documentation/timetable/latest/timetable/EventProvider/EventProvider.simpleStream.html
[`EventProvider.stream`]: https://pub.dev/documentation/timetable/latest/timetable/EventProvider/EventProvider.stream.html
[`Timetable`]: https://pub.dev/documentation/timetable/latest/timetable/Timetable-class.html
[`TimetableController`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableController-class.html
[`TimetableController.dispose`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableController/dispose.html
[`TimetableThemeData`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableThemeData-class.html
[`VisibleRange`]: https://pub.dev/documentation/timetable/latest/timetable/VisibleRange-class.html
[#17]: https://github.com/JonasWanke/timetable/issues/17
<!-- time_machine -->
[<kbd>time_machine</kbd>]: https://pub.dev/packages/time_machine
[`Culture`]: https://pub.dev/documentation/time_machine/latest/time_machine/Culture-class.html
[`Culture.current`]: https://pub.dev/documentation/time_machine/latest/time_machine/Culture/current.html
[`TimeMachine.initialize`]: https://pub.dev/documentation/time_machine/latest/time_machine/TimeMachine/initialize.html
[Dana-Ferguson/time_machine#28]: https://github.com/Dana-Ferguson/time_machine/issues/28
