import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/settings_bloc.dart';
import '../../../../core/themes/app_colors.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  static const List<String> editorThemes = [
    'Dracula',
    'One Dark',
    'Nord',
    'Tokyo Night',
    'Gruvbox Dark',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              context.read<SettingsBloc>().add(const SettingsReset());
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configurações restauradas')),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return ListView(
            children: [
              _buildSectionHeader('Aparência', isDark),
              _buildThemeSelector(context, state, isDark),
              _buildSwitchTile(
                context,
                icon: Icons.dark_mode,
                title: 'Modo escuro',
                value: state.themeMode == ThemeMode.dark,
                onChanged: (v) {
                  context.read<SettingsBloc>().add(
                    SettingsUpdateThemeMode(v ? ThemeMode.dark : ThemeMode.light),
                  );
                },
                isDark: isDark,
              ),
              _buildEditorThemeSelector(context, state, isDark),
              _buildSectionHeader('Editor', isDark),
              _buildFontSizeSlider(context, state, isDark),
              _buildTabSizeSelector(context, state, isDark),
              _buildSwitchTile(
                context,
                icon: Icons.space_bar,
                title: 'Expandir tabs (espaços)',
                value: state.expandTabs,
                onChanged: (v) {
                  context.read<SettingsBloc>().add(SettingsUpdateExpandTabs(v));
                },
                isDark: isDark,
              ),
              _buildSwitchTile(
                context,
                icon: Icons.format_list_numbered,
                title: 'Mostrar números de linha',
                value: state.showLineNumbers,
                onChanged: (v) {
                  context.read<SettingsBloc>().add(SettingsUpdateLineNumbers(v));
                },
                isDark: isDark,
              ),
              _buildSwitchTile(
                context,
                icon: Icons.wrap_text,
                title: 'Quebra de linha',
                value: state.wordWrap,
                onChanged: (v) {
                  context.read<SettingsBloc>().add(SettingsUpdateWordWrap(v));
                },
                isDark: isDark,
              ),
              _buildSwitchTile(
                context,
                icon: Icons.save,
                title: 'Salvar automaticamente',
                value: state.autoSave,
                onChanged: (v) {
                  context.read<SettingsBloc>().add(SettingsUpdateAutoSave(v));
                },
                isDark: isDark,
              ),
              _buildSwitchTile(
                context,
                icon: Icons.visibility_off,
                title: 'Mostrar caracteres invisíveis',
                value: state.showInvisibles,
                onChanged: (v) {
                  context.read<SettingsBloc>().add(SettingsUpdateShowInvisibles(v));
                },
                isDark: isDark,
              ),
              _buildSwitchTile(
                context,
                icon: Icons.map,
                title: 'Mostrar minimapa',
                value: state.showMinimap,
                onChanged: (v) {
                  context.read<SettingsBloc>().add(SettingsUpdateShowMinimap(v));
                },
                isDark: isDark,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? AppColors.primaryDark : AppColors.primaryLight,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required bool isDark,
  }) {
    return SwitchListTile(
      secondary: Icon(icon, size: 20),
      title: Text(
        title,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 14,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    SettingsState state,
    bool isDark,
  ) {
    final themeModes = ['Claro', 'Escuro', 'Sistema'];
    final values = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];
    final currentIndex = values.indexOf(state.themeMode);

    return ListTile(
      leading: const Icon(Icons.palette, size: 20),
      title: Text(
        'Tema do app',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 14,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      trailing: SegmentedButton<ThemeMode>(
        segments: List.generate(themeModes.length, (i) {
          return ButtonSegment(
            value: values[i],
            label: Text(themeModes[i]),
          );
        }),
        selected: {values[currentIndex]},
        onSelectionChanged: (v) {
          context.read<SettingsBloc>().add(SettingsUpdateThemeMode(v.first));
        },
      ),
    );
  }

  Widget _buildEditorThemeSelector(
    BuildContext context,
    SettingsState state,
    bool isDark,
  ) {
    return ListTile(
      leading: const Icon(Icons.color_lens, size: 20),
      title: Text(
        'Tema do editor',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 14,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Text(
        state.activeTheme,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 12,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
        ),
      ),
      trailing: DropdownButton<String>(
        value: state.activeTheme,
        underline: const SizedBox(),
        items: editorThemes.map((theme) {
          return DropdownMenuItem(
            value: theme,
            child: Text(
              theme,
              style: const TextStyle(fontFamily: 'JetBrainsMono', fontSize: 13),
            ),
          );
        }).toList(),
        onChanged: (v) {
          if (v != null) {
            context.read<SettingsBloc>().add(SettingsUpdateActiveTheme(v));
          }
        },
      ),
    );
  }

  Widget _buildFontSizeSlider(
    BuildContext context,
    SettingsState state,
    bool isDark,
  ) {
    return ListTile(
      leading: const Icon(Icons.text_fields, size: 20),
      title: Text(
        'Tamanho da fonte: ${state.fontSize.toInt()}',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 14,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      subtitle: Slider(
        value: state.fontSize,
        min: 8,
        max: 32,
        divisions: 24,
        label: state.fontSize.toInt().toString(),
        onChanged: (v) {
          context.read<SettingsBloc>().add(SettingsUpdateFontSize(v));
        },
      ),
    );
  }

  Widget _buildTabSizeSelector(
    BuildContext context,
    SettingsState state,
    bool isDark,
  ) {
    return ListTile(
      leading: const Icon(Icons.view_column, size: 20),
      title: Text(
        'Tamanho da tabulação: ${state.tabSize}',
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 14,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (i) {
          final size = (i + 1) * 2;
          return Padding(
            padding: const EdgeInsets.only(left: 4),
            child: ChoiceChip(
              label: Text(
                size.toString(),
                style: const TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                ),
              ),
              selected: state.tabSize == size,
              onSelected: (_) {
                context.read<SettingsBloc>().add(SettingsUpdateTabSize(size));
              },
            ),
          );
        }),
      ),
    );
  }
}
