import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../features/editor/domain/entities/buffer_entity.dart';
import '../../../core/themes/app_colors.dart';

class VimKeyboard extends StatefulWidget {
  final EditorMode mode;
  final Function(String) onKey;
  final Function(EditorMode) onModeChange;

  const VimKeyboard({
    super.key,
    required this.mode,
    required this.onKey,
    required this.onModeChange,
  });

  @override
  State<VimKeyboard> createState() => _VimKeyboardState();
}

class _VimKeyboardState extends State<VimKeyboard> {
  bool _isShift = false;
  bool _isNumberMode = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.surfaceDark : AppColors.surfaceLight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildModeIndicator(isDark),
          _buildNavigationRow(isDark),
          if (_isNumberMode) _buildNumberRow(isDark) else _buildTopRow(isDark),
          _buildMiddleRow(isDark),
          _buildBottomRow(isDark),
          _buildSpaceRow(isDark),
        ],
      ),
    );
  }

  Widget _buildModeIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: _getModeColor(),
      child: Row(
        children: [
          Text(
            _getModeLabel(),
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
            ),
          ),
          const Spacer(),
          _buildModeButton(
            'NORMAL',
            EditorMode.normal,
            widget.mode == EditorMode.normal,
          ),
          _buildModeButton(
            'INSERT',
            EditorMode.insert,
            widget.mode == EditorMode.insert,
          ),
          _buildModeButton(
            'VISUAL',
            EditorMode.visual,
            widget.mode == EditorMode.visual,
          ),
        ],
      ),
    );
  }

  Color _getModeColor() {
    switch (widget.mode) {
      case EditorMode.normal:
        return AppColors.primaryDark;
      case EditorMode.insert:
        return AppColors.secondaryDark;
      case EditorMode.visual:
      case EditorMode.visualLine:
      case EditorMode.visualBlock:
        return Colors.orange;
      case EditorMode.command:
        return Colors.green;
    }
  }

  String _getModeLabel() {
    switch (widget.mode) {
      case EditorMode.normal:
        return '-- NORMAL --';
      case EditorMode.insert:
        return '-- INSERT --';
      case EditorMode.visual:
        return '-- VISUAL --';
      case EditorMode.visualLine:
        return '-- VISUAL LINE --';
      case EditorMode.visualBlock:
        return '-- VISUAL BLOCK --';
      case EditorMode.command:
        return ':';
    }
  }

  Widget _buildModeButton(String label, EditorMode mode, bool isActive) {
    return GestureDetector(
      onTap: () => widget.onModeChange(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        margin: const EdgeInsets.only(left: 4),
        decoration: BoxDecoration(
          color: isActive ? Colors.white.withOpacity(0.3) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 10,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildNavigationRow(bool isDark) {
    return Row(
      children: [
        _buildNavKey('Esc', 'Escape', isDark, flex: 2),
        Expanded(
          flex: 3,
          child: Container(),
        ),
        _buildNavKey('gg', 'gg', isDark),
        _buildNavKey('G', 'G', isDark),
        _buildNavKey('0', '0', isDark),
        _buildNavKey(r'$', r'$', isDark),
        _buildNavKey('w', 'w', isDark),
        _buildNavKey('b', 'b', isDark),
      ],
    );
  }

  Widget _buildTopRow(bool isDark) {
    return Row(
      children: [
        _buildKey('q', isDark),
        _buildKey('w', isDark),
        _buildKey('e', isDark),
        _buildKey('r', isDark),
        _buildKey('t', isDark),
        _buildKey('y', isDark),
        _buildKey('u', isDark),
        _buildKey('i', isDark),
        _buildKey('o', isDark),
        _buildKey('p', isDark),
      ],
    );
  }

  Widget _buildMiddleRow(bool isDark) {
    return Row(
      children: [
        _buildKey('a', isDark),
        _buildKey('s', isDark),
        _buildKey('d', isDark),
        _buildKey('f', isDark),
        _buildKey('g', isDark),
        _buildKey('h', isDark),
        _buildKey('j', isDark),
        _buildKey('k', isDark),
        _buildKey('l', isDark),
        _buildKey(':', isDark, label: ';:'),
      ],
    );
  }

  Widget _buildBottomRow(bool isDark) {
    return Row(
      children: [
        _buildKey('z', isDark),
        _buildKey('x', isDark),
        _buildKey('c', isDark),
        _buildKey('v', isDark),
        _buildKey('b', isDark),
        _buildKey('n', isDark),
        _buildKey('m', isDark),
        _buildNavKey(',', ',', isDark),
        _buildNavKey('.', '.', isDark),
        _buildNavKey('/', '/', isDark),
      ],
    );
  }

  Widget _buildNumberRow(bool isDark) {
    return Row(
      children: [
        _buildKey('1', isDark),
        _buildKey('2', isDark),
        _buildKey('3', isDark),
        _buildKey('4', isDark),
        _buildKey('5', isDark),
        _buildKey('6', isDark),
        _buildKey('7', isDark),
        _buildKey('8', isDark),
        _buildKey('9', isDark),
        _buildKey('0', isDark),
      ],
    );
  }

  Widget _buildSpaceRow(bool isDark) {
    return Row(
      children: [
        _buildSpecialKey(
          _isNumberMode ? 'ABC' : '123',
          () {
            setState(() {
              _isNumberMode = !_isNumberMode;
            });
          },
          isDark,
          flex: 2,
        ),
        _buildSpecialKey(
          '⇧',
          () {
            setState(() {
              _isShift = !_isShift;
            });
          },
          isDark,
          flex: 2,
          isActive: _isShift,
        ),
        _buildSpecialKey(
          '←',
          () => widget.onKey('h'),
          isDark,
          flex: 1,
        ),
        _buildSpecialKey(
          '↓',
          () => widget.onKey('j'),
          isDark,
          flex: 1,
        ),
        _buildSpecialKey(
          '↑',
          () => widget.onKey('k'),
          isDark,
          flex: 1,
        ),
        _buildSpecialKey(
          '→',
          () => widget.onKey('l'),
          isDark,
          flex: 1,
        ),
        Expanded(
          flex: 4,
          child: _buildSpecialKey(
            'Espaço',
            () => widget.onKey(' '),
            isDark,
          ),
        ),
        _buildSpecialKey(
          '⌫',
          () => widget.onKey('Backspace'),
          isDark,
          flex: 2,
        ),
        _buildSpecialKey(
          '↵',
          () => widget.onKey('Enter'),
          isDark,
          flex: 2,
        ),
      ],
    );
  }

  Widget _buildKey(String key, bool isDark, {String? label}) {
    final displayKey = _isShift ? key.toUpperCase() : key;
    final displayLabel = label ?? displayKey;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onKey(displayKey);
        },
        child: Container(
          height: 42,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.textPrimaryDark.withOpacity(0.1)
                : AppColors.textPrimaryLight.withOpacity(0.05),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              displayLabel,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavKey(String label, String key, bool isDark, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          widget.onKey(key);
        },
        child: Container(
          height: 36,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.primaryDark.withOpacity(0.2)
                : AppColors.primaryLight.withOpacity(0.15),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpecialKey(
    String label,
    VoidCallback onTap,
    bool isDark, {
    int flex = 1,
    bool isActive = false,
  }) {
    return Expanded(
      flex: flex,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          height: 48,
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.primaryDark
                : (isDark
                    ? AppColors.textPrimaryDark.withOpacity(0.15)
                    : AppColors.textPrimaryLight.withOpacity(0.08)),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isActive
                    ? Colors.white
                    : (isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
