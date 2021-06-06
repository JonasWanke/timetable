📅 Customizable, animated calendar widget including day, week, and month views.

TODO: update the graphics  
TODO: deploy to GitHub pages

|                                  Event positioning demo (outdated)                                   |                                                              Dark mode & custom range (outdated)                                                               |
| :--------------------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------------------------------------------------------------------------------: |
| ![Screenshot of Timetable](https://github.com/JonasWanke/timetable/raw/master/doc/demo.gif?raw=true) | ![Screenshot of Timetable in dark mode with only three visible days](https://github.com/JonasWanke/timetable/raw/master/doc/screenshot-3day-dark.jpg?raw=true) |

* [Available Layouts](#available-layouts)
* [Getting started](#getting-started)
  * [0. General Information](#0-general-information)
  * [1. Define your `Event`s](#1-define-your-events)
  * [2. Create a `DateController` (optional)](#2-create-a-datecontroller-optional)
  * [3. Create a `TimeController` (optional)](#3-create-a-timecontroller-optional)
  * [4. Create your Timetable](#4-create-your-timetable)
* [Theming](#theming)
* [Advanced Features](#advanced-features)
  * [Drag and Drop](#drag-and-drop)
  * [Time Overlays](#time-overlays)

## Available Layouts

| MultiDateTimetable | RecurringMultiDateTimetable | CompactMonthTimetable |
| :----------------: | :-------------------------: | :-------------------: |
|        TODO        |            TODO             |         TODO          |

## Getting started

### 0. General Information

Timetable doesn't care about any time-zone related stuff.
All supplied `DateTime`s must have `isUtc` set to `true`, but the actual time zone is then ignored when displaying events.

Some date/time-related parameters also have special suffixes:

* `date`: A `DateTime` with a time of zero.
* `month`: A `DateTime` with a time of zero and a day of one.
* `timeOfDay`: A `Duration` between zero and 24 hours.
* `dayOfWeek`: An `int` between one and seven ([`DateTime.monday`](https://api.flutter.dev/flutter/dart-core/DateTime/monday-constant.html) through [`DateTime.sunday`](https://api.flutter.dev/flutter/dart-core/DateTime/sunday-constant.html)).

Timetable currently offers localizations for English and German.
Even if you're just supporting English in your app, you have to add Timetable's localization delegate to your `MaterialApp`/`CupertinoApp`/`WidgetsApp`:

```dart
MaterialApp(
  localizationsDelegates: [
    TimetableLocalizationsDelegate(),
    // Other delegates, e.g., `GlobalMaterialLocalizations.delegate`
  ],
  // ...
);
```

### 1. Define your [`Event`]s

Events are provided as instances of [`Event`].
To get you started, there's the subclass [`BasicEvent`], which you can instantiate directly.
If you want to be more specific, you can also implement your own class extending [`Event`].

> **Note:** Most of Timetable's classes accept a type-parameter `E extends Event`.
> Please set it to your chosen [`Event`]-subclass (e.g. [`BasicEvent`]) to avoid runtime exceptions.

In addition, you also need a `Widget` to display your events.
When using [`BasicEvent`], this can simply be [`BasicEventWidget`].

### 2. Create a [`DateController`] (optional)

Similar to a [`ScrollController`] or a [`TabController`], a [`DateController`] is responsible for interacting with Timetable's widgets and managing their state.
As the name suggests, you can use a [`DateController`] to access the currently visible dates, and also animate or jump to different days.
And by supplying a [`VisibleDateRange`], you can also customize how many days are visible at once and whether they, e.g., snap to weeks.

```dart
final myDateController = DateController(
  // All parameters are optional and displayed wit their default value.
  initialDate: DateTimeTimetable.today(),
  visibleRange: VisibleDateRange.week(startOfWeek: DateTime.monday),
);
```

> Don't forget to [`dispose`][`DateController.dispose`] your controller, e.g., in [`State.dispose`]!

Here are some of the available [`VisibleDateRange`]s:

* [`VisibleDateRange.days`]: displays `visibleDayCount` consecutive days, snapping to every `swipeRange` days (aligned to `alignmentDate`) in the range from `minDate` to `maxDate`
* [`VisibleDateRange.week`]: displays and snaps to whole weeks with a customizable `startOfWeek` in the range from `minDate` to `maxDate`
* [`VisibleDateRange.weekAligned`]: displays `visibleDayCount` consecutive days while snapping to whole weeks with a customizable `firstDay` in the range from `minDate` to `maxDate` – can be used, e.g., to display a five-day workweek

### 3. Create a [`TimeController`] (optional)

Similar to the [`DateController`] above, a [`TimeController`] is also responsible for interacting with Timetable's widgets and managing their state.
More specifically, it controls the visible time range and zoom factor in a [`MultiDateTimetable`] or [`RecurringMultiDateTimetable`].
You can also programmatically change those and, e.g., animate out to reveal the full day.

```dart
final myTimeController = TimeController(
  // All parameters are optional. By default, the whole day is revealed
  // initially and you can zoom in to view just a single minute.
  minDuration: 15.minutes,
  initialRange: TimeRange(9.hours, 17.hours),
  maxRange: TimeRange(0.hours, 24.hours),
);
```

> This example uses some of [<kbd>supercharged</kbd>]'s extension methods on `int` to create a [`Duration`] more concisely.

> Don't forget to [`dispose`][`TimeController.dispose`] your controller, e.g., in [`State.dispose`]!

### 4. Create your timetable widget

The configuration for Timetable's widgets is provided via inherited widgets.
You can use a [`TimetableConfig<E>`] to provide all at once:

```dart
TimetableConfig<BasicEvent>(
  // Required:
  dateController: _dateController,
  timeController: _timeController,
  eventBuilder: (context, event) => BasicEventWidget(event),
  child: MultiDateTimetable<BasicEvent>(),
  // Optional:
  eventProvider: (date) => someListOfEvents,
  allDayEventBuilder: (context, event, info) =>
      BasicAllDayEventWidget(event, info: info),
  callbacks: TimetableCallbacks(
    // onWeekTap, onDateTap, onDateBackgroundTap, onDateTimeBackgroundTap
  ),
  theme: TimetableThemeData(
    context,
    // startOfWeek: DateTime.monday,
    // See the "Theming" section below for more options.
  ),
);
```

And you're done 🎉

## Theming

Timetable already supports light and dark themes out of the box, adapting to the ambient `ThemeData`.
You can, however, customize the styles of almost all components by providing a custom [`TimetableThemeData`].

To apply your own theme, specify it in the [`TimetableConfig<E>`] (or directly in a [`TimetableTheme`]):

```dart
TimetableConfig<BasicEvent>(
  theme: TimetableThemeData(
    context,
    startOfWeek: DateTime.monday,
    dateDividersStyle: DateDividersStyle(
      context,
      color: Colors.blue.withOpacity(.3),
      width: 2,
    ),
    dateHeaderStyleProvider: (date) =>
        DateHeaderStyle(context, date, tooltip: 'My custom tooltip'),
    nowIndicatorStyle: NowIndicatorStyle(
      context,
      lineColor: Colors.green,
      shape: TriangleNowIndicatorShape(color: Colors.green),
    ),
    // See the "Theming" section below for more.
  ),
  // Other properties...
);
Timetable<BasicEvent>(
  controller: /* ... */,
  theme: TimetableThemeData(
    primaryColor: Colors.teal,
    partDayEventMinimumDuration: Period(minutes: 30),
    // ...and many more!
  ),
),
```

> [`TimetableThemeData`] and all component styles provide two constructors each:
>
> * The default constructor takes a `BuildContext` and sometimes a day or month, using information from the ambient theme and locale to generate default values.
>   You can still override all options via optional, named parameters.
> * The named `raw` constructor is usually `const` and has required parameters for all options.

## Advanced Features

### Drag and Drop

You can easily make events inside the content area of [`MultiDateTimetable`] or [`RecurringMultiDateTimetable`] draggable by wrapping them in a [`PartDayDraggableEvent`]:

```dart
PartDayDraggableEvent(
  // The user started dragging this event.
  onDragStart: () {},
  // The event was dragged to the given [DateTime].
  onDragUpdate: (dateTime) {},
  // The user finished dragging the event and landed on the given [DateTime].
  onDragEnd: (dateTime) {},
  child: MyEventWidget(),
  // By default, the child is displayed with a reduced opacity when it's
  // dragged. But, of course, you can customize this:
  childWhileDragging: OptionalChildWhileDragging(),
);
```

Timetable doesn't automatically show a moving feedback widget at the current pointer position.
Instead, you can customize this and, e.g., snap to multiples of 15 minutes.
Have a look at the included example where we implemented exactly that by displaying the drag feedback as a time overlay.

### Time Overlays

TODO: `TimetableConfig.timeOverlayProvider` (similar to `eventProvider`)

[example/main.dart]: https://github.com/JonasWanke/timetable/blob/master/example/lib/main.dart
<!-- Flutter -->
[`Duration]: https://api.flutter.dev/flutter/dart-core/Duration-class.html
[`ScrollController`]: https://api.flutter.dev/flutter/widgets/ScrollController-class.html
[`State.dispose`]: https://api.flutter.dev/flutter/widgets/State/dispose.html
[`TabController`]: https://api.flutter.dev/flutter/material/TabController-class.html
<!-- timetable -->
[`BasicEvent`]: https://pub.dev/documentation/timetable/latest/timetable/BasicEvent-class.html
[`BasicEventWidget`]: https://pub.dev/documentation/timetable/latest/timetable/BasicEventWidget-class.html
[`CompactMonthTimetable`]: https://pub.dev/documentation/timetable/latest/timetable/CompactMonthTimetable-class.html
[`DateController`]: https://pub.dev/documentation/timetable/latest/timetable/DateController-class.html
[`DateController.dispose`]: https://pub.dev/documentation/timetable/latest/timetable/DateController/dispose.html
[`Event`]: https://pub.dev/documentation/timetable/latest/timetable/Event-class.html
[`MultiDateTimetable`]: https://pub.dev/documentation/timetable/latest/timetable/MultiDateTimetable-class.html
[`PartDayDraggableEvent`]: https://pub.dev/documentation/timetable/latest/timetable/PartDayDraggableEvent-class.html
[`RecurringMultiDateTimetable`]: https://pub.dev/documentation/timetable/latest/timetable/RecurringMultiDateTimetable-class.html
[`TimeController`]: https://pub.dev/documentation/timetable/latest/timetable/TimeController-class.html
[`TimeController.dispose`]: https://pub.dev/documentation/timetable/latest/timetable/TimeController/dispose.html
[`TimetableConfig<E>`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableConfig-class.html
[`TimetableTheme`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableTheme-class.html
[`TimetableThemeData`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableThemeData-class.html
[`VisibleDateRange.days`]: https://pub.dev/documentation/timetable/latest/timetable/VisibleDateRange/days.html
[`VisibleDateRange.week`]: https://pub.dev/documentation/timetable/latest/timetable/VisibleDateRange/week.html
[`VisibleDateRange.weekAligned`]: https://pub.dev/documentation/timetable/latest/timetable/VisibleDateRange/foo.html
<!-- supercharged -->
[<kbd>supercharged</kbd>]: https://pub.dev/packages/supercharged
