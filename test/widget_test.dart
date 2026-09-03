import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:link_saver/main.dart';

void main() {
  testWidgets('App boots and shows the Home greeting', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: LinkSaverApp()),
    );
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.textContaining('Your saved web, organized.'), findsOneWidget);
  });
}
