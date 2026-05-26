part of 'templates_bloc.dart';

abstract class TemplatesState extends Equatable {
  const TemplatesState();

  @override
  List<Object?> get props => [];
}

class TemplatesInitial extends TemplatesState {
  const TemplatesInitial();
}

class TemplatesLoading extends TemplatesState {
  const TemplatesLoading();
}

class TemplatesReady extends TemplatesState {
  final List<TemplateEntity> templates;
  final List<TemplateEntity> filteredTemplates;
  final TemplateCategory? selectedCategory;
  final String searchQuery;

  const TemplatesReady({
    required this.templates,
    required this.filteredTemplates,
    this.selectedCategory,
    this.searchQuery = '',
  });

  @override
  List<Object?> get props => [templates, filteredTemplates, selectedCategory, searchQuery];

  TemplatesReady copyWith({
    List<TemplateEntity>? templates,
    List<TemplateEntity>? filteredTemplates,
    TemplateCategory? selectedCategory,
    String? searchQuery,
  }) {
    return TemplatesReady(
      templates: templates ?? this.templates,
      filteredTemplates: filteredTemplates ?? this.filteredTemplates,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class TemplateApplied extends TemplatesState {
  final TemplateEntity template;
  final String targetPath;
  final List<String> commands;

  const TemplateApplied({
    required this.template,
    required this.targetPath,
    required this.commands,
  });

  @override
  List<Object?> get props => [template, targetPath, commands];
}

class TemplatesError extends TemplatesState {
  final String message;

  const TemplatesError(this.message);

  @override
  List<Object?> get props => [message];
}
