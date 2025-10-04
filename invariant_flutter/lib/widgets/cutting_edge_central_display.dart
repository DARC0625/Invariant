import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:rive/rive.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../providers/system_monitor_provider.dart';

class CuttingEdgeCentralDisplay extends ConsumerStatefulWidget {
  final String? projectName;
  final VoidCallback onFullScreenToggle;

  const CuttingEdgeCentralDisplay({
    super.key,
    this.projectName,
    required this.onFullScreenToggle,
  });

  @override
  ConsumerState<CuttingEdgeCentralDisplay> createState() => _CuttingEdgeCentralDisplayState();
}

class _CuttingEdgeCentralDisplayState extends ConsumerState<CuttingEdgeCentralDisplay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GlassmorphicContainer(
      width: double.infinity,
      height: double.infinity,
      borderRadius: 12,
      blur: 20,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF1A1A2E).withOpacity(0.8),
          const Color(0xFF16213E).withOpacity(0.6),
        ],
      ),
      borderGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.3),
          const Color(0xFF0099CC).withOpacity(0.1),
        ],
      ),
      child: widget.projectName == null ? _buildIdleState() : _buildProjectDisplay(),
    );
  }

  Widget _buildIdleState() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF00D4FF),
                            Color(0xFF0099CC),
                            Color(0xFF0066AA),
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.rocket_launch,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 50),
              Text(
                'INVARIANT',
                style: GoogleFonts.orbitron(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF00D4FF),
                  letterSpacing: 6,
                  shadows: [
                    Shadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.5),
                      blurRadius: 20,
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 1500.ms, delay: 500.ms).scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1.0, 1.0),
                curve: Curves.elasticOut,
              ),
              const SizedBox(height: 20),
              Text(
                'COMMAND CENTER',
                style: GoogleFonts.robotoMono(
                  fontSize: 18,
                  color: const Color(0xFF00FF88),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ).animate().fadeIn(duration: 1000.ms, delay: 1000.ms).slideY(begin: 0.3, end: 0),
              const SizedBox(height: 10),
              Text(
                'SYSTEM READY',
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  color: Colors.grey,
                  letterSpacing: 2,
                ),
              ).animate().fadeIn(duration: 800.ms, delay: 1200.ms),
              const SizedBox(height: 30),
              GlassmorphicContainer(
                width: 300,
                height: 60,
                borderRadius: 30,
                blur: 15,
                alignment: Alignment.center,
                border: 1,
                linearGradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D4FF).withOpacity(0.1),
                    const Color(0xFF0099CC).withOpacity(0.05),
                  ],
                ),
                borderGradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D4FF).withOpacity(0.3),
                    const Color(0xFF0099CC).withOpacity(0.1),
                  ],
                ),
                child: Text(
                  'SELECT PROJECT FROM LEFT PANEL',
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    color: const Color(0xFF00D4FF),
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),
              ).animate().fadeIn(duration: 1000.ms, delay: 1500.ms).slideY(begin: 0.5, end: 0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectDisplay() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          children: [
            _buildProjectHeader(),
            Expanded(
              child: _buildProjectContent(),
            ),
            _buildProjectControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectHeader() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
        border: const Border(
          bottom: BorderSide(
            color: Color(0xFF333333),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.psychology,
                  color: Color(0xFF00D4FF),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    widget.projectName!.toUpperCase(),
                    style: GoogleFonts.orbitron(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF00D4FF),
                      letterSpacing: 2,
                    ),
                  ),
                  Text(
                    'ADVANCED AI AGENT SYSTEM',
                    style: GoogleFonts.robotoMono(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            children: [
              _buildStatusIndicator('ONLINE', const Color(0xFF00FF88)),
              const SizedBox(width: 16),
              _buildStatusIndicator('v2.1.4', const Color(0xFF00D4FF)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: widget.onFullScreenToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF00D4FF).withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'FULLSCREEN',
                    style: GoogleFonts.robotoMono(
                      color: const Color(0xFF00D4FF),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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

  Widget _buildStatusIndicator(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.robotoMono(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildProjectContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSystemMetrics(),
          const SizedBox(height: 24),
          _buildAdvancedCharts(),
          const SizedBox(height: 24),
          _buildActivityLog(),
        ],
      ),
    );
  }

  Widget _buildSystemMetrics() {
    return Consumer(
      builder: (context, ref, child) {
        final monitor = ref.watch(systemMonitorProvider);
        return GlassmorphicContainer(
          width: double.infinity,
          height: 120,
          borderRadius: 12,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            colors: [
              const Color(0xFF1A1A2E).withOpacity(0.6),
              const Color(0xFF16213E).withOpacity(0.4),
            ],
          ),
          borderGradient: LinearGradient(
            colors: [
              const Color(0xFF00D4FF).withOpacity(0.2),
              const Color(0xFF0099CC).withOpacity(0.1),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SYSTEM METRICS',
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFF00D4FF),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildMetricGauge('CPU', monitor.cpuUsage, const Color(0xFF00D4FF)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricGauge('MEMORY', monitor.memoryUsage, const Color(0xFF00FF88)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricGauge('DISK', monitor.diskUsage, const Color(0xFFFFD93D)),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildMetricGauge('NETWORK', 12.0, const Color(0xFFFF6B6B)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricGauge(String label, double value, Color color) {
    return Column(
      children: [
        SizedBox(
          height: 40,
          width: 40,
          child: CustomPaint(
            painter: CircularGaugePainter(value, color),
            size: const Size(40, 40),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.robotoMono(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          '${value.toStringAsFixed(0)}%',
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedCharts() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 250,
      borderRadius: 12,
      blur: 15,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          const Color(0xFF1A1A2E).withOpacity(0.6),
          const Color(0xFF16213E).withOpacity(0.4),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.2),
          const Color(0xFF0099CC).withOpacity(0.1),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'PERFORMANCE ANALYTICS',
              style: GoogleFonts.orbitron(
                color: const Color(0xFF00D4FF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: CustomPaint(
                painter: LineChartPainter(_getChartData()),
                size: const Size(double.infinity, 200),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<ChartData> _getChartData() {
    return [
      ChartData(0, 20),
      ChartData(1, 35),
      ChartData(2, 45),
      ChartData(3, 30),
      ChartData(4, 55),
      ChartData(5, 40),
      ChartData(6, 65),
      ChartData(7, 50),
      ChartData(8, 70),
      ChartData(9, 60),
      ChartData(10, 45),
    ];
  }

  Widget _buildActivityLog() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 150,
      borderRadius: 12,
      blur: 15,
      alignment: Alignment.center,
      border: 1,
      linearGradient: LinearGradient(
        colors: [
          const Color(0xFF1A1A2E).withOpacity(0.6),
          const Color(0xFF16213E).withOpacity(0.4),
        ],
      ),
      borderGradient: LinearGradient(
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.2),
          const Color(0xFF0099CC).withOpacity(0.1),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ACTIVITY LOG',
              style: GoogleFonts.orbitron(
                color: const Color(0xFF00D4FF),
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _buildLogEntry('14:32:15', 'SYSTEM INITIALIZED', const Color(0xFF00FF88)),
                  _buildLogEntry('14:32:18', 'PROJECT LOADED', const Color(0xFF00FF88)),
                  _buildLogEntry('14:32:22', 'CONNECTIONS ESTABLISHED', const Color(0xFF00FF88)),
                  _buildLogEntry('14:32:25', 'MONITORING ACTIVE', const Color(0xFF00FF88)),
                  _buildLogEntry('14:32:28', 'ALL SYSTEMS OPERATIONAL', const Color(0xFF00FF88)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogEntry(String time, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            time,
            style: GoogleFonts.robotoMono(
              color: Colors.grey,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 16),
          Text(
            message,
            style: GoogleFonts.robotoMono(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectControls() {
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E).withOpacity(0.8),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(12),
          bottomRight: Radius.circular(12),
        ),
        border: const Border(
          top: BorderSide(
            color: Color(0xFF333333),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton('LAUNCH', const Color(0xFF00FF88), Icons.play_arrow),
          const SizedBox(width: 16),
          _buildControlButton('CONFIGURE', const Color(0xFFFFD93D), Icons.settings),
          const SizedBox(width: 16),
          _buildControlButton('MONITOR', const Color(0xFF00D4FF), Icons.analytics),
          const SizedBox(width: 16),
          _buildControlButton('TERMINATE', const Color(0xFFFF6B6B), Icons.stop),
        ],
      ),
    );
  }

  Widget _buildControlButton(String label, Color color, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Handle button tap
      },
      child: GlassmorphicContainer(
        width: 100,
        height: 50,
        borderRadius: 8,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            color.withOpacity(0.3),
            color.withOpacity(0.1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 16,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.robotoMono(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChartData {
  final double x;
  final double y;

  ChartData(this.x, this.y);
}

class CircularGaugePainter extends CustomPainter {
  final double value;
  final Color color;

  CircularGaugePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;

    // Background circle
    final backgroundPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (value / 100) * 2 * 3.14159;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularGaugePainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}

class LineChartPainter extends CustomPainter {
  final List<ChartData> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final xStep = size.width / (data.length - 1);
    final yMax = data.map((d) => d.y).reduce((a, b) => a > b ? a : b);
    final yMin = data.map((d) => d.y).reduce((a, b) => a < b ? a : b);
    final yRange = yMax - yMin;

    for (int i = 0; i < data.length; i++) {
      final x = i * xStep;
      final y = size.height - ((data[i].y - yMin) / yRange) * size.height;
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Draw points
    final pointPaint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < data.length; i++) {
      final x = i * xStep;
      final y = size.height - ((data[i].y - yMin) / yRange) * size.height;
      canvas.drawCircle(Offset(x, y), 3, pointPaint);
    }
  }

  @override
  bool shouldRepaint(LineChartPainter oldDelegate) {
    return oldDelegate.data != data;
  }
}
