import 'package:fast_i18n/src/builder/node_builder.dart';
import 'package:fast_i18n/src/model/build_config.dart';
import 'package:fast_i18n/src/model/node.dart';
import 'package:test/test.dart';

import '../../util/build_config_utils.dart';

void main() {
  group(NodeBuilder.fromMap, () {
    test('1 TextNode', () {
      final result = NodeBuilder.fromMap(baseConfig, defaultLocale, {
        'test': 'a',
      });
      final map = result.root.entries;
      expect((map['test'] as TextNode).content, 'a');
    });

    test('keyCase=snake and keyMapCase=camel', () {
      final result = NodeBuilder.fromMap(
        baseConfig.copyWith(
          maps: ['my_map'],
          keyCase: CaseStyle.snake,
          keyMapCase: CaseStyle.camel,
        ),
        defaultLocale,
        {
          'myMap': {'my_value': 'cool'},
        },
      );
      final mapNode = result.root.entries['my_map'] as ObjectNode;
      expect((mapNode.entries['myValue'] as TextNode).content, 'cool');
    });

    test('keyCase=snake and keyMapCase=null', () {
      final result = NodeBuilder.fromMap(
        baseConfig.copyWith(
          maps: ['my_map'],
          keyCase: CaseStyle.snake,
        ),
        defaultLocale,
        {
          'myMap': {'my_value 3': 'cool'},
        },
      );
      final mapNode = result.root.entries['my_map'] as ObjectNode;
      expect((mapNode.entries['my_value 3'] as TextNode).content, 'cool');
    });

    test('one link no parameters', () {
      final result = NodeBuilder.fromMap(
        baseConfig,
        defaultLocale,
        {
          'a': 'A',
          'b': 'Hello @:a',
        },
      );
      final textNode = result.root.entries['b'] as TextNode;
      expect(textNode.params, <String>{});
      expect(textNode.content, r'Hello ${AppLocale.en.translations.a}');
    });

    test('one link 2 parameters straight', () {
      final result = NodeBuilder.fromMap(
        baseConfig,
        defaultLocale,
        {
          'a': r'A $p1 $p1 $p2',
          'b': 'Hello @:a',
        },
      );
      final textNode = result.root.entries['b'] as TextNode;
      expect(textNode.params, {'p1', 'p2'});
      expect(textNode.content,
          r'Hello ${AppLocale.en.translations.a(p1: p1, p2: p2)}');
    });

    test('linked translations with parameters recursive', () {
      final result = NodeBuilder.fromMap(
        baseConfig,
        defaultLocale,
        {
          'a': r'A $p1 $p1 $p2 @:b @:c',
          'b': r'Hello $p3 @:a',
          'c': r'C $p4 @:a',
        },
      );
      final textNode = result.root.entries['b'] as TextNode;
      expect(textNode.params, {'p1', 'p2', 'p3', 'p4'});
      expect(textNode.content,
          r'Hello $p3 ${AppLocale.en.translations.a(p1: p1, p2: p2, p3: p3, p4: p4)}');
    });
  });
}
