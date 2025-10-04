import 'dart:convert';
import 'dart:io';

/// ---------- Data Models ----------
class CpuInfo {
  final String model;      // e.g., "i9-13900K" (Intel/AMD 제거)
  final int cores;         // physical cores (fallback: logical)
  CpuInfo({required this.model, required this.cores});
}

class MemoryInfo {
  final String type;       // e.g., "DDR5" (unknown 가능)
  final int totalGB;       // total rounded GB
  MemoryInfo({required this.type, required this.totalGB});
}

class DiskInfo {
  final String kind;       // "SSD" | "HDD" | "NVMe" | "Unknown"
  final int sizeGB;        // rounded GB
  DiskInfo({required this.kind, required this.sizeGB});
}

class SystemSpec {
  final CpuInfo cpu;
  final MemoryInfo memory;
  final List<DiskInfo> disks;
  SystemSpec({required this.cpu, required this.memory, required this.disks});
}

/// ---------- Public API ----------
Future<SystemSpec> probeSystem() async {
  if (Platform.isWindows) {
    return _probeWindows();
  } else if (Platform.isMacOS) {
    return _probeMac();
  } else if (Platform.isLinux) {
    return _probeLinux();
  }
  // Fallback (unsupported)
  return SystemSpec(
    cpu: CpuInfo(model: 'Unknown', cores: Platform.numberOfProcessors),
    memory: MemoryInfo(type: 'Unknown', totalGB: 0),
    disks: const [],
  );
}

/// ---------- Utilities ----------
String _cleanCpuModel(String raw) {
  // Remove vendor noise to keep "i7/i9/Ryzen 9" flavor
  var s = raw;
  for (final junk in [
    'Intel(R)', 'Intel', 'Core(TM)', 'Core', 'CPU', 'Processor',
    'AMD', 'Ryzen', '(TM)', '(R)', 'with Radeon Graphics'
  ]) {
    s = s.replaceAll(junk, '');
  }
  s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
  // Convert "Ryzen 9 7950X" -> "9 7950X" (we still want the family number)
  s = s.replaceAll(RegExp(r'^([Rr]yzen)\s'), '');
  // Common splits
  s = s.replaceAll('@', '').split('  ').first.trim();
  return s;
}

int _bytesToGB(dynamic bytes) {
  if (bytes is String) {
    final v = int.tryParse(bytes.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    return (v / (1024 * 1024 * 1024)).round();
  } else if (bytes is int) {
    return (bytes / (1024 * 1024 * 1024)).round();
  }
  return 0;
}

String _mapWinMemoryType(int? smbiosType) {
  // WMI Win32_PhysicalMemory.SMBIOSMemoryType mapping (common subset)
  switch (smbiosType) {
    case 26: return 'DDR4';
    case 24: return 'DDR3';
    case 27: return 'LPDDR4';
    case 28: return 'LPDDR4X';
    case 29: return 'LPDDR5';
    case 34: return 'DDR5';
    default: return 'Unknown';
  }
}

/// Execute command and return stdout (trimmed). On Windows uses PowerShell if binary is 'powershell'.
Future<String> _run(String exe, List<String> args) async {
  final result = await Process.run(exe, args, runInShell: Platform.isWindows);
  if (result.exitCode != 0) return '';
  return (result.stdout is String ? result.stdout as String : utf8.decode(result.stdout)).trim();
}

/// ---------- Windows ----------
Future<SystemSpec> _probeWindows() async {
  // CPU (Name, Cores)
  final cpuOut = await _run('powershell', [
    '-NoProfile', '-Command',
    r"(Get-CimInstance Win32_Processor | Select-Object -First 1 Name,NumberOfCores | ConvertTo-Json)"
  ]);
  String cpuModel = 'Unknown';
  int cores = Platform.numberOfProcessors;
  if (cpuOut.isNotEmpty) {
    final map = jsonDecode(cpuOut);
    cpuModel = _cleanCpuModel(map['Name'] ?? 'Unknown');
    cores = (map['NumberOfCores'] ?? cores) as int;
  }

  // Memory (Type + Total)
  final memTypeOut = await _run('powershell', [
    '-NoProfile','-Command',
    r"(Get-CimInstance Win32_PhysicalMemory | Select-Object -ExpandProperty SMBIOSMemoryType | ConvertTo-Json)"
  ]);
  String memType = 'Unknown';
  if (memTypeOut.isNotEmpty) {
    try {
      final decoded = jsonDecode(memTypeOut);
      final list = decoded is List ? decoded.cast<int>() : [decoded as int];
      // take most common type code
      final freq = <int,int>{};
      for (final t in list) { freq[t] = (freq[t] ?? 0) + 1; }
      final best = (freq.keys.toList()..sort((a,b)=>freq[b]!.compareTo(freq[a]!))).first;
      memType = _mapWinMemoryType(best);
    } catch (_) {}
  }
  // Total memory
  final memTotalOut = await _run('powershell', [
    '-NoProfile','-Command',
    r"(Get-CimInstance Win32_ComputerSystem).TotalPhysicalMemory"
  ]);
  final totalGB = _bytesToGB(memTotalOut);

  // Disks (MediaType + Size). Prefer Get-PhysicalDisk (Win10+), fallback Win32_DiskDrive
  String disksJson = await _run('powershell', [
    '-NoProfile','-Command',
    r"if (Get-Command Get-PhysicalDisk -ErrorAction SilentlyContinue) { Get-PhysicalDisk | Select MediaType, Size | ConvertTo-Json } else { Get-CimInstance Win32_DiskDrive | Select MediaType, Size | ConvertTo-Json }"
  ]);
  final disks = <DiskInfo>[];
  if (disksJson.isNotEmpty) {
    final decoded = jsonDecode(disksJson);
    final list = decoded is List ? decoded : [decoded];
    for (final d in list) {
      String kind = '${d['MediaType'] ?? 'Unknown'}'.toUpperCase();
      if (kind.contains('SSD') || kind.contains('NVME')) kind = kind.contains('NVME') ? 'NVMe' : 'SSD';
      else if (kind.contains('HDD') || kind.contains('HARD DISK')) kind = 'HDD';
      else kind = 'Unknown';
      disks.add(DiskInfo(kind: kind, sizeGB: _bytesToGB(d['Size'])));
    }
  }

  return SystemSpec(
    cpu: CpuInfo(model: cpuModel, cores: cores),
    memory: MemoryInfo(type: memType, totalGB: totalGB),
    disks: disks,
  );
}

/// ---------- macOS ----------
Future<SystemSpec> _probeMac() async {
  // CPU
  final brand = await _run('sysctl', ['-n', 'machdep.cpu.brand_string']);
  final coresStr = await _run('sysctl', ['-n', 'hw.physicalcpu']);
  final cpu = CpuInfo(
    model: _cleanCpuModel(brand),
    cores: int.tryParse(coresStr) ?? Platform.numberOfProcessors,
  );

  // Memory
  final memBytes = await _run('sysctl', ['-n', 'hw.memsize']);
  String memType = 'Unknown';
  final spMem = await _run('system_profiler', ['SPMemoryDataType']);
  final typeMatch = RegExp(r'Type:\s*(.+)').firstMatch(spMem);
  if (typeMatch != null) memType = typeMatch.group(1)!.trim();
  final memory = MemoryInfo(type: memType, totalGB: _bytesToGB(int.tryParse(memBytes) ?? 0));

  // Disks (NVMe / SATA)
  final nvme = await _run('system_profiler', ['SPNVMeDataType']);
  final sata = await _run('system_profiler', ['SPSerialATADataType']);
  final disks = <DiskInfo>[];
  for (final m in RegExp(r'Capacity:\s*([\d\.]+)\s*GB', multiLine: true).allMatches(nvme)) {
    disks.add(DiskInfo(kind: 'NVMe', sizeGB: double.parse(m.group(1)!).round()));
  }
  for (final m in RegExp(r'Capacity:\s*([\d\.]+)\s*GB', multiLine: true).allMatches(sata)) {
    disks.add(DiskInfo(kind: 'HDD', sizeGB: double.parse(m.group(1)!).round())); // SATA SSD면 Kind 'SSD'로 교체
  }
  // try to detect SSD in SATA text
  if (sata.contains('Solid State')) {
    for (int i=0;i<disks.length;i++) {
      if (disks[i].kind=='HDD') disks[i] = DiskInfo(kind:'SSD', sizeGB:disks[i].sizeGB);
    }
  }

  return SystemSpec(cpu: cpu, memory: memory, disks: disks);
}

/// ---------- Linux ----------
Future<SystemSpec> _probeLinux() async {
  // CPU
  final cpuinfo = await File('/proc/cpuinfo').readAsString();
  final modelLine = RegExp(r'model name\s*:\s*(.+)').firstMatch(cpuinfo)?.group(1) ?? 'Unknown';
  final coresLine = RegExp(r'cpu cores\s*:\s*(\d+)').firstMatch(cpuinfo)?.group(1);
  final cpu = CpuInfo(model: _cleanCpuModel(modelLine), cores: int.tryParse(coresLine ?? '') ?? Platform.numberOfProcessors);

  // Memory
  final meminfo = await File('/proc/meminfo').readAsString();
  final memTotalKbStr = RegExp(r'MemTotal:\s*(\d+)\s*kB').firstMatch(meminfo)?.group(1) ?? '0';
  String memType = 'Unknown';
  // Try dmidecode (needs permissions, so best-effort)
  final dmi = await _run('bash', ['-lc', 'which dmidecode >/dev/null 2>&1 && sudo dmidecode -t memory | grep -E "Type:|Speed:" || true']);
  final typeMatch = RegExp(r'Type:\s*(\w+)', multiLine: true).firstMatch(dmi);
  if (typeMatch != null) memType = typeMatch.group(1)!.toUpperCase();

  final memory = MemoryInfo(type: memType, totalGB: ((int.parse(memTotalKbStr) * 1024) / (1024*1024*1024)).round());

  // Disks via lsblk (ROTA=1 → HDD, 0 → SSD/NVMe)
  final lsblk = await _run('bash', ['-lc', r"lsblk -b -o NAME,TYPE,SIZE,ROTA -J"]);
  final disks = <DiskInfo>[];
  if (lsblk.isNotEmpty) {
    final map = jsonDecode(lsblk) as Map<String, dynamic>;
    for (final dev in (map['blockdevices'] as List)) {
      if (dev['type'] == 'disk') {
        final sizeGB = _bytesToGB(dev['size']);
        final rota = (dev['rota'] ?? 0) == 1;
        final name = '${dev['name']}';
        String kind = rota ? 'HDD' : (name.contains('nvme') ? 'NVMe' : 'SSD');
        disks.add(DiskInfo(kind: kind, sizeGB: sizeGB));
      }
    }
  }

  return SystemSpec(cpu: cpu, memory: memory, disks: disks);
}
