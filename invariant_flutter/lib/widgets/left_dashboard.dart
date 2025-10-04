import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class LeftDashboard extends StatefulWidget {
  final Function(String) onProjectSelect;

  const LeftDashboard({
    super.key,
    required this.onProjectSelect,
  });

  @override
  State<LeftDashboard> createState() => _LeftDashboardState();
}

class _LeftDashboardState extends State<LeftDashboard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          right: BorderSide(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
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
            Icons.rocket_launch,
            color: Color(0xFF00D4FF),
            size: 20,
          ),
          SizedBox(width: 10),
          Text(
            'PROJECT CONTROL',
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

  Widget _buildProjectList() {
    final projects = [
      {
        'name': 'Project 1',
        'description': 'AI Agent System',
        'status': 'Active',
        'color': const Color(0xFF00D4FF),
        'icon': Icons.rocket_launch,
        'lastUpdate': '2 min ago',
      },
      {
        'name': 'Project 2',
        'description': 'Data Analytics',
        'status': 'Standby',
        'color': const Color(0xFF00FF88),
        'icon': Icons.analytics,
        'lastUpdate': '1 hour ago',
      },
      {
        'name': 'Project 3',
        'description': 'Security Framework',
        'status': 'Active',
        'color': const Color(0xFFFF6B6B),
        'icon': Icons.security,
        'lastUpdate': '5 min ago',
      },
      {
        'name': 'Project 4',
        'description': 'Android AI Agent',
        'status': 'Active',
        'color': const Color(0xFFFFD93D),
        'icon': Icons.android,
        'lastUpdate': '30 sec ago',
      },
      {
        'name': 'Project 5',
        'description': 'Web Dashboard',
        'status': 'Development',
        'color': const Color(0xFF9C27B0),
        'icon': Icons.web,
        'lastUpdate': '3 hours ago',
      },
      {
        'name': 'Project 6',
        'description': 'API Gateway',
        'status': 'Maintenance',
        'color': const Color(0xFFFF9800),
        'icon': Icons.api,
        'lastUpdate': '1 day ago',
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(10),
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
    
    Color statusColor;
    switch (status.toLowerCase()) {
      case 'active':
        statusColor = const Color(0xFF00FF88);
        break;
      case 'standby':
        statusColor = const Color(0xFF00D4FF);
        break;
      case 'development':
        statusColor = const Color(0xFFFFD93D);
        break;
      case 'maintenance':
        statusColor = const Color(0xFFFF6B6B);
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => widget.onProjectSelect(project['name'] as String),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Container(
                  width: 35,
                  height: 35,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Icon(
                    project['icon'] as IconData,
                    color: color,
                    size: 18,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project['name'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        project['description'] as String,
                        style: const TextStyle(
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
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      project['lastUpdate'] as String,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 8,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: 400.ms,
      delay: (index * 100).ms,
    ).slideX(
      begin: -0.3,
      end: 0,
      duration: 400.ms,
      delay: (index * 100).ms,
    );
  }

  Widget _buildSystemStatus() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF00D4FF).withOpacity(0.3),
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
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          _buildStatusItem('Network', 'ONLINE', const Color(0xFF00FF88)),
          _buildStatusItem('Security', 'SECURE', const Color(0xFF00FF88)),
          _buildStatusItem('Storage', 'NORMAL', const Color(0xFF00FF88)),
          _buildStatusItem('Power', 'STABLE', const Color(0xFF00FF88)),
        ],
      ),
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
                    fontSize: 8,
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
}
