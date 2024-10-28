import 'package:flutter/material.dart';
import 'package:panorama_image/panorama_image.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Panorama Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const PanoramaDemo(),
    );
  }
}

class PanoramaDemo extends StatefulWidget {
  const PanoramaDemo({super.key});

  @override
  State<PanoramaDemo> createState() => _PanoramaDemoState();
}

class _PanoramaDemoState extends State<PanoramaDemo> {
  double _longitude = 0.0;
  double _latitude = 0.0;
  double _fov = 90.0;

  final _controller = PanoramaController(
    initialLongitude: 180.0, // Start looking at the opposite direction
    initialLatitude: 0.0, // Start at horizon level
    initialFOV: 90.0, // Start with 90° field of view
  );

  @override
  void initState() {
    super.initState();
    // Initialize the view values from the controller
    _longitude = _controller.longitude;
    _latitude = _controller.latitude;
    _fov = _controller.fov;
  }

  void _updateView(ViewChangeDetails details) {
    setState(() {
      _longitude = details.longitude;
      _latitude = details.latitude;
      _fov = details.fov;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Panorama Demo'),
      ),
      body: Stack(
        children: [
          PanoramaViewer(
            image: const NetworkImage(
                'https://upload.wikimedia.org/wikipedia/commons/9/92/Alte_Schachtschleuse_Waltrop_Panorama.jpg'),
            controller: _controller, // Use the controller
            onViewChanged: _updateView,
          ),
          Positioned(
            left: 16,
            bottom: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Longitude: ${_longitude.toStringAsFixed(1)}°',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'Latitude: ${_latitude.toStringAsFixed(1)}°',
                        style: const TextStyle(color: Colors.white),
                      ),
                      Text(
                        'FOV: ${_fov.toStringAsFixed(1)}°',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _ControlButton(
                      icon: Icons.arrow_left,
                      onPressed: () {
                        _controller.updateView(
                          longitude: _controller.longitude - 30,
                          onViewChanged: _updateView,
                        );
                      },
                    ),
                    _ControlButton(
                      icon: Icons.arrow_right,
                      onPressed: () {
                        _controller.updateView(
                          longitude: _controller.longitude + 30,
                          onViewChanged: _updateView,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    _ControlButton(
                      icon: Icons.arrow_upward,
                      onPressed: () {
                        _controller.updateView(
                          latitude: _controller.latitude + 30,
                          onViewChanged: _updateView,
                        );
                      },
                    ),
                    _ControlButton(
                      icon: Icons.arrow_downward,
                      onPressed: () {
                        _controller.updateView(
                          latitude: _controller.latitude - 30,
                          onViewChanged: _updateView,
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    _ControlButton(
                      icon: Icons.zoom_in,
                      onPressed: () {
                        _controller.updateView(
                          fov: _controller.fov * 0.8,
                          onViewChanged: _updateView,
                        );
                      },
                    ),
                    _ControlButton(
                      icon: Icons.zoom_out,
                      onPressed: () {
                        _controller.updateView(
                          fov: _controller.fov * 1.2,
                          onViewChanged: _updateView,
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
