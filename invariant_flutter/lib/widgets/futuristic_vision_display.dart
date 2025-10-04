import 'package:flutter/material.dart';
import 'dart:math' as math;

class FuturisticVisionDisplay extends StatefulWidget {
  const FuturisticVisionDisplay({super.key});

  @override
  State<FuturisticVisionDisplay> createState() => _FuturisticVisionDisplayState();
}

class _FuturisticVisionDisplayState extends State<FuturisticVisionDisplay>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _detectionController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _detectionController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _detectionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border.all(
          color: const Color(0xFF00FFFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background grid
          _buildGridPattern(),
          
          // Main vision display
          _buildVisionDisplay(),
          
          // Scanning effects
          _buildScanningEffects(),
          
          // Detection overlays
          _buildDetectionOverlays(),
          
          // Corner decorations
          _buildCornerDecorations(),
          
          // Status indicators
          _buildStatusIndicators(),
        ],
      ),
    );
  }

  Widget _buildGridPattern() {
    return CustomPaint(
      painter: VisionGridPainter(),
      size: Size.infinite,
    );
  }

  Widget _buildVisionDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vision system title
          const Text(
            'VISION SYSTEM',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00FFFF),
              letterSpacing: 3,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Main vision area
          Container(
            width: 400,
            height: 300,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: const Color(0xFF00FFFF).withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Stack(
              children: [
                // Simulated camera feed
                _buildCameraFeed(),
                
                // Detection boxes
                _buildDetectionBoxes(),
                
                // Crosshair
                _buildCrosshair(),
              ],
            ),
          ),
          
          const SizedBox(height: 30),
          
          // Vision controls
          _buildVisionControls(),
        ],
      ),
    );
  }

  Widget _buildCameraFeed() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(13),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1A1A2E),
            Color(0xFF16213E),
            Color(0xFF0A0A0A),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Simulated objects
          Positioned(
            top: 50,
            left: 80,
            child: _buildSimulatedObject('PERSON', const Color(0xFF00FF00)),
          ),
          Positioned(
            top: 120,
            right: 100,
            child: _buildSimulatedObject('VEHICLE', const Color(0xFFFFD700)),
          ),
          Positioned(
            bottom: 80,
            left: 120,
            child: _buildSimulatedObject('BUILDING', const Color(0xFFFF6B6B)),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulatedObject(String label, Color color) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(4),
            border: Border.all(
              color: color.withOpacity(0.5 + _pulseController.value * 0.3),
              width: 1,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetectionBoxes() {
    return Stack(
      children: [
        // Detection box 1
        Positioned(
          top: 45,
          left: 75,
          child: _buildDetectionBox(const Color(0xFF00FF00)),
        ),
        // Detection box 2
        Positioned(
          top: 115,
          right: 95,
          child: _buildDetectionBox(const Color(0xFFFFD700)),
        ),
        // Detection box 3
        Positioned(
          bottom: 75,
          left: 115,
          child: _buildDetectionBox(const Color(0xFFFF6B6B)),
        ),
      ],
    );
  }

  Widget _buildDetectionBox(Color color) {
    return AnimatedBuilder(
      animation: _detectionController,
      builder: (context, child) {
        return Container(
          width: 60,
          height: 40,
          decoration: BoxDecoration(
            border: Border.all(
              color: color.withOpacity(0.8),
              width: 2,
            ),
          ),
          child: Stack(
            children: [
              // Corner markers
              Positioned(
                top: 0,
                left: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: color, width: 2),
                      left: BorderSide(color: color, width: 2),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(color: color, width: 2),
                      right: BorderSide(color: color, width: 2),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: color, width: 2),
                      left: BorderSide(color: color, width: 2),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: color, width: 2),
                      right: BorderSide(color: color, width: 2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCrosshair() {
    return Center(
      child: AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              border: Border.all(
                color: const Color(0xFF00FFFF).withOpacity(0.8 + _pulseController.value * 0.2),
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.add,
                color: Color(0xFF00FFFF),
                size: 12,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVisionControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton('ZOOM', Icons.zoom_in, const Color(0xFF00FFFF)),
        const SizedBox(width: 20),
        _buildControlButton('TRACK', Icons.gps_fixed, const Color(0xFF00FF00)),
        const SizedBox(width: 20),
        _buildControlButton('RECORD', Icons.videocam, const Color(0xFFFF6B6B)),
        const SizedBox(width: 20),
        _buildControlButton('ANALYZE', Icons.analytics, const Color(0xFFFFD700)),
      ],
    );
  }

  Widget _buildControlButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 9,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildScanningEffects() {
    return Stack(
      children: [
        // Horizontal scan line
        AnimatedBuilder(
          animation: _scanController,
          builder: (context, child) {
            return Positioned(
              top: 200 + 100 * _scanController.value,
              left: 0,
              right: 0,
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      const Color(0xFF00FFFF).withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
        // Vertical scan line
        AnimatedBuilder(
          animation: _scanController,
          builder: (context, child) {
            return Positioned(
              left: 200 + 100 * _scanController.value,
              top: 0,
              bottom: 0,
              child: Container(
                width: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      const Color(0xFF00FFFF).withOpacity(0.8),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDetectionOverlays() {
    return Stack(
      children: [
        // Radar sweep
        Positioned(
          top: 50,
          right: 50,
          child: _buildRadarSweep(),
        ),
        // Status overlay
        Positioned(
          top: 20,
          left: 20,
          child: _buildStatusOverlay(),
        ),
      ],
    );
  }

  Widget _buildRadarSweep() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF00FFFF).withOpacity(0.3),
              width: 2,
            ),
          ),
          child: CustomPaint(
            painter: RadarSweepPainter(_scanController.value),
            size: const Size(80, 80),
          ),
        );
      },
    );
  }

  Widget _buildStatusOverlay() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00FFFF).withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'VISION STATUS',
            style: TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          _buildStatusItem('CAMERA', 'ACTIVE', const Color(0xFF00FF00)),
          _buildStatusItem('DETECTION', '3 OBJECTS', const Color(0xFFFFD700)),
          _buildStatusItem('TRACKING', 'ENABLED', const Color(0xFF00FF00)),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 8,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCornerDecorations() {
    return Stack(
      children: [
        // Top left
        Positioned(
          top: 20,
          left: 20,
          child: _buildCornerPiece(),
        ),
        // Top right
        Positioned(
          top: 20,
          right: 20,
          child: _buildCornerPiece(),
        ),
        // Bottom left
        Positioned(
          bottom: 20,
          left: 20,
          child: _buildCornerPiece(),
        ),
        // Bottom right
        Positioned(
          bottom: 20,
          right: 20,
          child: _buildCornerPiece(),
        ),
      ],
    );
  }

  Widget _buildCornerPiece() {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF00FFFF).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Stack(
        children: [
          // Corner lines
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 10,
              height: 2,
              color: const Color(0xFF00FFFF),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 2,
              height: 10,
              color: const Color(0xFF00FFFF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicators() {
    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(0xFF00FFFF).withOpacity(0.5),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DETECTION',
              style: TextStyle(
                color: Color(0xFF00FFFF),
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            _buildDetectionItem('PERSON', const Color(0xFF00FF00)),
            _buildDetectionItem('VEHICLE', const Color(0xFFFFD700)),
            _buildDetectionItem('BUILDING', const Color(0xFFFF6B6B)),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectionItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class VisionGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1)
      ..strokeWidth = 1;

    const spacing = 40.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(VisionGridPainter oldDelegate) => false;
}

class RadarSweepPainter extends CustomPainter {
  final double animation;

  RadarSweepPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Sweep line
    final sweepPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final sweepAngle = animation * 2 * 3.14159;
    final endPoint = Offset(
      center.dx + radius * math.cos(sweepAngle),
      center.dy + radius * math.sin(sweepAngle),
    );

    canvas.drawLine(center, endPoint, sweepPaint);

    // Center dot
    final centerPaint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 3, centerPaint);
  }

  @override
  bool shouldRepaint(RadarSweepPainter oldDelegate) => oldDelegate.animation != animation;
}
