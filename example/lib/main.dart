import 'dart:convert';
import 'package:flutter/material.dart';
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
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: Scaffold(
        body: _buildFullScreenSurvey(context), // Build the survey directly
      ),
    );
  }

  Widget _buildFullScreenSurvey(BuildContext context) {
    return FutureBuilder<Task>(
      future: getJsonTask(),
      builder: (BuildContext context, AsyncSnapshot<Task> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.hasData &&
            snapshot.data != null) {
          final Task task = snapshot.data!;
          return Center(
            child: Container(
              height: MediaQuery.of(context).size.height * 0.6, // 70% of the screen height
              child: SurveyKit(
                onResult: (SurveyResult result) {
                  print('Survey finished!');
                  print(jsonEncode(result.toJson()));
                },
                task: task,
                showProgress: true,
                localizations: const <String, String>{
                  'cancel': 'Cancel',
                  'next': 'Next',
                },
                themeData: Theme.of(context),
                surveyProgressbarConfiguration: SurveyProgressConfiguration(
                  backgroundColor: KulukoTheme.of(context).primaryBackground,
                ),
              ),
            ),
          );
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }

  Future<Task> getJsonTask() async {
    try {
      print('Loading task from JSON...');
      final String taskJson = await rootBundle.loadString('assets/onboarding_flow.json');
      print('Task JSON loaded: $taskJson');
      final Map<String, dynamic> taskMap = json.decode(taskJson);
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
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          minimumSize: MaterialStateProperty.all(
            const Size(150.0, 60.0),
          ),
          side: MaterialStateProperty.resolveWith(
            (Set<MaterialState> state) {
              if (state.contains(MaterialState.disabled)) {
                return BorderSide(color: theme.secondary);
              }
              return BorderSide(color: theme.primary);
            },
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          textStyle: MaterialStateProperty.all(
            TextStyle(color: theme.primary),
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
        labelStyle: TextStyle(color: theme.primaryText),
      ),
      colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.cyan)
          .copyWith(onPrimary: theme.primaryText)
          .copyWith(background: theme.primaryBackground),
    );
  }
}
