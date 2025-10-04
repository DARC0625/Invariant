import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProjectDisplayScreen extends StatefulWidget {
  final String projectName;
  final bool isFullScreen;

  const ProjectDisplayScreen({
    super.key,
    required this.projectName,
    required this.isFullScreen,
  });

  @override
  State<ProjectDisplayScreen> createState() => _ProjectDisplayScreenState();
}

class _ProjectDisplayScreenState extends State<ProjectDisplayScreen>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;

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
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
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
        ],
      ),
    );
  }

  Widget _buildGridPattern() {
    return CustomPaint(
      painter: GridPainter(),
      size: Size.infinite,
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Project status indicator
          _buildStatusIndicator(),
          
          const SizedBox(height: 40),
          
          // Project name
          Text(
            widget.projectName.toUpperCase(),
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
          Text(
            'SYSTEM ACTIVE',
            style: TextStyle(
              fontSize: 16,
              color: const Color(0xFF00FF88),
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
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.1)
      ..strokeWidth = 1;

    const spacing = 50.0;

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
  bool shouldRepaint(GridPainter oldDelegate) => false;
}
