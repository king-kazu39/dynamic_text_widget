// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:myapp/main.dart';

void main() {
  group('DynamicTextWidget Tests', () {
    testWidgets('renders text with no placeholders',
        (WidgetTester tester) async {
      const textStyle = TextStyle(fontSize: 16, color: Colors.black);
      const template = "This is a static text.";

      await tester.pumpWidget(const MaterialApp(
        home: DynamicTextWidget(
          template: template,
          replacements: {},
          textStyle: textStyle,
        ),
      ));

      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsOneWidget);

      // RichTextの内容を取得して検証
      final richTextWidget = tester.widget<RichText>(richTextFinder);
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.toPlainText(), template); // テンプレートと一致するか確認
    });

    testWidgets('renders text with placeholder replacements',
        (WidgetTester tester) async {
      const textStyle = TextStyle(fontSize: 16, color: Colors.black);
      const template = "Hello {icon} World!";
      final replacements = {
        "icon": const Icon(Icons.star, size: 16, color: Colors.yellow),
      };

      await tester.pumpWidget(MaterialApp(
        home: DynamicTextWidget(
          template: template,
          replacements: replacements,
          textStyle: textStyle,
        ),
      ));

      // DynamicTextWidget内のRichTextを探す
      final dynamicTextWidgetFinder = find.byType(DynamicTextWidget);
      final richTextFinder = find.descendant(
        of: dynamicTextWidgetFinder,
        matching: find.byType(RichText),
      );

      // 複数のRichTextが検出される場合に絞り込む
      final matchingRichText = richTextFinder.evaluate().where((element) {
        final richText = element.widget as RichText;
        final textSpan = richText.text as TextSpan;
        return textSpan.toPlainText().contains("Hello ") &&
            textSpan.toPlainText().contains(" World!");
      }).toList();

      // 絞り込み後、1つだけであることを確認
      expect(matchingRichText.length, 1);

      // 対象のRichTextの内容を検証
      final richTextWidget = matchingRichText.first.widget as RichText;
      final textSpan = richTextWidget.text as TextSpan;

      // テキストの順序と内容を確認
      expect(textSpan.children?.length, 3); // "Hello ", WidgetSpan, " World!"
      expect((textSpan.children![0] as TextSpan).toPlainText(), "Hello ");
      expect((textSpan.children![2] as TextSpan).toPlainText(), " World!");

      // WidgetSpanの内容を検証
      final widgetSpan = textSpan.children![1] as WidgetSpan;

      // WidgetSpan.child が SizedBox > FittedBox とラップされていることを確認
      final sizedBox = widgetSpan.child as SizedBox;
      final fittedBox = sizedBox.child as FittedBox;
      final iconWidget = fittedBox.child as Icon;

      // Icon のプロパティを検証
      expect(iconWidget.icon, Icons.star);
      expect(iconWidget.color, Colors.yellow);
      expect(iconWidget.size, 16);
    });

    testWidgets('renders unknown placeholder as red text',
        (WidgetTester tester) async {
      const textStyle = TextStyle(fontSize: 16, color: Colors.black);
      const template = "Unknown {missing} Placeholder!";

      await tester.pumpWidget(const MaterialApp(
        home: DynamicTextWidget(
          template: template,
          replacements: {},
          textStyle: textStyle,
        ),
      ));

      // DynamicTextWidget内のRichTextを見つける
      final dynamicTextWidgetFinder = find.byType(DynamicTextWidget);
      final richTextFinder = find.descendant(
        of: dynamicTextWidgetFinder,
        matching: find.byType(RichText),
      );

      // RichTextが見つかることを確認
      expect(richTextFinder, findsOneWidget);

      // RichText内のテキスト内容を検証
      final richTextWidget = tester.widget<RichText>(richTextFinder);
      final textSpan = richTextWidget.text as TextSpan;

      // プレースホルダーが赤字として描画されていることを確認
      final unknownPlaceholderSpan = textSpan.children!.firstWhere(
        (child) =>
            child is TextSpan &&
            child.text == "{missing}" &&
            child.style?.color == Colors.red,
        orElse: () => const TextSpan(text: ""), // 空の TextSpan を返す
      );

      // 検出した InlineSpan が空でないことを確認
      expect(unknownPlaceholderSpan is TextSpan, isTrue);
      expect((unknownPlaceholderSpan as TextSpan).text, "{missing}");
      expect(unknownPlaceholderSpan.style?.color, Colors.red);
    });

    testWidgets('uses default font size when TextStyle.fontSize is null',
        (WidgetTester tester) async {
      const textStyle = TextStyle(color: Colors.black); // fontSize未指定
      const template = "Dynamic {icon} Text!";
      final replacements = {
        "icon": const Icon(Icons.star, color: Colors.yellow),
      };

      await tester.pumpWidget(MaterialApp(
        home: DynamicTextWidget(
          template: template,
          replacements: replacements,
          textStyle: textStyle,
        ),
      ));

      // DynamicTextWidget内のRichTextを探す
      final dynamicTextWidgetFinder = find.byType(DynamicTextWidget);
      final richTextFinder = find.descendant(
        of: dynamicTextWidgetFinder,
        matching: find.byType(RichText),
      );

      // 複数のRichTextが検出される場合に絞り込む
      final matchingRichText = richTextFinder.evaluate().where((element) {
        final richText = element.widget as RichText;
        final textSpan = richText.text as TextSpan;
        return textSpan.toPlainText().contains("Dynamic ") &&
            textSpan.toPlainText().contains(" Text!");
      }).toList();

      // 絞り込み後、1つだけであることを確認
      expect(matchingRichText.length, 1);

      // 対象のRichTextの内容を検証
      final richTextWidget = matchingRichText.first.widget as RichText;
      final textSpan = richTextWidget.text as TextSpan;

      // テキストの順序と内容を確認
      expect(textSpan.children?.length, 3); // "Dynamic ", WidgetSpan, " Text!"
      expect((textSpan.children![0] as TextSpan).toPlainText(), "Dynamic ");
      expect((textSpan.children![2] as TextSpan).toPlainText(), " Text!");

      // WidgetSpanの内容を検証
      final widgetSpan = textSpan.children![1] as WidgetSpan;

      // WidgetSpan.child が SizedBox でラップされていることを確認
      final sizedBox = widgetSpan.child as SizedBox;
      expect(sizedBox.width, isNotNull);
      expect(sizedBox.height, isNotNull);

      // SizedBox の幅と高さがフォントサイズに基づいていることを確認
      expect(sizedBox.width, 16.0); // デフォルトフォントサイズが 16.0 と仮定
      expect(sizedBox.height, 16.0);
    });

    testWidgets('handles empty template gracefully',
        (WidgetTester tester) async {
      const textStyle = TextStyle(fontSize: 16, color: Colors.black);
      const template = "";

      await tester.pumpWidget(const MaterialApp(
        home: DynamicTextWidget(
          template: template,
          replacements: {},
          textStyle: textStyle,
        ),
      ));

      // RichTextが描画されていることを確認
      final richTextFinder = find.byType(RichText);
      expect(richTextFinder, findsOneWidget);

      // RichTextの内容が空であることを確認
      final richTextWidget = tester.widget<RichText>(richTextFinder);
      final textSpan = richTextWidget.text as TextSpan;
      expect(textSpan.toPlainText(), ""); // 空のテンプレートなので内容も空
    });
  });
}
