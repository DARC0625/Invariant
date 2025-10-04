import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:syncfusion_flutter_gauges/gauges.dart';
import '../providers/system_monitor_provider.dart';

class CuttingEdgeRightPanel extends ConsumerStatefulWidget {
  const CuttingEdgeRightPanel({super.key});

  @override
  ConsumerState<CuttingEdgeRightPanel> createState() => _CuttingEdgeRightPanelState();
}

class _CuttingEdgeRightPanelState extends ConsumerState<CuttingEdgeRightPanel>
    with TickerProviderStateMixin {
  late AnimationController _gaugeController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _gaugeController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gaugeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: GlassmorphicContainer(
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
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildContent(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'SYSTEM MONITOR',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00D4FF),
              letterSpacing: 2,
            ),
          ).animate().fadeIn(duration: 800.ms).slideX(begin: 0.3, end: 0),
          const SizedBox(height: 8),
          Text(
            'REAL-TIME METRICS',
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(duration: 1000.ms, delay: 200.ms),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF00D4FF).withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return PageView(
      children: [
        // Page 1: System Status & Performance
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildSystemStatus(),
              const SizedBox(height: 20),
              _buildPerformanceGauges(),
            ],
          ),
        ),
        // Page 2: Network & Security
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildNetworkStatus(),
              const SizedBox(height: 20),
              _buildSecurityStatus(),
            ],
          ),
        ),
        // Page 3: Resource Usage
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              _buildResourceUsage(),
              const SizedBox(height: 20),
              _buildAdvancedMetrics(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSystemStatus() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
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
          const Color(0xFF00FF88).withOpacity(0.2),
          const Color(0xFF00CC66).withOpacity(0.1),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'SYSTEM STATUS',
              style: GoogleFonts.orbitron(
                color: const Color(0xFF00FF88),
                fontSize: 10,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    return Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00FF88),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00FF88).withOpacity(0.5 + 0.3 * _pulseController.value),
                            blurRadius: 8 + 4 * _pulseController.value,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ALL SYSTEMS OPERATIONAL',
                        style: GoogleFonts.robotoMono(
                          color: const Color(0xFF00FF88),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Uptime: 2d 14h 32m',
                        style: GoogleFonts.robotoMono(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildStatusItem('CPU', '45%', const Color(0xFF00D4FF)),
                const SizedBox(width: 16),
                _buildStatusItem('RAM', '67%', const Color(0xFF00FF88)),
                const SizedBox(width: 16),
                _buildStatusItem('DISK', '23%', const Color(0xFFFFD93D)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.robotoMono(
            color: Colors.grey,
            fontSize: 9,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceGauges() {
    return Consumer(
      builder: (context, ref, child) {
        final monitor = ref.watch(systemMonitorProvider);
        return GlassmorphicContainer(
          width: double.infinity,
          height: 200,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PERFORMANCE GAUGES',
                  style: GoogleFonts.orbitron(
                    color: const Color(0xFF00D4FF),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildCircularGauge('CPU', monitor.cpuUsage, const Color(0xFF00D4FF)),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildCircularGauge('MEM', monitor.memoryUsage, const Color(0xFF00FF88)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCircularGauge(String label, double value, Color color) {
    return Column(
      children: [
        Expanded(
          child: CustomPaint(
            painter: CircularGaugePainter(value, color),
            size: const Size(80, 80),
            child: Center(
              child: Text(
                '${value.toStringAsFixed(0)}%',
                style: GoogleFonts.orbitron(
                  color: color,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
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
      ],
    );
  }

  Widget _buildNetworkStatus() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
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
          const Color(0xFF9B59B6).withOpacity(0.2),
          const Color(0xFF8E44AD).withOpacity(0.1),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NETWORK STATUS',
              style: GoogleFonts.orbitron(
                color: const Color(0xFF9B59B6),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FF88),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CONNECTED',
                        style: GoogleFonts.robotoMono(
                          color: const Color(0xFF00FF88),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '192.168.1.100',
                        style: GoogleFonts.robotoMono(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '12.5 MB/s',
                      style: GoogleFonts.orbitron(
                        color: const Color(0xFF9B59B6),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'DOWN',
                      style: GoogleFonts.robotoMono(
                        color: Colors.grey,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityStatus() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 100,
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
          const Color(0xFFFFD93D).withOpacity(0.2),
          const Color(0xFFFFC107).withOpacity(0.1),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SECURITY STATUS',
              style: GoogleFonts.orbitron(
                color: const Color(0xFFFFD93D),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF00FF88),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SECURE',
                        style: GoogleFonts.robotoMono(
                          color: const Color(0xFF00FF88),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'All protocols active',
                        style: GoogleFonts.robotoMono(
                          color: Colors.grey,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '256-bit',
                      style: GoogleFonts.orbitron(
                        color: const Color(0xFFFFD93D),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'ENCRYPTION',
                      style: GoogleFonts.robotoMono(
                        color: Colors.grey,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceUsage() {
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
          const Color(0xFFFF6B6B).withOpacity(0.2),
          const Color(0xFFE74C3C).withOpacity(0.1),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'RESOURCE USAGE',
              style: GoogleFonts.orbitron(
                color: const Color(0xFFFF6B6B),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 12),
            _buildResourceBar('CPU', 45, const Color(0xFF00D4FF)),
            const SizedBox(height: 8),
            _buildResourceBar('Memory', 67, const Color(0xFF00FF88)),
            const SizedBox(height: 8),
            _buildResourceBar('Disk', 23, const Color(0xFFFFD93D)),
          ],
        ),
      ),
    );
  }

  Widget _buildResourceBar(String label, double value, Color color) {
    return Row(
      children: [
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: GoogleFonts.robotoMono(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(3),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '${value.toInt()}%',
          style: GoogleFonts.orbitron(
            color: color,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedMetrics() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 200,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ADVANCED METRICS',
              style: GoogleFonts.orbitron(
                color: const Color(0xFF00D4FF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildMetricCard('TEMP', '42°C', const Color(0xFFFF6B6B)),
                  _buildMetricCard('FAN', '1200 RPM', const Color(0xFF00FF88)),
                  _buildMetricCard('POWER', '85W', const Color(0xFFFFD93D)),
                  _buildMetricCard('UPTIME', '2d 14h', const Color(0xFF9B59B6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A).withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GoogleFonts.robotoMono(
              color: Colors.grey,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF00D4FF).withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFooterButton('REFRESH', Icons.refresh),
              _buildFooterButton('ALERTS', Icons.notifications),
              _buildFooterButton('LOGS', Icons.list_alt),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Handle button tap
      },
      child: GlassmorphicContainer(
        width: 60,
        height: 40,
        borderRadius: 8,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.3),
            const Color(0xFF16213E).withOpacity(0.2),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            const Color(0xFF333333).withOpacity(0.3),
            const Color(0xFF333333).withOpacity(0.1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF00D4FF),
              size: 16,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.robotoMono(
                fontSize: 8,
                color: const Color(0xFF00D4FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CircularGaugePainter extends CustomPainter {
  final double value;
  final Color color;

  CircularGaugePainter(this.value, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;

    // Background circle
    final backgroundPaint = Paint()
      ..color = const Color(0xFF333333)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
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
