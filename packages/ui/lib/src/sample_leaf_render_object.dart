import 'dart:math' as math;
import 'dart:ui' as ui hide Size;
import 'package:flutter/rendering.dart' show BoxHitTestResult, RenderBox;
import 'package:flutter/widgets.dart';

/// (@template apple_logo)
/// AppleLogo widget.
/// (@endtemplate}
class SampleLeafRenderObject extends LeafRenderObjectWidget
    implements PreferredSizeWidget {
  /// {@macro apple_logo}
  const SampleLeafRenderObject({
    this.size = 48,
    super.key,
  });

  /// The size of the logo.

  final double size;

  @override
  Size get preferredSize => Size.square(size);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _SampleLeafRenderObject().._targetSize = Size.square(size);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBox renderObject) {
    if (renderObject is _SampleLeafRenderObject) {
      renderObject._targetSize = Size.square(size);
    }
  }
}

class _SampleLeafRenderObject extends RenderBox {
  _SampleLeafRenderObject();
  Size _targetSize = Size.zero;

  double _scale = 0;

  @override
  bool get isRepaintBoundary => false;

  @override
  bool get alwaysNeedsCompositing => false;

  @override
  bool get sizedByParent => false;

  @override
  Size computeDryLayout(BoxConstraints constraints) =>
      constraints.constrain(_targetSize);

  @override
  void performLayout() {
    final size = super.size = computeDryLayout(constraints);
    _scale = math.min(size.width / 128, size.height / 128);
  }

  @override
  bool hitTestSelf(Offset position) => true;

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) =>
      false;

  @override
  void paint(PaintingContext context, Offset offset) {
    final scale = _scale;
    final canvas = context.canvas..save();
    if (scale < .01) {
      // No need to paint if the scale is too small.
      return;
    } else if (scale < 1.0) {
      // Move the logo to the center of the box.
      canvas.translate(
        offset.dx + (size.width - 128 * scale) / 2,
        offset.dy + (size.height - 128 * scale) / 2,
      );
    } else {
      // Move the logo to the top left corner of the box.
      canvas
        ..translate(offset.dx, offset.dy)
        // ..clipRect(Offset.zero & size)
        ..scale(scale, scale)
        ..drawPicture(_$logoPicture)
        ..restore();
    }
  }

  static final ui.Picture _$logoPicture = () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final path = Path()
      ///...
      ..close();

    final paintFill = Paint()..style = PaintingStyle.fill;

    canvas.drawPath(path, paintFill);

    return recorder.endRecording();
  }();
}
