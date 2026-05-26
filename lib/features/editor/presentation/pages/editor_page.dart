import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/editor_bloc.dart';
import '../bloc/editor_event.dart';
import '../bloc/editor_state.dart';
import '../../domain/entities/buffer_entity.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../widgets/vim_keyboard/vim_keyboard.dart';
import '../../../../widgets/status_bar/status_bar.dart';
import '../../../../widgets/tab_bar/buffer_tab_bar.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../../terminal/presentation/pages/terminal_page.dart';
import '../../../plugins/presentation/pages/plugins_page.dart';
import '../../../templates/presentation/pages/templates_page.dart';
import '../../../git/presentation/pages/git_page.dart';

class EditorPage extends StatefulWidget {
  const EditorPage({super.key});

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _verticalController = ScrollController();
  final ScrollController _horizontalController = ScrollController();
  bool _showKeyboard = false;
  bool _isSidebarOpen = false;

  @override
  void initState() {
    super.initState();
    _editorFocusNode.requestFocus();
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    _verticalController.dispose();
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: BlocBuilder<EditorBloc, EditorState>(
        builder: (context, state) {
          if (state is EditorInitial || state is EditorLoading) {
            return _buildLoading(isDark);
          }

          if (state is EditorError) {
            return _buildError(state, isDark);
          }

          final editorState = state as EditorReady;
          final buffer = editorState.activeBuffer;

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(editorState, buffer, isDark),
                BufferTabBar(
                  buffers: editorState.buffers,
                  activeBufferId: editorState.activeBufferId,
                  onTap: (id) => context.read<EditorBloc>().add(EditorSwitchBuffer(id)),
                  onClose: (id) => context.read<EditorBloc>().add(EditorCloseBuffer(id)),
                  onAdd: () => context.read<EditorBloc>().add(const EditorNewBuffer()),
                ),
                Expanded(
                  child: Row(
                    children: [
                      _buildSidebar(editorState, isDark),
                      Expanded(
                        child: _buildEditorContent(buffer, editorState, isDark),
                      ),
                    ],
                  ),
                ),
                StatusBarWidget(
                  buffer: buffer,
                  searchPattern: editorState.searchPattern,
                  statusMessage: editorState.statusMessage,
                ),
                if (_showKeyboard)
                  VimKeyboard(
                    mode: buffer.mode,
                    onKey: (key) {
                      _handleKeyPress(key, buffer);
                    },
                    onModeChange: (mode) {
                      context.read<EditorBloc>().add(EditorChangeMode(mode));
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoading(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primaryDark,
            ),
            const SizedBox(height: 16),
            Text(
              'Carregando MobileVim...',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(EditorError state, bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.errorDark,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  context.read<EditorBloc>().add(const EditorNewBuffer());
                },
                child: const Text('Criar Novo Arquivo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar(EditorReady state, BufferEntity buffer, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Row(
        children: [
          IconButton(
            icon: Icon(
              _isSidebarOpen ? Icons.menu_open : Icons.menu,
              size: 24,
            ),
            onPressed: () {
              setState(() {
                _isSidebarOpen = !_isSidebarOpen;
              });
            },
          ),
          const SizedBox(width: 8),
          Text(
            'MobileVim',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.file_open, size: 22),
            onPressed: _openFile,
          ),
          IconButton(
            icon: const Icon(Icons.save, size: 22),
            onPressed: () {
              context.read<EditorBloc>().add(EditorSaveBuffer(path: buffer.filePath));
            },
          ),
          IconButton(
            icon: const Icon(Icons.search, size: 22),
            onPressed: () {
              context.read<EditorBloc>().add(const EditorChangeMode(EditorMode.command));
              context.read<EditorBloc>().add(const EditorCommandInput('/'));
            },
          ),
          IconButton(
            icon: const Icon(Icons.terminal, size: 22),
            onPressed: _openTerminal,
          ),
          IconButton(
            icon: const Icon(Icons.extension, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const PluginsPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TemplatesPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.code, size: 22),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const GitPage()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.keyboard, size: 22),
            onPressed: () {
              setState(() {
                _showKeyboard = !_showKeyboard;
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings, size: 22),
            onPressed: _openSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildSidebar(EditorReady state, bool isDark) {
    if (!_isSidebarOpen) return const SizedBox.shrink();

    return Container(
      width: 280,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Column(
        children: [
          _buildSidebarHeader(isDark),
          const Divider(height: 1),
          Expanded(
            child: _buildFileExplorer(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Text(
            'Explorador',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.create_new_folder, size: 18),
            onPressed: _createNewFolder,
          ),
          IconButton(
            icon: const Icon(Icons.note_add, size: 18),
            onPressed: () {
              context.read<EditorBloc>().add(const EditorNewBuffer());
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFileExplorer(bool isDark) {
    return FutureBuilder<List<FileSystemEntity>>(
      future: _getRootDirectories(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(color: AppColors.primaryDark),
          );
        }

        final entities = snapshot.data!;
        
        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 4),
          itemCount: entities.length,
          itemBuilder: (context, index) {
            final entity = entities[index];
            final isDirectory = entity is Directory;
            final name = path.basename(entity.path);

            return ListTile(
              dense: true,
              leading: Icon(
                isDirectory ? Icons.folder : Icons.insert_drive_file,
                size: 20,
                color: isDirectory
                    ? AppColors.primaryDark
                    : isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
              ),
              title: Text(
                name,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 13,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                ),
              ),
              onTap: () {
                if (isDirectory) {
                  _navigateToDirectory(entity.path);
                } else {
                  context.read<EditorBloc>().add(EditorLoadFile(entity.path));
                }
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEditorContent(
    BufferEntity buffer,
    EditorReady state,
    bool isDark,
  ) {
    return KeyboardListener(
      focusNode: _editorFocusNode,
      onKeyEvent: (event) {
        if (event is KeyDownEvent) {
          _handlePhysicalKey(event);
        }
      },
      child: Container(
        color: _getEditorBackground(isDark),
        child: Row(
          children: [
            _buildLineNumbers(buffer, isDark),
            _buildVerticalDivider(isDark),
            Expanded(
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 500),
                  child: SingleChildScrollView(
                    controller: _verticalController,
                    child: _buildCodeArea(buffer, state, isDark),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineNumbers(BufferEntity buffer, bool isDark) {
    return Container(
      padding: const EdgeInsets.only(left: 16, right: 8),
      color: _getEditorBackground(isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: buffer.lines.asMap().entries.map((entry) {
          final lineNum = entry.key + 1;
          final isCurrentLine = entry.key == buffer.cursor.line;

          return Container(
            height: 24,
            alignment: Alignment.centerRight,
            child: Text(
              lineNum.toString(),
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 13,
                color: isCurrentLine
                    ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                    : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight)
                        .withOpacity(0.5),
                fontWeight: isCurrentLine ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildVerticalDivider(bool isDark) {
    return VerticalDivider(
      width: 1,
      thickness: 1,
      color: isDark
          ? AppColors.textSecondaryDark.withOpacity(0.2)
          : AppColors.textSecondaryLight.withOpacity(0.2),
    );
  }

  Widget _buildCodeArea(
    BufferEntity buffer,
    EditorReady state,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: buffer.lines.asMap().entries.map((entry) {
          final lineIndex = entry.key;
          final lineText = entry.value;
          final isCurrentLine = lineIndex == buffer.cursor.line;

          return Container(
            height: 24,
            color: isCurrentLine
                ? (isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.03))
                : Colors.transparent,
            child: _buildLineContent(
              lineIndex,
              lineText,
              buffer,
              state,
              isDark,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLineContent(
    int lineIndex,
    String lineText,
    BufferEntity buffer,
    EditorReady state,
    bool isDark,
  ) {
    final isCurrentLine = lineIndex == buffer.cursor.line;
    final cursorColumn = buffer.cursor.column;
    final mode = buffer.mode;

    final spans = <InlineSpan>[];

    for (var i = 0; i < lineText.length; i++) {
      final char = lineText[i];
      final isCursorPos = isCurrentLine && i == cursorColumn;
      final isInSelection = _isInSelection(lineIndex, i, buffer);

      TextStyle charStyle = TextStyle(
        fontFamily: 'JetBrainsMono',
        fontSize: 13,
        height: 1.2,
        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        backgroundColor: isInSelection
            ? AppColors.primaryDark.withOpacity(0.3)
            : Colors.transparent,
      );

      if (isCursorPos && mode == EditorMode.normal) {
        spans.add(
          TextSpan(
            text: char,
            style: charStyle.copyWith(
              backgroundColor: AppColors.primaryDark,
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            ),
          ),
        );
      } else if (isCursorPos && mode == EditorMode.insert) {
        spans.add(
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Container(
              width: 2,
              height: 20,
              color: AppColors.secondaryDark,
            ),
          ),
        );
        spans.add(TextSpan(text: char, style: charStyle));
      } else {
        spans.add(TextSpan(text: char, style: charStyle));
      }
    }

    if (isCurrentLine && cursorColumn >= lineText.length && mode == EditorMode.insert) {
      spans.add(
        WidgetSpan(
          alignment: PlaceholderAlignment.middle,
          child: Container(
            width: 2,
            height: 20,
            color: AppColors.secondaryDark,
          ),
        ),
      );
    }

    if (isCurrentLine && cursorColumn >= lineText.length && mode == EditorMode.normal) {
      spans.add(
        TextSpan(
          text: ' ',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 13,
            backgroundColor: AppColors.primaryDark,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          RichText(
            text: TextSpan(children: spans),
          ),
        ],
      ),
    );
  }

  bool _isInSelection(int line, int column, BufferEntity buffer) {
    if (buffer.selection == null) return false;

    final start = buffer.selection!.start;
    final end = buffer.selection!.end;

    final minLine = min(start.line, end.line);
    final maxLine = max(start.line, end.line);

    if (line < minLine || line > maxLine) return false;

    if (line == minLine && line == maxLine) {
      final minCol = min(start.column, end.column);
      final maxCol = max(start.column, end.column);
      return column >= minCol && column <= maxCol;
    }

    if (line == minLine) {
      return column >= min(start.column, end.column);
    }

    if (line == maxLine) {
      return column <= max(start.column, end.column);
    }

    return true;
  }

  Color _getEditorBackground(bool isDark) {
    return EditorColors.dracula['background'] ??
        (isDark ? AppColors.backgroundDark : AppColors.backgroundLight);
  }

  void _handleKeyPress(String key, BufferEntity buffer) {
    if (buffer.mode == EditorMode.command) {
      if (key == 'Enter') {
        context.read<EditorBloc>().add(const EditorExecuteCommand());
      } else if (key == 'Escape') {
        context.read<EditorBloc>().add(const EditorCancelCommand());
      } else if (key == 'Backspace') {
        final newCmd = buffer.commandBuffer.isNotEmpty
            ? buffer.commandBuffer.substring(0, buffer.commandBuffer.length - 1)
            : '';
        context.read<EditorBloc>().add(
          EditorChangeMode(EditorMode.command),
        );
      } else {
        context.read<EditorBloc>().add(EditorCommandInput(key));
      }
    } else {
      context.read<EditorBloc>().add(EditorInputKey(
        key: key,
        isShift: key.toUpperCase() == key && key.length == 1,
      ));
    }
  }

  void _handlePhysicalKey(KeyDownEvent event) {
    final key = event.logicalKey;
    final isShift = HardwareKeyboard.instance.isShiftPressed;
    final isControl = HardwareKeyboard.instance.isControlPressed;
    final isAlt = HardwareKeyboard.instance.isAltPressed;

    String keyStr;

    if (key == LogicalKeyboardKey.enter) {
      keyStr = 'Enter';
    } else if (key == LogicalKeyboardKey.escape) {
      keyStr = 'Escape';
    } else if (key == LogicalKeyboardKey.backspace) {
      keyStr = 'Backspace';
    } else if (key == LogicalKeyboardKey.tab) {
      keyStr = 'Tab';
    } else if (key == LogicalKeyboardKey.arrowUp) {
      keyStr = 'k';
    } else if (key == LogicalKeyboardKey.arrowDown) {
      keyStr = 'j';
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      keyStr = 'h';
    } else if (key == LogicalKeyboardKey.arrowRight) {
      keyStr = 'l';
    } else {
      keyStr = event.character ?? '';
    }

    if (keyStr.isNotEmpty) {
      context.read<EditorBloc>().add(EditorInputKey(
        key: keyStr,
        isShift: isShift,
        isControl: isControl,
        isAlt: isAlt,
      ));
    }
  }

  Future<List<FileSystemEntity>> _getRootDirectories() async {
    final entities = <FileSystemEntity>[];

    try {
      final appDir = await getApplicationDocumentsDirectory();
      entities.add(appDir);

      if (Platform.isAndroid) {
        final externalDirs = await getExternalStorageDirectories();
        if (externalDirs != null) {
          entities.addAll(externalDirs);
        }
      }
    } catch (e) {
      // ignore
    }

    return entities;
  }

  void _openFile() async {
    try {
      final result = await FilePicker.pickFiles();
      if (result != null && result.files.isNotEmpty) {
        final path = result.files.single.path;
        if (path != null) {
          if (mounted) {
            context.read<EditorBloc>().add(EditorLoadFile(path));
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao abrir arquivo: $e')),
        );
      }
    }
  }

  void _openTerminal() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TerminalPage()),
    );
  }

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  Future<void> _createNewFolder() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nova Pasta'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Nome da pasta',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text('Criar'),
          ),
        ],
      ),
    );

    if (name != null && name.trim().isNotEmpty) {
      try {
        final appDir = await getApplicationDocumentsDirectory();
        final newDir = Directory('${appDir.path}/$name');
        await newDir.create();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Pasta "$name" criada')),
          );
          setState(() {});
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $e')),
          );
        }
      }
    }
  }

  Future<void> _navigateToDirectory(String dirPath) async {
    try {
      final dir = Directory(dirPath);
      if (await dir.exists()) {
        final entities = dir.listSync();
        if (mounted) {
          _showDirectoryContents(dirPath, entities);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      }
    }
  }

  void _showDirectoryContents(String dirPath, List<FileSystemEntity> entities) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      '📁 ${path.basename(dirPath)}',
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  itemCount: entities.length,
                  itemBuilder: (context, index) {
                    final entity = entities[index];
                    final isDir = entity is Directory;
                    final name = path.basename(entity.path);

                    return ListTile(
                      dense: true,
                      leading: Icon(
                        isDir ? Icons.folder : Icons.insert_drive_file,
                        size: 20,
                        color: isDir
                            ? AppColors.primaryDark
                            : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                      ),
                      title: Text(
                        name,
                        style: TextStyle(
                          fontFamily: 'JetBrainsMono',
                          fontSize: 13,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                        ),
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        if (isDir) {
                          _navigateToDirectory(entity.path);
                        } else {
                          context.read<EditorBloc>().add(EditorLoadFile(entity.path));
                        }
                      },
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
