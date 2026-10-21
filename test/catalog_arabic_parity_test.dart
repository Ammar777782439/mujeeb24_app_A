import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mujeeb24_app/core/models/catalog_models.dart';
import 'package:mujeeb24_app/features/catalog/presentation/catalog_specification_input.dart';

void main() {
  const definition = AttributeDefinition(
    id: 'server-defined',
    key: 'attr_opaque_123',
    label: 'مدة الضمان',
    dataType: 'number',
    required: true,
    displayOrder: 1,
    validationRules: {'min': 1, 'max': 60},
  );

  test('Server-owned schema key never leaks to merchant labels', () {
    expect(specificationName(definition.key, [definition]), 'مدة الضمان');
    expect(specificationName(definition.key, []), 'معلومة محفوظة من قالب');
    expect(specificationName('اللون', []), 'اللون');
    expect(displaySpecification(true), 'نعم');
    expect(displaySpecification(false), 'لا');
    expect(displaySpecification(['أزرق', 'أبيض']), 'أزرق، أبيض');
  });

  test('Typed required and numeric limits enforce backend schema definitions', () {
    expect(validateSpecification(definition, null), 'أدخل مدة الضمان');
    expect(validateSpecification(definition, '12'), contains('رقمًا صحيحًا'));
    expect(validateSpecification(definition, 0), contains('لا يقل عن 1'));
    expect(validateSpecification(definition, 61), contains('لا يزيد عن 60'));
    expect(validateSpecification(definition, 12), isNull);
    const opts = AttributeDefinition(
      id: '1', key: 'opaque',
      label: 'اللون', dataType: 'multi_select', required: true,
      validationRules: {'enum': ['أزرق', 'أسود']},
    );
    expect(validateSpecification(opts, ['أزرق']), isNull);
    expect(validateSpecification(opts, ['أحمر']), contains('اختر اللون'));
  });

  test('Schema payload sends Arabic label and never generates local keys', () {
    const req = CreateAttributeSchemaRequest(
      name: 'الهواتف',
      definitions: [
        AttributeDefinitionInput(
          label: 'حجم الذاكرة',
          dataType: 'select',
          required: true,
          displayOrder: 1,
          validationRules: {'enum': ['128 جيجا', '256 جيجا']},
        ),
      ],
    );
    final json = req.toJson();
    final entry = (json['definitions'] as List).first as Map<String, dynamic>;
    expect(entry['label'], 'حجم الذاكرة');
    expect(entry['validation_rules'], {'enum': ['128 جيجا', '256 جيجا']});
    expect(entry.containsKey('key'), isFalse);
    expect(entry.containsKey('id'), isFalse);
  });

  test('Unmodified typed old attributes can be sent without lossy string conversion', () {
    final saved = <String, dynamic>{
      'attr_abc': true,
      'الخيارات': ['كبير', 'صغير'],
      'عدد الغرف': 3,
      'بيانات إضافية': {'a': 1},
    };
    final req = UpdateCatalogItemRequest(name: 'تحديث الاسم');
    expect(req.toJson().containsKey('attributes'), isFalse);
    expect(saved['attr_abc'], isA<bool>());
    expect(saved['الخيارات'], isA<List>());
  });

  for (final width in [320.0, 390.0, 600.0]) {
    testWidgets('Arabic typed attribute controls fit width ' + width.toString(),
        (tester) async {
      tester.view.physicalSize = Size(width, 780);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      dynamic current;
      await tester.pumpWidget(MaterialApp(
        locale: const Locale('ar'),
        home: Scaffold(body: SafeArea(child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: CatalogSpecificationInput(
              definition: definition,
              value: current,
              onChanged: (value) => current = value,
            ),
          ),
        ))),
      ));
      await tester.pumpAndSettle();
      expect(find.byType(TextFormField), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.enterText(find.byType(TextFormField), '24');
      expect(current, 24);
      expect(tester.takeException(), isNull);
    });
  }
}
