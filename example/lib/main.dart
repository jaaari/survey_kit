import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:survey_kit/src/kuluko_theme.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        // You can add your Firebase options here if needed
        // options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  await KulukoTheme.initialize();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.white,
  ));
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _buildTheme(LightModeTheme()),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          color: KulukoTheme.of(context).primary,
          child: Align(
            alignment: Alignment.center,
            child: FutureBuilder<Task>(
              future: getJsonTask(),
              builder: (BuildContext context, AsyncSnapshot<Task> snapshot) {
                if (snapshot.connectionState == ConnectionState.done &&
                    snapshot.hasData &&
                    snapshot.data != null) {
                  final Task task = snapshot.data!;
                  return SurveyKit(
                    onResult: (SurveyResult result) {
                      print('Survey finished!');
                      print(jsonEncode(result.toJson()));
                      print(result.finishReason);
                      Navigator.pushNamed(context, '/');
                    },
                    task: task,
                    localizations: const <String, String>{
                      'cancel': 'Cancel',
                      'next': 'Next',
                    },
                    themeData: Theme.of(context),
                    
                    height: MediaQuery.of(context).size.height * 0.65,
                  );
                }
                return const CircularProgressIndicator.adaptive();
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<Task> getJsonTask() async {
  try {
    print('Loading task from JSON...');

    // Initialize global state manager (add creator_user_id to global state)
    final Map<String, dynamic> data = <String, dynamic>{
      'user_id': 'jCa0yl7QTeZLSLd9sg25OXUqpVp2',
    };
    GlobalStateManager().updateData(data);

    // Load the JSON file
    final String taskJson = await rootBundle.loadString('assets/adult_customizer_flow.json');
    print('Task JSON loaded: $taskJson');

    // Decode the JSON file
    final Map<String, dynamic> taskMap = json.decode(taskJson);
    print('Task JSON decoded');

    // Create and return the Task object
    return Task.fromJson(taskMap);
  } catch (e) {
    print('Error loading task: $e');
    rethrow;
  }
}


  ThemeData _buildTheme(KulukoTheme theme) {
    return ThemeData(
      primaryColor: theme.primary,
      appBarTheme: AppBarTheme(
        color: theme.primaryBackground,
        iconTheme: IconThemeData(
          color: theme.primary,
        ),
        titleTextStyle: TextStyle(
          color: theme.primary,
        ),
      ),
      iconTheme: IconThemeData(
        color: theme.primary,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: theme.primary,
        selectionColor: theme.primary,
        selectionHandleColor: theme.primary,
      ),
      cupertinoOverrideTheme: CupertinoThemeData(
        primaryColor: theme.primary,
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(
            const Size(150.0, 60.0),
          ),
          side: MaterialStateProperty.resolveWith(
            (Set<MaterialState> state) {
              if (state.contains(MaterialState.disabled)) {
                return BorderSide(
                  color: theme.secondary,
                );
              }
              return BorderSide(
                color: theme.primary,
              );
            },
          ),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          textStyle: MaterialStateProperty.resolveWith(
            (Set<MaterialState> state) {
              if (state.contains(MaterialState.disabled)) {
                return TextStyle(
                  color: theme.secondary,
                );
              }
              return TextStyle(
                color: theme.primary,
              );
            },
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            TextStyle(
              color: theme.primary,
            ),
          ),
        ),
      ),
      textTheme: TextTheme(
        displayMedium: theme.typography.displayMedium,
        headlineSmall: theme.typography.headlineSmall,
        bodyMedium: theme.typography.bodyMedium,
        bodySmall: theme.typography.bodySmall,
        titleMedium: theme.typography.titleMedium,
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyle(
          color: theme.primaryText,
        ),
      ),
      colorScheme: ColorScheme.fromSwatch(
        primarySwatch: Colors.cyan,
      )
          .copyWith(
            onPrimary: theme.primaryText,
          )
          .copyWith(background: theme.primary),
    );
  }
}
