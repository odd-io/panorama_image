import 'package:flutter/material.dart';
import 'panorama_gesture_controller.dart';
import 'view_change_details.dart';
import 'panorama_controller.dart';
import 'panorama_painter.dart';

/// Possible error states that can occur when loading or displaying a panorama.
enum PanoramaError {
  /// The provided image is not in a valid equirectangular format
  invalidImage,

  /// The image failed to load
  loadError,

  /// Insufficient memory to process the image
  memoryError,
}

/// A widget that displays and allows interaction with 360° panoramic images.
///
/// This widget takes an equirectangular panoramic image and renders it with
/// proper spherical projection, allowing users to pan and zoom to explore
/// the entire 360° view.
///
/// Example usage:
/// ```dart
/// PanoramaViewer(
///   image: AssetImage('assets/panorama.jpg'),
///   initialFOV: 90.0,
///   onViewChanged: (details) {
///     print('View changed to: ${details.longitude}, ${details.latitude}, ${details.fov}');
///   },
/// )
/// ```
class PanoramaViewer extends StatefulWidget {
  const PanoramaViewer({
    super.key,
    required this.image,
    this.initialFOV = 90.0,
    this.maxFOV = 140.0,
    this.minFOV = 30.0,
    this.onViewChanged,
    this.onError,
    this.controller,
    this.gestureController,
  });

  /// Notifies when the view parameters (longitude, latitude, or FOV) change.
  final void Function(ViewChangeDetails)? onViewChanged;

  /// Callback for handling various error conditions during panorama loading/display.
  final void Function(PanoramaError)? onError;

  /// Optional controller for programmatically controlling the panorama view.
  final PanoramaController? controller;

  /// Optional custom gesture controller for custom interaction handling
  final PanoramaGestureController? gestureController;

  /// The equirectangular panoramic image to display.
  final ImageProvider image;

  /// The initial field of view in degrees. Defaults to 90.0.
  final double initialFOV;

  /// The maximum allowed field of view in degrees. Defaults to 140.0.
  final double maxFOV;

  /// The minimum allowed field of view in degrees. Defaults to 30.0.
  final double minFOV;

  @override
  State<PanoramaViewer> createState() => _PanoramaViewerState();
}

class _PanoramaViewerState extends State<PanoramaViewer> {
  late final PanoramaController _controller;
  late final PanoramaGestureController _gestureController;
  ImageInfo? _imageInfo;
  // ignore: unused_field
  late ImageStream _imageStream;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        PanoramaController(
          initialFOV: widget.initialFOV,
          maxFOV: widget.maxFOV,
          minFOV: widget.minFOV,
        );
    _gestureController = widget.gestureController ??
        DefaultPanoramaGestureController(
          controller: _controller,
          onViewChanged: widget.onViewChanged,
        );
    _loadImage();
  }

  void _loadImage() {
    final ImageStream newStream =
        widget.image.resolve(ImageConfiguration.empty);
    _imageStream = newStream;
    final ImageStreamListener listener = ImageStreamListener(
      _handleImageLoaded,
      onError: _handleImageError,
    );
    newStream.addListener(listener);
  }

  void _handleImageLoaded(ImageInfo imageInfo, bool synchronousCall) {
    setState(() {
      _imageInfo = imageInfo;
    });
  }

  void _handleImageError(Object exception, StackTrace? stackTrace) {
    widget.onError?.call(PanoramaError.loadError);
  }

  @override
  Widget build(BuildContext context) {
    if (_imageInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Listener(
      onPointerSignal: _gestureController.handlePointerSignal,
      child: GestureDetector(
        onScaleStart: _gestureController.handleScaleStart,
        onScaleUpdate: _gestureController.handleScaleUpdate,
        onScaleEnd: _gestureController.handleScaleEnd,
        child: CustomPaint(
          painter: PanoramaPainter(
            image: _imageInfo!.image,
            controller: _controller,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}
