import 'package:flutter/material.dart';
import '../models/db_models.dart';

class QueryResultTable extends StatelessWidget {
  final QueryResult result;

  const QueryResultTable({
    super.key,
    required this.result,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (result.rows.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.inbox, size: 48, color: theme.colorScheme.outline),
              const SizedBox(height: 8),
              Text('No records found', style: theme.textTheme.titleMedium),
            ],
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Table header stats
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Icon(
                  Icons.table_chart,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Query Results',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 10),
                Chip(
                  label: Text('${result.rows.length} rows'),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelStyle: theme.textTheme.labelSmall,
                ),
                const SizedBox(width: 6),
                Chip(
                  avatar: const Icon(Icons.bolt, size: 14, color: Colors.amber),
                  label: Text('${result.executionTimeMs} ms'),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  labelStyle: theme.textTheme.labelSmall,
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Simulated CSV export complete!'),
                      ),
                    );
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Export CSV'),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Scrollable table
          ClipRRect(
            borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: DataTable(
                  headingRowColor: WidgetStateProperty.all(
                    theme.colorScheme.surfaceContainerHighest.withAlpha(120),
                  ),
                  columns: result.columns.map((col) {
                    return DataColumn(
                      label: Text(
                        col,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    );
                  }).toList(),
                  rows: result.rows.map((row) {
                    return DataRow(
                      cells: result.columns.map((col) {
                        final val = row[col];
                        return DataCell(
                          Text(
                            val?.toString() ?? 'NULL',
                            style: TextStyle(
                              fontFamily: val is num ? 'monospace' : null,
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
