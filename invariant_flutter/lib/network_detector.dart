import 'dart:io';
import 'dart:convert';

/// 네트워크 연결 정보
class NetworkInfo {
  final List<String> ips; // 여러 IP 주소
  final String connectionType;
  final bool isVpnConnected;
  final String interface;
  final int signalStrength; // 0-100
  final String ssid; // WiFi SSID
  
  NetworkInfo({
    required this.ips,
    required this.connectionType,
    required this.isVpnConnected,
    required this.interface,
    required this.signalStrength,
    required this.ssid,
  });
  
  // 기존 호환성을 위한 getter
  String get ip => ips.isNotEmpty ? ips.first : 'Unknown';
}

/// 네트워크 감지 클래스
class NetworkDetector {
  static Future<NetworkInfo> getNetworkInfo() async {
    if (Platform.isLinux) {
      return _getLinuxNetworkInfo();
    } else if (Platform.isWindows) {
      return _getWindowsNetworkInfo();
    } else if (Platform.isMacOS) {
      return _getMacNetworkInfo();
    }
    
    // Fallback
    return NetworkInfo(
      ips: ['127.0.0.1'],
      connectionType: 'Unknown',
      isVpnConnected: false,
      interface: 'lo',
      signalStrength: 0,
      ssid: '',
    );
  }

  /// Linux 네트워크 정보 감지
  static Future<NetworkInfo> _getLinuxNetworkInfo() async {
    try {
      // 모든 IP 주소 가져오기
      final ipResult = await Process.run('bash', ['-c', r'''
        ip addr show | grep -oP 'inet \K[0-9.]+' | grep -v '127.0.0.1' | sort -u
      ''']);
      
      List<String> ips = ['127.0.0.1'];
      if (ipResult.exitCode == 0) {
        final output = ipResult.stdout.toString().trim();
        if (output.isNotEmpty) {
          ips = output.split('\n').where((ip) => ip.isNotEmpty).toList();
        }
      }

      // 네트워크 인터페이스 정보
      final interfaceResult = await Process.run('bash', ['-c', r'''
        ip route get 8.8.8.8 2>/dev/null | grep -oP 'dev \K\S+' || echo "eth0"
      ''']);
      
      String interface = 'eth0';
      if (interfaceResult.exitCode == 0) {
        interface = interfaceResult.stdout.toString().trim();
      }

      // 연결 타입 감지
      String connectionType = 'LAN';
      int signalStrength = 100;
      String ssid = '';

      // WiFi 감지
      if (interface.startsWith('wlan') || interface.startsWith('wlp')) {
        connectionType = 'WiFi';
        
        // WiFi 신호 강도
        final signalResult = await Process.run('bash', ['-c', r'''
          iwconfig $interface 2>/dev/null | grep -oP 'Signal level=\K[0-9-]+' | head -1 || echo "-50"
        '''.replaceAll('\$interface', interface)]);
        
        if (signalResult.exitCode == 0) {
          final signalStr = signalResult.stdout.toString().trim();
          final signal = int.tryParse(signalStr) ?? -50;
          // -100 (약함) ~ -30 (강함)을 0-100으로 변환
          signalStrength = ((signal + 100) * 100 / 70).clamp(0, 100).round();
        }

        // SSID 가져오기
        final ssidResult = await Process.run('bash', ['-c', r'''
          iwconfig $interface 2>/dev/null | grep -oP 'ESSID:"\K[^"]+' || echo ""
        '''.replaceAll('\$interface', interface)]);
        
        if (ssidResult.exitCode == 0) {
          ssid = ssidResult.stdout.toString().trim();
        }
      }
      
      // 모바일 네트워크 감지 (USB 테더링 등)
      else if (interface.startsWith('usb') || interface.startsWith('wwan')) {
        connectionType = 'Mobile';
        signalStrength = 75; // 기본값
      }
      
      // 이더넷
      else if (interface.startsWith('eth') || interface.startsWith('en')) {
        connectionType = 'LAN';
        signalStrength = 100;
      }

      // VPN 감지
      bool isVpnConnected = false;
      final vpnResult = await Process.run('bash', ['-c', r'''
        ip tuntap show 2>/dev/null | grep -q tun && echo "true" || 
        ip link show | grep -q tun && echo "true" ||
        ps aux | grep -E "(openvpn|wireguard|nordvpn|expressvpn)" | grep -v grep | wc -l | awk '{if($1>0) print "true"; else print "false"}'
      ''']);
      
      if (vpnResult.exitCode == 0) {
        isVpnConnected = vpnResult.stdout.toString().trim() == 'true';
      }

      return NetworkInfo(
        ips: ips,
        connectionType: connectionType,
        isVpnConnected: isVpnConnected,
        interface: interface,
        signalStrength: signalStrength,
        ssid: ssid,
      );
    } catch (e) {
      print('Network detection error: $e');
      return NetworkInfo(
        ips: ['127.0.0.1'],
        connectionType: 'Unknown',
        isVpnConnected: false,
        interface: 'lo',
        signalStrength: 0,
        ssid: '',
      );
    }
  }

  /// Windows 네트워크 정보 감지
  static Future<NetworkInfo> _getWindowsNetworkInfo() async {
    try {
      // 모든 IP 주소
      final ipResult = await Process.run('powershell', [
        '-NoProfile', '-Command',
        r"(Get-NetIPAddress -AddressFamily IPv4 | Where-Object {$_.IPAddress -notlike '127.*' -and $_.IPAddress -notlike '169.254.*'} | Select-Object -ExpandProperty IPAddress) -join '`n'"
      ]);
      
      List<String> ips = ['127.0.0.1'];
      if (ipResult.exitCode == 0) {
        final output = ipResult.stdout.toString().trim();
        if (output.isNotEmpty) {
          ips = output.split('\n').where((ip) => ip.isNotEmpty).toList();
        }
      }

      // 네트워크 어댑터 정보
      final adapterResult = await Process.run('powershell', [
        '-NoProfile', '-Command',
        r"Get-NetAdapter | Where-Object {$_.Status -eq 'Up' -and $_.InterfaceDescription -notlike '*Loopback*'} | Select-Object -First 1 | ConvertTo-Json"
      ]);
      
      String connectionType = 'LAN';
      String interface = 'Ethernet';
      int signalStrength = 100;
      String ssid = '';

      if (adapterResult.exitCode == 0) {
        try {
          final adapter = jsonDecode(adapterResult.stdout.toString());
          interface = adapter['Name'] ?? 'Ethernet';
          
          // WiFi 감지
          if (adapter['InterfaceDescription']?.toString().toLowerCase().contains('wireless') == true ||
              adapter['InterfaceDescription']?.toString().toLowerCase().contains('wifi') == true) {
            connectionType = 'WiFi';
            
            // WiFi 신호 강도
            final signalResult = await Process.run('powershell', [
              '-NoProfile', '-Command',
              r"(netsh wlan show profiles | Select-String 'All User Profile').Count"
            ]);
            
            // SSID 가져오기
            final ssidResult = await Process.run('powershell', [
              '-NoProfile', '-Command',
              r"(netsh wlan show interfaces | Select-String 'SSID').Line.Split(':')[1].Trim()"
            ]);
            
            if (ssidResult.exitCode == 0) {
              ssid = ssidResult.stdout.toString().trim();
            }
            
            signalStrength = 75; // Windows에서는 정확한 신호 강도 측정이 복잡
          }
        } catch (e) {
          print('Windows adapter parsing error: $e');
        }
      }

      // VPN 감지
      bool isVpnConnected = false;
      final vpnResult = await Process.run('powershell', [
        '-NoProfile', '-Command',
        r"Get-NetAdapter | Where-Object {$_.InterfaceDescription -like '*VPN*' -or $_.InterfaceDescription -like '*TAP*' -or $_.InterfaceDescription -like '*TUN*'} | Measure-Object | Select-Object -ExpandProperty Count"
      ]);
      
      if (vpnResult.exitCode == 0) {
        final count = int.tryParse(vpnResult.stdout.toString().trim()) ?? 0;
        isVpnConnected = count > 0;
      }

      return NetworkInfo(
        ips: ips,
        connectionType: connectionType,
        isVpnConnected: isVpnConnected,
        interface: interface,
        signalStrength: signalStrength,
        ssid: ssid,
      );
    } catch (e) {
      print('Windows network detection error: $e');
      return NetworkInfo(
        ips: ['127.0.0.1'],
        connectionType: 'Unknown',
        isVpnConnected: false,
        interface: 'Ethernet',
        signalStrength: 0,
        ssid: '',
      );
    }
  }

  /// macOS 네트워크 정보 감지
  static Future<NetworkInfo> _getMacNetworkInfo() async {
    try {
      // 모든 IP 주소
      final ipResult = await Process.run('bash', ['-c', r'''
        ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | sort -u
      ''']);
      
      List<String> ips = ['127.0.0.1'];
      if (ipResult.exitCode == 0) {
        final output = ipResult.stdout.toString().trim();
        if (output.isNotEmpty) {
          ips = output.split('\n').where((ip) => ip.isNotEmpty).toList();
        }
      }

      // 네트워크 인터페이스
      final interfaceResult = await Process.run('bash', ['-c', r'''
        route get 8.8.8.8 2>/dev/null | grep interface | awk '{print $2}' | head -1
      ''']);
      
      String interface = 'en0';
      if (interfaceResult.exitCode == 0) {
        interface = interfaceResult.stdout.toString().trim();
      }

      // 연결 타입 감지
      String connectionType = 'LAN';
      int signalStrength = 100;
      String ssid = '';

      // WiFi 감지
      if (interface.startsWith('en') && interface != 'en0') {
        connectionType = 'WiFi';
        
        // WiFi 신호 강도
        final signalResult = await Process.run('bash', ['-c', r'''
          /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep 'agrCtlRSSI' | awk '{print $2}'
        ''']);
        
        if (signalResult.exitCode == 0) {
          final signal = int.tryParse(signalResult.stdout.toString().trim()) ?? -50;
          signalStrength = ((signal + 100) * 100 / 70).clamp(0, 100).round();
        }

        // SSID
        final ssidResult = await Process.run('bash', ['-c', r'''
          /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep 'SSID' | awk '{print $2}'
        ''']);
        
        if (ssidResult.exitCode == 0) {
          ssid = ssidResult.stdout.toString().trim();
        }
      }

      // VPN 감지
      bool isVpnConnected = false;
      final vpnResult = await Process.run('bash', ['-c', r'''
        ifconfig | grep -E 'utun|tun' | wc -l | awk '{if($1>0) print "true"; else print "false"}'
      ''']);
      
      if (vpnResult.exitCode == 0) {
        isVpnConnected = vpnResult.stdout.toString().trim() == 'true';
      }

      return NetworkInfo(
        ips: ips,
        connectionType: connectionType,
        isVpnConnected: isVpnConnected,
        interface: interface,
        signalStrength: signalStrength,
        ssid: ssid,
      );
    } catch (e) {
      print('macOS network detection error: $e');
      return NetworkInfo(
        ips: ['127.0.0.1'],
        connectionType: 'Unknown',
        isVpnConnected: false,
        interface: 'en0',
        signalStrength: 0,
        ssid: '',
      );
    }
  }
}

