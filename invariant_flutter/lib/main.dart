import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;

import 'ui/design_tokens.dart';
import 'system_probe.dart';
import 'resource_monitor_panel.dart';
import 'network_detector.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 완전 전체화면 + 가로 고정
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);

  runApp(const InvariantApp());
}

class InvariantApp extends StatelessWidget {
  const InvariantApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Invariant - Razor HUD',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: DesignTokens.primary,
        colorScheme: const ColorScheme.dark(
          primary: DesignTokens.accent,
          surface: DesignTokens.secondary,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: DesignTokens.fontFamily,
              bodyColor: DesignTokens.textPrimary,
              displayColor: DesignTokens.textPrimary,
            ),
      ),
      home: const MilitaryCommandCenter(),
    );
  }
}

class MilitaryCommandCenter extends StatefulWidget {
  const MilitaryCommandCenter({super.key});

  @override
  State<MilitaryCommandCenter> createState() => _MilitaryCommandCenterState();
}

class _MilitaryCommandCenterState extends State<MilitaryCommandCenter>
    with TickerProviderStateMixin {
  late Timer _updateTimer;
  late Timer _timeTimer;
  late AnimationController _pulseController;
  late AnimationController _glowController;
  late PageController _pageController;

  // System monitoring data
  double cpuUsage = 0.0;
  double memoryUsage = 0.0;
  double diskUsage = 0.0;
  String currentTime = '';
  String gmtTime = '';
  String operationTime = '';

  // System specs
  SystemSpec? systemSpec;
  DateTime startTime = DateTime.now();
  int currentViewIndex = 0;

  // Network monitoring data
  NetworkInfo? networkInfo;

  // Welcome animation
  bool showWelcome = true;
  late AnimationController _welcomeController;
  late Animation<double> _welcomeFadeAnimation;
  late Animation<double> _welcomeScaleAnimation;

  // Project data
  final List<Map<String, dynamic>> projects = [
    {
      'id': 'PROJECT_ALPHA',
      'name': 'Project 1',
      'status': 'ERROR',
      'description': 'Text Generation WebUI',
      'icon': Icons.psychology,
      'color': DesignTokens.statusError,
    },
    {
      'id': 'PROJECT_BETA',
      'name': 'Project 2',
      'status': 'ERROR',
      'description': 'Advanced AI System',
      'icon': Icons.smart_toy,
      'color': DesignTokens.statusError,
    },
    {
      'id': 'PROJECT_GAMMA',
      'name': 'Project 3',
      'status': 'ERROR',
      'description': 'Instagram Crawler',
      'icon': Icons.camera_alt,
      'color': DesignTokens.statusError,
    },
    {
      'id': 'PROJECT_DELTA',
      'name': 'Project 4',
      'status': 'ERROR',
      'description': 'AI Agent System',
      'icon': Icons.android,
      'color': DesignTokens.statusError,
    },
  ];

  String? selectedProject;

  @override
  void initState() {
    super.initState();

    _pageController = PageController(initialPage: currentViewIndex);

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _glowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _welcomeController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _welcomeFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _welcomeController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeInOut),
      ),
    );

    _welcomeScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _welcomeController,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticOut),
      ),
    );

    // 웰컴 애니메이션 - 1.5초 로딩 후 바로 사라짐
    _welcomeController.forward().then((_) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          setState(() => showWelcome = false);
        }
      });
    });

    // 시스템 데이터 업데이트 타이머 (100ms마다 - 10fps)
    _updateTimer =
        Timer.periodic(const Duration(milliseconds: 100), (_) => _updateSystemData());

    // 시계 업데이트 타이머 (100ms마다 - 10fps)
    _timeTimer = Timer.periodic(const Duration(milliseconds: 100), (_) {
      if (mounted) {
    setState(() {
          currentTime = _formatTime(DateTime.now());
          gmtTime = _formatGMTTime(DateTime.now());
          operationTime = _formatOperationTime(DateTime.now().difference(startTime));
        });
      }
    });

    _loadSystemSpecs();
    _updateSystemData();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    _timeTimer.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    _welcomeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadSystemSpecs() async {
    try {
      final spec = await probeSystem();
      if (!mounted) return;
      setState(() => systemSpec = spec);
    } catch (e) {
      // ignore
    }
  }

  void _updateSystemData() async {
    final newCpuUsage = await _getCpuUsage();
    final newMemoryUsage = await _getMemoryUsage();
    final newDiskUsage = await _getDiskUsage();
    final newNetworkInfo = await NetworkDetector.getNetworkInfo();

    if (!mounted) return;
    setState(() {
      cpuUsage = newCpuUsage;
      memoryUsage = newMemoryUsage;
      diskUsage = newDiskUsage;
      networkInfo = newNetworkInfo;
      // 시간 업데이트는 별도 타이머에서 처리
    });
  }

  Future<double> _getCpuUsage() async {
    try {
      final result = await Process.run('bash', [
        '-c',
        r"grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {print usage}'"
      ]);
      if (result.exitCode == 0) {
        final usage = double.tryParse(result.stdout.toString().trim()) ?? 0.0;
        return usage;
      }
    } catch (_) {}
    return 15.0 + (DateTime.now().millisecond % 20);
  }

  Future<double> _getMemoryUsage() async {
    try {
      final result = await Process.run('bash', [
        '-c',
        "free | grep Mem | awk '{printf \"%.1f\", \\\$3/\\\$2 * 100.0}'"
      ]);
      if (result.exitCode == 0) {
        final usage = double.tryParse(result.stdout.toString().trim()) ?? 0.0;
        return usage;
      }
    } catch (_) {}
    return 25.0 + (DateTime.now().second % 15);
  }

  Future<double> _getDiskUsage() async {
    try {
      final result = await Process.run('bash', [
        '-c',
        r"df / | tail -1 | awk '{print $5}' | sed 's/%//'"
      ]);
      if (result.exitCode == 0) {
        final usage = double.tryParse(result.stdout.toString().trim()) ?? 0.0;
        return usage;
      }
    } catch (_) {}
    return 45.0 + (DateTime.now().minute % 10);
  }

  String _formatTime(DateTime time) {
    final koreaTime = time.toUtc().add(const Duration(hours: 9));
    return '${koreaTime.hour.toString().padLeft(2, '0')}:${koreaTime.minute.toString().padLeft(2, '0')}:${koreaTime.second.toString().padLeft(2, '0')}';
  }

  String _formatGMTTime(DateTime time) {
    final t = time.toUtc();
    return '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:${t.second.toString().padLeft(2, '0')}';
  }

  String _formatOperationTime(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    final cs = (d.inMilliseconds % 1000) ~/ 100;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.$cs';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.primary,
      body: Stack(
        children: [
          // 메인 콘텐츠 배경
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [DesignTokens.primary, DesignTokens.secondary],
              ),
            ),
            child: SafeArea(
        child: Column(
                children: [
                  _buildTopTimeBar(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(DesignTokens.spacingLG),
                      child: Row(
                        children: [
                          // 왼쪽 패널
                          SizedBox(
                            width: DesignTokens.sidebarWidth,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: _buildPanel(
                                    title: 'SENSOR SYSTEMS',
                                    child: _buildRadarVideoSystem(),
                                  ),
                                ),
                                const SizedBox(height: DesignTokens.spacingLG),
                                SizedBox(
                                  height: 200,
                                  child: _buildPanel(
                                    title: 'MISSION SYSTEMS',
                                    child: _buildProjectSlider(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spacingLG),

                          // 중앙 메인
                          Expanded(
                            child: _buildPanel(
                              title: 'COMMAND CENTER',
                              child: _buildCenterContent(),
                            ),
                          ),
                          const SizedBox(width: DesignTokens.spacingLG),

                          // 오른쪽 패널
                          SizedBox(
                            width: 320,
                            child: Column(
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: _buildPanel(
                                    title: 'SYSTEM STATUS',
                                    child: _buildSemicircularGauges(),
                                  ),
                                ),
                                const SizedBox(height: DesignTokens.spacingMD),
                                Expanded(
                                  flex: 2,
                                  child: _buildPanel(
                                    title: 'NETWORK STATUS',
                                    child: _buildNetworkStatus(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 웰컴 오버레이
          if (showWelcome)
            AnimatedBuilder(
              animation: _welcomeController,
              builder: (context, _) {
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF0A0A0A),
                        const Color(0xFF1A1A1A),
                        const Color(0xFF0F0F0F),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Transform.scale(
                      scale: _welcomeScaleAnimation.value,
                      child: Opacity(
                        opacity: _welcomeFadeAnimation.value,
                        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // 철문 느낌의 메탈릭 로고
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF2A2A2A),
                                    const Color(0xFF1A1A1A),
                                    const Color(0xFF0A0A0A),
                                  ],
                                ),
                                border: Border.all(
                                  color: DesignTokens.accent,
                                  width: 3,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: DesignTokens.accent.withOpacity(0.8),
                                    blurRadius: 40,
                                    spreadRadius: 15,
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                              child: Container(
                                margin: const EdgeInsets.all(25),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      const Color(0xFF3A3A3A),
                                      const Color(0xFF1A1A1A),
                                      const Color(0xFF2A2A2A),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: const Color(0xFF4A4A4A),
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.security,
                                  size: 60,
                                  color: DesignTokens.accent,
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            // 메인 타이틀 - 메탈릭 효과
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFF2A2A2A),
                                    const Color(0xFF1A1A1A),
                                    const Color(0xFF0A0A0A),
                                  ],
                                ),
                                border: Border.all(
                                  color: DesignTokens.accent,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: DesignTokens.accent.withOpacity(0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Text(
                                'INVARIANT',
                                style: TextStyles.headerLarge.copyWith(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 8,
                                  shadows: [
                                    Shadow(
                                      color: DesignTokens.accent.withOpacity(0.8),
                                      blurRadius: 15,
                                      offset: const Offset(0, 0),
                                    ),
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 5,
                                      offset: const Offset(2, 2),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 25),
                            // 서브타이틀
            Text(
                              'MILITARY COMMAND CENTER',
                              style: TextStyles.labelMedium.copyWith(
                                color: const Color(0xFF888888),
                                fontSize: 16,
                                letterSpacing: 4,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 15),
                            // 버전 정보
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(
                                  color: const Color(0xFF3A3A3A),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                'v1.1.0',
                                style: TextStyles.monoSmall.copyWith(
                                  color: DesignTokens.accent,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(height: 50),
                            // 철문 느낌의 로딩 바
                            Container(
                              width: 300,
                              height: 4,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1A1A),
                                borderRadius: BorderRadius.circular(2),
                                border: Border.all(
                                  color: const Color(0xFF3A3A3A),
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 5,
                                    offset: const Offset(0, 2),
            ),
          ],
        ),
                              child: Stack(
                                children: [
                                  // 진행률 바 - 0.3초 동안만 채워짐
                                  FractionallySizedBox(
                                    alignment: Alignment.centerLeft,
                                    widthFactor: _welcomeController.value <= 0.3 
                                        ? _welcomeController.value / 0.3 
                                        : 1.0,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            DesignTokens.accent,
                                            DesignTokens.accent.withOpacity(0.7),
                                            DesignTokens.accent,
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: DesignTokens.accent.withOpacity(0.6),
                                            blurRadius: 8,
                                            spreadRadius: 2,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  // 메탈릭 하이라이트
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.white.withOpacity(0.1),
                                          Colors.transparent,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            // 로딩 텍스트
                            Text(
                              'INITIALIZING SECURITY PROTOCOLS...',
                              style: TextStyles.monoSmall.copyWith(
                                color: const Color(0xFF666666),
                                fontSize: 10,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  // ---------- UI helpers ----------

  Widget _buildPanel({String? title, required Widget child}) {
    return Container(
      decoration: PanelStyles.defaultPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.panelPadding),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: DesignTokens.border)),
              ),
              child: Text(
                title,
                style: TextStyles.labelMedium
                    .copyWith(color: DesignTokens.accent),
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(DesignTokens.panelPadding),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMissionSystemPanel() {
    return SizedBox(
      height: 120,
      child: _buildPanel(
        title: 'MISSION SYSTEMS',
        child: _buildProjectSlider(),
      ),
    );
  }

  Widget _buildProjectSlider() {
    return Row(
      children: [
        if (projects.length > 4)
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0x1AE6FEFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x1AE6FEFF)),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: Color(0xFF7BA5AE),
                size: 20,
              ),
            ),
          ),
        if (projects.length > 4) const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: projects.take(4).map((project) {
              final isSelected = selectedProject == project['id'];
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => selectedProject = project['id']),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? project['color'].withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? project['color']
                            : const Color(0x1AE6FEFF),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: project['color'].withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: project['color'].withOpacity(0.3)),
                          ),
                          child: Icon(
                            project['icon'],
                            color: project['color'],
                            size: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          project['name'],
                          textAlign: TextAlign.center,
                          style: TextStyles.monoSmall.copyWith(
                            fontSize: 11,
                            color: isSelected
                                ? project['color']
                                : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _getStatusColor(project['status']),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        if (projects.length > 4) const SizedBox(width: 8),
        if (projects.length > 4)
          GestureDetector(
            onTap: () {},
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: const Color(0x1AE6FEFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0x1AE6FEFF)),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: Color(0xFF7BA5AE),
                size: 20,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTopTimeBar() {
    return Container(
      height: DesignTokens.headerHeight,
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: DesignTokens.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingLG),
      child: Row(
        children: [
          // 로고
          Text(
            'INVARIANT',
            style: TextStyles.headerMedium.copyWith(
              color: DesignTokens.accent,
              letterSpacing: 2.0,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // 시간 정보들
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTimeItem('KST (UTC+9)', currentTime, DesignTokens.textPrimary),
              const SizedBox(width: DesignTokens.spacingLG),
              _buildTimeItem('OPERATION TIME', operationTime, DesignTokens.error),
              const SizedBox(width: DesignTokens.spacingLG),
              _buildTimeItem('GMT (UTC+0)', gmtTime, DesignTokens.accent),
            ],
          ),
          const Spacer(),
          // 전원 버튼
          GestureDetector(
            onTap: () => SystemNavigator.pop(),
            child: Icon(
              Icons.power_settings_new,
              size: 18,
              color: DesignTokens.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeItem(String label, String time, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: TextStyles.labelSmall.copyWith(
            color: DesignTokens.textMuted,
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          time,
          style: TextStyles.monoSmall.copyWith(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildRadarVideoSystem() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSlideIndicator(0, 'RADAR'),
            const SizedBox(width: DesignTokens.spacingLG),
            _buildSlideIndicator(1, 'VIDEO'),
          ],
        ),
        const SizedBox(height: DesignTokens.spacingMD),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) =>
                setState(() => currentViewIndex = index),
            itemCount: 2,
            itemBuilder: (context, index) =>
                index == 0 ? _buildRadarSystem() : _buildVideoSystem(),
          ),
        ),
      ],
    );
  }

  Widget _buildSlideIndicator(int index, String label) {
    final isActive = currentViewIndex == index;
    return GestureDetector(
      onTap: () => _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingMD,
          vertical: DesignTokens.spacingSM,
        ),
        decoration: BoxDecoration(
          color: isActive
              ? DesignTokens.accent.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignTokens.spacingSM),
          border: Border.all(
            color: isActive ? DesignTokens.accent : DesignTokens.border,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyles.labelSmall.copyWith(
            color: isActive ? DesignTokens.accent : DesignTokens.textMuted,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildRadarSystem() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.radar,
              size: DesignTokens.iconSizeXL,
              color: DesignTokens.accent.withOpacity(0.6)),
          const SizedBox(height: DesignTokens.spacingLG),
          Text('RADAR SYSTEM',
              style:
                  TextStyles.labelLarge.copyWith(color: DesignTokens.textSecondary)),
          const SizedBox(height: DesignTokens.spacingSM),
          Text('OFFLINE',
              style:
                  TextStyles.labelMedium.copyWith(color: DesignTokens.statusError)),
        ],
      ),
    );
  }

  Widget _buildVideoSystem() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.videocam,
              size: DesignTokens.iconSizeXL,
              color: DesignTokens.accent.withOpacity(0.6)),
          const SizedBox(height: DesignTokens.spacingLG),
          Text('VIDEO SYSTEM',
              style:
                  TextStyles.labelLarge.copyWith(color: DesignTokens.textSecondary)),
          const SizedBox(height: DesignTokens.spacingSM),
          Text('OFFLINE',
              style:
                  TextStyles.labelMedium.copyWith(color: DesignTokens.statusError)),
        ],
      ),
    );
  }

  Widget _buildSemicircularGauges() {
    if (systemSpec == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final spec = systemSpec!;
    final primaryDisk = spec.disks.isNotEmpty ? spec.disks.first : null;

    return Row(
      children: [
        Expanded(
          child: _buildGaugeWithInfo(
            'CPU',
            '${spec.cpu.cores} Cores',
            cpuUsage,
          ),
        ),
        const SizedBox(width: DesignTokens.spacingSM),
        Expanded(
          child: _buildGaugeWithInfo(
            'MEMORY',
            '${spec.memory.totalGB}GB',
            memoryUsage,
          ),
        ),
        const SizedBox(width: DesignTokens.spacingSM),
        Expanded(
          child: _buildGaugeWithInfo(
            'DISK',
            '${primaryDisk?.sizeGB ?? 0}GB',
            diskUsage,
          ),
        ),
      ],
    );
  }

  Widget _buildGaugeWithInfo(String label, String spec, double value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CustomPaint(
          painter: CircularGaugePainter(value: value, label: ''),
          size: const Size(120, 60),
        ),
        const SizedBox(height: DesignTokens.spacingSM),
        Text(
          label,
          style: TextStyles.monoSmall.copyWith(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          spec,
          style: TextStyles.monoSmall.copyWith(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSystemInfo(String title, String spec, IconData icon, double usage) {
    return Container(
      padding: const EdgeInsets.all(DesignTokens.spacingSM),
      decoration: BoxDecoration(
        color: DesignTokens.surface.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: DesignTokens.primary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16,
                color: DesignTokens.primary,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyles.monoSmall.copyWith(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              Text(
                '${usage.toInt()}%',
                style: TextStyles.monoSmall.copyWith(
                  color: DesignTokens.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            spec,
            style: TextStyles.monoMedium.copyWith(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStatus() {
    if (networkInfo == null) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final info = networkInfo!;
    return Column(
      children: [
        // 네트워크 정보
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spacingSM),
            decoration: BoxDecoration(
              color: DesignTokens.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: DesignTokens.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 상단 중앙 정렬된 라벨
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(_getConnectionIcon(info.connectionType), 
                         size: 14, color: DesignTokens.accent),
                    const SizedBox(width: 6),
                    Text(
                      'NETWORK',
                      style: TextStyles.monoSmall.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // IP 주소들 - 중앙 정렬
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: info.ips.map((ip) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 4,
                                height: 4,
                                decoration: BoxDecoration(
                                  color: DesignTokens.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                ip,
                                style: TextStyles.monoSmall.copyWith(
                                  color: DesignTokens.accent,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spacingXS),
        // VPN 상태
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spacingSM),
            decoration: BoxDecoration(
              color: DesignTokens.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: DesignTokens.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 상단 중앙 정렬된 라벨
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.vpn_key, size: 14, color: DesignTokens.accent),
                    const SizedBox(width: 6),
                    Text(
                      'VPN',
                      style: TextStyles.monoSmall.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // VPN 상태 - 중앙 정렬
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: info.isVpnConnected 
                            ? DesignTokens.success.withOpacity(0.2)
                            : DesignTokens.error.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: info.isVpnConnected 
                              ? DesignTokens.success
                              : DesignTokens.error,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        info.isVpnConnected ? 'CONNECTED' : 'DISCONNECTED',
                        style: TextStyles.monoSmall.copyWith(
                          color: info.isVpnConnected 
                              ? DesignTokens.success
                              : DesignTokens.error,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.spacingXS),
        // 보안 상태 - 확대하여 경보용으로 활용
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(DesignTokens.spacingSM),
            decoration: BoxDecoration(
              color: DesignTokens.surface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: DesignTokens.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                // 상단 중앙 정렬된 라벨
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.security, size: 16, color: DesignTokens.accent),
                    const SizedBox(width: 8),
                    Text(
                      'SECURITY ALERTS',
                      style: TextStyles.monoSmall.copyWith(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // 보안 경보들 - 중앙 정렬
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSecurityAlert('DDoS Protection', 'ACTIVE', DesignTokens.success),
                        const SizedBox(height: 4),
                        _buildSecurityAlert('Location Tracking', 'CLEAR', DesignTokens.success),
                        const SizedBox(height: 4),
                        _buildSecurityAlert('Intrusion Detection', 'MONITORING', DesignTokens.accent),
                        const SizedBox(height: 4),
                        _buildSecurityAlert('Firewall Status', 'ENABLED', DesignTokens.success),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSecurityAlert(String label, String status, Color color) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 4,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            label,
            style: TextStyles.monoSmall.copyWith(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color,
              width: 1,
            ),
          ),
          child: Text(
            status,
            style: TextStyles.monoSmall.copyWith(
              color: color,
              fontSize: 7,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkItemWithIcon(
      String label, String value, IconData icon, Color color) {
    return Row(
      children: [
        Icon(icon, size: 14, color: DesignTokens.textMuted),
        const SizedBox(width: DesignTokens.spacingXS),
        Text(label,
            style: TextStyles.monoSmall
                .copyWith(color: DesignTokens.textMuted, fontSize: 12)),
        const SizedBox(width: DesignTokens.spacingSM),
        Expanded(
          child: Text(
            value,
            style: TextStyles.monoSmall.copyWith(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  IconData _getConnectionIcon(String connectionType) {
    switch (connectionType.toUpperCase()) {
      case 'WIFI':
        return Icons.wifi;
      case 'LAN':
        return Icons.cable;
      case 'MOBILE':
      case '5G':
      case 'LTE':
        return Icons.signal_cellular_4_bar;
      case 'SATELLITE':
        return Icons.satellite;
      default:
        return Icons.network_check;
    }
  }

  Widget _buildCenterContent() {
    return Stack(
      children: [
        Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (selectedProject != null) _buildProjectThumbnail() else _buildDefaultLogo(),
              const SizedBox(height: 24),
              if (selectedProject != null) _buildProjectInfo() else _buildDefaultInfo(),
            ],
          ),
        ),
        if (selectedProject != null)
          Positioned(left: 0, right: 0, bottom: 0, child: _buildLaunchButton()),
      ],
    );
  }

  Widget _buildDefaultLogo() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: DesignTokens.accent.withOpacity(0.1),
            border: Border.all(
              color: DesignTokens.accent
                  .withOpacity(0.5 + (0.3 * _pulseController.value)),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    DesignTokens.accent.withOpacity(0.3 * _pulseController.value),
                blurRadius: 20 + (10 * _pulseController.value),
                spreadRadius: 5 + (5 * _pulseController.value),
              ),
            ],
          ),
          child: const Icon(Icons.shield, size: 80, color: DesignTokens.accent),
        );
      },
    );
  }

  Widget _buildProjectThumbnail() {
    final project = projects.firstWhere((p) => p['id'] == selectedProject);
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: project['color'].withOpacity(0.1),
            border: Border.all(
              color: project['color']
                  .withOpacity(0.5 + (0.3 * _pulseController.value)),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color:
                    project['color'].withOpacity(0.3 * _pulseController.value),
                blurRadius: 20 + (10 * _pulseController.value),
                spreadRadius: 5 + (5 * _pulseController.value),
              ),
            ],
          ),
          child: Icon(project['icon'], size: 60, color: project['color']),
        );
      },
    );
  }

  Widget _buildDefaultInfo() {
    return Column(
      children: const [
        Text('INVARIANT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
              color: Color(0xFF21D3EE),
            )),
        SizedBox(height: 8),
        Text('RAZOR HUD SYSTEM',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            )),
        SizedBox(height: 16),
        Text('SELECT MISSION SYSTEM FROM LEFT PANEL',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF7BA5AE),
              letterSpacing: 1,
            )),
      ],
    );
  }

  Widget _buildProjectInfo() {
    final project = projects.firstWhere((p) => p['id'] == selectedProject);
    return Column(
      children: [
        Text(project['name'],
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            )),
        const SizedBox(height: 8),
        Text(project['description'],
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF7BA5AE),
              letterSpacing: 0.5,
            )),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _getStatusColor(project['status']).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _getStatusColor(project['status'])),
          ),
          child: Text(
            project['status'],
            style: TextStyle(
              fontSize: 12,
              color: _getStatusColor(project['status']),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLaunchButton() {
    final project = projects.firstWhere((p) => p['id'] == selectedProject);
    return SizedBox(
      height: 60,
      child: ElevatedButton(
        onPressed: () => debugPrint('Launching ${project['name']}...'),
        style: ElevatedButton.styleFrom(
          backgroundColor: project['color'],
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 8,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.play_arrow, size: 20),
            const SizedBox(width: 8),
            Text(
              'LAUNCH ${project['name'].toString().toUpperCase()}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'RUNNING':
        return DesignTokens.statusRunning;
      case 'STANDBY':
        return DesignTokens.statusStandby;
      case 'OFFLINE':
      case 'ERROR':
      default:
        return DesignTokens.statusError;
    }
  }
}

class CircularGaugePainter extends CustomPainter {
  final double value;
  final String label;

  CircularGaugePainter({required this.value, required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final radius = (size.width / 2) - 20;

    final backgroundPaint = Paint()
      ..color = DesignTokens.surface.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      math.pi,
      false,
      backgroundPaint,
    );

    Color valueColor;
    if (value <= 30) {
      valueColor = const Color(0xFF00FF41);
    } else if (value <= 60) {
      valueColor = const Color(0xFFFFB800);
    } else if (value <= 80) {
      valueColor = const Color(0xFFFF6B00);
    } else {
      valueColor = const Color(0xFFFF0040);
    }

    final valuePaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;

    final sweepAngle = (value / 100) * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi,
      sweepAngle,
      false,
      valuePaint,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: '${value.toInt()}%',
        style: TextStyles.monoMedium.copyWith(
          color: DesignTokens.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(center.dx - textPainter.width / 2,
          center.dy - textPainter.height / 2 - 8),
    );

    // 라벨이 비어있지 않을 때만 표시
    if (label.isNotEmpty) {
      final labelPainter = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyles.monoSmall.copyWith(
            color: DesignTokens.textSecondary,
            fontSize: 10,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      labelPainter.paint(
        canvas,
        Offset(center.dx - labelPainter.width / 2, center.dy + 12),
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
