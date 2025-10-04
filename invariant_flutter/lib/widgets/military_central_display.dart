import 'package:flutter/material.dart';

class MilitaryCentralDisplay extends StatelessWidget {
  final String? projectName;

  const MilitaryCentralDisplay({
    super.key,
    this.projectName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A),
        border: Border.all(
          color: Color(0xFF333333),
          width: 1,
        ),
      ),
      child: projectName == null ? _buildIdleState() : _buildProjectDisplay(),
    );
  }

  Widget _buildIdleState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF00D4FF).withOpacity(0.1),
              border: Border.all(
                color: const Color(0xFF00D4FF),
                width: 2,
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.play_arrow,
                color: Color(0xFF00D4FF),
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'INVARIANT',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D4FF),
              letterSpacing: 3,
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            'COMMAND CENTER READY',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF00FF88),
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'SELECT PROJECT FROM LEFT PANEL',
            style: TextStyle(
              fontSize: 12,
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
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF333333),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            projectName!.toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D4FF),
              letterSpacing: 2,
            ),
          ),
          const Text(
            'SYSTEM ACTIVE',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF00FF88),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectContent() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SYSTEM METRICS',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _buildMetricItem('CPU USAGE', '45%', const Color(0xFF00FF88)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMetricItem('MEMORY', '67%', const Color(0xFFFFD93D)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMetricItem('DISK', '23%', const Color(0xFF00FF88)),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _buildMetricItem('NETWORK', '12%', const Color(0xFF00FF88)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: double.parse(value.replaceAll('%', '')) / 100,
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityLog() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIVITY LOG',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          _buildLogEntry('14:32:15', 'SYSTEM INITIALIZED', const Color(0xFF00FF88)),
          _buildLogEntry('14:32:18', 'PROJECT LOADED', const Color(0xFF00FF88)),
          _buildLogEntry('14:32:22', 'CONNECTIONS ESTABLISHED', const Color(0xFF00FF88)),
          _buildLogEntry('14:32:25', 'MONITORING ACTIVE', const Color(0xFF00FF88)),
          _buildLogEntry('14:32:28', 'ALL SYSTEMS OPERATIONAL', const Color(0xFF00FF88)),
        ],
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
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 10,
            ),
          ),
          const SizedBox(width: 15),
          Text(
            message,
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

  Widget _buildDataVisualization() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'DATA VISUALIZATION',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            height: 100,
            child: CustomPaint(
              painter: DataChartPainter(),
              size: const Size(double.infinity, 100),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectControls() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          top: BorderSide(
            color: Color(0xFF333333),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton('LAUNCH', const Color(0xFF00FF88)),
          const SizedBox(width: 20),
          _buildControlButton('CONFIGURE', const Color(0xFFFFD93D)),
          const SizedBox(width: 20),
          _buildControlButton('MONITOR', const Color(0xFF00D4FF)),
          const SizedBox(width: 20),
          _buildControlButton('TERMINATE', const Color(0xFFFF6B6B)),
        ],
      ),
    );
  }

  Widget _buildControlButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class DataChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF)
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
      ..color = const Color(0xFF00D4FF).withOpacity(0.1)
      ..style = PaintingStyle.fill;

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(DataChartPainter oldDelegate) => false;
}
