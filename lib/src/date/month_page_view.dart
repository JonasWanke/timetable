import 'dart:core' as core;
import 'dart:core' hide Duration;
import 'dart:ui';

import 'package:chrono/chrono.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils.dart';

/// A page view for displaying months that supports shrink-wrapping in the cross
/// axis.
class MonthPageView extends StatefulWidget {
  const MonthPageView({
    super.key,
    this.monthPageController,
    this.shrinkWrapInCrossAxis = false,
    required this.builder,
  });

  final MonthPageController? monthPageController;
  final bool shrinkWrapInCrossAxis;
  final YearMonthWidgetBuilder builder;

  @override
  State<MonthPageView> createState() => _MonthPageViewState();
}

class _MonthPageViewState extends State<MonthPageView> {
  late final MonthPageController _controller;
  final _heights = <int, double>{};

  @override
  void initState() {
    super.initState();
    _controller = widget.monthPageController ??
        MonthPageController(initialMonth: YearMonth.currentInLocalZone());
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
          child = ImmediateSizeReportingOverflowPage(
            onSizeChanged: (size) {
              if (_heights[page] == size.height) return;
              _heights[page] = size.height;
              WidgetsBinding.instance
                  .addPostFrameCallback((_) => setState(() {}));
            },
            child: child,
          );
        }
        return child;
      },
    );

    if (widget.shrinkWrapInCrossAxis) {
      child = AnimatedBuilder(
        animation: _controller._pageController,
        builder: (context, child) => ImmediateSizedBox(
          // By using a lambda, the `heightGetter`'s identity changes with every
          // call, forcing the `ImmediateSizedBox` to run a new layout pass.
          // ignore: unnecessary_lambdas
          heightGetter: () => _getHeight(),
          child: child!,
        ),
        child: child,
      );
    }
    return child;
  }

  double _getHeight() {
    final pageController = _controller._pageController;
    if (!pageController.hasClients) return 0;

    final page = pageController.page;
    if (page == null) return 0;
    final oldMaxHeight = _heights[page.floor()];
    final newMaxHeight = _heights[page.ceil()];

    // When swiping, the next page might not have been measured yet. When
    // jumping to a page that hasn't been measured yet, we might not have any
    // heights for that or neighboring pages at all.
    if (oldMaxHeight == null || newMaxHeight == null) {
      return oldMaxHeight ?? newMaxHeight ?? _heights.values.min;
    }

    return lerpDouble(oldMaxHeight, newMaxHeight, page - page.floorToDouble())!;
  }
}

/// Controls a [MonthPageView].
class MonthPageController extends ChangeNotifier
    implements ValueListenable<YearMonth> {
  MonthPageController({required YearMonth initialMonth})
      : _pageController =
            PageController(initialPage: _pageFromMonth(initialMonth)) {
    _pageController.addListener(notifyListeners);
  }

  final PageController _pageController;

  @override
  YearMonth get value => _monthFromPage(_pageController.page!.round());

  late YearMonth _previousValue = value;
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

  // FIXME: if negative pages are supported: get rid of this
  static final _minYearMonth = const Year(-1000000).months.start;
  static final _minPage =
      (_minYearMonth.year.number * Months.perYear) + _minYearMonth.month.index;
  static YearMonth _monthFromPage(int page) {
    page += _minPage;
    final year =
        Year((page < 0 ? page - Months.perYear + 1 : page) ~/ Months.perYear);
    final month = Month.fromIndex(page % Months.perYear).unwrap();
    return YearMonth(year, month);
  }

  static int _pageFromMonth(YearMonth month) {
    return month.year.number * Months.perYear + month.month.index - _minPage;
  }

  // Animation
  Future<void> animateTo(
    YearMonth yearMonth, {
    Curve curve = Curves.easeInOut,
    core.Duration duration = const core.Duration(milliseconds: 200),
  }) async {
    await _pageController.animateToPage(
      _pageFromMonth(yearMonth),
      duration: duration,
      curve: curve,
    );
  }

  void jumpTo(YearMonth yearMonth) =>
      _pageController.jumpToPage(_pageFromMonth(yearMonth));
}
