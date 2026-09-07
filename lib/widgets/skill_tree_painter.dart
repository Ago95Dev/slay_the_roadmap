import 'package:flutter/material.dart';
import '../models/types.dart';

class SkillTreePainter extends CustomPainter {
  final List<SkillNode> skills;
  final Map<String, Offset> nodePositions;

  SkillTreePainter({
    required this.skills,
    required this.nodePositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (final skill in skills) {
      if (skill.prerequisite != null && nodePositions.containsKey(skill.id)) {
        final startPos = nodePositions[skill.prerequisite];
        final endPos = nodePositions[skill.id];

        if (startPos != null && endPos != null) {
          // Determine line color based on unlock status
          // If both nodes are unlocked, line is full color
          // If prerequisite is unlocked but current is not, line is "active" but maybe dimmer
          // If prerequisite is locked, line is grey
          
          final prereqNode = skills.firstWhere((s) => s.id == skill.prerequisite);
          
          if (prereqNode.unlocked) {
            if (skill.unlocked) {
              paint.color = _getBranchColor(skill.branch); // Fully active path
            } else {
              paint.color = _getBranchColor(skill.branch).withValues(alpha: 0.5); // Available path
            }
          } else {
            paint.color = Colors.grey[800]!; // Locked path
          }

          // Draw curved line (Bezier)
          final path = Path();
          path.moveTo(startPos.dx, startPos.dy);
          
          // Control points for smooth curve
          final controlPoint1 = Offset(startPos.dx, (startPos.dy + endPos.dy) / 2);
          final controlPoint2 = Offset(endPos.dx, (startPos.dy + endPos.dy) / 2);
          
          path.cubicTo(
            controlPoint1.dx, controlPoint1.dy,
            controlPoint2.dx, controlPoint2.dy,
            endPos.dx, endPos.dy,
          );

          canvas.drawPath(path, paint);
        }
      }
    }
  }

  Color _getBranchColor(SkillBranch branch) {
    switch (branch) {
      case SkillBranch.offensive: return Colors.red[700]!;
      case SkillBranch.defensive: return Colors.blue[700]!;
      case SkillBranch.utility: return Colors.purple[700]!;
    }
  }

  @override
  bool shouldRepaint(covariant SkillTreePainter oldDelegate) {
    return true; // Repaint when skills update (unlock status changes)
  }
}
