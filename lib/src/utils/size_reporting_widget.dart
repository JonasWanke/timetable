import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

// Copied and modified from https://github.com/Limbou/expandable_page_view/blob/d692cff38f9e098ad5c020d80123a13ab2a53083/lib/size_reporting_widget.dart
class SizeReportingWidget extends StatefulWidget {
  const SizeReportingWidget({
    super.key,
    required this.onSizeChanged,
    required this.child,
  });

  final ValueChanged<Size> onSizeChanged;
  final Widget child;

  @override
  State<SizeReportingWidget> createState() => _SizeReportingWidgetState();
}

class _SizeReportingWidgetState extends State<SizeReportingWidget> {
  final _widgetKey = GlobalKey();
  Size? _oldSize;

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
    return NotificationListener(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _notifySize());
        return true;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(key: _widgetKey, child: widget.child),
      ),
    );
  }

  void _notifySize() {
    final context = _widgetKey.currentContext;
    if (context == null) return;

    final size = context.size!;
    if (_oldSize != size) {
      _oldSize = size;
      widget.onSizeChanged(size);
    }
  }
}

// In order for [DatePageView] and [MonthPageView] to shrink in their cross
// axis, they first have to layout the children in their viewport, and then size
// themselves accordingly. When just observing the size, calling `setState` and
// then returning a [SizedBox], all of this is one frame delayed.
//
// To apply the size during the same layout pass, the "immediate" widgets below
// report their size during layout ([ImmediateSizeReportingWidget] and
// [ImmediateSizeReportingOverflowPage]) or request their height during layout
// ([ImmediateSizedBox]).

// Copied and modified from: https://github.com/Limbou/expandable_page_view/blob/d692cff38f9e098ad5c020d80123a13ab2a53083/lib/expandable_page_view.dart
class ImmediateSizeReportingOverflowPage extends StatelessWidget {
  const ImmediateSizeReportingOverflowPage({
    super.key,
    required this.onSizeChanged,
    required this.child,
  });

  /// Called during layout!
  final ValueChanged<Size> onSizeChanged;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return OverflowBox(
      minHeight: 0,
      maxHeight: double.infinity,
      alignment: Alignment.topCenter,
      child: ImmediateSizeReportingWidget(
        onSizeChanged: onSizeChanged,
        child: child,
      ),
    );
  }
}

class ImmediateSizeReportingWidget extends SingleChildRenderObjectWidget {
  const ImmediateSizeReportingWidget({
    super.key,
    required this.onSizeChanged,
    required super.child,
  });

  /// Called during layout!
  final ValueChanged<Size> onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ImmediateSizeReportingRenderObject(onSizeChanged);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    renderObject as _ImmediateSizeReportingRenderObject;
    renderObject.onSizeChanged = onSizeChanged;
  }
}

class _ImmediateSizeReportingRenderObject extends RenderProxyBox {
  _ImmediateSizeReportingRenderObject(this._onSizeChanged);

  ValueChanged<Size> get onSizeChanged => _onSizeChanged;
  ValueChanged<Size> _onSizeChanged;
  set onSizeChanged(ValueChanged<Size> value) {
    if (_onSizeChanged == value) return;
    _onSizeChanged = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final oldSize = hasSize ? size : null;
    super.performLayout();
    if (size != oldSize) onSizeChanged(size);
  }
}

/// A widget that requests its height during layout via [heightGetter].
class ImmediateSizedBox extends SingleChildRenderObjectWidget {
  const ImmediateSizedBox({
    super.key,
    required this.heightGetter,
    required super.child,
  });

  final ValueGetter<double> heightGetter;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ImmediateSizedBoxRenderObject(heightGetter);
  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderObject renderObject,
  ) {
    renderObject as _ImmediateSizedBoxRenderObject;
    renderObject.heightGetter = heightGetter;
  }
}

class _ImmediateSizedBoxRenderObject extends RenderProxyBox {
  _ImmediateSizedBoxRenderObject(this._heightGetter);

  ValueGetter<double> get heightGetter => _heightGetter;
  ValueGetter<double> _heightGetter;
  set heightGetter(ValueGetter<double> value) {
    if (_heightGetter == value) return;
    _heightGetter = value;
    markNeedsLayout();
  }

  @override
  void performLayout() {
    final oldHeight = hasSize ? size.height : null;
    child!.layout(
      constraints.tighten(height: heightGetter()),
      parentUsesSize: true,
    );
    if (heightGetter() != oldHeight) {
      child!.layout(
        constraints.tighten(height: heightGetter()),
        parentUsesSize: true,
      );
    }
    size = Size(child!.size.width, heightGetter());
  }
}
