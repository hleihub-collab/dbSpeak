import 'package:flutter/material.dart';
import '../models/db_models.dart';

class SchemaViewerSheet extends StatelessWidget {
  final List<TableSchema> tables;
  final String databaseName;

  const SchemaViewerSheet({
    super.key,
    required this.tables,
    required this.databaseName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Title Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.schema_outlined, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Database Schema Explorer',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$databaseName (${tables.length} tables)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.outline,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // Tables List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: tables.length,
                  itemBuilder: (context, index) {
                    final table = tables[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      elevation: 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: theme.colorScheme.outlineVariant.withAlpha(60),
                        ),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          radius: 16,
                          backgroundColor: theme.colorScheme.primaryContainer,
                          child: Icon(
                            Icons.table_view,
                            size: 18,
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                        title: Text(
                          table.name,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '~${table.rowCount} rows • ${table.columns.length} columns',
                          style: theme.textTheme.bodySmall,
                        ),
                        children: table.columns.map((col) {
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                            leading: Icon(
                              col.isPrimaryKey ? Icons.key : Icons.commit,
                              size: 16,
                              color: col.isPrimaryKey
                                  ? Colors.amber
                                  : theme.colorScheme.outline,
                            ),
                            title: Text(
                              col.name,
                              style: TextStyle(
                                fontWeight: col.isPrimaryKey
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                            trailing: Text(
                              col.type,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.secondary,
                                fontFamily: 'monospace',
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
