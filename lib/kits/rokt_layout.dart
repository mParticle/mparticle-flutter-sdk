part of '../mparticle_flutter_sdk.dart';

/// Callback when Rokt platform view gets created and returns platform view id
typedef RoktPlatformViewCreatedCallback = void Function(int widgetId);

/// Callback when Rokt layout is created
typedef LayoutCreatedCallback = void Function();

/// Rokt embedded layout custom view
class RoktLayout extends StatefulWidget {
  /// name for the Rokt layout
  final String placeholderName;

  /// callback when layout is created
  final LayoutCreatedCallback onLayoutCreated;

  /// Initializes [key] for subclasses, [placeholderName] is the location name
  const RoktLayout(
      {Key? key,
      required this.placeholderName,
      this.onLayoutCreated = _defaultLayoutCreatedCallback})
      : super(key: key);

  static void _defaultLayoutCreatedCallback() {}

  @override
  State<StatefulWidget> createState() => _RoktContainerState();
}

class _RoktContainerState extends State<RoktLayout>
    with AutomaticKeepAliveClientMixin<RoktLayout> {
  double _height = 0;
  double _left = 0;
  double _top = 0;
  double _right = 0;
  double _bottom = 0;
  LayoutController? _layoutController;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    _height = 1;
    _left = 0;
    _top = 0;
    _right = 0;
    _bottom = 0;
    print('RoktLayout initState');
    super.initState();
  }

  @override
  void dispose() {
    _layoutController = null;
    super.dispose();
  }

  void _changeHeight(double newHeight) {
    setState(() {
      _height = newHeight;
    });
  }

  void _changePadding(BoundingBox box) {
    setState(() {
      _left = box.left;
      _top = box.top;
      _right = box.right;
      _bottom = box.bottom;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    print('RoktLayout build');
    return AnimatedOpacity(
        opacity: (_height > 1) ? 1.0 : 0.1,
        duration: Duration(milliseconds: 200),
        child: Padding(
          padding: EdgeInsets.fromLTRB(_left, _top, _right, _bottom),
          child: SizedBox(
              height: _height,
              child: _RoktStatelessWidget(
                  platformViewCreatedCallback: _onPlatformViewCreated)),
        ));
  }

  void _onPlatformViewCreated(int id) {
    print('RoktLayout _onPlatformViewCreated');
    MparticleFlutterSdk.getInstance().then((value) => value?.attachPlaceholder(id: id, name: widget.placeholderName));

    _layoutController = LayoutController(
        id: id,
        sizeChangeCallback: _changeHeight,
        paddingChangeCallback: _changePadding);
    widget.onLayoutCreated();
  }
}

class _RoktStatelessWidget extends StatelessWidget {
  final RoktPlatformViewCreatedCallback platformViewCreatedCallback;

  const _RoktStatelessWidget(
      {Key? key, required this.platformViewCreatedCallback})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pass parameters to the platform side.
    final Map<String, dynamic> creationParams = <String, dynamic>{};
    const String viewType = 'rokt_sdk.rokt.com/rokt_layout';

    if (defaultTargetPlatform == TargetPlatform.android) {
      return PlatformViewLink(
        viewType: viewType,
        surfaceFactory: (
          BuildContext context,
          PlatformViewController controller,
        ) {
          return AndroidViewSurface(
            controller: controller as AndroidViewController,
            gestureRecognizers: const <Factory<OneSequenceGestureRecognizer>>{},
            hitTestBehavior: PlatformViewHitTestBehavior.opaque,
          );
        },
        onCreatePlatformView: (PlatformViewCreationParams params) {
          final SurfaceAndroidViewController controller =
              PlatformViewsService.initSurfaceAndroidView(
            id: params.id,
            viewType: viewType,
            layoutDirection: TextDirection.ltr,
            creationParams: creationParams,
            creationParamsCodec: const StandardMessageCodec(),
            onFocus: () => params.onFocusChanged(true),
          )
                ..addOnPlatformViewCreatedListener(
                  params.onPlatformViewCreated,
                )
                ..addOnPlatformViewCreatedListener(
                  platformViewCreatedCallback,
                )
                ..create();
          return controller;
        },
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        onPlatformViewCreated: platformViewCreatedCallback,
        layoutDirection: TextDirection.ltr,
        creationParams: creationParams,
        creationParamsCodec: const StandardMessageCodec(),
      );
    }
    return Text(
        '$defaultTargetPlatform is not yet supported by the rokt sdk plugin');
  }
}
