import 'package:fleet_watch/home/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/helpers.dart';

void main() {
  group('HomePage', () {
    testWidgets('renders body Center', (tester) async {
      await tester.pumpApp(const HomePage());
      expect(find.byType(Center), findsOneWidget);
    });
  });
}
