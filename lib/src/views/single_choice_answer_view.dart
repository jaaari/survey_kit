import 'package:flutter/material.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:survey_kit/src/controller/survey_controller.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/src/theme_extensions.dart';

class SingleChoiceAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final SingleChoiceQuestionResult? result;

  const SingleChoiceAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  _SingleChoiceAnswerViewState createState() => _SingleChoiceAnswerViewState();
}

class _SingleChoiceAnswerViewState extends State<SingleChoiceAnswerView> {
  late final DateTime _startDate;
  late final SingleChoiceAnswerFormat _singleChoiceAnswerFormat;
  TextChoice? _selectedChoice;
  List<TextChoice> _choices = [];
  List<String> _imageChoices = [];
  bool isClicked = false;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _singleChoiceAnswerFormat =
        widget.questionStep.answerFormat as SingleChoiceAnswerFormat;
    _selectedChoice = null; // No choice is preselected
    _initChoices();
    print("SingleChoiceAnswerView: Initialized");
    _initImages(); // Initialize image choices
    GlobalStateManager().addListener(_refreshChoices);
  }

  void _initImages() {
    print("SingleChoiceAnswerView: Initializing image choices");
    if (_singleChoiceAnswerFormat.imageChoices.isNotEmpty) {
      print("SingleChoiceAnswerView: Initializing image choices");
      print("Image urls: ${_singleChoiceAnswerFormat.imageChoices}");
      _imageChoices = _singleChoiceAnswerFormat.imageChoices;
      print("Image choices loaded: ${_imageChoices.length}");
    }
    else if (_singleChoiceAnswerFormat.dynamicImageChoices != "") {
      var manager = GlobalStateManager();
      var dynamicImageChoices = manager
          .getData(_singleChoiceAnswerFormat.dynamicImageChoices.substring(1));
      print('Using dynamicImageChoices: $dynamicImageChoices');
      if (dynamicImageChoices != null && dynamicImageChoices is List) {
        _imageChoices = dynamicImageChoices.cast<String>();
        print('Dynamic image choices added: ${_imageChoices.length}');
      } else {
        print('Dynamic image choices data is not in expected List format.');
      }
    }
  }

  @override
  void dispose() {
    GlobalStateManager().removeListener(_refreshChoices);
    super.dispose();
  }

  void _refreshChoices() {
    _fetchAndUpdateChoices();
  }

  void _initChoices() {
    print("SingleChoiceAnswerView: Initializing choices");
    _fetchAndUpdateChoices();
  }

  void _fetchAndUpdateChoices() {
    if (isClicked) return;
    final prevChoices = _singleChoiceAnswerFormat.textChoices.toList();
    _choices.clear();

    if (_singleChoiceAnswerFormat.textChoices.isNotEmpty) {
      _choices = prevChoices;
      print('Static text choices loaded: ${_choices.length}');
    }

    if (_singleChoiceAnswerFormat.dynamicTextChoices.isNotEmpty) {
      var manager = GlobalStateManager();
      var dynamicChoices = manager
          .getData(_singleChoiceAnswerFormat.dynamicTextChoices.substring(1));
      print('Using dynamicTextChoices: $dynamicChoices');
      if (dynamicChoices != null && dynamicChoices is List) {
        _choices += dynamicChoices
            .map<TextChoice>((choice) => TextChoice.fromJson(choice))
            .toList();
        print('Dynamic choices added: ${dynamicChoices.length}');
      } else {
        print('Dynamic choices data is not in expected List format.');
      }
    }

    if (_singleChoiceAnswerFormat.buttonChoices.isNotEmpty) {
      _choices += _singleChoiceAnswerFormat.buttonChoices;
    }

    print('Total choices available after update: ${_choices.length}');
  }

  void _onAnswerChanged(TextChoice tc) {
    setState(() {
      _selectedChoice = tc;
    });
    
    Map<String, dynamic> _resultMap = {};
    
    // Update for relatedParameter
    if (widget.questionStep.relatedParameter.isNotEmpty) {
      _resultMap[widget.questionStep.relatedParameter] = tc.value;
    }

    // Update for relatedTextChoiceParameter
    if (widget.questionStep.relatedTextChoiceParameter.isNotEmpty) {
      _resultMap[widget.questionStep.relatedTextChoiceParameter] = [
        {'text': tc.text, 'value': tc.value}
      ];
    }

    GlobalStateManager().updateData(_resultMap);
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.questionStep,
      resultFunction: () => SingleChoiceQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDate,
        endDate: DateTime.now(),
        valueIdentifier: _selectedChoice?.value ?? '',
        result: _selectedChoice,
      ),
      isValid: widget.questionStep.isOptional || _selectedChoice != null,
      title: widget.questionStep.title.isNotEmpty
          ? Text(widget.questionStep.title,
              style: context.body.copyWith(color: context.textPrimary),
              textAlign: TextAlign.center)
          : widget.questionStep.content,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ..._choices.asMap().entries.map((entry) {
              int idx = entry.key;
              TextChoice tc = entry.value;
              bool hasImage = idx < _imageChoices.length && 
                  _imageChoices[idx].isNotEmpty && 
                  _imageChoices[idx] != "";
              return SelectionListTile(
                text: tc.text,
                imageURL: hasImage ? _imageChoices[idx] : "",
                onTap: () {
                  _onAnswerChanged(tc);
                },
                isSelected: _selectedChoice == tc,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}

