import 'package:flutter/material.dart';
import '../../../features/editor/domain/entities/buffer_entity.dart';
import '../../../core/themes/app_colors.dart';

class BufferTabBar extends StatelessWidget {
  final List<BufferEntity> buffers;
  final String activeBufferId;
  final Function(String) onTap;
  final Function(String) onClose;
  final VoidCallback? onAdd;

  const BufferTabBar({
    super.key,
    required this.buffers,
    required this.activeBufferId,
    required this.onTap,
    required this.onClose,
    this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 36,
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Row(
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: buffers.length,
              itemBuilder: (context, index) {
                final buffer = buffers[index];
                final isActive = buffer.id == activeBufferId;

                return _buildTab(buffer, isActive, isDark);
              },
            ),
          ),
          _buildAddButton(isDark),
        ],
      ),
    );
  }

  Widget _buildTab(BufferEntity buffer, bool isActive, bool isDark) {
    return GestureDetector(
      onTap: () => onTap(buffer.id),
      child: Container(
        width: 180,
        height: double.infinity,
        decoration: BoxDecoration(
          color: isActive
              ? (isDark ? AppColors.backgroundDark : AppColors.backgroundLight)
              : Colors.transparent,
          border: isActive
              ? Border(
                  top: BorderSide(color: AppColors.primaryDark, width: 2),
                )
              : null,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Icon(
              buffer.isModified ? Icons.insert_drive_file : Icons.description,
              size: 16,
              color: buffer.isModified
                  ? AppColors.secondaryDark
                  : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                buffer.fileName ?? 'Untitled',
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                  color: isActive
                      ? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight)
                      : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                ),
              ),
            ),
            const SizedBox(width: 4),
            if (buffer.isModified)
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppColors.secondaryDark,
                  shape: BoxShape.circle,
                ),
              )
            else
              GestureDetector(
                onTap: () => onClose(buffer.id),
                child: Icon(
                  Icons.close,
                  size: 16,
                  color: isDark
                      ? AppColors.textSecondaryDark.withOpacity(0.6)
                      : AppColors.textSecondaryLight.withOpacity(0.6),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(bool isDark) {
    return GestureDetector(
      onTap: onAdd ?? () {},
      child: Container(
        width: 40,
        height: double.infinity,
        child: Icon(
          Icons.add,
          size: 20,
          color: isDark
              ? AppColors.textSecondaryDark.withOpacity(0.6)
              : AppColors.textSecondaryLight.withOpacity(0.6),
        ),
      ),
    );
  }
}
