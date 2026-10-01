import 'package:flutter/material.dart';
import '../models/db_models.dart';

class ConnectionModal extends StatelessWidget {
  final List<DbConnection> connections;
  final DbConnection activeConnection;
  final ValueChanged<DbConnection> onSelectConnection;

  const ConnectionModal({
    super.key,
    required this.connections,
    required this.activeConnection,
    required this.onSelectConnection,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Row(
        children: [
          Icon(Icons.storage, color: theme.colorScheme.primary),
          const SizedBox(width: 10),
          const Text('Database Connections'),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.separated(
          shrinkWrap: true,
          itemCount: connections.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final conn = connections[index];
            final isSelected = conn.id == activeConnection.id;

            return ListTile(
              selected: isSelected,
              selectedTileColor: theme.colorScheme.primaryContainer.withAlpha(50),
              leading: Icon(
                isSelected ? Icons.check_circle : Icons.circle_outlined,
                color: isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
              ),
              title: Text(
                conn.name,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              subtitle: Text(
                '${conn.dialect.label} • ${conn.databaseName}',
                style: theme.textTheme.bodySmall,
              ),
              trailing: Chip(
                label: Text(
                  isSelected ? 'Connected' : 'Available',
                  style: TextStyle(
                    fontSize: 11,
                    color: isSelected ? Colors.green.shade800 : theme.colorScheme.outline,
                  ),
                ),
                backgroundColor: isSelected ? Colors.green.shade100 : null,
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              onTap: () {
                onSelectConnection(conn);
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
