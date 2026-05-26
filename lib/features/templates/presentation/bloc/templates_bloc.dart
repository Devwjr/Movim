import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/template_entity.dart';

part 'templates_event.dart';
part 'templates_state.dart';

class TemplatesBloc extends Bloc<TemplatesEvent, TemplatesState> {
  TemplatesBloc() : super(const TemplatesInitial()) {
    on<TemplatesLoad>(_onLoad);
    on<TemplatesSearch>(_onSearch);
    on<TemplatesFilterCategory>(_onFilterCategory);
    on<TemplatesApplyTemplate>(_onApplyTemplate);
  }

  Future<void> _onLoad(
    TemplatesLoad event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(const TemplatesLoading());
    emit(TemplatesReady(
      templates: DefaultTemplates.templates,
      filteredTemplates: DefaultTemplates.templates,
      selectedCategory: null,
      searchQuery: '',
    ));
  }

  void _onSearch(
    TemplatesSearch event,
    Emitter<TemplatesState> emit,
  ) {
    if (state is! TemplatesReady) return;
    final currentState = state as TemplatesReady;

    final query = event.query.toLowerCase();
    final filtered = currentState.templates.where((t) {
      final matchesSearch = query.isEmpty ||
          t.name.toLowerCase().contains(query) ||
          t.description.toLowerCase().contains(query) ||
          t.tags.any((tag) => tag.toLowerCase().contains(query));

      final matchesCategory = currentState.selectedCategory == null ||
          t.category == currentState.selectedCategory;

      return matchesSearch && matchesCategory;
    }).toList();

    emit(currentState.copyWith(
      filteredTemplates: filtered,
      searchQuery: event.query,
    ));
  }

  void _onFilterCategory(
    TemplatesFilterCategory event,
    Emitter<TemplatesState> emit,
  ) {
    if (state is! TemplatesReady) return;
    final currentState = state as TemplatesReady;

    final category = event.category;
    final filtered = currentState.templates.where((t) {
      final matchesCategory = category == null || t.category == category;
      final matchesSearch = currentState.searchQuery.isEmpty ||
          t.name.toLowerCase().contains(currentState.searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(currentState.searchQuery.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    emit(currentState.copyWith(
      filteredTemplates: filtered,
      selectedCategory: category,
    ));
  }

  Future<void> _onApplyTemplate(
    TemplatesApplyTemplate event,
    Emitter<TemplatesState> emit,
  ) async {
    emit(const TemplatesLoading());

    try {
      final template = event.template;
      final targetDir = Directory(event.targetPath);

      if (!await targetDir.exists()) {
        await targetDir.create(recursive: true);
      }

      for (final file in template.files) {
        final filePath = '${event.targetPath}/${file.path}';
        final fileDir = Directory(filePath.substring(0, filePath.lastIndexOf('/')));

        if (!await fileDir.exists()) {
          await fileDir.create(recursive: true);
        }

        await File(filePath).writeAsString(file.content);
      }

      emit(TemplateApplied(
        template: template,
        targetPath: event.targetPath,
        commands: template.commands,
      ));
    } catch (e) {
      emit(TemplatesError('Erro ao aplicar template: $e'));
    }
  }
}
