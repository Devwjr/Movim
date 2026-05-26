import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/terminal_service.dart';
import '../../../../core/services/service_locator.dart';
import '../../../../core/themes/app_colors.dart';

class TerminalPage extends StatefulWidget {
  const TerminalPage({super.key});

  @override
  State<TerminalPage> createState() => _TerminalPageState();
}

class _TerminalPageState extends State<TerminalPage> {
  final TerminalService _terminalService = getIt<TerminalService>();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _inputFocus = FocusNode();
  String _output = '';
  StreamSubscription? _outputSub;
  List<String> _history = [];
  int _historyIndex = -1;

  @override
  void initState() {
    super.initState();
    _output = _terminalService.currentOutput;
    _outputSub = _terminalService.outputStream.listen((output) {
      if (mounted) {
        setState(() => _output = output);
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
      }
    });
  }

  @override
  void dispose() {
    _outputSub?.cancel();
    _inputController.dispose();
    _scrollController.dispose();
    _inputFocus.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
      );
    }
  }

  void _executeCommand() {
    final cmd = _inputController.text;
    if (cmd.trim().isEmpty) return;

    _inputController.clear();
    _historyIndex = -1;
    _terminalService.executeCommand(cmd);
  }

  void _previousHistory() {
    final prev = _terminalService.getPreviousHistory();
    if (prev != null) {
      _inputController.text = prev;
      _inputController.selection = TextSelection.collapsed(offset: prev.length);
    }
  }

  void _nextHistory() {
    final next = _terminalService.getNextHistory();
    _inputController.text = next ?? '';
    if (next != null) {
      _inputController.selection = TextSelection.collapsed(offset: next.length);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Terminal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _terminalService.executeCommand('clear'),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: const Color(0xFF1E1E1E),
              child: SingleChildScrollView(
                controller: _scrollController,
                padding: const EdgeInsets.all(12),
                child: SelectableText(
                  _output,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 13,
                    color: Color(0xFFD4D4D4),
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),
          _buildInputBar(isDark),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark) {
    return Container(
      color: const Color(0xFF252526),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        children: [
            Text(
              _terminalService.getPrompt(),
            style: const TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 13,
              color: Color(0xFF4EC9B0),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _inputController,
              focusNode: _inputFocus,
              autofocus: true,
              style: const TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 13,
                color: Color(0xFFD4D4D4),
              ),
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                filled: false,
              ),
              onSubmitted: (_) => _executeCommand(),
              onChanged: (_) => setState(() {}),
            ),
          ),
          if (_inputController.text.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.send, size: 18, color: Color(0xFF4EC9B0)),
              onPressed: _executeCommand,
            ),
        ],
      ),
    );
  }
}
