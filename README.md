# Panorama Image 🖼️

A Flutter widget for displaying and interacting with 360° panoramic images using equirectangular projection.

Available for all platforms supported by Flutter.

## Features ✨

- Display 360° panoramic images with proper spherical projection
- Smooth pan and zoom interactions
- Mouse and touch support

## Installation 📦

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  panorama_image: ^0.0.1
```

## Usage 💡

See the [example app](example/lib/main.dart) for a complete example.

### Basic Example

```dart
import 'package:panorama_image/panorama_image.dart';

PanoramaViewer(
  image: AssetImage('assets/panorama.jpg'),
  initialFOV: 90.0,
  onViewChanged: (details) {
    print('Longitude: ${details.longitude}');
    print('Latitude: ${details.latitude}');
    print('FOV: ${details.fov}');
  },
)
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](/LICENSE) file for details.

---

Made with ❤️ by [odd.io](https://odd.io/)
