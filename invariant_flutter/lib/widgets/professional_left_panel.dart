import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_monitor_provider.dart';

class ProfessionalLeftPanel extends StatelessWidget {
  final Function(String) onProjectSelect;
  final String? selectedProject;

  const ProfessionalLeftPanel({
    super.key,
    required this.onProjectSelect,
    this.selectedProject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        border: Border(
          right: BorderSide(
            color: Color(0xFF333333),
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
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A),
        border: Border(
          bottom: BorderSide(
            color: Color(0xFF333333),
            width: 1,
          ),
        ),
      ),
      child: const Row(
        children: [
          Icon(
            Icons.rocket_launch,
            color: Color(0xFF00D4FF),
            size: 16,
          ),
          SizedBox(width: 8),
          Text(
            'PROJECT CONTROL',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
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
        'color': const Color(0xFF00FF88),
      },
      {
        'name': 'PROJECT-002',
        'description': 'Data Analytics',
        'status': 'STANDBY',
        'color': const Color(0xFF00D4FF),
      },
      {
        'name': 'PROJECT-003',
        'description': 'Security Framework',
        'status': 'ACTIVE',
        'color': const Color(0xFF00FF88),
      },
      {
        'name': 'PROJECT-004',
        'description': 'Android AI Agent',
        'status': 'ACTIVE',
        'color': const Color(0xFF00FF88),
      },
      {
        'name': 'PROJECT-005',
        'description': 'Web Dashboard',
        'status': 'DEVELOPMENT',
        'color': const Color(0xFFFFD93D),
      },
      {
        'name': 'PROJECT-006',
        'description': 'API Gateway',
        'status': 'MAINTENANCE',
        'color': const Color(0xFFFF6B6B),
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return _buildProjectItem(project);
      },
    );
  }

  Widget _buildProjectItem(Map<String, dynamic> project) {
    final color = project['color'] as Color;
    final status = project['status'] as String;
    final isSelected = selectedProject == project['name'];

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected 
            ? color.withOpacity(0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isSelected 
              ? color.withOpacity(0.5)
              : Colors.transparent,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onProjectSelect(project['name'] as String),
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
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: color,
                          fontSize: 8,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  project['description'] as String,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSystemStatus() {
    return Consumer<SystemMonitorProvider>(
      builder: (context, monitor, child) {
        return Container(
          padding: const EdgeInsets.all(12),
          decoration: const BoxDecoration(
            color: Color(0xFF2A2A2A),
            border: Border(
              top: BorderSide(
                color: Color(0xFF333333),
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
                  color: Color(0xFF00D4FF),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              _buildStatusItem('NETWORK', 'ONLINE', const Color(0xFF00FF88)),
              _buildStatusItem('SECURITY', 'SECURE', const Color(0xFF00FF88)),
              _buildStatusItem('STORAGE', 'NORMAL', const Color(0xFF00FF88)),
              _buildStatusItem('POWER', 'STABLE', const Color(0xFF00FF88)),
              const SizedBox(height: 8),
              _buildSystemMetrics(monitor),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusItem(String label, String status, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSystemMetrics(SystemMonitorProvider monitor) {
    return Column(
      children: [
        _buildMetricRow('CPU', monitor.cpuUsage, const Color(0xFF00D4FF)),
        _buildMetricRow('RAM', monitor.memoryUsage, const Color(0xFF00FF88)),
        _buildMetricRow('DISK', monitor.diskUsage, const Color(0xFFFFD93D)),
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
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
