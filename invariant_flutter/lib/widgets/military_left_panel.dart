import 'package:flutter/material.dart';

class MilitaryLeftPanel extends StatelessWidget {
  final Function(String) onProjectSelect;

  const MilitaryLeftPanel({
    super.key,
    required this.onProjectSelect,
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
      padding: const EdgeInsets.symmetric(horizontal: 15),
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
          Text(
            'PROJECT CONTROL',
            style: TextStyle(
              color: Color(0xFF00D4FF),
              fontSize: 12,
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
        'name': 'PROJECT-001',
        'description': 'AI Agent System',
        'status': 'ACTIVE',
        'color': const Color(0xFF00FF88),
        'lastUpdate': '02:34:15',
      },
      {
        'name': 'PROJECT-002',
        'description': 'Data Analytics',
        'status': 'STANDBY',
        'color': const Color(0xFF00D4FF),
        'lastUpdate': '01:23:45',
      },
      {
        'name': 'PROJECT-003',
        'description': 'Security Framework',
        'status': 'ACTIVE',
        'color': const Color(0xFF00FF88),
        'lastUpdate': '00:45:12',
      },
      {
        'name': 'PROJECT-004',
        'description': 'Android AI Agent',
        'status': 'ACTIVE',
        'color': const Color(0xFF00FF88),
        'lastUpdate': '00:12:33',
      },
      {
        'name': 'PROJECT-005',
        'description': 'Web Dashboard',
        'status': 'DEVELOPMENT',
        'color': const Color(0xFFFFD93D),
        'lastUpdate': '03:15:22',
      },
      {
        'name': 'PROJECT-006',
        'description': 'API Gateway',
        'status': 'MAINTENANCE',
        'color': const Color(0xFFFF6B6B),
        'lastUpdate': '24:00:00',
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

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(4),
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
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
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
                          fontWeight: FontWeight.bold,
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
                const SizedBox(height: 4),
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

  Widget _buildSystemStatus() {
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
              fontWeight: FontWeight.bold,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatusItem('NETWORK', 'ONLINE', const Color(0xFF00FF88)),
          _buildStatusItem('SECURITY', 'SECURE', const Color(0xFF00FF88)),
          _buildStatusItem('STORAGE', 'NORMAL', const Color(0xFF00FF88)),
          _buildStatusItem('POWER', 'STABLE', const Color(0xFF00FF88)),
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
