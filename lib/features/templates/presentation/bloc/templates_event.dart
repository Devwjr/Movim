part of 'templates_bloc.dart';

abstract class TemplatesEvent extends Equatable {
  const TemplatesEvent();

  @override
  List<Object?> get props => [];
}

class TemplatesLoad extends TemplatesEvent {
  const TemplatesLoad();
}

class TemplatesSearch extends TemplatesEvent {
  final String query;

  const TemplatesSearch(this.query);

  @override
  List<Object?> get props => [query];
}

class TemplatesFilterCategory extends TemplatesEvent {
  final TemplateCategory? category;

  const TemplatesFilterCategory(this.category);

  @override
  List<Object?> get props => [category];
}

class TemplatesApplyTemplate extends TemplatesEvent {
  final TemplateEntity template;
  final String targetPath;

  const TemplatesApplyTemplate({
    required this.template,
    required this.targetPath,
  });

  @override
  List<Object?> get props => [template, targetPath];
}
