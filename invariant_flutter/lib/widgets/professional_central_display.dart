import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shimmer/shimmer.dart';
import '../providers/system_monitor_provider.dart';

class ProfessionalCentralDisplay extends StatefulWidget {
  final String? projectName;
  final VoidCallback onFullScreenToggle;

  const ProfessionalCentralDisplay({
    super.key,
    this.projectName,
    required this.onFullScreenToggle,
  });

  @override
  State<ProfessionalCentralDisplay> createState() => _ProfessionalCentralDisplayState();
}

class _ProfessionalCentralDisplayState extends State<ProfessionalCentralDisplay>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
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

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
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
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF00D4FF),
                      Color(0xFF0099CC),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF00D4FF).withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Colors.white,
                  size: 50,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'INVARIANT',
                style: GoogleFonts.orbitron(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF00D4FF),
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'COMMAND CENTER READY',
                style: GoogleFonts.robotoMono(
                  fontSize: 16,
                  color: const Color(0xFF00FF88),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'SELECT PROJECT FROM LEFT PANEL',
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
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
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
        ),
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
            widget.projectName!.toUpperCase(),
            style: GoogleFonts.orbitron(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00D4FF),
              letterSpacing: 2,
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FF88).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: const Color(0xFF00FF88).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  'SYSTEM ACTIVE',
                  style: GoogleFonts.robotoMono(
                    fontSize: 12,
                    color: const Color(0xFF00FF88),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: widget.onFullScreenToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D4FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
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
                      fontWeight: FontWeight.w500,
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
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          _buildSystemMetrics(),
          const SizedBox(height: 24),
          _buildPerformanceChart(),
          const SizedBox(height: 24),
          _buildActivityLog(),
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
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF333333),
              width: 1,
            ),
          ),
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
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard('CPU USAGE', monitor.cpuUsage, const Color(0xFF00D4FF)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard('MEMORY', monitor.memoryUsage, const Color(0xFF00FF88)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard('DISK', monitor.diskUsage, const Color(0xFFFFD93D)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildMetricCard('NETWORK', 12.0, const Color(0xFFFF6B6B)),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String label, double value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A0A0A),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
            '${value.toStringAsFixed(0)}%',
            style: GoogleFonts.orbitron(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Container(
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
        ],
      ),
    );
  }

  Widget _buildPerformanceChart() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PERFORMANCE CHART',
            style: GoogleFonts.orbitron(
              color: const Color(0xFF00D4FF),
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  horizontalInterval: 20,
                  verticalInterval: 1,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF333333),
                      strokeWidth: 1,
                    );
                  },
                  getDrawingVerticalLine: (value) {
                    return FlLine(
                      color: const Color(0xFF333333),
                      strokeWidth: 1,
                    );
                  },
                ),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 1,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${value.toInt()}',
                          style: GoogleFonts.robotoMono(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 20,
                      reservedSize: 40,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        return Text(
                          '${value.toInt()}%',
                          style: GoogleFonts.robotoMono(
                            color: Colors.grey,
                            fontSize: 10,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(
                    color: const Color(0xFF333333),
                    width: 1,
                  ),
                ),
                minX: 0,
                maxX: 10,
                minY: 0,
                maxY: 100,
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      const FlSpot(0, 20),
                      const FlSpot(1, 35),
                      const FlSpot(2, 45),
                      const FlSpot(3, 30),
                      const FlSpot(4, 55),
                      const FlSpot(5, 40),
                      const FlSpot(6, 65),
                      const FlSpot(7, 50),
                      const FlSpot(8, 70),
                      const FlSpot(9, 60),
                      const FlSpot(10, 45),
                    ],
                    isCurved: true,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF00D4FF),
                        Color(0xFF0099CC),
                      ],
                    ),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF00D4FF).withOpacity(0.3),
                          const Color(0xFF00D4FF).withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLog() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF333333),
          width: 1,
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 4),
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
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(8),
          bottomRight: Radius.circular(8),
        ),
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
          const SizedBox(width: 16),
          _buildControlButton('CONFIGURE', const Color(0xFFFFD93D)),
          const SizedBox(width: 16),
          _buildControlButton('MONITOR', const Color(0xFF00D4FF)),
          const SizedBox(width: 16),
          _buildControlButton('TERMINATE', const Color(0xFFFF6B6B)),
        ],
      ),
    );
  }

  Widget _buildControlButton(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: GoogleFonts.robotoMono(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
