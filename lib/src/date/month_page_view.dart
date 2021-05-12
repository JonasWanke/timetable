import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

class MonthPageView extends StatefulWidget {
  const MonthPageView({
    this.monthPageController,
    this.shrinkWrapInCrossAxis = false,
    required this.builder,
  });

  final MonthPageController? monthPageController;
  final bool shrinkWrapInCrossAxis;
  final MonthWidgetBuilder builder;

  @override
  _MonthPageViewState createState() => _MonthPageViewState();
}

class _MonthPageViewState extends State<MonthPageView> {
  late final MonthPageController _controller;
  final _heights = <int, double>{};

  @override
  void initState() {
    super.initState();
    _controller = widget.monthPageController ??
        MonthPageController(initialMonth: DateTimeTimetable.currentMonth());
    _controller.addListener(_onMonthChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onMonthChanged);
    if (widget.monthPageController == null) _controller.dispose();
    super.dispose();
  }

  void _onMonthChanged() {
    final page = _controller._pageController.page!.round();
    _heights.removeWhere((key, _) => (key - page).abs() > 5);
  }

  @override
  Widget build(BuildContext context) {
    Widget child = PageView.builder(
      controller: _controller._pageController,
      itemBuilder: (context, page) {
        final month = MonthPageController._monthFromPage(page);

        var child = widget.builder(context, month);
        if (widget.shrinkWrapInCrossAxis) {
          child = SizeReportingOverflowPage(
            onSizeChanged: (size) =>
                setState(() => _heights[page] = size.height),
            child: child,
          );
        }
        return child;
      },
    );

    if (widget.shrinkWrapInCrossAxis) {
      child = AnimatedBuilder(
        animation: _controller._pageController,
        builder: (context, child) =>
            SizedBox(height: _getHeight(), child: child),
        child: child,
      );
    }
    return child;
  }

  double _getHeight() {
    final pageController = _controller._pageController;
    if (!pageController.hasClients) return 0;

    final page = pageController.page!;
    final oldMaxHeight = _heights[page.floor()];
    final newMaxHeight = _heights[page.ceil()];

    // When swiping, the next page might not have been measured yet.
    if (oldMaxHeight == null) return newMaxHeight!;
    if (newMaxHeight == null) return oldMaxHeight;

    return lerpDouble(oldMaxHeight, newMaxHeight, page - page.floorToDouble())!;
  }
}

class MonthPageController extends ChangeNotifier
    implements ValueListenable<DateTime> {
  MonthPageController({required DateTime initialMonth})
      : assert(initialMonth.isValidTimetableMonth),
        _pageController =
            PageController(initialPage: _pageFromMonth(initialMonth)) {
    _pageController.addListener(notifyListeners);
  }

  final PageController _pageController;

  @override
  DateTime get value => _monthFromPage(_pageController.page!.round());

  late DateTime _previousValue = value;
  @override
  void notifyListeners() {
    final newValue = value;
    if (newValue == _previousValue) return;
    _previousValue = newValue;
    super.notifyListeners();
  }

  @override
  void dispose() {
    _pageController.removeListener(notifyListeners);
    super.dispose();
  }

  // "DateTimes can represent time values that are at a distance of at most
  // 100,000,000 days from epoch […]", which would be -271821-04-20.
  static final _minMonth = DateTime.utc(-271821, 6, 1);
  static final _minPage =
      (_minMonth.year * DateTime.monthsPerYear) + (_minMonth.month - 1);
  static DateTime _monthFromPage(int page) {
    page = _minPage + page;
    final year = (page < 0 ? page - DateTime.monthsPerYear + 1 : page) ~/
        DateTime.monthsPerYear;
    final month = page % DateTime.monthsPerYear + 1;
    return DateTimeTimetable.month(year, month);
  }

  static int _pageFromMonth(DateTime month) {
    assert(month.isValidTimetableMonth);
    return (month.year * DateTime.monthsPerYear) + (month.month - 1) - _minPage;
  }

  // Animation
  Future<void> animateTo(
    DateTime month, {
    Curve curve = Curves.easeInOut,
    Duration duration = const Duration(milliseconds: 200),
  }) async {
    await _pageController.animateToPage(
      _pageFromMonth(month),
      duration: duration,
      curve: curve,
    );
  }

  void jumpTo(DateTime month) =>
      _pageController.jumpToPage(_pageFromMonth(month));
}
