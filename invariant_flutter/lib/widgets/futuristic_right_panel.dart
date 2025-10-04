import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_monitor_provider.dart';

class FuturisticRightPanel extends StatefulWidget {
  const FuturisticRightPanel({super.key});

  @override
  State<FuturisticRightPanel> createState() => _FuturisticRightPanelState();
}

class _FuturisticRightPanelState extends State<FuturisticRightPanel>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _scanController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF00FFFF).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  _buildSystemMetrics(),
                  const SizedBox(height: 15),
                  _buildNetworkStatus(),
                  const SizedBox(height: 15),
                  _buildPerformanceChart(),
                  const SizedBox(height: 15),
                  _buildAlerts(),
                  const SizedBox(height: 15),
                  _buildThreatAssessment(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 15),
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
        children: [
          const Icon(
            Icons.monitor,
            color: Color(0xFF00FFFF),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Text(
            'SYSTEM MONITOR',
            style: TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const Spacer(),
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF00).withOpacity(0.8 + _pulseController.value * 0.2),
                  shape: BoxShape.circle,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMetrics() {
    return Consumer<SystemMonitorProvider>(
      builder: (context, monitor, child) {
        return Container(
          padding: const EdgeInsets.all(15),
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
                'PERFORMANCE',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 15),
              _buildMetricRow('CPU', monitor.cpuUsage, const Color(0xFF00FFFF)),
              _buildMetricRow('RAM', monitor.memoryUsage, const Color(0xFF00FF00)),
              _buildMetricRow('DISK', monitor.diskUsage, const Color(0xFFFFD700)),
              _buildMetricRow('NET', 12.0, const Color(0xFFFF6B6B)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.2),
                borderRadius: BorderRadius.circular(2),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: value / 100,
                child: Container(
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${value.toStringAsFixed(0)}%',
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStatus() {
    return Container(
      padding: const EdgeInsets.all(15),
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
            'NETWORK STATUS',
            style: TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          _buildNetworkItem('IP ADDRESS', '192.168.1.100', const Color(0xFF00FF00)),
          _buildNetworkItem('LATENCY', '12ms', const Color(0xFF00FF00)),
          _buildNetworkItem('BANDWIDTH', '1.2 Gbps', const Color(0xFF00FF00)),
          _buildNetworkItem('CONNECTIONS', '24', const Color(0xFF00FF00)),
        ],
      ),
    );
  }

  Widget _buildNetworkItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(15),
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
            'ACTIVITY CHART',
            style: TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 80,
            child: AnimatedBuilder(
              animation: _scanController,
              builder: (context, child) {
                return CustomPaint(
                  painter: PerformanceChartPainter(_scanController.value),
                  size: const Size(double.infinity, 80),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlerts() {
    return Container(
      padding: const EdgeInsets.all(15),
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
            'SYSTEM ALERTS',
            style: TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          _buildAlertItem('SYSTEM', 'All systems operational', const Color(0xFF00FF00)),
          _buildAlertItem('NETWORK', 'Connection stable', const Color(0xFF00FF00)),
          _buildAlertItem('SECURITY', 'No threats detected', const Color(0xFF00FF00)),
          _buildAlertItem('STORAGE', 'Disk space normal', const Color(0xFF00FF00)),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String category, String message, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
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
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$category: $message',
              style: TextStyle(
                color: color,
                fontSize: 9,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThreatAssessment() {
    return Container(
      padding: const EdgeInsets.all(15),
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
            'THREAT ASSESSMENT',
            style: TextStyle(
              color: Color(0xFF00FFFF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          _buildThreatItem('MALWARE', 'NONE DETECTED', const Color(0xFF00FF00)),
          _buildThreatItem('INTRUSION', 'NONE DETECTED', const Color(0xFF00FF00)),
          _buildThreatItem('DATA BREACH', 'NONE DETECTED', const Color(0xFF00FF00)),
          _buildThreatItem('UNAUTHORIZED ACCESS', 'NONE DETECTED', const Color(0xFF00FF00)),
        ],
      ),
    );
  }

  Widget _buildThreatItem(String threat, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            threat,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 9,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              color: color,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

class PerformanceChartPainter extends CustomPainter {
  final double animation;

  PerformanceChartPainter(this.animation);

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
  bool shouldRepaint(PerformanceChartPainter oldDelegate) => oldDelegate.animation != animation;
}
