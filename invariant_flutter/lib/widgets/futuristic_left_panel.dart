import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_monitor_provider.dart';

class FuturisticLeftPanel extends StatefulWidget {
  final Function(String) onProjectSelect;
  final String? selectedProject;

  const FuturisticLeftPanel({
    super.key,
    required this.onProjectSelect,
    this.selectedProject,
  });

  @override
  State<FuturisticLeftPanel> createState() => _FuturisticLeftPanelState();
}

class _FuturisticLeftPanelState extends State<FuturisticLeftPanel>
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
        color: Colors.black.withOpacity(0.7),
        border: Border(
          right: BorderSide(
            color: const Color(0xFF00FFFF).withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _buildProjectList(),
          ),
          _buildSystemStatus(),
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
            Icons.rocket_launch,
            color: Color(0xFF00FFFF),
            size: 20,
          ),
          const SizedBox(width: 10),
          const Text(
            'PROJECT CONTROL',
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

  Widget _buildProjectList() {
    final projects = [
      {
        'name': 'PROJECT-001',
        'description': 'AI Agent System',
        'status': 'ACTIVE',
        'color': const Color(0xFF00FF00),
        'lastUpdate': '02:34:15',
        'cpu': 45,
        'memory': 67,
        'network': 12,
      },
      {
        'name': 'PROJECT-002',
        'description': 'Data Analytics',
        'status': 'STANDBY',
        'color': const Color(0xFF00FFFF),
        'lastUpdate': '01:23:45',
        'cpu': 23,
        'memory': 45,
        'network': 8,
      },
      {
        'name': 'PROJECT-003',
        'description': 'Security Framework',
        'status': 'ACTIVE',
        'color': const Color(0xFF00FF00),
        'lastUpdate': '00:45:12',
        'cpu': 78,
        'memory': 89,
        'network': 15,
      },
      {
        'name': 'PROJECT-004',
        'description': 'Android AI Agent',
        'status': 'ACTIVE',
        'color': const Color(0xFF00FF00),
        'lastUpdate': '00:12:33',
        'cpu': 56,
        'memory': 72,
        'network': 22,
      },
      {
        'name': 'PROJECT-005',
        'description': 'Web Dashboard',
        'status': 'DEVELOPMENT',
        'color': const Color(0xFFFFD700),
        'lastUpdate': '03:15:22',
        'cpu': 34,
        'memory': 58,
        'network': 5,
      },
      {
        'name': 'PROJECT-006',
        'description': 'API Gateway',
        'status': 'MAINTENANCE',
        'color': const Color(0xFFFF6B6B),
        'lastUpdate': '24:00:00',
        'cpu': 12,
        'memory': 23,
        'network': 3,
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectItem(project, index);
      },
    );
  }

  Widget _buildProjectItem(Map<String, dynamic> project, int index) {
    final color = project['color'] as Color;
    final status = project['status'] as String;
    final isSelected = widget.selectedProject == project['name'];

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: isSelected 
            ? color.withOpacity(0.2)
            : Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isSelected 
              ? color.withOpacity(0.8)
              : color.withOpacity(0.3),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected ? [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => widget.onProjectSelect(project['name'] as String),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      project['name'] as String,
                      style: TextStyle(
                        color: isSelected ? color : Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: color,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  project['description'] as String,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 8),
                _buildProjectMetrics(project),
                const SizedBox(height: 6),
                Text(
                  'LAST UPDATE: ${project['lastUpdate']}',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectMetrics(Map<String, dynamic> project) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricBar('CPU', project['cpu'] as int, const Color(0xFF00FFFF)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricBar('RAM', project['memory'] as int, const Color(0xFF00FF00)),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildMetricBar('NET', project['network'] as int, const Color(0xFFFFD700)),
        ),
      ],
    );
  }

  Widget _buildMetricBar(String label, int value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 8,
          ),
        ),
        const SizedBox(height: 2),
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
        Text(
          '$value%',
          style: TextStyle(
            color: color,
            fontSize: 8,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemStatus() {
    return Consumer<SystemMonitorProvider>(
      builder: (context, monitor, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.8),
            border: Border(
              top: BorderSide(
                color: const Color(0xFF00FFFF).withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'SYSTEM STATUS',
                style: TextStyle(
                  color: Color(0xFF00FFFF),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 10),
              _buildStatusItem('NETWORK', 'ONLINE', const Color(0xFF00FF00)),
              _buildStatusItem('SECURITY', 'SECURE', const Color(0xFF00FF00)),
              _buildStatusItem('STORAGE', 'NORMAL', const Color(0xFF00FF00)),
              _buildStatusItem('POWER', 'STABLE', const Color(0xFF00FF00)),
              const SizedBox(height: 10),
              _buildSystemMetrics(monitor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
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
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2 + _pulseController.value * 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: color,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMetrics(SystemMonitorProvider monitor) {
    return Column(
      children: [
        _buildMetricRow('CPU', monitor.cpuUsage, const Color(0xFF00FFFF)),
        _buildMetricRow('RAM', monitor.memoryUsage, const Color(0xFF00FF00)),
        _buildMetricRow('DISK', monitor.diskUsage, const Color(0xFFFFD700)),
      ],
    );
  }

  Widget _buildMetricRow(String label, double value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 9,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 3,
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
          const SizedBox(width: 8),
          Text(
            '${value.toStringAsFixed(0)}%',
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
