import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import '../bloc/templates_bloc.dart';
import '../../domain/entities/template_entity.dart';
import '../../../../core/themes/app_colors.dart';

class TemplatesPage extends StatefulWidget {
  const TemplatesPage({super.key});

  @override
  State<TemplatesPage> createState() => _TemplatesPageState();
}

class _TemplatesPageState extends State<TemplatesPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TemplatesBloc>().add(const TemplatesLoad());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
      ),
      body: BlocConsumer<TemplatesBloc, TemplatesState>(
        listener: (context, state) {
          if (state is TemplateApplied) {
            final commands = state.commands;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Template ${state.template.name} aplicado!\n'
                  'Comandos: ${commands.join(", ")}',
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 5),
              ),
            );
            Navigator.pop(context);
          }
          if (state is TemplatesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.errorDark,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is TemplatesLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primaryDark),
            );
          }

          if (state is TemplatesReady) {
            return Column(
              children: [
                _buildSearchBar(isDark),
                _buildCategoryFilter(context, state, isDark),
                Expanded(
                  child: state.filteredTemplates.isEmpty
                      ? _buildEmptyState(isDark)
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: state.filteredTemplates.length,
                          itemBuilder: (context, index) {
                            return _buildTemplateCard(
                              context,
                              state.filteredTemplates[index],
                              isDark,
                            );
                          },
                        ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        style: TextStyle(
          fontFamily: 'JetBrainsMono',
          fontSize: 13,
          color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar templates...',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    context.read<TemplatesBloc>().add(const TemplatesSearch(''));
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (v) {
          context.read<TemplatesBloc>().add(TemplatesSearch(v));
        },
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, TemplatesReady state, bool isDark) {
    final categories = <TemplateCategory?>[null, ...TemplateCategory.values];
    final labels = <String>['Todos', 'Frontend', 'Backend', 'Fullstack', 'Mobile', 'Database', 'Util'];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final isSelected = state.selectedCategory == categories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(
                labels[index],
                style: TextStyle(
                  fontFamily: 'JetBrainsMono',
                  fontSize: 12,
                  color: isSelected ? Colors.white : null,
                ),
              ),
              selected: isSelected,
              onSelected: (_) {
                context.read<TemplatesBloc>().add(TemplatesFilterCategory(categories[index]));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTemplateCard(BuildContext context, TemplateEntity template, bool isDark) {
    final categoryColors = {
      TemplateCategory.frontend: Colors.blue,
      TemplateCategory.backend: Colors.green,
      TemplateCategory.fullstack: Colors.purple,
      TemplateCategory.mobile: Colors.orange,
      TemplateCategory.database: Colors.teal,
      TemplateCategory.utility: Colors.grey,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _applyTemplate(context, template),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: (categoryColors[template.category] ?? Colors.blue).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    template.icon ?? '📦',
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      template.name,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      template.description,
                      style: TextStyle(
                        fontFamily: 'JetBrainsMono',
                        fontSize: 11,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      children: template.tags.take(3).map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.textSecondaryDark.withOpacity(0.15)
                                : AppColors.textSecondaryLight.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            tag,
                            style: TextStyle(
                              fontFamily: 'JetBrainsMono',
                              fontSize: 9,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 64,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
          ),
          const SizedBox(height: 16),
          Text(
            'Nenhum template encontrado',
            style: TextStyle(
              fontFamily: 'JetBrainsMono',
              fontSize: 16,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _applyTemplate(BuildContext context, TemplateEntity template) async {
    final result = await FilePicker.getDirectoryPath(
      dialogTitle: 'Selecione o diretório para o projeto',
    );

    if (result != null && mounted) {
      context.read<TemplatesBloc>().add(TemplatesApplyTemplate(
        template: template,
        targetPath: result,
      ));
    }
  }
}
