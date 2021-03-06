import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:first_app/generated/l10n.dart';
import 'package:first_app/models/appstate.dart';
import 'package:first_app/ui/pages/home/index.dart';
import 'package:first_app/ui/pages/login/index.dart';
import 'package:first_app/ui/theme/style.dart';

void main() async {
  // A breaking change in the platform messaging, as of Flutter 1.12.13+hotfix.5,
  // we need to explicitly initialise bindings to get access to the BinaryMessenger
  // This is needed by Crashlytics.
  // https://groups.google.com/forum/#!msg/flutter-announce/sHAL2fBtJ1Y/mGjrKH3dEwAJ
  WidgetsFlutterBinding.ensureInitialized();

  // Set `enableInDevMode` to true to see reports while in debug mode
  // This is only to be used for confirming that reports are being
  // submitted as expected. It is not intended to be used for everyday
  // development.
  Crashlytics.instance.enableInDevMode = true;

  // Pass all uncaught errors from the framework to Crashlytics.
  FlutterError.onError = Crashlytics.instance.recordFlutterError;

  // Get an instance so that globals are initialised
  var prefs = await SharedPreferences.getInstance();
  // Let's initialise the app state with the stored preferences
  var appState = new AppStateModel(prefs);

  // Use dart zone to define Crashlytics as error handler for errors
  // that occur outside runApp
  runZoned<Future<Null>>(() async {
    runApp(new MaterialApp(
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => S.of(context).appTitle,
      localizationsDelegates: [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: S.delegate.supportedLocales,
      home: new ChangeNotifierProvider.value(
        value: appState,
        child: new HomePage(),
      ),
      theme: appTheme,
      routes: <String, WidgetBuilder>{
        "/HomePage": (BuildContext context) => new ChangeNotifierProvider.value(
        value: appState,
        child: new HomePage(),
      ),
        "/LoginPage": (BuildContext context) => new ChangeNotifierProvider.value(
        value: appState,
        child: new LoginPage(),
      ),
      },
    ));
  }, onError: Crashlytics.instance.recordError);
}
