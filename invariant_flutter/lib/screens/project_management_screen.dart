import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/system_monitor_provider.dart';
import '../widgets/semicircle_gauge.dart';
import '../widgets/project_card.dart';

class ProjectManagementScreen extends StatefulWidget {
  const ProjectManagementScreen({super.key});

  @override
  State<ProjectManagementScreen> createState() => _ProjectManagementScreenState();
}

class _ProjectManagementScreenState extends State<ProjectManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 300));
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
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                children: [
                  _buildHeader(),
                  _buildCompactSystemStatus(),
                  Expanded(
                    child: _buildProjectManagement(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'INVARIANT',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D4FF),
                  letterSpacing: 3,
                ),
              ),
              const Text(
                'Project Management Hub',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'v1.1',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              const SizedBox(width: 15),
              IconButton(
                onPressed: () {
                  // Settings or menu
                },
                icon: const Icon(
                  Icons.settings,
                  color: Color(0xFF00D4FF),
                  size: 24,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactSystemStatus() {
    return Consumer<SystemMonitorProvider>(
      builder: (context, monitor, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.3),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFF00D4FF).withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SemicircleGauge(
                value: monitor.cpuUsage,
                maxValue: 100,
                label: 'CPU',
                color: const Color(0xFF00D4FF),
                size: 60,
              ),
              SemicircleGauge(
                value: monitor.memoryUsage,
                maxValue: 100,
                label: 'RAM',
                color: const Color(0xFF00FF88),
                size: 60,
              ),
              SemicircleGauge(
                value: monitor.diskUsage,
                maxValue: 100,
                label: 'Disk',
                color: const Color(0xFFFF6B6B),
                size: 60,
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey.withOpacity(0.3),
              ),
              Column(
                children: [
                  Text(
                    monitor.ipAddress,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    monitor.uptime,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProjectManagement() {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROJECTS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D4FF),
                  letterSpacing: 2,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // Add new project
                },
                icon: const Icon(Icons.add, size: 16),
                label: const Text('New Project'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00D4FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: _buildProjectGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectGrid() {
    final projects = [
      {
        'name': 'Project 1',
        'description': 'AI Agent System',
        'status': 'Active',
        'version': 'v2.1.3',
        'color': const Color(0xFF00D4FF),
        'icon': Icons.rocket_launch,
        'lastUpdate': '2 hours ago',
      },
      {
        'name': 'Project 2',
        'description': 'Data Analytics Platform',
        'status': 'Inactive',
        'version': 'v1.5.2',
        'color': const Color(0xFF00FF88),
        'icon': Icons.analytics,
        'lastUpdate': '1 day ago',
      },
      {
        'name': 'Project 3',
        'description': 'Security Framework',
        'status': 'Active',
        'version': 'v3.0.1',
        'color': const Color(0xFFFF6B6B),
        'icon': Icons.security,
        'lastUpdate': '30 minutes ago',
      },
      {
        'name': 'Project 4',
        'description': 'Android AI Agent',
        'status': 'Active',
        'version': 'v1.2.0',
        'color': const Color(0xFFFFD93D),
        'icon': Icons.android,
        'lastUpdate': '5 minutes ago',
      },
      {
        'name': 'Project 5',
        'description': 'Web Dashboard',
        'status': 'Development',
        'version': 'v0.8.4',
        'color': const Color(0xFF9C27B0),
        'icon': Icons.web,
        'lastUpdate': '3 hours ago',
      },
      {
        'name': 'Project 6',
        'description': 'API Gateway',
        'status': 'Maintenance',
        'version': 'v2.3.1',
        'color': const Color(0xFFFF9800),
        'icon': Icons.api,
        'lastUpdate': '1 week ago',
      },
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.1,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectCard(
          project: project,
          index: index,
        );
      },
    );
  }
}
