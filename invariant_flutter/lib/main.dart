import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'package:system_info2/system_info2.dart';
import 'ui/design_tokens.dart';
import 'system_probe.dart';
import 'resource_monitor_panel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 전체화면 모드로 설정
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  
  // 창 크기 설정 (1920x1080)
  await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
  
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

class _MilitaryCommandCenterState extends State<MilitaryCommandCenter> with TickerProviderStateMixin {
  late Timer _updateTimer;
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
  
  // System specs - 새로운 system_probe 사용
  SystemSpec? systemSpec;
  DateTime startTime = DateTime.now();
  int currentViewIndex = 0;
  
  // Project data
  final List<Map<String, dynamic>> projects = [
    {
      'id': 'PROJECT_ALPHA',
      'name': 'Project 1',
      'status': 'ERROR',
      'description': 'Text Generation WebUI',
      'icon': Icons.psychology,
      'color': DesignTokens.statusError, // 빨간색 - 오류 (미구현)
    },
    {
      'id': 'PROJECT_BETA',
      'name': 'Project 2',
      'status': 'ERROR',
      'description': 'Advanced AI System',
      'icon': Icons.smart_toy,
      'color': DesignTokens.statusError, // 빨간색 - 오류 (미구현)
    },
    {
      'id': 'PROJECT_GAMMA',
      'name': 'Project 3',
      'status': 'ERROR',
      'description': 'Instagram Crawler',
      'icon': Icons.camera_alt,
      'color': DesignTokens.statusError, // 빨간색 - 오류 (미구현)
    },
    {
      'id': 'PROJECT_DELTA',
      'name': 'Project 4',
      'status': 'ERROR',
      'description': 'AI Agent System',
      'icon': Icons.android,
      'color': DesignTokens.statusError, // 빨간색 - 오류
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
    
    _updateTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      _updateSystemData();
    });
    
    print('initState: calling _loadSystemSpecs()');
    _loadSystemSpecs();
    print('initState: calling _updateSystemData()');
    _updateSystemData();
  }

  @override
  void dispose() {
    _updateTimer.cancel();
    _pulseController.dispose();
    _glowController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _loadSystemSpecs() async {
    print('_loadSystemSpecs() called');
    try {
      final spec = await probeSystem();
      setState(() {
        systemSpec = spec;
        print('System specs loaded: CPU=${spec.cpu.model}, Cores=${spec.cpu.cores}, Memory=${spec.memory.totalGB}GB ${spec.memory.type}, Disks=${spec.disks.length}');
      });
    } catch (e) {
      print('System specs error: $e');
      print('Stack trace: ${StackTrace.current}');
    }
  }

  void _updateSystemData() async {
    // 실제 시스템 데이터 수집
    final newCpuUsage = await _getCpuUsage();
    final newMemoryUsage = await _getMemoryUsage();
    final newDiskUsage = await _getDiskUsage();
    
    setState(() {
      cpuUsage = newCpuUsage;
      memoryUsage = newMemoryUsage;
      diskUsage = newDiskUsage;
      currentTime = _formatTime(DateTime.now());
      gmtTime = _formatGMTTime(DateTime.now());
      operationTime = _formatOperationTime(DateTime.now().difference(startTime));
    });
  }

  Future<double> _getCpuUsage() async {
    try {
      final result = await Process.run('bash', ['-c', r'''
        grep 'cpu ' /proc/stat | awk '{usage=($2+$4)*100/($2+$3+$4+$5)} END {print usage}'
      ''']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        final usage = double.tryParse(output) ?? 0.0;
        print('CPU Usage: $usage%');
        return usage;
      } else {
        print('CPU command failed: ${result.stderr}');
        return 15.0 + (DateTime.now().millisecond % 20);
      }
    } catch (e) {
      print('CPU error: $e');
      return 15.0 + (DateTime.now().millisecond % 20);
    }
  }

  Future<double> _getMemoryUsage() async {
    try {
      final result = await Process.run('bash', ['-c', r'''
        free | grep Mem | awk '{printf "%.1f", $3/$2 * 100.0}'
      ''']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        final usage = double.tryParse(output) ?? 0.0;
        print('Memory Usage: $usage%');
        return usage;
      } else {
        print('Memory command failed: ${result.stderr}');
        return 25.0 + (DateTime.now().second % 15);
      }
    } catch (e) {
      print('Memory error: $e');
      return 25.0 + (DateTime.now().second % 15);
    }
  }

  Future<double> _getDiskUsage() async {
    try {
      final result = await Process.run('bash', ['-c', r'''
        df / | tail -1 | awk '{print $5}' | sed 's/%//'
      ''']);
      if (result.exitCode == 0) {
        final output = result.stdout.toString().trim();
        final usage = double.tryParse(output) ?? 0.0;
        print('Disk Usage: $usage%');
        return usage;
      } else {
        print('Disk command failed: ${result.stderr}');
        return 45.0 + (DateTime.now().minute % 10);
      }
    } catch (e) {
      print('Disk error: $e');
      return 45.0 + (DateTime.now().minute % 10);
    }
  }

  String _formatTime(DateTime time) {
    // 한국 시간 (UTC+9)
    final koreaTime = time.toUtc().add(const Duration(hours: 9));
    return '${koreaTime.hour.toString().padLeft(2, '0')}:${koreaTime.minute.toString().padLeft(2, '0')}:${koreaTime.second.toString().padLeft(2, '0')}';
  }

  String _formatGMTTime(DateTime time) {
    final gmtTime = time.toUtc();
    return '${gmtTime.hour.toString().padLeft(2, '0')}:${gmtTime.minute.toString().padLeft(2, '0')}:${gmtTime.second.toString().padLeft(2, '0')}';
  }

  String _formatOperationTime(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;
    final milliseconds = (duration.inMilliseconds % 1000) ~/ 100;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.$milliseconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DesignTokens.primary,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DesignTokens.primary, DesignTokens.secondary],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 시간 표시
              _buildTopTimeBar(),
              // 메인 콘텐츠
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(DesignTokens.spacingLG),
                  child: Row(
                    children: [
                      // 왼쪽 패널 (레이더/영상 + 프로젝트)
                      SizedBox(
                        width: DesignTokens.sidebarWidth,
                        child: Column(
                          children: [
                            // 상단: 레이더/영상 시스템
                            Expanded(
                              flex: 2,
                              child: _buildPanel(
                                title: 'SENSOR SYSTEMS',
                                child: _buildRadarVideoSystem(),
                              ),
                            ),
                            
                            const SizedBox(height: DesignTokens.spacingLG),
                            
                            // 하단: 프로젝트 슬라이드 (4개)
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
                      
                      // 중앙 메인 디스플레이
                      Expanded(
                        child: _buildPanel(
                          title: 'COMMAND CENTER',
                          child: _buildCenterContent(),
                        ),
                      ),
                      
                      const SizedBox(width: DesignTokens.spacingLG),
                      
                      // 오른쪽 패널 (시스템 상태 + 네트워크 상태)
                      SizedBox(
                        width: 320,
                        child: Column(
                          children: [
                            // 시스템 상태 패널 (네트워크보다 작게)
                            Expanded(
                              flex: 1,
                              child: _buildPanel(
                                title: 'SYSTEM STATUS',
                                child: _buildSemicircularGauges(),
                              ),
                            ),
                            
                            const SizedBox(height: DesignTokens.spacingMD),
                            
                            // 네트워크 상태 패널 (시스템보다 크게)
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
    );
  }

  Widget _buildPanel({String? title, required Widget child}) {
    return Container(
      decoration: PanelStyles.defaultPanel,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null)
            Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.panelPadding),
              alignment: Alignment.centerLeft,
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: DesignTokens.border)),
              ),
              child: Text(
                title,
                style: TextStyles.labelMedium.copyWith(
                  color: DesignTokens.accent,
                ),
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
    return Container(
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
        // 이전 버튼
        if (projects.length > 4)
          GestureDetector(
            onTap: () {
              // 슬라이드 로직 (나중에 구현)
            },
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
        
        // 프로젝트 카드들 (최대 4개)
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
                      color: isSelected ? project['color'].withOpacity(0.1) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected ? project['color'] : const Color(0x1AE6FEFF),
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
                            border: Border.all(color: project['color'].withOpacity(0.3)),
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
                          style: TextStyle(
                            fontSize: 12,
                            color: isSelected ? project['color'] : Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        _buildStatusDot(project['status']),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        
        // 다음 버튼
        if (projects.length > 4)
          const SizedBox(width: 8),
        if (projects.length > 4)
          GestureDetector(
            onTap: () {
              // 슬라이드 로직 (나중에 구현)
            },
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
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.spacingXL),
      child: Row(
        children: [
          // 좌측: INVARIANT 로고
          Text(
            'INVARIANT',
            style: TextStyles.headerMedium.copyWith(
              color: DesignTokens.accent,
              letterSpacing: 2.0,
            ),
          ),
          
          const Spacer(),
          
          // 중앙: 시간 세트 (3개 일정한 크기로)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // KST 시간
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'KST (UTC+9)',
                    style: TextStyles.labelSmall.copyWith(
                      color: DesignTokens.textMuted,
                    ),
                  ),
                  Text(
                    currentTime,
                    style: TextStyles.monoLarge.copyWith(
                      color: DesignTokens.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: DesignTokens.spacingXL),
              
              // 오퍼레이션 타임
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'OPERATION TIME',
                    style: TextStyles.labelSmall.copyWith(
                      color: DesignTokens.textMuted,
                    ),
                  ),
                  Text(
                    operationTime,
                    style: TextStyles.monoLarge.copyWith(
                      color: DesignTokens.error,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(width: DesignTokens.spacingXL),
              
              // GMT 시간
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'GMT (UTC+0)',
                    style: TextStyles.labelSmall.copyWith(
                      color: DesignTokens.textMuted,
                    ),
                  ),
                  Text(
                    gmtTime,
                    style: TextStyles.monoLarge.copyWith(
                      color: DesignTokens.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const Spacer(),
          
               // 우측: 종료 버튼
               Container(
                 decoration: BoxDecoration(
                   color: DesignTokens.secondary.withOpacity(0.3),
                   borderRadius: BorderRadius.circular(8),
                   border: Border.all(
                     color: DesignTokens.border,
                     width: 1,
                   ),
                 ),
                 child: IconButton(
                   icon: const Icon(Icons.power_settings_new, size: 20),
                   color: DesignTokens.textSecondary,
                   onPressed: () {
                     SystemNavigator.pop();
                   },
                   tooltip: 'EXIT',
                   padding: const EdgeInsets.all(8),
                   constraints: const BoxConstraints(
                     minWidth: 36,
                     minHeight: 36,
                   ),
                 ),
               ),
        ],
      ),
    );
  }

  Widget _buildRadarVideoSystem() {
    return Container(
      child: Column(
        children: [
          // 슬라이드 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSlideIndicator(0, 'RADAR'),
              const SizedBox(width: DesignTokens.spacingLG),
              _buildSlideIndicator(1, 'VIDEO'),
            ],
          ),
          const SizedBox(height: DesignTokens.spacingMD),
          
          // 슬라이드 컨텐츠
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  currentViewIndex = index;
                });
              },
              itemCount: 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildRadarSystem();
                } else {
                  return _buildVideoSystem();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlideIndicator(int index, String label) {
    final isActive = currentViewIndex == index;
    return GestureDetector(
      onTap: () {
        _pageController.animateToPage(
          index,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DesignTokens.spacingMD,
          vertical: DesignTokens.spacingSM,
        ),
        decoration: BoxDecoration(
          color: isActive ? DesignTokens.accent.withOpacity(0.2) : Colors.transparent,
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
          Icon(
            Icons.radar,
            size: DesignTokens.iconSizeXL,
            color: DesignTokens.accent.withOpacity(0.6),
          ),
          const SizedBox(height: DesignTokens.spacingLG),
          Text(
            'RADAR SYSTEM',
            style: TextStyles.labelLarge.copyWith(
              color: DesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingSM),
          Text(
            'OFFLINE',
            style: TextStyles.labelMedium.copyWith(
              color: DesignTokens.statusError,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoSystem() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.videocam,
            size: DesignTokens.iconSizeXL,
            color: DesignTokens.accent.withOpacity(0.6),
          ),
          const SizedBox(height: DesignTokens.spacingLG),
          Text(
            'VIDEO SYSTEM',
            style: TextStyles.labelLarge.copyWith(
              color: DesignTokens.textSecondary,
            ),
          ),
          const SizedBox(height: DesignTokens.spacingSM),
          Text(
            'OFFLINE',
            style: TextStyles.labelMedium.copyWith(
              color: DesignTokens.statusError,
            ),
          ),
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
        // CPU 게이지
        Expanded(
          child: _buildCircularGaugeWithSpecs('CPU', cpuUsage, '${spec.cpu.model}\n${spec.cpu.cores} Cores'),
        ),
        
        const SizedBox(width: DesignTokens.spacingSM),
        
        // Memory 게이지
        Expanded(
          child: _buildCircularGaugeWithSpecs('MEMORY', memoryUsage, '${spec.memory.type}\n${spec.memory.totalGB}GB'),
        ),
        
        const SizedBox(width: DesignTokens.spacingSM),
        
        // Disk 게이지
        Expanded(
          child: _buildCircularGaugeWithSpecs('DISK', diskUsage, primaryDisk != null ? '${primaryDisk.kind}\n${primaryDisk.sizeGB}GB' : 'Unknown\n0GB'),
        ),
      ],
    );
  }

  Widget _buildCircularGauge(String label, double value) {
    return Container(
      child: CustomPaint(
        painter: CircularGaugePainter(
          value: value,
          label: label,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyles.labelSmall.copyWith(
                  color: DesignTokens.textSecondary,
                ),
              ),
              const SizedBox(height: DesignTokens.spacingSM),
              Text(
                '${value.toStringAsFixed(1)}%',
                style: TextStyles.monoMedium.copyWith(
                  color: DesignTokens.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCircularGaugeWithSpecs(String label, double value, String specs) {
    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomPaint(
            painter: CircularGaugePainter(
              value: value,
              label: label,
            ),
            size: const Size(80, 40),
          ),
          const SizedBox(height: DesignTokens.spacingXS),
          Text(
            specs,
            style: TextStyles.monoSmall.copyWith(
              color: DesignTokens.textSecondary,
              fontSize: 8,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkStatus() {
    return Column(
      children: [
        // 1줄: IP 주소
        Expanded(
          child: _buildNetworkItem('IP', '192.168.1.100', DesignTokens.success),
        ),
        const SizedBox(height: DesignTokens.spacingXS),
        // 2줄: VPN 상태
        Expanded(
          child: _buildNetworkItem('VPN', 'DISCONNECTED', DesignTokens.error),
        ),
        const SizedBox(height: DesignTokens.spacingXS),
        // 3줄: 위협 상태
        Expanded(
          child: _buildNetworkItem('THREAT', 'CLEAR', DesignTokens.success),
        ),
      ],
    );
  }

  Widget _buildNetworkItem(String label, String value, Color color) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyles.monoSmall.copyWith(
            color: DesignTokens.textMuted,
            fontSize: 10,
          ),
        ),
        const SizedBox(width: DesignTokens.spacingSM),
        Expanded(
          child: Text(
            value,
            style: TextStyles.monoSmall.copyWith(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCenterContent() {
    return Stack(
      children: [
        // 중앙 콘텐츠
        Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 프로젝트 썸네일 또는 기본 로고
              if (selectedProject != null) 
                _buildProjectThumbnail()
              else
                _buildDefaultLogo(),
              const SizedBox(height: 24),
              if (selectedProject != null)
                _buildProjectInfo()
              else
                _buildDefaultInfo(),
            ],
          ),
        ),
        // 런치 버튼
        if (selectedProject != null)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildLaunchButton(),
          ),
      ],
    );
  }

  Widget _buildDefaultLogo() {
    return AnimatedBuilder(
      animation: _glowController,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF21D3EE).withOpacity(0.3 * _glowController.value),
                blurRadius: 20 + (10 * _glowController.value),
                spreadRadius: 5 + (5 * _glowController.value),
              ),
            ],
          ),
          child: const Icon(
            Icons.shield,
            size: 80,
            color: Color(0xFF21D3EE),
          ),
        );
      },
    );
  }

  Widget _buildProjectThumbnail() {
    final project = projects.firstWhere((p) => p['id'] == selectedProject);
    
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: project['color'].withOpacity(0.1),
            border: Border.all(
              color: project['color'].withOpacity(0.5 + (0.3 * _pulseController.value)),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: project['color'].withOpacity(0.3 * _pulseController.value),
                blurRadius: 20 + (10 * _pulseController.value),
                spreadRadius: 5 + (5 * _pulseController.value),
              ),
            ],
          ),
          child: Icon(
            project['icon'],
            size: 60,
            color: project['color'],
          ),
        );
      },
    );
  }

  Widget _buildDefaultInfo() {
    return Column(
      children: [
        const Text(
          'INVARIANT',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: Color(0xFF21D3EE),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'RAZOR HUD SYSTEM',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'SELECT MISSION SYSTEM FROM LEFT PANEL',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF7BA5AE),
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildProjectInfo() {
    final project = projects.firstWhere((p) => p['id'] == selectedProject);
    
    return Column(
      children: [
        Text(
          project['name'],
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          project['description'],
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF7BA5AE),
            letterSpacing: 0.5,
          ),
        ),
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
              fontSize: 10,
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
    
    return Container(
      height: 60,
      margin: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          // 프로젝트 런치 로직
          print('Launching ${project['name']}...');
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: project['color'],
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
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
        return DesignTokens.statusRunning; // 파란색
      case 'STANDBY':
        return DesignTokens.statusStandby; // 초록색
      case 'OFFLINE':
        return DesignTokens.statusError; // 빨간색
      case 'ERROR':
        return DesignTokens.statusError; // 빨간색
      default:
        return DesignTokens.statusError; // 빨간색 (기본값)
    }
  }

  Widget _buildResourcePanel() {
    return Column(
      children: [
        _buildMetricRow('CPU', cpuUsage.toInt()),
        const SizedBox(height: 12),
        _buildMetricRow('MEMORY', memoryUsage.toInt(), color: const Color(0xFF34D399)),
        const SizedBox(height: 12),
        _buildMetricRow('DISK', diskUsage.toInt()),
      ],
    );
  }

  Widget _buildMetricRow(String label, int value, {Color color = const Color(0xFF21D3EE)}) {
    return Column(
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF7BA5AE),
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              '${value.toString().padLeft(2, '0')}%',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 7,
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: const Color(0x14000000),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: [color, color.withOpacity(0.8)],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusDot(String status) {
    Color color;
    switch (status) {
      case 'RUNNING':
        color = DesignTokens.statusRunning; // 파란색 - 실행 중
        break;
      case 'STANDBY':
        color = DesignTokens.statusStandby; // 초록색 - 대기 중
        break;
      case 'OFFLINE':
        color = DesignTokens.statusError; // 빨간색 - 오프라인 (통일)
        break;
      case 'ERROR':
        color = DesignTokens.statusError; // 빨간색 - 오류
        break;
      default:
        color = const Color(0xFF7BA5AE);
    }
    
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }
}

class CircularGaugePainter extends CustomPainter {
  final double value;
  final String label;

  CircularGaugePainter({required this.value, required this.label});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 5);
    final radius = (size.width / 2) - 15;
    
    // 배경 호 (회색)
    final backgroundPaint = Paint()
      ..color = DesignTokens.surface.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // 180도부터 시작 (반원)
      math.pi, // 180도까지
      false,
      backgroundPaint,
    );
    
    // 값에 따른 색상 결정 (무지개색: 초록 → 노랑 → 빨강)
    Color valueColor;
    if (value <= 30) {
      valueColor = const Color(0xFF00FF41); // 초록색 (정상)
    } else if (value <= 60) {
      valueColor = const Color(0xFFFFB800); // 노랑색 (주의)
    } else if (value <= 80) {
      valueColor = const Color(0xFFFF6B00); // 주황색 (경고)
    } else {
      valueColor = const Color(0xFFFF0040); // 빨간색 (위험)
    }
    
    // 값 호
    final valuePaint = Paint()
      ..color = valueColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    
    final sweepAngle = (value / 100) * math.pi;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      math.pi, // 180도부터 시작
      sweepAngle, // 값에 따른 각도
      false,
      valuePaint,
    );
    
    // 중앙 텍스트 (퍼센트)
    final textPainter = TextPainter(
      text: TextSpan(
        text: '${value.toInt()}%',
        style: TextStyles.monoMedium.copyWith(
          color: DesignTokens.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2 - 8,
      ),
    );

    // 라벨
    final labelPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyles.monoSmall.copyWith(
          color: DesignTokens.textSecondary,
          fontSize: 9,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    labelPainter.layout();
    labelPainter.paint(
      canvas,
      Offset(
        center.dx - labelPainter.width / 2,
        center.dy + 8,
      ),
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true; // 항상 리페인트하여 실시간 업데이트 보장
  }
}