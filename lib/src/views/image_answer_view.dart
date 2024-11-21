import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:survey_kit/src/answer_format/image_answer_format.dart';
import 'package:survey_kit/src/kuluko_0.2_theme.dart';
import 'package:survey_kit/src/result/question/image_question_result.dart';
import 'package:survey_kit/src/steps/predefined_steps/question_step.dart';
import 'package:survey_kit/src/views/widget/step_view.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:survey_kit/src/views/global_state_manager.dart';
import 'package:path/path.dart' as path;
import 'dart:io';
import 'package:survey_kit/src/theme_extensions.dart';
class ImageAnswerView extends StatefulWidget {
  final QuestionStep questionStep;
  final ImageQuestionResult? result;

  const ImageAnswerView({
    Key? key,
    required this.questionStep,
    required this.result,
  }) : super(key: key);

  @override
  State<ImageAnswerView> createState() => _ImageAnswerViewState();
}

class _ImageAnswerViewState extends State<ImageAnswerView> {
  late final ImageAnswerFormat _imageAnswerFormat;
  late final DateTime _startDate;

  bool _isValid = false;
  String filePath = '';
  String user_id = '';
  String publicURL = '';
  bool isUploading = false;
/*   FirebaseStorage storage = FirebaseStorage.instance;
 */
  @override
  void initState() {
    super.initState();
    _imageAnswerFormat = widget.questionStep.answerFormat as ImageAnswerFormat;
    _startDate = DateTime.now();
    get_user_id();
/*     get_firebase_storage_instance();
 */  }

  void get_user_id() async {
    user_id = GlobalStateManager().getData("user_id");
    print("User ID: $user_id");
  }

  /* void get_firebase_storage_instance() async {
    storage = GlobalStateManager().getData("firebase_storage");
  } */

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.questionStep,
      resultFunction: () => ImageQuestionResult(
        id: widget.questionStep.stepIdentifier,
        startDate: _startDate,
        endDate: DateTime.now(),
        valueIdentifier: publicURL,
        result: publicURL,
      ),
      isValid: _isValid || widget.questionStep.isOptional,
      title: widget.questionStep.title.isNotEmpty
          ? Text(widget.questionStep.title,
              style: context.body,
              textAlign: TextAlign.center)
          : widget.questionStep.content,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32.0),
        child: Container(
          width: MediaQuery.of(context).size.width,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32.0,
                  vertical: 8.0,
                ),
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.all<Color>(
                        context.surface),
                    shape: WidgetStateProperty.all<OutlinedBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                      EdgeInsets.symmetric(horizontal: 32.0, vertical: 24.0),
                    ),
                  ),
                  onPressed: () {
                    _optionsDialogBox();
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.upload,
                          size: 24.0,
                          color: context.secondaryPurple),
                      SizedBox(width: 8.0),
                      Text(_imageAnswerFormat.buttonText,
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface)),
                      filePath.isNotEmpty
                          ? Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "File selected!",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                        isUploading
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: CircularProgressIndicator(),
                          )
                        : SizedBox(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _optionsDialogBox() {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                GestureDetector(
                  child: Text('Take a picture'),
                  onTap: () {
                    if (_imageAnswerFormat.hintImage != null &&
                        _imageAnswerFormat.hintTitle != null) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            _imageAnswerFormat.hintTitle.toString(),
                            style: TextStyle(color: context.accentGreen),
                          ),
                          content: Image.network(
                            _imageAnswerFormat.hintImage.toString(),
                          ),
                          actions: [
                            TextButton(
                                onPressed: () => _openCamera(),
                                child: Text('Open Camera')),
                          ],
                        ),
                      );
                    } else {
                      _openCamera();
                    }
                  },
                ),
                Padding(padding: EdgeInsets.all(8.0)),
                _imageAnswerFormat.useGallery
                    ? GestureDetector(
                        child: Text('Select from Gallery'),
                        onTap: () {
                          _openGallery();
                        },
                      )
                    : SizedBox(),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openCamera() async {
    var picture = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    Navigator.pop(context);

    if (picture != null) {
/*       _uploadImageToFirebase(picture);
 */    }
  }

  Future<void> _openGallery() async {
    var picture = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    Navigator.pop(context);

    if (picture != null) {
/*       _uploadImageToFirebase(picture);
 */    }
  }

  /* Future<void> _uploadImageToFirebase(XFile picture) async {
    isUploading = true;
    String fileName = path.basename(picture.path);
    String firebasePath = 'profilePictures/$user_id/$fileName';
    Reference ref = storage.ref().child(firebasePath);

    try {
      print("Uploading image to Firebase Storage");
      await ref.putFile(File(picture.path));
      String downloadURL = await ref.getDownloadURL();
      print("Got download URL: $downloadURL");
      setState(() {
        filePath = picture.path;
        publicURL = downloadURL;
        _isValid = true;
      });
      isUploading = false;
      print("Uploaded Image URL: $publicURL");

      Map<String, dynamic> _resultMap = {
        widget.questionStep.relatedParameter: publicURL,
      };
      GlobalStateManager().updateData(_resultMap);
    } catch (e) {
      print("Error uploading image: $e");
    }
  } */
}
