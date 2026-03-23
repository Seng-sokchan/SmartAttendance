import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:smart_attendance_app/screens/login_screen.dart';

void main() {
  testWidgets('Login screen builds', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: LoginScreen()),
    );
    expect(find.text('SmartAttendanceApp'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
