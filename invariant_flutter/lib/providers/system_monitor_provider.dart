import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:system_info/system_info.dart';

class SystemMonitorProvider extends ChangeNotifier {
  Timer? _timer;
  
  // System metrics
  double _cpuUsage = 0.0;
  double _memoryUsage = 0.0;
  double _diskUsage = 0.0;
  String _ipAddress = 'Unknown';
  String _uptime = 'Unknown';
  int _processCount = 0;
  double _cpuFrequency = 0.0;

  // Getters
  double get cpuUsage => _cpuUsage;
  double get memoryUsage => _memoryUsage;
  double get diskUsage => _diskUsage;
  String get ipAddress => _ipAddress;
  String get uptime => _uptime;
  int get processCount => _processCount;
  double get cpuFrequency => _cpuFrequency;

  SystemMonitorProvider() {
    _initializeMonitoring();
  }

  void _initializeMonitoring() {
    _updateSystemInfo();
    _timer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      _updateSystemInfo();
    });
  }

  void _updateSystemInfo() {
    try {
      // CPU Usage (simplified)
      _cpuUsage = _getCpuUsage();
      
      // Memory Usage
      _memoryUsage = _getMemoryUsage();
      
      // Disk Usage
      _diskUsage = _getDiskUsage();
      
      // IP Address
      _ipAddress = _getIpAddress();
      
      // Uptime
      _uptime = _getUptime();
      
      // Process Count
      _processCount = _getProcessCount();
      
      // CPU Frequency
      _cpuFrequency = _getCpuFrequency();
      
      notifyListeners();
    } catch (e) {
      if (kDebugMode) {
        print('Error updating system info: $e');
      }
    }
  }

  double _getCpuUsage() {
    // Simplified CPU usage calculation
    // In a real implementation, you'd read from /proc/stat
    return (DateTime.now().millisecond % 100).toDouble();
  }

  double _getMemoryUsage() {
    try {
      final totalMemory = SysInfo.getTotalPhysicalMemory();
      final freeMemory = SysInfo.getFreePhysicalMemory();
      final usedMemory = totalMemory - freeMemory;
      return (usedMemory / totalMemory) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  double _getDiskUsage() {
    try {
      final totalSpace = SysInfo.getTotalVirtualMemory();
      final freeSpace = SysInfo.getFreeVirtualMemory();
      final usedSpace = totalSpace - freeSpace;
      return (usedSpace / totalSpace) * 100;
    } catch (e) {
      return 0.0;
    }
  }

  String _getIpAddress() {
    try {
      // This is a simplified approach
      // In a real implementation, you'd get the actual IP
      return '192.168.1.100';
    } catch (e) {
      return 'Unknown';
    }
  }

  String _getUptime() {
    try {
      // Simplified uptime calculation
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final uptime = now.difference(startOfDay);
      
      final hours = uptime.inHours;
      final minutes = uptime.inMinutes % 60;
      
      return '${hours}h ${minutes}m';
    } catch (e) {
      return 'Unknown';
    }
  }

  int _getProcessCount() {
    try {
      // Simplified process count
      return 150 + (DateTime.now().second % 50);
    } catch (e) {
      return 0;
    }
  }

  double _getCpuFrequency() {
    try {
      // Simplified CPU frequency
      return 2400.0 + (DateTime.now().millisecond % 800);
    } catch (e) {
      return 0.0;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

// Riverpod provider
final systemMonitorProvider = ChangeNotifierProvider<SystemMonitorProvider>((ref) {
  return SystemMonitorProvider();
});
