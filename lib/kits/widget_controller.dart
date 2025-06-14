import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Callback when Rokt layout size gets changed
typedef RoktLayoutSizeChangeCallback = void Function(double size);

/// Callback when Rokt layout padding gets changed
typedef RoktLayoutPaddingChangeCallback = void Function(
    BoundingBox boundingBox);

/// Layout Controller to handle callbacks and Method channels of view
class LayoutController {
  /// Id of the Rokt layout view
  final int id;
  final MethodChannel _channel;

  /// callback for the RoktLayout size change
  final RoktLayoutSizeChangeCallback sizeChangeCallback;

  /// callback for the RoktLayout padding change
  final RoktLayoutPaddingChangeCallback paddingChangeCallback;

  /// Initialize LayoutController with a specific method channel
  LayoutController(
      {required this.id,
      required this.sizeChangeCallback,
      required this.paddingChangeCallback})
      : _channel = MethodChannel('rokt_layout_$id') {
    _channel.setMethodCallHandler(_methodCallHandler);
  }

  /// Dispose the controller
  void dispose() {
    _channel.setMethodCallHandler(null);
  }

  Future<void> _methodCallHandler(MethodCall call) async {
    switch (call.method) {
      case 'viewHeightListener':
        sizeChangeCallback.call(call.arguments['size']);
        break;
      case 'viewPaddingListener':
        paddingChangeCallback.call(BoundingBox(
            left: call.arguments['left'],
            top: call.arguments['top'],
            right: call.arguments['right'],
            bottom: call.arguments['bottom']));
        break;
      default:
        if (kDebugMode) {
          print('No method matching !!');
        }
    }
  }
}

/// Padding box
class BoundingBox {
  /// left padding
  final double left;

  /// top padding
  final double top;

  /// right padding
  final double right;

  /// bottom padding
  final double bottom;

  /// Initialize Bound box with LTRB padding
  const BoundingBox(
      {required this.left,
      required this.top,
      required this.right,
      required this.bottom});
}
