import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import '../bloc/git_bloc.dart';
import '../../../../core/services/git_service.dart';
import '../../../../core/themes/app_colors.dart';

class GitPage extends StatefulWidget {
  const GitPage({super.key});

  @override
  State<GitPage> createState() => _GitPageState();
}

class _GitPageState extends State<GitPage> {
  final TextEditingController _commitController = TextEditingController();
  String? _repoPath;

  @override
  void dispose() {
    _commitController.dispose();
    super.dispose();
  }

  Future<void> _selectRepo() async {
    final result = await FilePicker.getDirectoryPath(
      dialogTitle: 'Selecione um repositório Git',
    );

    if (result != null && mounted) {
      setState(() => _repoPath = result);
      context.read<GitBloc>().add(GitLoadRepo(result));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Git'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (_repoPath != null) {
                context.read<GitBloc>().add(const GitRefreshStatus());
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.folder_open),
            onPressed: _selectRepo,
          ),
        ],
      ),
      body: BlocBuilder<GitBloc, GitState>(
        builder: (context, state) {
          if (state is GitInitial) {
            return _buildInitialState(isDark);
          }

          if (state is GitLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            );
          }

          if (state is GitNotARepo) {
            return _buildNotARepo(isDark);
          }

          if (state is GitReady) {
            return _buildGitUI(context, state, isDark);
          }

          if (state is GitError) {
            return Center(
              child: Text(
                state.message,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  color: AppColors.errorDark,
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildInitialState(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.code,
              size: 64,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
            const SizedBox(height: 24),
            Text(
              'Selecione um repositório Git\npara visualizar o status',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectRepo,
              icon: const Icon(Icons.folder_open),
              label: const Text('Abrir Repositório'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotARepo(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.errorDark,
            ),
            const SizedBox(height: 24),
            Text(
              'Este diretório não é um\nrepositório Git',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _selectRepo,
              icon: const Icon(Icons.folder_open),
              label: const Text('Tentar outro diretório'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGitUI(BuildContext context, GitReady state, bool isDark) {
    return Column(
      children: [
        _buildBranchBar(context, state, isDark),
        if (state.lastCommitMessage != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.green.withOpacity(0.15),
            child: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Text(
                  state.lastCommitMessage!,
                  style: const TextStyle(
                    fontFamily: 'JetBrainsMono',
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
        _buildCommitBar(context, state, isDark),
        Expanded(
          child: ListView(
            children: [
              if (state.status.where((e) => e.isStaged).isNotEmpty) ...[
                _buildSectionHeader('Staged (${state.stagedCount})', isDark),
                ...state.status
                    .where((e) => e.isStaged)
                    .map((e) => _buildStatusTile(context, e, isDark)),
              ],
              if (state.status.where((e) => !e.isStaged).isNotEmpty) ...[
                _buildSectionHeader('Unstaged (${state.unstagedCount})', isDark),
                ...state.status
                    .where((e) => !e.isStaged)
                    .map((e) => _buildStatusTile(context, e, isDark)),
              ],
              if (state.status.isEmpty)
                _buildEmptyStatus(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBranchBar(BuildContext context, GitReady state, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Row(
        children: [
          const Icon(Icons.call_split, size: 16),
          const SizedBox(width: 8),
          Text(
            state.currentBranch,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          const Spacer(),
          Text(
            path.basename(state.repoPath),
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommitBar(BuildContext context, GitReady state, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commitController,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 13,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
              decoration: InputDecoration(
                hintText: 'Mensagem do commit...',
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: (msg) {
                if (msg.trim().isNotEmpty) {
                  context.read<GitBloc>().add(GitCommit(msg));
                  _commitController.clear();
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.upload),
            color: AppColors.primaryDark,
            onPressed: () {
              if (_commitController.text.trim().isNotEmpty) {
                context.read<GitBloc>().add(GitCommit(_commitController.text));
                _commitController.clear();
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildStatusTile(BuildContext context, GitStatusEntry entry, bool isDark) {
    final statusColors = {
      'M': Colors.orange,
      'A': Colors.green,
      'D': Colors.red,
      'R': Colors.blue,
      'C': Colors.teal,
      'U': Colors.purple,
      '?': Colors.grey,
    };

    final color = statusColors[entry.status] ?? Colors.grey;

    return ListTile(
      dense: true,
      leading: Container(
        width: 28,
        height: 24,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Center(
          child: Text(
            entry.status,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ),
      title: Text(
        path.basename(entry.path),
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 13,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        entry.path,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 10,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      trailing: entry.isStaged
          ? IconButton(
              icon: const Icon(Icons.unarchive, size: 18),
              onPressed: () {
                context.read<GitBloc>().add(GitUnstageFile(entry.path));
              },
            )
          : IconButton(
              icon: const Icon(Icons.archive, size: 18),
              onPressed: () {
                context.read<GitBloc>().add(GitStageFile(entry.path));
              },
            ),
    );
  }

  Widget _buildEmptyStatus(bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: Colors.green,
            ),
            const SizedBox(height: 16),
            Text(
              'Working directory limpo',
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
