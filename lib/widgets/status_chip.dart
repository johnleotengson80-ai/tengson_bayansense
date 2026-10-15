import 'package:flutter/material.dart';

/// Shows a report status. The meaning is always in the TEXT; color is only extra (Activity 6, Part G).
class StatusChip extends StatelessWidget {
  const StatusChip({super.key, required this.label});

  /// Typically 'Received', 'In Progress', 'Resolved', or 'Needs Review'.
  final String label;

  static const Map<String, List<Color>> _palette = {
    // [background, text]
    'Received': [Color(0xFFE3F2FD), Color(0xFF0D47A1)],
    'In Progress': [Color(0xFFFFF3E0), Color(0xFFE65100)],
    'Resolved': [Color(0xFFE8F5E9), Color(0xFF1B5E20)],
    'Needs Review': [Color(0xFFFCE4EC), Color(0xFF880E4F)],
  };

  @override
  Widget build(BuildContext context) {
    final colors = _palette[label] ?? const [Color(0xFFECEFF1), Color(0xFF37474F)];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: colors[0],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: colors[1], fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }
}
