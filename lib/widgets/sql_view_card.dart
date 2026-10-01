import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/db_models.dart';

class SqlViewCard extends StatefulWidget {
  final QueryRecord record;
  final DbDialect dialect;
  final VoidCallback? onRerun;
  final VoidCallback? onToggleFavorite;

  const SqlViewCard({
    super.key,
    required this.record,
    required this.dialect,
    this.onRerun,
    this.onToggleFavorite,
  });

  @override
  State<SqlViewCard> createState() => _SqlViewCardState();
}

class _SqlViewCardState extends State<SqlViewCard> {
  bool _showExplanation = true;

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.record.sql));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('SQL query copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withAlpha(80),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? theme.colorScheme.surfaceContainerHighest
                  : theme.colorScheme.surfaceContainerLow,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.terminal,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Generated SQL',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.dialect.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(
                    widget.record.isFavorite ? Icons.star : Icons.star_border,
                    color: widget.record.isFavorite ? Colors.amber : null,
                    size: 20,
                  ),
                  tooltip: widget.record.isFavorite ? 'Favorited' : 'Add to favorites',
                  onPressed: widget.onToggleFavorite,
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 18),
                  tooltip: 'Copy SQL',
                  onPressed: _copyToClipboard,
                ),
                if (widget.onRerun != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: 'Re-run query',
                    onPressed: widget.onRerun,
                  ),
              ],
            ),
          ),

          // Code Box
          Container(
            padding: const EdgeInsets.all(16),
            color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFF24292E),
            child: SelectableText(
              widget.record.sql.trim(),
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 13.5,
                height: 1.5,
                color: Color(0xFFE1E4E8),
              ),
            ),
          ),

          // AI Explanation Section
          InkWell(
            onTap: () {
              setState(() {
                _showExplanation = !_showExplanation;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_awesome,
                    size: 16,
                    color: theme.colorScheme.tertiary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Query Explanation',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.tertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    _showExplanation
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 18,
                    color: theme.colorScheme.outline,
                  ),
                ],
              ),
            ),
          ),

          if (_showExplanation)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiaryContainer.withAlpha(70),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.record.explanation,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onTertiaryContainer,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
