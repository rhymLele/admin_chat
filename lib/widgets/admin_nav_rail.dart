import 'package:flutter/material.dart';

class AdminNavRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const AdminNavRail({
    super.key,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onIndexChanged,
      labelType: NavigationRailLabelType.all,
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.dashboard),
          label: Text('Trang chủ'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.people),
          label: Text('Người dùng'),
        ),
      ],
    );
  }
}
