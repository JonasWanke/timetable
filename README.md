📅 Customizable, animated calendar widget including day, week, and month views.

|                                       Navigation                                        |                                       Animation                                        |
| :-------------------------------------------------------------------------------------: | :------------------------------------------------------------------------------------: |
| ![](https://github.com/JonasWanke/timetable/raw/main/doc/demo-navigation.webp?raw=true) | ![](https://github.com/JonasWanke/timetable/raw/main/doc/demo-animation.webp?raw=true) |

|                                       Callbacks                                        |                               Changing the [`VisibleDateRange`]                               |
| :------------------------------------------------------------------------------------: | :-------------------------------------------------------------------------------------------: |
| ![](https://github.com/JonasWanke/timetable/raw/main/doc/demo-callbacks.webp?raw=true) | ![](https://github.com/JonasWanke/timetable/raw/main/doc/demo-visibleDateRange.webp?raw=true) |

- [Available Layouts](#available-layouts)
- [Getting started](#getting-started)
  - [0. General Information](#0-general-information)
  - [1. Define your `Event`s](#1-define-your-events)
  - [2. Create a `DateController` (optional)](#2-create-a-datecontroller-optional)
  - [3. Create a `TimeController` (optional)](#3-create-a-timecontroller-optional)
  - [4. Create your Timetable](#4-create-your-timetable)
- [Theming](#theming)
- [Advanced Features](#advanced-features)
  - [Drag and Drop](#drag-and-drop)
  - [Time Overlays](#time-overlays)

## Available Layouts

### [`MultiDateTimetable`]

A Timetable widget that displays multiple consecutive days.

|                                                 Light Mode                                                  |                                                 Dark Mode                                                  |
| :---------------------------------------------------------------------------------------------------------: | :--------------------------------------------------------------------------------------------------------: |
| ![](https://github.com/JonasWanke/timetable/raw/main/doc/screenshot-MultiDateTimetable-light.webp?raw=true) | ![](https://github.com/JonasWanke/timetable/raw/main/doc/screenshot-MultiDateTimetable-dark.webp?raw=true) |

### [`RecurringMultiDateTimetable`]

A Timetable widget that displays multiple consecutive days without their dates and without a week indicator.

|                                                      Light Mode                                                      |                                                      Dark Mode                                                      |
| :------------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------: |
| ![](https://github.com/JonasWanke/timetable/raw/main/doc/screenshot-RecurringMultiDateTimetable-light.webp?raw=true) | ![](https://github.com/JonasWanke/timetable/raw/main/doc/screenshot-RecurringMultiDateTimetable-dark.webp?raw=true) |

### [`CompactMonthTimetable`]

A Timetable widget that displays [`MonthWidget`]s in a page view.

|                                                   Light Mode                                                   |                                                   Dark Mode                                                   |
| :------------------------------------------------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------: |
| ![](https://github.com/JonasWanke/timetable/raw/main/doc/screenshot-CompactMonthTimetable-light.webp?raw=true) | ![](https://github.com/JonasWanke/timetable/raw/main/doc/screenshot-CompactMonthTimetable-dark.webp?raw=true) |


## Getting started

### 0. General Information

Timetable doesn't care about any time-zone related stuff.
All supplied `DateTime`s must have `isUtc` set to `true`, but the actual time zone is then ignored when displaying events.

Some date/time-related parameters also have special suffixes:

- `date`: A `DateTime` with a time of zero.
- `month`: A `DateTime` with a time of zero and a day of one.
- `timeOfDay`: A `Duration` between zero and 24 hours.
- `dayOfWeek`: An `int` between one and seven ([`DateTime.monday`](https://api.flutter.dev/flutter/dart-core/DateTime/monday-constant.html) through [`DateTime.sunday`](https://api.flutter.dev/flutter/dart-core/DateTime/sunday-constant.html)).

Timetable currently offers localizations for Chinese, English, French, German, Hungarian, Italian, Japanese, Portuguese, and Spanish.
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

> You want to contribute a new localization?
> Awesome!
> Please follow the steps listed in the doc comment of [`TimetableLocalizationsDelegate`].

### 1. Define your [`Event`]s

Events are provided as instances of [`Event`].
To get you started, there's the subclass [`BasicEvent`], which you can instantiate directly.
If you want to be more specific, you can also implement your own class extending [`Event`].

> ⚠️ Most of Timetable's classes accept a type-parameter `E extends Event`.
> Please set it to your chosen [`Event`]-subclass (e.g., [`BasicEvent`]) to avoid runtime exceptions.

In addition, you also need a `Widget` to display your events.
When using [`BasicEvent`], this can simply be [`BasicEventWidget`].

### 2. Create a [`DateController`] (optional)

Similar to a [`ScrollController`] or a [`TabController`], a [`DateController`] is responsible for interacting with Timetable's widgets and managing their state.
As the name suggests, you can use a [`DateController`] to access the currently visible dates, and also animate or jump to different days.
And by supplying a [`VisibleDateRange`], you can also customize how many days are visible at once and whether they, e.g., snap to weeks.

```dart
final myDateController = DateController(
  // All parameters are optional and displayed with their default value.
  initialDate: DateTimeTimetable.today(),
  visibleRange: VisibleDateRange.week(startOfWeek: DateTime.monday),
);
```

> Don't forget to [`dispose`][`DateController.dispose`] your controller, e.g., in [`State.dispose`]!

Here are some of the available [`VisibleDateRange`]s:

- [`VisibleDateRange.days`]: displays `visibleDayCount` consecutive days, snapping to every `swipeRange` days (aligned to `alignmentDate`) in the range from `minDate` to `maxDate`
- [`VisibleDateRange.week`]: displays and snaps to whole weeks with a customizable `startOfWeek` in the range from `minDate` to `maxDate`
- [`VisibleDateRange.weekAligned`]: displays `visibleDayCount` consecutive days while snapping to whole weeks with a customizable `firstDay` in the range from `minDate` to `maxDate` – can be used, e.g., to display a five-day workweek

### 3. Create a [`TimeController`] (optional)

Similar to the [`DateController`] above, a [`TimeController`] is also responsible for interacting with Timetable's widgets and managing their state.
More specifically, it controls the visible time range and zoom factor in a [`MultiDateTimetable`] or [`RecurringMultiDateTimetable`].
You can also programmatically change those and, e.g., animate out to reveal the full day.

```dart
final myTimeController = TimeController(
  // All parameters are optional. By default, the whole day is revealed
  // initially and you can zoom in to view just a single minute.
  minDuration: 15.minutes, // The closest you can zoom in.
  maxDuration: 23.hours, // The farthest you can zoom out.
  initialRange: TimeRange(9.hours, 17.hours),
  maxRange: TimeRange(0.hours, 24.hours),
);
```

> This example uses some of [<kbd>time</kbd>]'s extension methods on `int` to create a [`Duration`] more concisely.

> Don't forget to [`dispose`][`TimeController.dispose`] your controller, e.g., in [`State.dispose`]!

### 4. Create your Timetable widget

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
  allDayOverflowBuilder: (date, overflowedEvents) => /* … */,
  callbacks: TimetableCallbacks(
    // onWeekTap, onDateTap, onDateBackgroundTap, onDateTimeBackgroundTap, and
    // onMultiDateHeaderOverflowTap
  ),
  theme: TimetableThemeData(
    context,
    // startOfWeek: DateTime.monday,
    // See the "Theming" section below for more options.
  ),
)
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
)
```

> [`TimetableThemeData`] and all component styles provide two constructors each:
>
> - The default constructor takes a `BuildContext` and sometimes a day or month, using information from the ambient theme and locale to generate default values.
>   You can still override all options via optional, named parameters.
> - The named `raw` constructor is usually `const` and has required parameters for all options.

## Advanced Features

### Drag and Drop

<img src="https://github.com/JonasWanke/timetable/raw/main/doc/demo-dragAndDrop.webp?raw=true" width="400px" alt="Drag and Drop demo" />

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
)
```

Timetable doesn't automatically show a moving feedback widget at the current pointer position.
Instead, you can customize this and, e.g., snap event starts to multiples of 15 minutes.
Have a look at the included example app where we implemented exactly that by displaying the drag feedback as a time overlay.

If you have widgets outside of timetable that can be dragged into timetable, you have to give your [`MultiDateContent`] and each [`PartDayDraggableEvent`] a `geometryKey`.
A `geometryKey` is a [`GlobalKey`]`<`[`MultiDateContentGeometry`]`>` with which the current drag offset can be converted to a [`DateTime`].

```dart
final geometryKey = GlobalKey<MultiDateContentGeometry>();

final timetable = MultiDateTimetable(contentGeometryKey: geometryKey);
// Or `MultiDateContent(geometryKey: geometryKey)` if you build your timetable
// from the provided, modular widgets.

final draggableEvent = PartDayDraggableEvent.forGeometryKeys(
  {geometryKey},
  // `child`, `childWhileDragging`, and the callbacks are available here as
  // well.
);
```

You could even offer to drag the event into one of multiple timetables:
Give each timetable its own `geometryKey` and pass all of them to [`PartDayDraggableEvent.forGeometryKeys`].
In the callbacks, you receive the `geometryKey` of the timetable that the event is currently being dragged over.
See [`PartDayDraggableEvent.geometryKeys`] for the exact behavior.

### Time Overlays

<img src="https://github.com/JonasWanke/timetable/raw/main/doc/screenshot-timeOverlays.webp?raw=true" width="400px" alt="Drag and Drop demo" />

In addition to displaying events, [`MultiDateTimetable`] and [`RecurringMultiDateTimetable`] can display overlays for time ranges on every day.
In the screenshot above, a light gray overlay is displayed on weekdays before 8 a.m. and after 8 p.m., and over the full day for weekends.
Time overlays are provided similarly to events: Just add a timeOverlayProvider to your [`TimetableConfig<E>`] (or use a [`DefaultTimeOverlayProvider`] directly).

```dart
TimetableConfig<MyEvent>(
  timeOverlayProvider: (context, date) => <TimeOverlay>[
    TimeOverlay(
      start: 0.hours,
      end: 8.hours,
      widget: ColoredBox(color: Colors.black12),
      position: TimeOverlayPosition.behindEvents, // the default, alternatively `inFrontOfEvents`
    ),
    TimeOverlay(
      start: 20.hours,
      end: 24.hours,
      widget: ColoredBox(color: Colors.black12),
    ),
  ],
  // Other properties...
)
```

The provider is just a function that receives a date and returns a list of [`TimeOverlay`] for that date.
The example above therefore draws a light gray background before 8 a.m. and after 8 p.m. on every day.

[example/main.dart]: https://github.com/JonasWanke/timetable/blob/main/example/lib/main.dart
<!-- Flutter -->
[`DateTime`]: https://api.flutter.dev/flutter/dart-core/DateTime-class.html
[`Duration`]: https://api.flutter.dev/flutter/dart-core/Duration-class.html
[`GlobalKey`]: https://api.flutter.dev/flutter/widgets/GlobalKey-class.html
[`ScrollController`]: https://api.flutter.dev/flutter/widgets/ScrollController-class.html
[`State.dispose`]: https://api.flutter.dev/flutter/widgets/State/dispose.html
[`TabController`]: https://api.flutter.dev/flutter/material/TabController-class.html
<!-- timetable -->
[`BasicEvent`]: https://pub.dev/documentation/timetable/latest/timetable/BasicEvent-class.html
[`BasicEventWidget`]: https://pub.dev/documentation/timetable/latest/timetable/BasicEventWidget-class.html
[`CompactMonthTimetable`]: https://pub.dev/documentation/timetable/latest/timetable/CompactMonthTimetable-class.html
[`DateController`]: https://pub.dev/documentation/timetable/latest/timetable/DateController-class.html
[`DateController.dispose`]: https://pub.dev/documentation/timetable/latest/timetable/DateController/dispose.html
[`DefaultTimeOverlayProvider`]: https://pub.dev/documentation/timetable/latest/timetable/DefaultTimeOverlayProvider-class.html
[`Event`]: https://pub.dev/documentation/timetable/latest/timetable/Event-class.html
[`MonthWidget`]: https://pub.dev/documentation/timetable/latest/timetable/MonthWidget-class.html
[`MultiDateContent`]: https://pub.dev/documentation/timetable/latest/timetable/MultiDateContent-class.html
[`MultiDateContentGeometry`]: https://pub.dev/documentation/timetable/latest/timetable/MultiDateContentGeometry-class.html
[`MultiDateTimetable`]: https://pub.dev/documentation/timetable/latest/timetable/MultiDateTimetable-class.html
[`PartDayDraggableEvent`]: https://pub.dev/documentation/timetable/latest/timetable/PartDayDraggableEvent-class.html
[`PartDayDraggableEvent.forGeometryKeys`]: https://pub.dev/documentation/timetable/latest/timetable/PartDayDraggableEvent/PartDayDraggableEvent.forGeometryKeys.html
[`PartDayDraggableEvent.geometryKeys`]: https://pub.dev/documentation/timetable/latest/timetable/PartDayDraggableEvent/geometryKeys.html
[`RecurringMultiDateTimetable`]: https://pub.dev/documentation/timetable/latest/timetable/RecurringMultiDateTimetable-class.html
[`TimeController`]: https://pub.dev/documentation/timetable/latest/timetable/TimeController-class.html
[`TimeController.dispose`]: https://pub.dev/documentation/timetable/latest/timetable/TimeController/dispose.html
[`TimeOverlay`]: https://pub.dev/documentation/timetable/latest/timetable/TimeOverlay-class.html
[`TimetableConfig<E>`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableConfig-class.html
[`TimetableLocalizationsDelegate`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableLocalizationsDelegate-class.html
[`TimetableTheme`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableTheme-class.html
[`TimetableThemeData`]: https://pub.dev/documentation/timetable/latest/timetable/TimetableThemeData-class.html
[`VisibleDateRange`]: https://pub.dev/documentation/timetable/latest/timetable/VisibleDateRange-class.html
[`VisibleDateRange.days`]: https://pub.dev/documentation/timetable/latest/timetable/VisibleDateRange/days.html
[`VisibleDateRange.week`]: https://pub.dev/documentation/timetable/latest/timetable/VisibleDateRange/week.html
[`VisibleDateRange.weekAligned`]: https://pub.dev/documentation/timetable/latest/timetable/VisibleDateRange/foo.html
<!-- time -->
[<kbd>time</kbd>]: https://pub.dev/packages/time
