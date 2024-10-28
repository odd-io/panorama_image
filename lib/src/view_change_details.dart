/// Represents the current view state of a panorama.
///
/// This class encapsulates all the parameters that define the current viewing
/// position and zoom level of a panoramic image.
class ViewChangeDetails {
  /// The horizontal rotation in degrees, from 0 to 360.
  /// 0° represents the initial view, 180° is looking backward.
  final double longitude;

  /// The vertical rotation in degrees, from -90 to 90.
  /// 0° is looking at the horizon, 90° is looking straight up,
  /// and -90° is looking straight down.
  final double latitude;

  /// The current field of view in degrees.
  /// Smaller values zoom in, larger values zoom out.
  final double fov;

  /// Creates a new view change details object.
  const ViewChangeDetails({
    required this.longitude,
    required this.latitude,
    required this.fov,
  });
}
