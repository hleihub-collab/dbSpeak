import 'dart:async';
import 'package:flutter/material.dart';
import '../models/db_models.dart';
import '../services/mock_db_service.dart';
import '../widgets/voice_mic_button.dart';
import '../widgets/sql_view_card.dart';
import '../widgets/query_result_table.dart';
import '../widgets/schema_viewer_sheet.dart';
import '../widgets/connection_modal.dart';

class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _promptController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<DbConnection> _connections = MockDbService.defaultConnections;
  late DbConnection _activeConnection;

  QueryRecord? _currentRecord;
  final List<QueryRecord> _history = [];
  bool _isLoading = false;
  bool _isListening = false;
  Timer? _listeningSimulationTimer;

  @override
  void initState() {
    super.initState();
    _activeConnection = _connections.first;
    // Execute a default query so the user immediately sees a live demonstration!
    _runPrompt('Top 5 customers by lifetime spend');
  }

  @override
  void dispose() {
    _promptController.dispose();
    _scrollController.dispose();
    _listeningSimulationTimer?.cancel();
    super.dispose();
  }

  void _switchConnection(DbConnection connection) {
    setState(() {
      _activeConnection = connection;
      _connections = _connections.map((c) {
        return c.copyWith(isConnected: c.id == connection.id);
      }).toList();
    });
  }

  Future<void> _runPrompt(String promptText) async {
    final text = promptText.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _isLoading = true;
      _promptController.text = text;
    });

    try {
      final record = await MockDbService.processNaturalLanguageQuery(
        prompt: text,
        connection: _activeConnection,
      );

      setState(() {
        _currentRecord = record;
        _history.insert(0, record);
        _isLoading = false;
      });

      // Scroll smoothly to top
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error generating query: $e')),
        );
      }
    }
  }

  void _toggleVoiceInput() {
    if (_isListening) {
      _stopListening(simulateSpeech: true);
    } else {
      _startListening();
    }
  }

  void _startListening() {
    setState(() {
      _isListening = true;
    });

    // Simulate speech-to-text dictation
    _listeningSimulationTimer?.cancel();
    final samplePhrases = [
      'Show products with low stock (less than 20 units)',
      'Count total orders by status',
      'Find orders over \$500 placed this month',
      'Show average product rating grouped by category',
    ];
    final picked = samplePhrases[DateTime.now().second % samplePhrases.length];

    _listeningSimulationTimer = Timer(const Duration(milliseconds: 2200), () {
      if (mounted && _isListening) {
        _promptController.text = picked;
        _stopListening(simulateSpeech: false);
        _runPrompt(picked);
      }
    });
  }

  void _stopListening({bool simulateSpeech = false}) {
    _listeningSimulationTimer?.cancel();
    setState(() {
      _isListening = false;
    });
  }

  void _openSchemaExplorer() {
    final schemas = MockDbService.getSchemasForConnection(_activeConnection);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SchemaViewerSheet(
        tables: schemas,
        databaseName: _activeConnection.databaseName,
      ),
    );
  }

  void _openConnectionSelector() {
    showDialog(
      context: context,
      builder: (context) => ConnectionModal(
        connections: _connections,
        activeConnection: _activeConnection,
        onSelectConnection: _switchConnection,
      ),
    );
  }

  void _toggleFavorite(QueryRecord record) {
    setState(() {
      final updated = record.copyWith(isFavorite: !record.isFavorite);
      if (_currentRecord?.id == record.id) {
        _currentRecord = updated;
      }
      final index = _history.indexWhere((h) => h.id == record.id);
      if (index != -1) {
        _history[index] = updated;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 16,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.record_voice_over,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'dbSpeak',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        actions: [
          // Active connection chip
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ActionChip(
              avatar: const Icon(Icons.circle, size: 12, color: Colors.green),
              label: Text(
                _activeConnection.name,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: _openConnectionSelector,
            ),
          ),
          const SizedBox(width: 4),

          // Schema explorer button
          IconButton(
            icon: const Icon(Icons.schema_outlined),
            tooltip: 'Explore database schema',
            onPressed: _openSchemaExplorer,
          ),

          // Theme toggle
          IconButton(
            icon: Icon(widget.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: 'Toggle Theme',
            onPressed: widget.onToggleTheme,
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Column(
        children: [
          // Voice listening active banner
          if (_isListening)
            Container(
              width: double.infinity,
              color: colorScheme.errorContainer,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Listening... Speak your database query now',
                      style: TextStyle(
                        color: colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _stopListening(simulateSpeech: false),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ),

          // Main scrollable content
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              children: [
                // Quick suggested prompts
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: MockDbService.samplePrompts.map((p) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0, bottom: 8.0),
                        child: ActionChip(
                          avatar: const Icon(Icons.auto_awesome, size: 14),
                          label: Text(p),
                          onPressed: _isLoading ? null : () => _runPrompt(p),
                        ),
                      );
                    }).toList(),
                  ),
                ),

                const SizedBox(height: 8),

                if (_isLoading)
                  Card(
                    elevation: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 16),
                          Text(
                            'Synthesizing SQL and querying database...',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                if (_currentRecord != null && !_isLoading) ...[
                  // User Question Card
                  Card(
                    color: colorScheme.primaryContainer.withAlpha(50),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: colorScheme.primary.withAlpha(60),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.chat_bubble_outline,
                              color: colorScheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prompt',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _currentRecord!.prompt,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // SQL View Card
                  SqlViewCard(
                    record: _currentRecord!,
                    dialect: _activeConnection.dialect,
                    onRerun: () => _runPrompt(_currentRecord!.prompt),
                    onToggleFavorite: () => _toggleFavorite(_currentRecord!),
                  ),

                  // Query Result Table
                  if (_currentRecord!.result != null)
                    QueryResultTable(result: _currentRecord!.result!),
                ],
              ],
            ),
          ),

          // Bottom Input Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outlineVariant.withAlpha(80),
                ),
              ),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  VoiceMicButton(
                    isListening: _isListening,
                    onTap: _toggleVoiceInput,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _promptController,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _runPrompt,
                      decoration: InputDecoration(
                        hintText: 'Speak or ask a database question...',
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(100),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.send),
                          color: colorScheme.primary,
                          tooltip: 'Run Query',
                          onPressed: () => _runPrompt(_promptController.text),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
