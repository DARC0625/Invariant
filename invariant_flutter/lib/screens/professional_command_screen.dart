import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_monitor_provider.dart';
import '../widgets/professional_left_panel.dart';
import '../widgets/professional_central_display.dart';
import '../widgets/professional_right_panel.dart';

class ProfessionalCommandScreen extends StatefulWidget {
  const ProfessionalCommandScreen({super.key});

  @override
  State<ProfessionalCommandScreen> createState() => _ProfessionalCommandScreenState();
}

class _ProfessionalCommandScreenState extends State<ProfessionalCommandScreen> {
  String? selectedProject;
  bool showVisionSystem = false;
  bool isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF000000),
            ],
          ),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Row(
                children: [
                  // Left Panel
                  if (!isFullScreen)
                    Container(
                      width: 300,
                      child: ProfessionalLeftPanel(
                        onProjectSelect: (projectName) {
                          setState(() {
                            selectedProject = projectName;
                          });
                        },
                        selectedProject: selectedProject,
                      ),
                    ),
                  
                  // Central Display
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.all(4),
                      child: ProfessionalCentralDisplay(
                        projectName: selectedProject,
                        onFullScreenToggle: () {
                          setState(() {
                            isFullScreen = !isFullScreen;
                          });
                        },
                      ),
                    ),
                  ),
                  
                  // Right Panel
                  if (!isFullScreen)
                    Container(
                      width: 300,
                      child: const ProfessionalRightPanel(),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFF333333),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF00D4FF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Color(0xFF00D4FF),
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'INVARIANT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF00D4FF),
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'v1.1',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              if (selectedProject != null) ...[
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
                    'ACTIVE: $selectedProject',
                    style: const TextStyle(
                      color: Color(0xFF00FF88),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      showVisionSystem = !showVisionSystem;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: showVisionSystem 
                          ? const Color(0xFF00D4FF).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF00D4FF).withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'VISION',
                      style: TextStyle(
                        color: showVisionSystem 
                            ? const Color(0xFF00D4FF)
                            : Colors.grey,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedProject = null;
                      showVisionSystem = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'DISCONNECT',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'SYSTEM READY',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
