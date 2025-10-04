import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/system_monitor_provider.dart';
import '../widgets/project_display_screen.dart';
import '../widgets/project_selector.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String? selectedProject;
  bool isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
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

    _startAnimations();
  }

  void _startAnimations() async {
    await Future.delayed(const Duration(milliseconds: 200));
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
                  _buildTopBar(),
                  Expanded(
                    child: _buildMainContent(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF00D4FF).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Text(
                'INVARIANT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D4FF),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'v1.1',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (selectedProject != null) ...[
                Text(
                  'Displaying: $selectedProject',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 15),
                IconButton(
                  onPressed: () {
                    setState(() {
                      isFullScreen = !isFullScreen;
                    });
                  },
                  icon: Icon(
                    isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    color: const Color(0xFF00D4FF),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: () {
                    setState(() {
                      selectedProject = null;
                      isFullScreen = false;
                    });
                  },
                  icon: const Icon(
                    Icons.close,
                    color: Colors.red,
                  ),
                ),
              ] else ...[
                const Text(
                  'Select a project to display',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    if (selectedProject == null) {
      return _buildProjectSelector();
    } else {
      return _buildProjectDisplay();
    }
  }

  Widget _buildProjectSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'PROJECT DISPLAY CENTER',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF00D4FF),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Select a project to display on the main screen',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 30),
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
        'color': const Color(0xFF00D4FF),
        'icon': Icons.rocket_launch,
        'hasDisplay': true,
      },
      {
        'name': 'Project 2',
        'description': 'Data Analytics Platform',
        'status': 'Inactive',
        'color': const Color(0xFF00FF88),
        'icon': Icons.analytics,
        'hasDisplay': true,
      },
      {
        'name': 'Project 3',
        'description': 'Security Framework',
        'status': 'Active',
        'color': const Color(0xFFFF6B6B),
        'icon': Icons.security,
        'hasDisplay': true,
      },
      {
        'name': 'Project 4',
        'description': 'Android AI Agent',
        'status': 'Active',
        'color': const Color(0xFFFFD93D),
        'icon': Icons.android,
        'hasDisplay': true,
      },
      {
        'name': 'Project 5',
        'description': 'Web Dashboard',
        'status': 'Development',
        'color': const Color(0xFF9C27B0),
        'icon': Icons.web,
        'hasDisplay': false,
      },
      {
        'name': 'Project 6',
        'description': 'API Gateway',
        'status': 'Maintenance',
        'color': const Color(0xFFFF9800),
        'icon': Icons.api,
        'hasDisplay': false,
      },
    ];

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
        childAspectRatio: 1.2,
      ),
      itemCount: projects.length,
      itemBuilder: (context, index) {
        final project = projects[index];
        return ProjectSelector(
          project: project,
          index: index,
          onSelect: (projectName) {
            setState(() {
              selectedProject = projectName;
            });
          },
        );
      },
    );
  }

  Widget _buildProjectDisplay() {
    return Container(
      margin: isFullScreen ? EdgeInsets.zero : const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: isFullScreen ? BorderRadius.zero : BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFF00D4FF).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: ProjectDisplayScreen(
        projectName: selectedProject!,
        isFullScreen: isFullScreen,
      ),
    );
  }
}
