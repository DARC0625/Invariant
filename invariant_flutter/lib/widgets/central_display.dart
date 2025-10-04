import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class CentralDisplay extends StatefulWidget {
  final String? projectName;

  const CentralDisplay({
    super.key,
    this.projectName,
  });

  @override
  State<CentralDisplay> createState() => _CentralDisplayState();
}

class _CentralDisplayState extends State<CentralDisplay>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _gridController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _gridController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _gridController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF0A0A0A),
            Color(0xFF1A1A2E),
          ],
        ),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Stack(
        children: [
          // Background grid pattern
          _buildGridPattern(),
          
          // Main content
          _buildMainContent(),
          
          // Scanning line effect
          _buildScanningLine(),
          
          // Corner decorations
          _buildCornerDecorations(),
          
          // Data points
          _buildDataPoints(),
        ],
      ),
    );
  }

  Widget _buildGridPattern() {
    return AnimatedBuilder(
      animation: _gridController,
      builder: (context, child) {
        return CustomPaint(
          painter: GridPainter(animation: _gridController.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildMainContent() {
    if (widget.projectName == null) {
      return _buildIdleState();
    } else {
      return _buildProjectDisplay();
    }
  }

  Widget _buildIdleState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00D4FF).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(0.3 + _pulseController.value * 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.3 + _pulseController.value * 0.2),
                      blurRadius: 30 + _pulseController.value * 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Color(0xFF00D4FF),
                    size: 60,
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 40),
          const Text(
            'INVARIANT',
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D4FF),
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Color(0xFF00D4FF),
                  blurRadius: 20,
                ),
              ],
            ),
          ).animate().fadeIn(
            duration: 1000.ms,
          ).slideY(
            begin: 0.3,
            end: 0,
            duration: 1000.ms,
          ),
          const SizedBox(height: 20),
          const Text(
            'COMMAND CENTER READY',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF00FF88),
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(
            duration: 1500.ms,
            delay: 500.ms,
          ),
          const SizedBox(height: 10),
          const Text(
            'Select a project from the left panel',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ).animate().fadeIn(
            duration: 2000.ms,
            delay: 1000.ms,
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDisplay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Project status indicator
          _buildStatusIndicator(),
          
          const SizedBox(height: 40),
          
          // Project name
          Text(
            widget.projectName!.toUpperCase(),
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D4FF),
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Color(0xFF00D4FF),
                  blurRadius: 20,
                ),
              ],
            ),
          ).animate().fadeIn(
            duration: 1000.ms,
          ).slideY(
            begin: 0.3,
            end: 0,
            duration: 1000.ms,
          ),
          
          const SizedBox(height: 20),
          
          // Status text
          const Text(
            'SYSTEM ACTIVE',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF00FF88),
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ).animate().fadeIn(
            duration: 1500.ms,
            delay: 500.ms,
          ),
          
          const SizedBox(height: 60),
          
          // Control buttons
          _buildControlButtons(),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFF00D4FF).withOpacity(0.1),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.3 + _pulseController.value * 0.3),
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00D4FF).withOpacity(0.3 + _pulseController.value * 0.2),
                blurRadius: 20 + _pulseController.value * 10,
                spreadRadius: 5,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.play_arrow,
              color: Color(0xFF00D4FF),
              size: 40,
            ),
          ),
        );
      },
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton('LAUNCH', Icons.rocket_launch, const Color(0xFF00FF88)),
        const SizedBox(width: 30),
        _buildControlButton('CONFIGURE', Icons.settings, const Color(0xFFFFD93D)),
        const SizedBox(width: 30),
        _buildControlButton('MONITOR', Icons.analytics, const Color(0xFFFF6B6B)),
      ],
    );
  }

  Widget _buildControlButton(String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: color.withOpacity(0.5),
              width: 2,
            ),
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildScanningLine() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return Positioned(
          top: _scanController.value * MediaQuery.of(context).size.height,
          left: 0,
          right: 0,
          child: Container(
            height: 2,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF00D4FF).withOpacity(0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        );
      },
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
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.5),
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
              width: 15,
              height: 2,
              color: const Color(0xFF00D4FF),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 2,
              height: 15,
              color: const Color(0xFF00D4FF),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataPoints() {
    return Stack(
      children: [
        // Random data points
        Positioned(
          top: 100,
          left: 150,
          child: _buildDataPoint(const Color(0xFF00FF88)),
        ),
        Positioned(
          top: 200,
          right: 200,
          child: _buildDataPoint(const Color(0xFFFF6B6B)),
        ),
        Positioned(
          bottom: 150,
          left: 200,
          child: _buildDataPoint(const Color(0xFFFFD93D)),
        ),
        Positioned(
          bottom: 100,
          right: 150,
          child: _buildDataPoint(const Color(0xFF9C27B0)),
        ),
      ],
    );
  }

  Widget _buildDataPoint(Color color) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 8 + _pulseController.value * 4,
          height: 8 + _pulseController.value * 4,
          decoration: BoxDecoration(
            color: color.withOpacity(0.8),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.5),
                blurRadius: 10 + _pulseController.value * 5,
                spreadRadius: 2,
              ),
            ],
          ),
        );
      },
    );
  }
}

class GridPainter extends CustomPainter {
  final double animation;

  GridPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.1)
      ..strokeWidth = 1;

    const spacing = 50.0;

    // Vertical lines
    for (double x = 0; x < size.width; x += spacing) {
      final offset = (animation * spacing) % spacing;
      canvas.drawLine(
        Offset(x - offset, 0),
        Offset(x - offset, size.height),
        paint,
      );
    }

    // Horizontal lines
    for (double y = 0; y < size.height; y += spacing) {
      final offset = (animation * spacing) % spacing;
      canvas.drawLine(
        Offset(0, y - offset),
        Offset(size.width, y - offset),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(GridPainter oldDelegate) => oldDelegate.animation != animation;
}
