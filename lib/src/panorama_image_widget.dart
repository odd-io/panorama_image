import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  });

  /// Notifies when the view parameters (longitude, latitude, or FOV) change.
  final void Function(ViewChangeDetails)? onViewChanged;

  /// Callback for handling various error conditions during panorama loading/display.
  final void Function(PanoramaError)? onError;

  /// Optional controller for programmatically controlling the panorama view.
  final PanoramaController? controller;

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
  ImageInfo? _imageInfo;
  // ignore: unused_field
  late ImageStream _imageStream;
  Offset? _lastFocalPoint;

  @override
  void dispose() {
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ??
        PanoramaController(
          initialFOV: widget.initialFOV,
          maxFOV: widget.maxFOV,
          minFOV: widget.minFOV,
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

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      // Adjust zoom sensitivity for mouse wheel
      const double zoomSensitivity = 0.05;
      final double scaleFactor = event.scrollDelta.dy > 0
          ? (1 + zoomSensitivity)
          : (1 - zoomSensitivity);

      final double newFOV = _controller.fov * scaleFactor;
      _controller.updateView(fov: newFOV);
      widget.onViewChanged?.call(_controller.viewDetails);
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details) {
    // Handle panning
    if (_lastFocalPoint != null) {
      final double dx = details.focalPoint.dx - _lastFocalPoint!.dx;
      final double dy = details.focalPoint.dy - _lastFocalPoint!.dy;

      // Adjust sensitivity based on FOV - more zoomed in = slower pan
      final double sensitivity = 0.1 * (_controller.fov / 90.0);

      // Update longitude (horizontal pan)
      double newLongitude = _controller.longitude - dx * sensitivity;
      // Ensure longitude wraps around properly
      newLongitude = (newLongitude + 360.0) % 360.0;

      // Update latitude (vertical pan) with inverted control
      double newLatitude = _controller.latitude - dy * sensitivity;
      // Clamp latitude to prevent over-rotation
      newLatitude = newLatitude.clamp(-90.0, 90.0);

      _controller.updateView(
        longitude: newLongitude,
        latitude: newLatitude,
      );
    }

    // Handle zooming
    if (details.scale != 1.0) {
      final double newFOV = _controller.fov / details.scale;
      _controller.updateView(fov: newFOV);
    }

    _lastFocalPoint = details.focalPoint;
    widget.onViewChanged?.call(_controller.viewDetails);
  }

  void _handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _lastFocalPoint = null;
  }

  @override
  Widget build(BuildContext context) {
    if (_imageInfo == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: GestureDetector(
        onScaleStart: _handleScaleStart,
        onScaleUpdate: _handleScaleUpdate,
        onScaleEnd: _handleScaleEnd,
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
