import 'package:flutter/material.dart';
import 'dart:ui';
import 'system_probe.dart';

/// Pretendard를 전역 폰트로 쓰고 있다고 가정.
/// 간단한 UI: CPU/메모리/디스크 표 + 메트릭 바
class ResourceMonitorPanel extends StatefulWidget {
  const ResourceMonitorPanel({super.key});
  @override State<ResourceMonitorPanel> createState() => _ResourceMonitorPanelState();
}

class _ResourceMonitorPanelState extends State<ResourceMonitorPanel> {
  SystemSpec? spec;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final s = await probeSystem();
      setState(() { spec = s; loading = false; });
    } catch (_) {
      setState(() { loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    if (loading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (spec == null) {
      return const Center(child: Text('Unable to read system info'));
    }

    final s = spec!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('SYSTEM', style: t.titleSmall),
        const SizedBox(height: 8),
        _row('CPU', '${s.cpu.model}  •  ${s.cpu.cores} cores'),
        _row('MEMORY', '${s.memory.type}  •  ${s.memory.totalGB} GB'),
        const SizedBox(height: 8),
        Text('DISKS', style: t.titleSmall),
        const SizedBox(height: 6),
        ...s.disks.map((d)=>_row('• ${d.kind}', '${d.sizeGB} GB')).toList(),
        const SizedBox(height: 16),
        // 예시: 현재 사용률이 있다면 여기 값 바인딩 (여기선 데모로 가짜 값)
        _metric('CPU Usage', 0.23),
        const SizedBox(height: 10),
        _metric('Memory Used', 0.52),
        const SizedBox(height: 10),
        _metric('Disk Used', 0.32),
      ],
    );
  }

  Widget _row(String left, String right) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(children: [
        Text(left, style: t.titleMedium),
        const Spacer(),
        Text(right, style: t.titleMedium!.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        )),
      ]),
    );
  }

  Widget _metric(String label, double value) {
    final t = Theme.of(context).textTheme;
    final pct = (value * 100).round();
    return Column(
      children: [
        Row(children: [
          Text(label, style: t.titleSmall),
          const Spacer(),
          Text('$pct%', style: t.titleMedium!.copyWith(
            fontFeatures: const [FontFeature.tabularFigures()],
          )),
        ]),
        const SizedBox(height: 6),
        SizedBox(height: 7, child: Stack(children: [
          Container(decoration: BoxDecoration(
            color: const Color(0x14000000), borderRadius: BorderRadius.circular(4))),
          FractionallySizedBox(widthFactor: value.clamp(0,1), child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              gradient: const LinearGradient(colors: [Color(0xFF21D3EE), Color(0xFF34D399)]),
            ),
          )),
        ])),
      ],
    );
  }
}
