import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:flutter/services.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:survey_kit/src/kuluko_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
      darkTheme: _buildTheme(DarkModeTheme()),
      themeMode: KulukoTheme.themeMode,
      home: Scaffold(
        body: Container(
          color: KulukoTheme.of(context).primaryBackground,
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
                    showProgress: true,
                    localizations: const <String, String>{
                      'cancel': 'Cancel',
                      'next': 'Next',
                    },
                    themeData: Theme.of(context).copyWith(
                      primaryColor: KulukoTheme.of(context).primary,
                      appBarTheme: AppBarTheme(
                        color: KulukoTheme.of(context).primaryBackground,
                        iconTheme: IconThemeData(
                          color: KulukoTheme.of(context).primary,
                        ),
                        titleTextStyle: TextStyle(
                          color: KulukoTheme.of(context).primary,
                        ),
                      ),
                      iconTheme: IconThemeData(
                        color: KulukoTheme.of(context).primary,
                      ),
                      textSelectionTheme: TextSelectionThemeData(
                        cursorColor: KulukoTheme.of(context).primary,
                        selectionColor: KulukoTheme.of(context).primary,
                        selectionHandleColor: KulukoTheme.of(context).primary,
                      ),
                      cupertinoOverrideTheme: CupertinoThemeData(
                        primaryColor: KulukoTheme.of(context).primary,
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
                                  color: KulukoTheme.of(context).secondary,
                                );
                              }
                              return BorderSide(
                                color: KulukoTheme.of(context).primary,
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
                                return Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: KulukoTheme.of(context).secondary,
                                    );
                              }
                              return Theme.of(context)
                                  .textTheme
                                  .labelLarge
                                  ?.copyWith(
                                    color: KulukoTheme.of(context).primary,
                                  );
                            },
                          ),
                        ),
                      ),
                      textButtonTheme: TextButtonThemeData(
                        style: ButtonStyle(
                          textStyle: MaterialStateProperty.all(
                            Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: KulukoTheme.of(context).primary,
                                ),
                          ),
                        ),
                      ),
                      textTheme: TextTheme(
                        displayMedium: KulukoTheme.of(context).typography.displayMedium,
                        headlineSmall: KulukoTheme.of(context).typography.headlineSmall,
                        bodyMedium: KulukoTheme.of(context).typography.bodyMedium,
                        bodySmall: KulukoTheme.of(context).typography.bodySmall,
                        titleMedium: KulukoTheme.of(context).typography.titleMedium,
                      ),
                      inputDecorationTheme: InputDecorationTheme(
                        labelStyle: TextStyle(
                          color: KulukoTheme.of(context).primaryText,
                        ),
                      ),
                      colorScheme: ColorScheme.fromSwatch(
                        primarySwatch: Colors.cyan,
                      )
                          .copyWith(
                            onPrimary: KulukoTheme.of(context).primaryText,
                          )
                          .copyWith(background: KulukoTheme.of(context).primaryBackground),
                    ),
                    surveyProgressbarConfiguration: SurveyProgressConfiguration(
                      backgroundColor: KulukoTheme.of(context).primaryBackground,
                    ),
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
      // initialize global state manager (add creator_user_id to global state)
      final Map<String, dynamic> data = <String, dynamic>{
        'user_id': 'VUuZfqDLnsZissgtTobpdorbppC2',
      };
      GlobalStateManager().updateData(data);
      final String taskJson =
          await rootBundle.loadString('adult_customizer_flow.json');
      final Map<String, dynamic> taskMap = json.decode(taskJson);
      print('Task loaded from JSON');
      return Task.fromJson(taskMap);
    } catch (e) {
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
          .copyWith(background: theme.primaryBackground),
    );
  }
}
