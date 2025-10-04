import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/system_monitor_provider.dart';
import '../widgets/military_left_panel.dart';
import '../widgets/military_central_display.dart';
import '../widgets/military_right_panel.dart';

class MilitaryCommandScreen extends StatefulWidget {
  const MilitaryCommandScreen({super.key});

  @override
  State<MilitaryCommandScreen> createState() => _MilitaryCommandScreenState();
}

class _MilitaryCommandScreenState extends State<MilitaryCommandScreen> {
  String? selectedProject;
  bool showVisionSystem = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Row(
              children: [
                // Left Panel
                SizedBox(
                  width: 300,
                  child: MilitaryLeftPanel(
                    onProjectSelect: (projectName) {
                      setState(() {
                        selectedProject = projectName;
                      });
                    },
                  ),
                ),
                
                // Central Display
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.all(8),
                    child: showVisionSystem 
                        ? const MilitaryVisionDisplay()
                        : MilitaryCentralDisplay(projectName: selectedProject),
                  ),
                ),
                
                // Right Panel
                SizedBox(
                  width: 300,
                  child: const MilitaryRightPanel(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
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
          Row(
            children: [
              const Text(
                'INVARIANT',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00D4FF),
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(width: 15),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF00D4FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'v1.1',
                  style: TextStyle(
                    color: Color(0xFF00D4FF),
                    fontSize: 10,
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
                  'ACTIVE: $selectedProject',
                  style: const TextStyle(
                    color: Color(0xFF00FF88),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: showVisionSystem 
                          ? const Color(0xFF00D4FF).withOpacity(0.2)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: const Color(0xFF00D4FF),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'VISION',
                      style: TextStyle(
                        color: showVisionSystem 
                            ? const Color(0xFF00D4FF)
                            : Colors.grey,
                        fontSize: 10,
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
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: Colors.red,
                        width: 1,
                      ),
                    ),
                    child: const Text(
                      'DISCONNECT',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ] else ...[
                const Text(
                  'SYSTEM READY',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
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
