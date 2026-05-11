import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:crudapi/login_page.dart';

void main() {
  testWidgets('La page de connexion affiche les champs email et mot de passe', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    expect(find.text('CONNEXION'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Password'), findsOneWidget);
    expect(find.text('SE CONNECTER'), findsOneWidget);
    expect(find.text("S'INSCRIRE"), findsOneWidget);
  });

  testWidgets('Le bouton SE CONNECTER est présent et cliquable', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: LoginPage()));

    final bouton = find.text('SE CONNECTER');
    expect(bouton, findsOneWidget);
    await tester.tap(bouton);
    await tester.pump();
  });
}