import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class ProjectSelector extends StatelessWidget {
  final Map<String, dynamic> project;
  final int index;
  final Function(String) onSelect;

  const ProjectSelector({
    super.key,
    required this.project,
    required this.index,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final color = project['color'] as Color;
    final hasDisplay = project['hasDisplay'] as bool;

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasDisplay ? color.withOpacity(0.5) : Colors.grey.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: hasDisplay ? color.withOpacity(0.2) : Colors.transparent,
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: hasDisplay ? () => onSelect(project['name'] as String) : null,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: hasDisplay ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(
                      color: hasDisplay ? color : Colors.grey,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    project['icon'] as IconData,
                    color: hasDisplay ? color : Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  project['name'] as String,
                  style: TextStyle(
                    color: hasDisplay ? Colors.white : Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  project['description'] as String,
                  style: TextStyle(
                    color: hasDisplay ? Colors.grey : Colors.grey.withOpacity(0.5),
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: hasDisplay ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    hasDisplay ? 'READY' : 'OFFLINE',
                    style: TextStyle(
                      color: hasDisplay ? color : Colors.grey,
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(
      duration: 500.ms,
      delay: (index * 100).ms,
    ).scale(
      begin: const Offset(0.8, 0.8),
      end: const Offset(1.0, 1.0),
      duration: 500.ms,
      delay: (index * 100).ms,
    );
  }
}
