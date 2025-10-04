import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shimmer/shimmer.dart';

class CuttingEdgeLeftPanel extends StatefulWidget {
  final Function(String) onProjectSelect;
  final String? selectedProject;

  const CuttingEdgeLeftPanel({
    super.key,
    required this.onProjectSelect,
    this.selectedProject,
  });

  @override
  State<CuttingEdgeLeftPanel> createState() => _CuttingEdgeLeftPanelState();
}

class _CuttingEdgeLeftPanelState extends State<CuttingEdgeLeftPanel>
    with TickerProviderStateMixin {
  late AnimationController _listController;
  final List<Map<String, dynamic>> projects = [
    {
      'name': 'Project Alpha',
      'status': 'active',
      'version': '2.1.4',
      'description': 'Advanced AI Agent System',
      'icon': Icons.psychology,
      'color': const Color(0xFF00D4FF),
    },
    {
      'name': 'Project Beta',
      'status': 'standby',
      'version': '1.8.2',
      'description': 'Neural Network Processor',
      'icon': Icons.memory,
      'color': const Color(0xFF00FF88),
    },
    {
      'name': 'Project Gamma',
      'status': 'maintenance',
      'version': '3.0.1',
      'description': 'Quantum Computing Interface',
      'icon': Icons.auto_awesome,
      'color': const Color(0xFFFFD93D),
    },
    {
      'name': 'Project Delta',
      'status': 'offline',
      'version': '0.9.7',
      'description': 'Holographic Display System',
      'icon': Icons.visibility,
      'color': const Color(0xFFFF6B6B),
    },
    {
      'name': 'Project Epsilon',
      'status': 'active',
      'version': '4.2.0',
      'description': 'Blockchain Security Protocol',
      'icon': Icons.security,
      'color': const Color(0xFF9B59B6),
    },
  ];

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      child: GlassmorphicContainer(
        width: double.infinity,
        height: double.infinity,
        borderRadius: 12,
        blur: 20,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.8),
            const Color(0xFF16213E).withOpacity(0.6),
          ],
        ),
        borderGradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF00D4FF).withOpacity(0.3),
            const Color(0xFF0099CC).withOpacity(0.1),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _buildProjectList(),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PROJECTS',
            style: GoogleFonts.orbitron(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF00D4FF),
              letterSpacing: 2,
            ),
          ).animate().fadeIn(duration: 800.ms).slideX(begin: -0.3, end: 0),
          const SizedBox(height: 8),
          Text(
            '${projects.length} SYSTEMS ONLINE',
            style: GoogleFonts.robotoMono(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(duration: 1000.ms, delay: 200.ms),
          const SizedBox(height: 16),
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF00D4FF).withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectList() {
    return PageView.builder(
      controller: PageController(viewportFraction: 0.9),
      itemCount: (projects.length / 2).ceil(),
      itemBuilder: (context, pageIndex) {
        final startIndex = pageIndex * 2;
        final endIndex = (startIndex + 2).clamp(0, projects.length);
        final pageProjects = projects.sublist(startIndex, endIndex);
        
        return AnimatedBuilder(
          animation: _listController,
          builder: (context, child) {
            final animationValue = Curves.easeOutCubic.transform(
              (_listController.value - pageIndex * 0.2).clamp(0.0, 1.0),
            );
            
            return Transform.translate(
              offset: Offset(0, 30 * (1 - animationValue)),
              child: Opacity(
                opacity: animationValue,
                child: Column(
                  children: pageProjects.map((project) {
                    final isSelected = widget.selectedProject == project['name'];
                    return _buildProjectCard(project, isSelected);
                  }).toList(),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: GestureDetector(
        onTap: () => widget.onProjectSelect(project['name']),
        child: GlassmorphicContainer(
          width: double.infinity,
          height: 70,
          borderRadius: 12,
          blur: 15,
          alignment: Alignment.center,
          border: 1,
          linearGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    project['color'].withOpacity(0.2),
                    project['color'].withOpacity(0.1),
                  ]
                : [
                    const Color(0xFF1A1A2E).withOpacity(0.3),
                    const Color(0xFF16213E).withOpacity(0.2),
                  ],
          ),
          borderGradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [
                    project['color'].withOpacity(0.5),
                    project['color'].withOpacity(0.2),
                  ]
                : [
                    const Color(0xFF333333).withOpacity(0.3),
                    const Color(0xFF333333).withOpacity(0.1),
                  ],
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildProjectIcon(project),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildProjectInfo(project),
                ),
                _buildProjectStatus(project),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProjectIcon(Map<String, dynamic> project) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: project['color'].withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: project['color'].withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Icon(
        project['icon'],
        color: project['color'],
        size: 20,
      ),
    );
  }

  Widget _buildProjectInfo(Map<String, dynamic> project) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          project['name'],
          style: GoogleFonts.orbitron(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          project['description'],
          style: GoogleFonts.robotoMono(
            fontSize: 9,
            color: Colors.grey,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 1),
        Text(
          'v${project['version']}',
          style: GoogleFonts.robotoMono(
            fontSize: 8,
            color: project['color'],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectStatus(Map<String, dynamic> project) {
    final status = project['status'];
    Color statusColor;
    String statusText;
    
    switch (status) {
      case 'active':
        statusColor = const Color(0xFF00FF88);
        statusText = 'ONLINE';
        break;
      case 'standby':
        statusColor = const Color(0xFFFFD93D);
        statusText = 'STANDBY';
        break;
      case 'maintenance':
        statusColor = const Color(0xFFFF6B6B);
        statusText = 'MAINT';
        break;
      case 'offline':
        statusColor = Colors.grey;
        statusText = 'OFFLINE';
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'UNKNOWN';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: statusColor.withOpacity(0.5),
                blurRadius: 4,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          statusText,
          style: GoogleFonts.robotoMono(
            fontSize: 8,
            color: statusColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  const Color(0xFF00D4FF).withOpacity(0.5),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildFooterButton('REFRESH', Icons.refresh),
              _buildFooterButton('ADD', Icons.add),
              _buildFooterButton('SETTINGS', Icons.settings),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButton(String label, IconData icon) {
    return GestureDetector(
      onTap: () {
        // Handle button tap
      },
      child: GlassmorphicContainer(
        width: 60,
        height: 40,
        borderRadius: 8,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            const Color(0xFF1A1A2E).withOpacity(0.3),
            const Color(0xFF16213E).withOpacity(0.2),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            const Color(0xFF333333).withOpacity(0.3),
            const Color(0xFF333333).withOpacity(0.1),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: const Color(0xFF00D4FF),
              size: 16,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: GoogleFonts.robotoMono(
                fontSize: 8,
                color: const Color(0xFF00D4FF),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
