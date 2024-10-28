import 'package:flutter/material.dart';

import 'view_change_details.dart';

/// Controls the view parameters of a panoramic image display.
///
/// This controller manages the current viewing position (longitude and latitude)
/// and zoom level (field of view) of the panorama. It can be used to
/// programmatically control the view or to get the current view state.
///
/// Example usage:
/// ```dart
/// final controller = PanoramaController();
/// controller.updateView(longitude: 180, latitude: 30, fov: 60);
/// ```
class PanoramaController extends ChangeNotifier {
  double _longitude = 0.0;
  double _latitude = 0.0;
  double _fov;
  final double maxFOV;
  final double minFOV;

  /// Creates a new panorama controller with optional initial values.
  ///
  /// - [initialLongitude]: Starting horizontal rotation in degrees (default: 0.0)
  /// - [initialLatitude]: Starting vertical rotation in degrees (default: 0.0)
  /// - [initialFOV]: Starting field of view in degrees (default: 90.0)
  /// - [maxFOV]: Maximum allowed field of view in degrees (default: 120.0)
  /// - [minFOV]: Minimum allowed field of view in degrees (default: 30.0)
  PanoramaController({
    double initialLongitude = 0.0,
    double initialLatitude = 0.0,
    double initialFOV = 90.0,
    this.maxFOV = 120.0,
    this.minFOV = 30.0,
  })  : _longitude = initialLongitude % 360.0,
        _latitude = initialLatitude.clamp(-90.0, 90.0),
        _fov = initialFOV.clamp(minFOV, maxFOV);

  /// The current horizontal rotation in degrees (0 to 360)
  double get longitude => _longitude;

  /// The current vertical rotation in degrees (-90 to 90)
  double get latitude => _latitude;

  /// The current field of view in degrees
  double get fov => _fov;

  /// Updates the view parameters of the panorama.
  ///
  /// Provide only the parameters you want to change. Null values will be ignored.
  /// The view will automatically wrap longitude around 360° and clamp latitude
  /// between -90° and 90°. FOV will be clamped between [minFOV] and [maxFOV].
  void updateView({
    double? longitude,
    double? latitude,
    double? fov,
    void Function(ViewChangeDetails)? onViewChanged,
  }) {
    bool changed = false;

    if (longitude != null && longitude != _longitude) {
      _longitude = longitude % 360.0;
      changed = true;
    }

    if (latitude != null && latitude != _latitude) {
      _latitude = latitude.clamp(-90.0, 90.0);
      changed = true;
    }

    if (fov != null && fov != _fov) {
      _fov = fov.clamp(minFOV, maxFOV);
      changed = true;
    }

    if (changed) {
      notifyListeners();
      onViewChanged?.call(viewDetails);
    }
  }

  /// Returns the current view state as a [ViewChangeDetails] object.
  ViewChangeDetails get viewDetails => ViewChangeDetails(
        longitude: _longitude,
        latitude: _latitude,
        fov: _fov,
      );
}
