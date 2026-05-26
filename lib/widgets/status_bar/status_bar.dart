import 'package:flutter/material.dart';
import '../../../features/editor/domain/entities/buffer_entity.dart';
import '../../../core/themes/app_colors.dart';

class StatusBarWidget extends StatelessWidget {
  final BufferEntity buffer;
  final String? searchPattern;
  final String? statusMessage;

  const StatusBarWidget({
    super.key,
    required this.buffer,
    this.searchPattern,
    this.statusMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 28,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Row(
        children: [
          if (statusMessage != null && statusMessage!.isNotEmpty)
            _buildStatusMessage(statusMessage!, isDark)
          else ...[
            _buildModeIndicator(isDark),
            _buildFileName(isDark),
          ],
          const Spacer(),
          if (searchPattern != null && searchPattern!.isNotEmpty)
            _buildSearchIndicator(isDark),
          _buildFileType(isDark),
          _buildEncoding(isDark),
          _buildLineColumn(isDark),
        ],
      ),
    );
  }

  Widget _buildStatusMessage(String message, bool isDark) {
    return Container(
      height: double.infinity,
      color: AppColors.primaryDark.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: Text(
          message,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildModeIndicator(bool isDark) {
    final modeColors = {
      EditorMode.normal: AppColors.primaryDark,
      EditorMode.insert: AppColors.secondaryDark,
      EditorMode.visual: Colors.orange,
      EditorMode.visualLine: Colors.orange,
      EditorMode.visualBlock: Colors.orange,
      EditorMode.command: Colors.green,
    };

    final modeLabels = {
      EditorMode.normal: ' NORMAL ',
      EditorMode.insert: ' INSERT ',
      EditorMode.visual: ' VISUAL ',
      EditorMode.visualLine: ' V-LINE ',
      EditorMode.visualBlock: ' V-BLOCK ',
      EditorMode.command: '  CMD   ',
    };

    final color = modeColors[buffer.mode] ?? AppColors.primaryDark;
    final label = modeLabels[buffer.mode] ?? ' NORMAL ';

    return Container(
      height: double.infinity,
      color: color,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildFileName(bool isDark) {
    final fileName = buffer.fileName ?? 'Untitled';
    final modified = buffer.isModified ? ' [+]' : '';
    final readOnly = buffer.isReadOnly ? ' [-]' : '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: isDark
          ? AppColors.textPrimaryDark.withOpacity(0.05)
          : AppColors.textPrimaryLight.withOpacity(0.03),
      child: Center(
        child: Text(
          '$fileName$modified$readOnly',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildSearchIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: AppColors.secondaryDark.withOpacity(0.2),
      child: Center(
        child: Text(
          '/$searchPattern',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: AppColors.secondaryDark,
          ),
        ),
      ),
    );
  }

  Widget _buildFileType(bool isDark) {
    final fileType = buffer.fileType ?? 'text';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Text(
          fileType.toUpperCase(),
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildEncoding(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Center(
        child: Text(
          'utf-8',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
        ),
      ),
    );
  }

  Widget _buildLineColumn(bool isDark) {
    final line = buffer.cursor.line + 1;
    final column = buffer.cursor.column + 1;
    final totalLines = buffer.lineCount;
    final percent = ((line / totalLines) * 100).toInt();

    return Container(
      height: double.infinity,
      color: isDark
          ? AppColors.textPrimaryDark.withOpacity(0.1)
          : AppColors.textPrimaryLight.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Center(
        child: Text(
          '$line:$column  $percent%',
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
      ),
    );
  }
}
