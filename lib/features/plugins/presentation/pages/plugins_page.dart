import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/plugins_bloc.dart';
import '../../domain/entities/plugin_entity.dart';
import '../../../../core/themes/app_colors.dart';

class PluginsPage extends StatelessWidget {
  const PluginsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugins'),
      ),
      body: BlocBuilder<PluginsBloc, PluginsState>(
        builder: (context, state) {
          if (state is PluginsLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            );
          }

          if (state is PluginsError) {
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

          if (state is PluginsReady) {
            final plugins = state.plugins;
            final enabled = plugins.where((p) => p.isEnabled).toList();
            final disabled = plugins.where((p) => !p.isEnabled).toList();

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (enabled.isNotEmpty) ...[
                  _buildSectionHeader('Ativos', enabled.length, isDark),
                  ...enabled.map((p) => _buildPluginTile(context, p, isDark)),
                  const SizedBox(height: 16),
                ],
                if (disabled.isNotEmpty) ...[
                  _buildSectionHeader('Inativos', disabled.length, isDark),
                  ...disabled.map((p) => _buildPluginTile(context, p, isDark)),
                ],
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: isDark ? AppColors.textSecondaryDark.withOpacity(0.2) : AppColors.textSecondaryLight.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPluginTile(BuildContext context, PluginEntity plugin, bool isDark) {
    final typeColors = {
      PluginType.syntax: AppColors.primaryDark,
      PluginType.lsp: AppColors.secondaryDark,
      PluginType.formatter: Colors.orange,
      PluginType.snippet: Colors.green,
      PluginType.theme: Colors.purple,
      PluginType.utility: Colors.cyan,
      PluginType.integration: Colors.amber,
    };

    final typeLabels = {
      PluginType.syntax: 'syntax',
      PluginType.lsp: 'lsp',
      PluginType.formatter: 'format',
      PluginType.snippet: 'snippet',
      PluginType.theme: 'theme',
      PluginType.utility: 'util',
      PluginType.integration: 'integ',
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: SwitchListTile(
        secondary: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (typeColors[plugin.type] ?? AppColors.primaryDark).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              plugin.icon ?? '🔌',
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
        title: Text(
          plugin.name,
          style: TextStyle(
            fontFamily: 'JetBrainsMono',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              plugin.description,
              style: TextStyle(
                fontFamily: 'JetBrainsMono',
                fontSize: 11,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: (typeColors[plugin.type] ?? AppColors.primaryDark).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                typeLabels[plugin.type] ?? 'util',
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 9,
                  color: typeColors[plugin.type] ?? AppColors.primaryDark,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        value: plugin.isEnabled,
        onChanged: (_) {
          context.read<PluginsBloc>().add(PluginsToggle(plugin.id));
        },
      ),
    );
  }
}
