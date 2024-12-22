import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:survey_kit/src/answer_format/multiple_choice_answer_format.dart';
import 'package:survey_kit/src/answer_format/text_choice.dart';
import 'package:survey_kit/src/result/question/multiple_choice_question_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/widget/selection_list_tile.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:survey_kit/src/controller/survey_controller.dart';
import 'package:provider/provider.dart';
import 'package:survey_kit/src/theme_extensions.dart';


class MultipleChoiceAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final MultipleChoiceQuestionResult? result;

  const MultipleChoiceAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  _MultipleChoiceAnswerView createState() => _MultipleChoiceAnswerView();
}

class _MultipleChoiceAnswerView extends State<MultipleChoiceAnswerView> {
  late final DateTime _startDateTime;
  late final MultipleChoiceAnswerFormat _multipleChoiceAnswer;

  List<TextChoice> _selectedChoices = [];
  List<TextChoice> _choices = [];
  List<String> _imageChoices = [];

  @override
  void initState() {
    super.initState();
    _multipleChoiceAnswer =
        widget.questionStep.answerFormat as MultipleChoiceAnswerFormat;
    _selectedChoices =
        widget.result?.result ?? _multipleChoiceAnswer.defaultSelection;
    _startDateTime = DateTime.now();
    _initChoices();
    _initImages();
  }

  void _initChoices() {
    print("MultichoiceAnswerView: Initializing choices");
    print("DynamicTextChoices: ${_multipleChoiceAnswer.dynamicTextChoices}");
    if (_multipleChoiceAnswer.textChoices.isNotEmpty) {
      print('SingleChoiceAnswerView: Using textChoices');
      _choices = _multipleChoiceAnswer.textChoices;
    } else if (_multipleChoiceAnswer.dynamicTextChoices != "") {
      var manager = GlobalStateManager();
      var dynamicChoices = manager
          .getData(_multipleChoiceAnswer.dynamicTextChoices.substring(1));
      print('Using dynamicTextChoices: $dynamicChoices');
      if (dynamicChoices != null && dynamicChoices is List) {
        print("Dynamic choices: $dynamicChoices");
        _choices = dynamicChoices
            .map<TextChoice>((choice) {
              if (choice is Map<String, dynamic>) {
                return TextChoice(
                  text: choice['text'] as String,
                  value: choice['value'] as String,
                  characterName: choice['character_name'] as String?,
                );
              } else {
                return TextChoice.fromJson(choice.toJson());
              }
            })
            .toList();
        print('Choices after parsing: ${_choices.map((c) => {'text': c.text, 'value': c.value, 'character_name': c.characterName}).toList()}');
      }
    }
    // Select default choice if not set
    if (_selectedChoices.isEmpty && _choices.isNotEmpty) {
      _selectedChoices = [_choices.first];
    }

    _onAnswerChanged();
  }

  void _initImages() {
    if (_multipleChoiceAnswer.imageChoices.isNotEmpty) {
      print("SingleChoiceAnswerView: Initializing image choices");
      print("Image urls: ${_multipleChoiceAnswer.imageChoices}");
      _imageChoices = _multipleChoiceAnswer.imageChoices;
      print("Image choices loaded: ${_imageChoices.length}");
    } else if (_multipleChoiceAnswer.dynamicImageChoices != "") {
      var manager = GlobalStateManager();
      var dynamicImageChoices = manager
          .getData(_multipleChoiceAnswer.dynamicImageChoices.substring(1));
      print('Using dynamicImageChoices: $dynamicImageChoices');
      if (dynamicImageChoices != null && dynamicImageChoices is List) {
        _imageChoices = dynamicImageChoices.cast<String>();
        print('Dynamic image choices added: ${_imageChoices.length}');
      } else {
        print('Dynamic image choices data is not in expected List format.');
      }
    }
  }

  void _onAnswerChanged() {
    print("Tapped a multiple choice answer");

    Map<String, dynamic> _resultMap = {};

    // Update for relatedParameter
    if (widget.questionStep.relatedParameter.isNotEmpty) {
      _resultMap[widget.questionStep.relatedParameter] =
          _selectedChoices.map((choice) => choice.value).join(',');
    }

    // Update for relatedTextChoiceParameter
    if (widget.questionStep.relatedTextChoiceParameter.isNotEmpty) {
      _resultMap[widget.questionStep.relatedTextChoiceParameter] =
          _selectedChoices.map((choice) {
        return {
          'text': choice.text, 
          'value': choice.value,
          'character_name': choice.characterName
        };
      }).toList();
    }

    GlobalStateManager().updateData(_resultMap);
    Map<String, dynamic> _allData = GlobalStateManager().getAllData();
    print("Updated multiple choice data: $_resultMap");
    print("Global state: $_allData");
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.questionStep,
      resultFunction: () => MultipleChoiceQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDateTime,
        endDate: DateTime.now(),
        valueIdentifier:
            _selectedChoices.map((choices) => choices.value).join(','),
        result: _selectedChoices,
      ),
      isValid: widget.questionStep.isOptional || _selectedChoices.isNotEmpty,
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
            if (widget.questionStep.text.isNotEmpty)
              Padding(
                padding: EdgeInsets.all(context.standard.value),
                child: Text(
                  widget.questionStep.text,
                  style: context.body.copyWith(color: context.textPrimary),
                  textAlign: TextAlign.center,
                ),
              ),
            ..._choices.asMap().entries.map(
              (entry) {
                int idx = entry.key;
                TextChoice tc = entry.value;
                bool hasImage = idx < _imageChoices.length &&
                    _imageChoices[idx].isNotEmpty &&
                    _imageChoices[idx] != "";
                
                // Create the display text with character name if available
                String displayText = tc.characterName != null 
                    ? "${tc.characterName}\n${tc.text}"
                    : tc.text;
                    
                return SelectionListTile(
                  text: displayText,
                  imageURL: hasImage ? _imageChoices[idx] : "",
                  onTap: () {
                    setState(() {
                      if (_selectedChoices.contains(tc)) {
                        _selectedChoices.remove(tc);
                      } else {
                        if (_multipleChoiceAnswer.maxAnswers >
                            _selectedChoices.length) {
                          _selectedChoices = [..._selectedChoices, tc];
                        }
                      }
                      _onAnswerChanged();
                    });
                  },
                  isSelected: _selectedChoices.contains(tc),
                );
              },
            ).toList(),
            if (_multipleChoiceAnswer.otherField) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14.0),
                child: ListTile(
                  title: TextField(
                    onChanged: (v) {
                      int? currentIndex;
                      final otherTextChoice = _selectedChoices
                          .firstWhereIndexedOrNull((index, element) {
                        final isOtherField = element.text == 'Other';

                        if (isOtherField) {
                          currentIndex = index;
                        }

                        return isOtherField;
                      });

                      setState(() {
                        if (v.isEmpty && otherTextChoice != null) {
                          _selectedChoices.remove(otherTextChoice);
                        } else if (v.isNotEmpty) {
                          final updatedTextChoice =
                              TextChoice(text: 'Other', value: v);
                          if (otherTextChoice == null) {
                            _selectedChoices.add(updatedTextChoice);
                          } else if (currentIndex != null) {
                            _selectedChoices[currentIndex!] =
                                updatedTextChoice;
                          }
                        }
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Other',
                      labelStyle: Theme.of(context).textTheme.headlineSmall,
                      hintText: 'Write other information here',
                      floatingLabelBehavior: FloatingLabelBehavior.always,
                    ),
                  ),
                ),
              ),
            ],
            if (_multipleChoiceAnswer.buttonChoices.isNotEmpty) ...[
              ..._multipleChoiceAnswer.buttonChoices.map(
                (TextChoice bc) => SelectionListTile(
                  text: bc.text,
                  onTap: () {
                    final surveyController =
                        Provider.of<SurveyController>(context, listen: false);
                    final resultFunction = () => MultipleChoiceQuestionResult(
                          id: widget.questionStep.stepIdentifier,
                          startDate: _startDateTime,
                          endDate: DateTime.now(),
                          valueIdentifier: [bc].map((choices) => choices.value).join(','),
                          result: [bc],
                        );
                    surveyController.nextStep(context, resultFunction);
                  },
                  isSelected: false,
                ),
              ).toList(),
            ],
          ],
        ),
      ),
    );
  }
}
