import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_monitor_provider.dart';
import '../widgets/futuristic_left_panel.dart';
import '../widgets/futuristic_central_display.dart';
import '../widgets/futuristic_right_panel.dart';
import '../widgets/futuristic_vision_display.dart';

class FuturisticCommandScreen extends StatefulWidget {
  const FuturisticCommandScreen({super.key});

  @override
  State<FuturisticCommandScreen> createState() => _FuturisticCommandScreenState();
}

class _FuturisticCommandScreenState extends State<FuturisticCommandScreen> {
  String? selectedProject;
  bool showVisionSystem = false;
  bool isFullScreen = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
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
                      width: 320,
                      child: FuturisticLeftPanel(
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
                      margin: const EdgeInsets.all(8),
                      child: showVisionSystem 
                          ? FuturisticVisionDisplay()
                          : FuturisticCentralDisplay(
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
                      width: 320,
                      child: const FuturisticRightPanel(),
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
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 20),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF00FFFF).withOpacity(0.5),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.rocket_launch,
                  color: Color(0xFF00FFFF),
                  size: 20,
                ),
              ),
              const SizedBox(width: 15),
              const Text(
                'INVARIANT',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00FFFF),
                  letterSpacing: 3,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF00FFFF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFF00FFFF).withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Text(
                  'v1.1',
                  style: TextStyle(
                    color: Color(0xFF00FFFF),
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF00).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFF00FF00).withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    'ACTIVE: $selectedProject',
                    style: const TextStyle(
                      color: Color(0xFF00FF00),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 15),
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
                          ? const Color(0xFF00FFFF).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFF00FFFF).withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'VISION',
                      style: TextStyle(
                        color: showVisionSystem 
                            ? const Color(0xFF00FFFF)
                            : Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: Colors.red.withOpacity(0.5),
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'DISCONNECT',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.grey.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'SYSTEM READY',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
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
