import 'package:flutter/material.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:survey_kit/src/controller/survey_controller.dart';
import 'package:survey_kit/src/answer_format/single_choice_audio_answer_format.dart';
import 'package:survey_kit/src/result/question/single_choice_audio_question_result.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';

class SingleChoiceAudioAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final SingleChoiceAudioQuestionResult? result;

  const SingleChoiceAudioAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  _SingleChoiceAudioAnswerViewState createState() => _SingleChoiceAudioAnswerViewState();
}

class _SingleChoiceAudioAnswerViewState extends State<SingleChoiceAudioAnswerView> {
  late final DateTime _startDate;
  late final SingleChoiceAudioAnswerFormat _SingleChoiceAudioAnswerFormat;
  TextChoice? _selectedChoice;
  List<TextChoice> _choices = [];
  List<String> _imageChoices = [];
  List<String> _audioChoices = [];
  bool isClicked = false;
  AudioPlayer? _audioPlayer;

  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now();
    _SingleChoiceAudioAnswerFormat =
        widget.questionStep.answerFormat as SingleChoiceAudioAnswerFormat;
    _selectedChoice = null; // No choice is preselected
    _initChoices();
    print("SingleChoiceAudioAnswerView: Initialized");
    _initImages(); // Initialize image choices
    _initAudioChoices(); // Initialize audio choices
    GlobalStateManager().addListener(_refreshChoices);
  }

  void _initImages() {
    print("SingleChoiceAudioAnswerView: Initializing image choices");
    if (_SingleChoiceAudioAnswerFormat.imageChoices.isNotEmpty) {
      print("SingleChoiceAudioAnswerView: Initializing image choices");
      print("Image urls: ${_SingleChoiceAudioAnswerFormat.imageChoices}");
      _imageChoices = _SingleChoiceAudioAnswerFormat.imageChoices;
      print("Image choices loaded: ${_imageChoices.length}");
    } else if (_SingleChoiceAudioAnswerFormat.dynamicImageChoices != "") {
      var manager = GlobalStateManager();
      var dynamicImageChoices = manager
          .getData(_SingleChoiceAudioAnswerFormat.dynamicImageChoices.substring(1));
      print('Using dynamicImageChoices: $dynamicImageChoices');
      if (dynamicImageChoices != null && dynamicImageChoices is List) {
        _imageChoices = dynamicImageChoices.cast<String>();
        print('Dynamic image choices added: ${_imageChoices.length}');
      } else {
        print('Dynamic image choices data is not in expected List format.');
      }
    }
  }

  void _initAudioChoices() {
    print("SingleChoiceAudioAnswerView: Initializing audio choices");
    if (_SingleChoiceAudioAnswerFormat.audioChoices.isNotEmpty) {
      print("SingleChoiceAudioAnswerView: Audio choices urls: ${_SingleChoiceAudioAnswerFormat.audioChoices}");
      _audioChoices = _SingleChoiceAudioAnswerFormat.audioChoices;
      print("Audio choices loaded: ${_audioChoices.length}");
    }
  }

  @override
  void dispose() {
    GlobalStateManager().removeListener(_refreshChoices);
    _audioPlayer?.dispose();
    super.dispose();
  }

  void _refreshChoices() {
    _fetchAndUpdateChoices();
  }

  void _initChoices() {
    print("SingleChoiceAudioAnswerView: Initializing choices");
    _fetchAndUpdateChoices();
  }

  void _fetchAndUpdateChoices() {
    if (isClicked) return;
    final prevChoices = _SingleChoiceAudioAnswerFormat.textChoices.toList();
    _choices.clear();

    if (_SingleChoiceAudioAnswerFormat.textChoices.isNotEmpty) {
      _choices = prevChoices;
      print('Static text choices loaded: ${_choices.length}');
    }

    if (_SingleChoiceAudioAnswerFormat.dynamicTextChoices.isNotEmpty) {
      var manager = GlobalStateManager();
      var dynamicChoices = manager
          .getData(_SingleChoiceAudioAnswerFormat.dynamicTextChoices.substring(1));
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

    if (_SingleChoiceAudioAnswerFormat.buttonChoices.isNotEmpty) {
      _choices += _SingleChoiceAudioAnswerFormat.buttonChoices;
    }

    print('Total choices available after update: ${_choices.length}');
  }

  void _onAnswerChanged(TextChoice selectedChoice) {
    isClicked = true;
    Map<String, dynamic> _resultMap = {};
    // Update for relatedParameter
    print("SingleChoiceAudioAnswerView: Updated relatedParameter ${widget.questionStep.relatedParameter}: ${selectedChoice.value}");
    if (widget.questionStep.relatedParameter.isNotEmpty) {
      _resultMap[widget.questionStep.relatedParameter] = selectedChoice.value;
      print(
          "SingleChoiceAudioAnswerView: Updated relatedParameter ${widget.questionStep.relatedParameter}: ${selectedChoice.value}");
    }

    // Update for relatedTextChoiceParameter
    if (widget.questionStep.relatedTextChoiceParameter.isNotEmpty) {
      _resultMap[widget.questionStep.relatedTextChoiceParameter] = [
        {'text': selectedChoice.text, 'value': selectedChoice.value}
      ];
    }

    GlobalStateManager().updateData(_resultMap);
    print('SingleChoiceAudioAnswerView: Updated data: $_resultMap');
    print("GlobalStateManager data: ${GlobalStateManager().getAllData()}");
  }

  void _playAudio(int index) async {
    if (_audioPlayer != null) {
      await _audioPlayer!.stop();
    }
    _audioPlayer = AudioPlayer();
    await _audioPlayer!.play(UrlSource(_audioChoices[index]));
  }

  @override
  Widget build(BuildContext context) {
    print("SingleChoiceAudioAnswerView: Building");
    return StepView(
      step: widget.questionStep,
      resultFunction: () => SingleChoiceAudioQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDate,
        endDate: DateTime.now(),
        valueIdentifier: _selectedChoice?.value ?? '',
        result: _selectedChoice,
      ),
      isValid: widget.questionStep.isOptional || _selectedChoice != null,
      title: widget.questionStep.title.isNotEmpty
          ? Text(widget.questionStep.title,
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleMedium!.fontSize,
                fontWeight: Theme.of(context).textTheme.titleMedium!.fontWeight,
                color: Theme.of(context).colorScheme.primary,
              ),
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
                  setState(() {
                    _selectedChoice = tc;
                  });
                  _onAnswerChanged(tc);
                  if (_audioChoices.isNotEmpty && idx < _audioChoices.length) {
                    _playAudio(idx);
                  }
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
