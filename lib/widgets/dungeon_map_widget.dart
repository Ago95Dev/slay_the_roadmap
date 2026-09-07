import 'package:flutter/material.dart';
import '../models/types.dart';

class DungeonMapWidget extends StatelessWidget {
  final DungeonRun dungeonRun;
  final Function(String) onRoomSelect;

  const DungeonMapWidget({
    super.key,
    required this.dungeonRun,
    required this.onRoomSelect,
  });

  @override
  Widget build(BuildContext context) {
    // Group rooms by floor (y coordinate)
    final maxY = dungeonRun.rooms.map((r) => r.y).reduce((a, b) => a > b ? a : b);
    final roomsByFloor = <int, List<DungeonRoom>>{};

    for (var y = 0; y <= maxY; y++) {
      roomsByFloor[y] = dungeonRun.rooms.where((r) => r.y == y).toList()
        ..sort((a, b) => a.x.compareTo(b.x));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Legend
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _LegendItem(icon: Icons.help_outline, label: 'Quiz', color: Colors.blue),
                _LegendItem(icon: Icons.local_fire_department, label: 'Combat', color: Colors.red),
                _LegendItem(icon: Icons.card_giftcard, label: 'Treasure', color: Colors.amber),
                _LegendItem(icon: Icons.local_cafe, label: 'Rest', color: Colors.green),
                _LegendItem(icon: Icons.shopping_cart, label: 'Merchant', color: Colors.orange),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Map
        ...List.generate(maxY + 1, (index) {
          final floor = maxY - index; // Reverse order
          final rooms = roomsByFloor[floor] ?? [];

          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Floor ${maxY - floor + 1}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: rooms.map((room) {
                    return _RoomNode(
                      room: room,
                      isAvailable: _isRoomAvailable(room),
                      isCurrent: room.id == dungeonRun.currentRoomId,
                      onTap: () {
                        if (_isRoomAvailable(room)) {
                          onRoomSelect(room.id);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  bool _isRoomAvailable(DungeonRoom room) {
    if (room.cleared) return false;
    if (dungeonRun.currentRoomId == null) return room.y == 0;

    final currentRoom = dungeonRun.rooms.firstWhere(
      (r) => r.id == dungeonRun.currentRoomId,
    );

    return currentRoom.connections.contains(room.id);
  }
}

class _LegendItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _LegendItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}

class _RoomNode extends StatelessWidget {
  final DungeonRoom room;
  final bool isAvailable;
  final bool isCurrent;
  final VoidCallback onTap;

  const _RoomNode({
    required this.room,
    required this.isAvailable,
    required this.isCurrent,
    required this.onTap,
  });

  IconData _getRoomIcon() {
    switch (room.type) {
      case DungeonRoomType.topicQuiz:
        return Icons.help_outline;
      case DungeonRoomType.combat:
        return Icons.local_fire_department;
      case DungeonRoomType.treasure:
        return Icons.card_giftcard;
      case DungeonRoomType.rest:
        return Icons.local_cafe;
      case DungeonRoomType.merchant:
        return Icons.shopping_cart;
      case DungeonRoomType.elite:
        return Icons.star;
      case DungeonRoomType.boss:
        return Icons.castle_outlined;
      case DungeonRoomType.secret:
        return Icons.help;
      default:
        return Icons.circle;
    }
  }

  Color _getRoomColor() {
    switch (room.type) {
      case DungeonRoomType.topicQuiz:
        return Colors.blue;
      case DungeonRoomType.combat:
        return Colors.red;
      case DungeonRoomType.treasure:
        return Colors.amber;
      case DungeonRoomType.rest:
        return Colors.green;
      case DungeonRoomType.merchant:
        return Colors.orange;
      case DungeonRoomType.elite:
        return Colors.pink;
      case DungeonRoomType.boss:
        return Colors.deepPurple;
      case DungeonRoomType.secret:
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getRoomColor();

    return GestureDetector(
      onTap: isAvailable ? onTap : null,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: room.cleared
                  ? Colors.grey[300]
                  : color,
              border: isCurrent
                  ? Border.all(color: Colors.white, width: 4)
                  : null,
              boxShadow: isCurrent
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.5),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Icon(
              room.cleared ? Icons.check : _getRoomIcon(),
              color: room.cleared || !isAvailable
                  ? Colors.grey[600]
                  : Colors.white,
              size: 32,
            ),
          ),
          if (!isAvailable && !room.cleared)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black26,
                ),
                child: const Icon(
                  Icons.lock,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          if (room.optional)
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.purple,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
