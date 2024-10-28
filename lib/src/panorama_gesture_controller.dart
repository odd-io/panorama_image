import 'package:flutter/gestures.dart';
import 'panorama_controller.dart';
import 'view_change_details.dart';

/// Abstract base class for panorama gesture control
abstract class PanoramaGestureController {
  void handlePointerSignal(PointerSignalEvent event);
  void handleScaleStart(ScaleStartDetails details);
  void handleScaleUpdate(ScaleUpdateDetails details);
  void handleScaleEnd(ScaleEndDetails details);
}

/// Default implementation of panorama gesture controls
class DefaultPanoramaGestureController implements PanoramaGestureController {
  DefaultPanoramaGestureController({
    required this.controller,
    required this.onViewChanged,
  });

  final PanoramaController controller;
  final void Function(ViewChangeDetails)? onViewChanged;
  Offset? _lastFocalPoint;

  // Constants for zoom sensitivity
  static const double _mouseWheelZoomSensitivity = 0.05;
  static const double _touchZoomSensitivity = 0.015;

  @override
  void handlePointerSignal(PointerSignalEvent event) {
    if (event is PointerScrollEvent) {
      final double scaleFactor = event.scrollDelta.dy > 0
          ? (1 + _mouseWheelZoomSensitivity)
          : (1 - _mouseWheelZoomSensitivity);

      final double newFOV = controller.fov * scaleFactor;
      controller.updateView(fov: newFOV);
      onViewChanged?.call(controller.viewDetails);
    }
  }

  @override
  void handleScaleUpdate(ScaleUpdateDetails details) {
    // Handle panning
    if (_lastFocalPoint != null) {
      final double dx = details.focalPoint.dx - _lastFocalPoint!.dx;
      final double dy = details.focalPoint.dy - _lastFocalPoint!.dy;

      // Adjust sensitivity based on FOV - more zoomed in = slower pan
      final double sensitivity = 0.1 * (controller.fov / 90.0);

      // Update longitude (horizontal pan)
      double newLongitude = controller.longitude - dx * sensitivity;
      // Ensure longitude wraps around properly
      newLongitude = (newLongitude + 360.0) % 360.0;

      // Update latitude (vertical pan) with inverted control
      double newLatitude = controller.latitude - dy * sensitivity;
      // Clamp latitude to prevent over-rotation
      newLatitude = newLatitude.clamp(-90.0, 90.0);

      controller.updateView(
        longitude: newLongitude,
        latitude: newLatitude,
      );
    }

    // Handle touch zooming with reduced sensitivity
    if (details.scale != 1.0) {
      // Calculate the scaled difference with reduced sensitivity
      final double scaleDiff = (details.scale - 1.0) * _touchZoomSensitivity;
      final double effectiveScale = 1.0 + scaleDiff;

      final double newFOV = controller.fov / effectiveScale;
      controller.updateView(fov: newFOV);
    }

    _lastFocalPoint = details.focalPoint;
    onViewChanged?.call(controller.viewDetails);
  }

  @override
  void handleScaleStart(ScaleStartDetails details) {
    _lastFocalPoint = details.focalPoint;
  }

  @override
  void handleScaleEnd(ScaleEndDetails details) {
    _lastFocalPoint = null;
  }
}
