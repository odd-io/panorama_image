import 'package:flutter/material.dart';
import 'panorama_controller.dart';
import 'dart:ui' as ui;
import 'dart:math' as math;
import 'package:vector_math/vector_math_64.dart' as vector;

/// A custom painter that renders a spherical panorama image onto a canvas.
///
/// This painter works in conjunction with [PanoramaController] to handle the
/// rendering of equirectangular panoramic images with proper perspective and
/// distortion correction.
class PanoramaPainter extends CustomPainter {
  final ui.Image image;
  final PanoramaController controller;

  PanoramaPainter({
    required this.image,
    required this.controller,
  }) : super(repaint: controller);

  @override
  void paint(Canvas canvas, Size size) {
    SphericalProjection.drawSphericalProjection(
      canvas,
      image,
      size,
      controller.longitude,
      controller.latitude,
      controller.fov,
    );
  }

  @override
  bool shouldRepaint(PanoramaPainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.controller != controller;
  }
}

/// Handles the mathematical calculations and rendering of spherical projections.
///
/// This class implements the core rendering logic for converting equirectangular
/// panoramic images into their proper spherical projection, taking into account
/// the viewer's position (longitude and latitude) and field of view.
class SphericalProjection {
  /// Renders a spherical projection of the panoramic image onto the canvas.
  ///
  /// Parameters:
  /// - [canvas]: The canvas to draw on
  /// - [image]: The equirectangular panoramic image to project
  /// - [size]: The size of the viewport
  /// - [longitude]: The horizontal rotation in degrees (0 to 360)
  /// - [latitude]: The vertical rotation in degrees (-90 to 90)
  /// - [fov]: The field of view in degrees
  static void drawSphericalProjection(
    Canvas canvas,
    ui.Image image,
    Size size,
    double longitude,
    double latitude,
    double fov,
  ) {
    final double viewportWidth = size.width;
    final double viewportHeight = size.height;

    // Create the ImageShader
    final shader = ImageShader(
      image,
      TileMode.repeated,
      TileMode.clamp,
      Matrix4.identity().storage,
    );

    final shaderPaint = Paint()..shader = shader;

    // Number of segments in the grid
    const int segmentsX = 64;
    const int segmentsY = 64;

    // Convert angles to radians
    final double lonRad = longitude * math.pi / 180.0;
    final double latRad = latitude * math.pi / 180.0;
    final double fovRad = fov * math.pi / 180.0;

    // Calculate horizontal and vertical field of view
    final double aspect = viewportWidth / viewportHeight;
    final double halfWidth = math.tan(fovRad / 2);
    final double halfHeight = halfWidth / aspect;

    // Generate vertices and texture coordinates
    final vertices = <Offset>[];
    final texCoords = <Offset>[];

    for (int y = 0; y <= segmentsY; y++) {
      final double v = y / segmentsY;
      final double yScreen = (1 - 2 * v) * halfHeight;

      for (int x = 0; x <= segmentsX; x++) {
        final double u = x / segmentsX;
        final double xScreen = (2 * u - 1) * halfWidth;

        // Convert screen coordinate to direction vector
        vector.Vector3 dir = vector.Vector3(xScreen, yScreen, -1).normalized();

        // Apply rotation based on longitude and latitude
        final rotation = vector.Matrix4.identity()
          ..rotateY(-lonRad)
          ..rotateX(-latRad);
        dir = rotation.transform3(dir);

        // Spherical coordinates
        double theta = math.atan2(dir.x, -dir.z);
        double phi = math.asin(dir.y);

        // Texture coordinates
        double uTex = (theta + math.pi) / (2 * math.pi);
        double vTex = 1.0 - ((phi + math.pi / 2) / math.pi);

        vertices.add(Offset(u * viewportWidth, v * viewportHeight));
        texCoords.add(Offset(uTex * image.width, vTex * image.height));
      }
    }

    // Draw the mesh
    for (int y = 0; y < segmentsY; y++) {
      for (int x = 0; x < segmentsX; x++) {
        final int i0 = y * (segmentsX + 1) + x;
        final int i1 = i0 + 1;
        final int i2 = i0 + segmentsX + 1;
        final int i3 = i2 + 1;

        // First triangle
        final triangleVertices1 = [
          vertices[i0],
          vertices[i1],
          vertices[i2],
        ];
        final textureCoordinates1 = [
          texCoords[i0],
          texCoords[i1],
          texCoords[i2],
        ];

        canvas.drawVertices(
          ui.Vertices(
            ui.VertexMode.triangles,
            triangleVertices1,
            textureCoordinates: textureCoordinates1,
          ),
          BlendMode.modulate,
          shaderPaint,
        );

        // Second triangle
        final triangleVertices2 = [
          vertices[i1],
          vertices[i3],
          vertices[i2],
        ];
        final textureCoordinates2 = [
          texCoords[i1],
          texCoords[i3],
          texCoords[i2],
        ];

        canvas.drawVertices(
          ui.Vertices(
            ui.VertexMode.triangles,
            triangleVertices2,
            textureCoordinates: textureCoordinates2,
          ),
          BlendMode.modulate,
          shaderPaint,
        );
      }
    }
  }
}
