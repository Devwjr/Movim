import 'package:flutter_test/flutter_test.dart';
import 'package:mobilevim/features/editor/domain/entities/buffer_entity.dart';

void main() {
  group('BufferEntity', () {
    test('should create a buffer with default values', () {
      final buffer = BufferEntity(id: '1', fileName: 'test.dart');

      expect(buffer.id, '1');
      expect(buffer.fileName, 'test.dart');
      expect(buffer.content, '');
      expect(buffer.mode, EditorMode.normal);
      expect(buffer.isModified, false);
      expect(buffer.lineCount, 1);
      expect(buffer.lines, ['']);
    });

    test('should parse content into lines', () {
      final buffer = BufferEntity(
        id: '1',
        fileName: 'test.dart',
        content: 'line1\nline2\nline3',
      );

      expect(buffer.lineCount, 3);
      expect(buffer.lines, ['line1', 'line2', 'line3']);
    });

    test('should return current line at cursor', () {
      final buffer = BufferEntity(
        id: '1',
        content: 'first\nsecond\nthird',
        cursor: const CursorPosition(line: 1, column: 0),
      );

      expect(buffer.currentLine, 'second');
    });

    test('should detect modification', () {
      final buffer = BufferEntity(
        id: '1',
        content: 'hello',
        isModified: true,
      );

      expect(buffer.isModified, true);
    });

    test('copyWith should create modified copy', () {
      final buffer = BufferEntity(id: '1', content: 'hello');
      final modified = buffer.copyWith(
        content: 'hello world',
        isModified: true,
      );

      expect(modified.content, 'hello world');
      expect(modified.isModified, true);
      expect(modified.id, '1');
    });
  });

  group('CursorPosition', () {
    test('should create cursor with default values', () {
      final cursor = const CursorPosition();
      expect(cursor.line, 0);
      expect(cursor.column, 0);
    });

    test('copyWith should update values', () {
      final cursor = const CursorPosition(line: 1, column: 2);
      final moved = cursor.copyWith(column: 5);

      expect(moved.line, 1);
      expect(moved.column, 5);
    });
  });
}
