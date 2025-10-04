import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_monitor_provider.dart';

class FuturisticCentralDisplay extends StatefulWidget {
  final String? projectName;
  final VoidCallback onFullScreenToggle;

  const FuturisticCentralDisplay({
    super.key,
    this.projectName,
    required this.onFullScreenToggle,
  });

  @override
  State<FuturisticCentralDisplay> createState() => _FuturisticCentralDisplayState();
}

class _FuturisticCentralDisplayState extends State<FuturisticCentralDisplay>
    with TickerProviderStateMixin {
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _dataController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _dataController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _dataController.dispose();
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
          
          // Main content
          widget.projectName == null ? _buildIdleState() : _buildProjectDisplay(),
          
          // Scanning effects
          _buildScanningEffects(),
          
          // Corner decorations
          _buildCornerDecorations(),
        ],
      ),
    );
  }

  Widget _buildGridPattern() {
    return AnimatedBuilder(
      animation: _scanController,
      builder: (context, child) {
        return CustomPaint(
          painter: FuturisticGridPainter(_scanController.value),
          size: Size.infinite,
        );
      },
    );
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
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF00FFFF).withOpacity(0.1),
                  border: Border.all(
                    color: const Color(0xFF00FFFF).withOpacity(0.3 + _pulseController.value * 0.3),
                    width: 3,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00FFFF).withOpacity(0.3 + _pulseController.value * 0.2),
                      blurRadius: 30 + _pulseController.value * 20,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_arrow,
                    color: Color(0xFF00FFFF),
                    size: 50,
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
              color: Color(0xFF00FFFF),
              letterSpacing: 4,
              shadows: [
                Shadow(
                  color: Color(0xFF00FFFF),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'COMMAND CENTER READY',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF00FF00),
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'SELECT PROJECT FROM LEFT PANEL',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectDisplay() {
    return Column(
      children: [
        _buildProjectHeader(),
        Expanded(
          child: _buildProjectContent(),
        ),
        _buildProjectControls(),
      ],
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00FFFF).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.projectName!.toUpperCase(),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00FFFF),
              letterSpacing: 2,
            ),
          ),
          Row(
            children: [
              const Text(
                'SYSTEM ACTIVE',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF00FF00),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 20),
              GestureDetector(
                onTap: widget.onFullScreenToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FFFF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF00FFFF).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'FULLSCREEN',
                    style: TextStyle(
                      color: Color(0xFF00FFFF),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProjectContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildSystemMetrics(),
          const SizedBox(height: 20),
          _buildActivityLog(),
          const SizedBox(height: 20),
          _buildDataVisualization(),
        ],
      ),
    );
  }

  Widget _buildSystemMetrics() {
    return Consumer<SystemMonitorProvider>(
      builder: (context, monitor, child) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF00FFFF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SYSTEM METRICS',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricGauge('CPU USAGE', monitor.cpuUsage, const Color(0xFF00FFFF)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildMetricGauge('MEMORY', monitor.memoryUsage, const Color(0xFF00FF00)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildMetricGauge('DISK', monitor.diskUsage, const Color(0xFFFFD700)),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: _buildMetricGauge('NETWORK', 12.0, const Color(0xFFFF6B6B)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricGauge(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Container(
              width: 80,
              height: 80,
              child: CustomPaint(
                painter: FuturisticGaugePainter(
                  value: value,
                  color: color,
                  animation: _pulseController.value,
                ),
                size: const Size(80, 80),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          '${value.toStringAsFixed(0)}%',
          style: TextStyle(
            color: color,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLog() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00FFFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVITY LOG',
            style: TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 15),
          _buildLogEntry('14:32:15', 'SYSTEM INITIALIZED', const Color(0xFF00FF00)),
          _buildLogEntry('14:32:18', 'PROJECT LOADED', const Color(0xFF00FF00)),
          _buildLogEntry('14:32:22', 'CONNECTIONS ESTABLISHED', const Color(0xFF00FF00)),
          _buildLogEntry('14:32:25', 'MONITORING ACTIVE', const Color(0xFF00FF00)),
          _buildLogEntry('14:32:28', 'ALL SYSTEMS OPERATIONAL', const Color(0xFF00FF00)),
        ],
      ),
    );
  }

  Widget _buildLogEntry(String time, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Text(
            time,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            message,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataVisualization() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00FFFF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DATA VISUALIZATION',
            style: TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 120,
            child: AnimatedBuilder(
              animation: _dataController,
              builder: (context, child) {
                return CustomPaint(
                  painter: FuturisticDataChartPainter(_dataController.value),
                  size: const Size(double.infinity, 120),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectControls() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.8),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00FFFF).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton('LAUNCH', const Color(0xFF00FF00)),
          const SizedBox(width: 20),
          _buildControlButton('CONFIGURE', const Color(0xFFFFD700)),
          const SizedBox(width: 20),
          _buildControlButton('MONITOR', const Color(0xFF00FFFF)),
          const SizedBox(width: 20),
          _buildControlButton('TERMINATE', const Color(0xFFFF6B6B)),
        ],
      ),
    );
  }

  Widget _buildControlButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
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
              top: 200 + 200 * _scanController.value,
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
              left: 200 + 200 * _scanController.value,
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
              width: 15,
              height: 2,
              color: const Color(0xFF00FFFF),
            ),
          ),
          Positioned(
            top: 0,
            left: 0,
            child: Container(
              width: 2,
              height: 15,
              color: const Color(0xFF00FFFF),
            ),
          ),
        ],
      ),
    );
  }
}

class FuturisticGridPainter extends CustomPainter {
  final double animation;

  FuturisticGridPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1)
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
  bool shouldRepaint(FuturisticGridPainter oldDelegate) => oldDelegate.animation != animation;
}

class FuturisticGaugePainter extends CustomPainter {
  final double value;
  final Color color;
  final double animation;

  FuturisticGaugePainter({
    required this.value,
    required this.color,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 5;

    // Background circle
    final backgroundPaint = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final startAngle = -3.14159 / 2;
    final sweepAngle = 2 * 3.14159 * (value / 100);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );

    // Glow effect
    final glowPaint = Paint()
      ..color = color.withOpacity(0.3 + animation * 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      glowPaint,
    );
  }

  @override
  bool shouldRepaint(FuturisticGaugePainter oldDelegate) => 
      oldDelegate.value != value || oldDelegate.animation != animation;
}

class FuturisticDataChartPainter extends CustomPainter {
  final double animation;

  FuturisticDataChartPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00FFFF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [0.0, 0.3, 0.2, 0.1, 0.4, 0.4, 0.6, 0.2, 0.8, 0.5, 1.0, 0.3];
    
    for (int i = 0; i < points.length; i += 2) {
      final x = points[i] * size.width;
      final y = points[i + 1] * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Fill area under the line
    final fillPaint = Paint()
      ..color = const Color(0xFF00FFFF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);

    // Animated data points
    for (int i = 0; i < points.length; i += 2) {
      final x = points[i] * size.width;
      final y = points[i + 1] * size.height;
      
      final pointPaint = Paint()
        ..color = const Color(0xFF00FFFF).withOpacity(0.8 + 0.2 * animation)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 3 + 2 * animation, pointPaint);
    }
  }

  @override
  bool shouldRepaint(FuturisticDataChartPainter oldDelegate) => oldDelegate.animation != animation;
}
