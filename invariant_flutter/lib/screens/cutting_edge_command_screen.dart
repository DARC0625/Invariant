import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:flutter_animate/flutter_animate.dart';
// import 'package:rive/rive.dart';
import '../providers/system_monitor_provider.dart';
import '../widgets/cutting_edge_left_panel.dart';
import '../widgets/cutting_edge_central_display.dart';
import '../widgets/cutting_edge_right_panel.dart';

class CuttingEdgeCommandScreen extends ConsumerStatefulWidget {
  const CuttingEdgeCommandScreen({super.key});

  @override
  ConsumerState<CuttingEdgeCommandScreen> createState() => _CuttingEdgeCommandScreenState();
}

class _CuttingEdgeCommandScreenState extends ConsumerState<CuttingEdgeCommandScreen>
    with TickerProviderStateMixin {
  String? selectedProject;
  bool showVisionSystem = false;
  bool isFullScreen = false;
  late AnimationController _backgroundController;
  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Animated Background
          _buildAnimatedBackground(),
          
          // Main Content
          Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Row(
                  children: [
                    // Left Panel
                    if (!isFullScreen)
                      Container(
                        width: 320,
                        child: CuttingEdgeLeftPanel(
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
                        child: CuttingEdgeCentralDisplay(
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
                        child: const CuttingEdgeRightPanel(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF0A0A0A),
                const Color(0xFF1A1A2E),
                const Color(0xFF16213E),
                const Color(0xFF0A0A0A),
              ],
              stops: [
                0.0,
                0.3 + 0.1 * _backgroundController.value,
                0.7 + 0.1 * _backgroundController.value,
                1.0,
              ],
            ),
          ),
          child: CustomPaint(
            painter: BackgroundGridPainter(_backgroundController.value),
            size: Size.infinite,
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return GlassmorphicContainer(
      width: double.infinity,
      height: 60,
      borderRadius: 0,
      blur: 20,
      alignment: Alignment.bottomCenter,
      border: 0,
      linearGradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFF00D4FF).withOpacity(0.1),
          const Color(0xFF0099CC).withOpacity(0.05),
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
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _glowController,
                  builder: (context, child) {
                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF00D4FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF00D4FF).withOpacity(0.3 + 0.2 * _glowController.value),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF00D4FF).withOpacity(0.3 + 0.2 * _glowController.value),
                            blurRadius: 10 + 5 * _glowController.value,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.rocket_launch,
                        color: Color(0xFF00D4FF),
                        size: 20,
                      ),
                    );
                  },
                ),
                const SizedBox(width: 16),
                Text(
                  'INVARIANT',
                  style: GoogleFonts.orbitron(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF00D4FF),
                    letterSpacing: 3,
                    shadows: [
                      Shadow(
                        color: const Color(0xFF00D4FF).withOpacity(0.5),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 1000.ms).slideX(begin: -0.3, end: 0),
                const SizedBox(width: 20),
                GlassmorphicContainer(
                  width: 60,
                  height: 30,
                  borderRadius: 15,
                  blur: 10,
                  alignment: Alignment.center,
                  border: 1,
                  linearGradient: LinearGradient(
                    colors: [
                      const Color(0xFF00D4FF).withOpacity(0.1),
                      const Color(0xFF0099CC).withOpacity(0.05),
                    ],
                  ),
                  borderGradient: LinearGradient(
                    colors: [
                      const Color(0xFF00D4FF).withOpacity(0.3),
                      const Color(0xFF0099CC).withOpacity(0.1),
                    ],
                  ),
                  child: Text(
                    'v1.1',
                    style: GoogleFonts.robotoMono(
                      color: const Color(0xFF00D4FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                if (selectedProject != null) ...[
                  GlassmorphicContainer(
                    width: 200,
                    height: 35,
                    borderRadius: 17,
                    blur: 10,
                    alignment: Alignment.center,
                    border: 1,
                    linearGradient: LinearGradient(
                      colors: [
                        const Color(0xFF00FF88).withOpacity(0.1),
                        const Color(0xFF00CC66).withOpacity(0.05),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        const Color(0xFF00FF88).withOpacity(0.3),
                        const Color(0xFF00CC66).withOpacity(0.1),
                      ],
                    ),
                    child: Text(
                      'ACTIVE: $selectedProject',
                      style: GoogleFonts.robotoMono(
                        color: const Color(0xFF00FF88),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildHeaderButton('VISION', showVisionSystem, () {
                    setState(() {
                      showVisionSystem = !showVisionSystem;
                    });
                  }),
                  const SizedBox(width: 12),
                  _buildHeaderButton('DISCONNECT', false, () {
                    setState(() {
                      selectedProject = null;
                      showVisionSystem = false;
                    });
                  }, isDestructive: true),
                ] else ...[
                  GlassmorphicContainer(
                    width: 150,
                    height: 35,
                    borderRadius: 17,
                    blur: 10,
                    alignment: Alignment.center,
                    border: 1,
                    linearGradient: LinearGradient(
                      colors: [
                        Colors.grey.withOpacity(0.1),
                        Colors.grey.withOpacity(0.05),
                      ],
                    ),
                    borderGradient: LinearGradient(
                      colors: [
                        Colors.grey.withOpacity(0.3),
                        Colors.grey.withOpacity(0.1),
                      ],
                    ),
                    child: Text(
                      'SYSTEM READY',
                      style: GoogleFonts.robotoMono(
                        color: Colors.grey,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderButton(String label, bool isActive, VoidCallback onTap, {bool isDestructive = false}) {
    final color = isDestructive ? Colors.red : const Color(0xFF00D4FF);
    
    return GestureDetector(
      onTap: onTap,
      child: GlassmorphicContainer(
        width: 100,
        height: 35,
        borderRadius: 17,
        blur: 10,
        alignment: Alignment.center,
        border: 1,
        linearGradient: LinearGradient(
          colors: [
            (isActive ? color : Colors.grey).withOpacity(0.1),
            (isActive ? color : Colors.grey).withOpacity(0.05),
          ],
        ),
        borderGradient: LinearGradient(
          colors: [
            (isActive ? color : Colors.grey).withOpacity(0.3),
            (isActive ? color : Colors.grey).withOpacity(0.1),
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.robotoMono(
            color: isActive ? color : Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class BackgroundGridPainter extends CustomPainter {
  final double animation;

  BackgroundGridPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00D4FF).withOpacity(0.05)
      ..strokeWidth = 1;

    const spacing = 50.0;

    // Animated grid lines
    for (double x = 0; x < size.width; x += spacing) {
      final offset = (animation * spacing) % spacing;
      canvas.drawLine(
        Offset(x - offset, 0),
        Offset(x - offset, size.height),
        paint,
      );
    }

    for (double y = 0; y < size.height; y += spacing) {
      final offset = (animation * spacing) % spacing;
      canvas.drawLine(
        Offset(0, y - offset),
        Offset(size.width, y - offset),
        paint,
      );
    }

    // Floating particles
    for (int i = 0; i < 20; i++) {
      final x = (i * 100.0 + animation * 50) % size.width;
      final y = (i * 80.0 + animation * 30) % size.height;
      
      final particlePaint = Paint()
        ..color = const Color(0xFF00D4FF).withOpacity(0.1 + 0.1 * (i % 3))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(x, y),
        2 + (i % 3),
        particlePaint,
      );
    }
  }

  @override
  bool shouldRepaint(BackgroundGridPainter oldDelegate) => oldDelegate.animation != animation;
}
