import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/system_monitor_provider.dart';
import 'semicircle_gauge.dart';

class RightDashboard extends StatefulWidget {
  const RightDashboard({super.key});

  @override
  State<RightDashboard> createState() => _RightDashboardState();
}

class _RightDashboardState extends State<RightDashboard>
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
        color: Colors.black.withOpacity(0.3),
        border: Border(
          left: BorderSide(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  _buildSystemMetrics(),
                  const SizedBox(height: 20),
                  _buildNetworkStatus(),
                  const SizedBox(height: 20),
                  _buildPerformanceChart(),
                  const SizedBox(height: 20),
                  _buildAlerts(),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFF00D4FF).withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.monitor,
            color: Color(0xFF00D4FF),
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            'SYSTEM MONITOR',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 14,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
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
            color: Colors.black.withOpacity(0.4),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'PERFORMANCE',
                style: TextStyle(
                  color: Color(0xFF00D4FF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  SemicircleGauge(
                    value: monitor.cpuUsage,
                    maxValue: 100,
                    label: 'CPU',
                    color: const Color(0xFF00D4FF),
                    size: 50,
                  ),
                  SemicircleGauge(
                    value: monitor.memoryUsage,
                    maxValue: 100,
                    label: 'RAM',
                    color: const Color(0xFF00FF88),
                    size: 50,
                  ),
                  SemicircleGauge(
                    value: monitor.diskUsage,
                    maxValue: 100,
                    label: 'DISK',
                    color: const Color(0xFFFF6B6B),
                    size: 50,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNetworkStatus() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'NETWORK STATUS',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          _buildNetworkItem('IP Address', '192.168.1.100', const Color(0xFF00FF88)),
          _buildNetworkItem('Latency', '12ms', const Color(0xFF00FF88)),
          _buildNetworkItem('Bandwidth', '1.2 Gbps', const Color(0xFF00FF88)),
          _buildNetworkItem('Connections', '24', const Color(0xFF00FF88)),
        ],
      ),
    );
  }

  Widget _buildNetworkItem(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
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
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVITY CHART',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 80,
            child: CustomPaint(
              painter: PerformanceChartPainter(),
              size: const Size(double.infinity, 80),
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
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SYSTEM ALERTS',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          _buildAlertItem('System', 'All systems operational', const Color(0xFF00FF88)),
          _buildAlertItem('Network', 'Connection stable', const Color(0xFF00FF88)),
          _buildAlertItem('Security', 'No threats detected', const Color(0xFF00FF88)),
          _buildAlertItem('Storage', 'Disk space normal', const Color(0xFF00FF88)),
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
}

class PerformanceChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final points = [20.0, 40.0, 30.0, 25.0, 40.0, 35.0, 50.0, 15.0, 60.0, 45.0, 70.0, 30.0, 80.0, 50.0];
    
    for (int i = 0; i < points.length; i += 2) {
      final x = points[i];
      final y = points[i + 1];
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);

    // Fill area under the line
    final fillPaint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.2)
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width - 20, size.height);
    fillPath.lineTo(20, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(PerformanceChartPainter oldDelegate) => false;
}
