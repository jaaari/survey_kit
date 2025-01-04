import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:survey_kit/src/answer_format/image_answer_format.dart';
import 'package:survey_kit/src/kuluko_0.2_theme.dart' as custom_theme;
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
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _imageAnswerFormat = widget.questionStep.answerFormat as ImageAnswerFormat;
    _startDate = DateTime.now();
    _isValid = false;
    filePath = '';
    publicURL = '';
    isUploading = false;
    get_user_id();
    get_firebase_storage_instance();
  }

  void get_user_id() async {
    user_id = GlobalStateManager().getData("user_id");
    print("User ID: $user_id");
  }

  void get_firebase_storage_instance() async {
    storage = GlobalStateManager().getData("firebase_storage") ?? FirebaseStorage.instance;
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
                child: Center(
                  child: Container(
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: MediaQuery.of(context).size.height * 0.065,
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      gradient: context.buttonGradient,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: ElevatedButton.icon(
                      icon: _isValid 
                        ? Icon(Icons.check, color: context.textPrimary)
                        : Icon(Icons.upload, color: context.textPrimary),
                      label: Text(
                        isUploading 
                          ? 'Uploading...'
                          : _isValid 
                            ? ''
                            : 'Upload',
                        style: context.body.copyWith(
                          color: context.textPrimary,
                        ),
                      ),
                      onPressed: _isValid ? null : () {
                        _optionsDialogBox();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                        minimumSize: Size(
                          MediaQuery.of(context).size.width * 0.7,
                          MediaQuery.of(context).size.height * 0.065,
                        ),
                        fixedSize: Size(
                          MediaQuery.of(context).size.width * 0.7,
                          MediaQuery.of(context).size.height * 0.065,
                        ),
                        padding: EdgeInsets.zero,
                        shadowColor: Colors.transparent,
                        elevation: 0,
                      ),
                    ),
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
  print("=== CAMERA CAPTURE FLOW START ===");
  print("Closing options dialog...");
  Navigator.of(context, rootNavigator: true).pop();

  try {
    print("Launching camera picker...");
    final XFile? picture = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (picture != null) {
      print("Image captured successfully:");
      print("- Path: ${picture.path}");
      print("- Name: ${path.basename(picture.path)}");
      
      if (mounted) {
        print("Widget is mounted, proceeding with upload...");
        await _uploadImageToFirebase(picture);
      } else {
        print("WARNING: Widget is not mounted after image capture");
      }
    } else {
      print("No image captured - user likely cancelled");
    }
  } catch (e, stackTrace) {
    print("=== CAMERA CAPTURE ERROR ===");
    print("Error: $e");
    print("Stack trace: $stackTrace");
    
    if (mounted) {
      setState(() {
        isUploading = false;
        _isValid = false;
      });
    }
  }
  print("=== CAMERA CAPTURE FLOW END ===\n");
}

Future<void> _openGallery() async {
  print("=== GALLERY PICKER FLOW START ===");
  print("Closing options dialog...");
  Navigator.of(context, rootNavigator: true).pop();

  try {
    print("Launching gallery picker...");
    final XFile? picture = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (picture != null) {
      print("Image selected successfully:");
      print("- Path: ${picture.path}");
      print("- Name: ${path.basename(picture.path)}");
      
      if (mounted) {
        print("Widget is mounted, proceeding with upload...");
        await _uploadImageToFirebase(picture);
      } else {
        print("WARNING: Widget is not mounted after image selection");
      }
    } else {
      print("No image selected - user likely cancelled");
    }
  } catch (e, stackTrace) {
    print("=== GALLERY PICKER ERROR ===");
    print("Error: $e");
    print("Stack trace: $stackTrace");
    
    if (mounted) {
      setState(() {
        isUploading = false;
        _isValid = false;
      });
    }
  }
  print("=== GALLERY PICKER FLOW END ===\n");
}

Future<void> _uploadImageToFirebase(XFile picture) async {
  print("\n=== FIREBASE UPLOAD FLOW START ===");
  print("Initial checks:");
  print("- Widget mounted: $mounted");
  print("- User ID: $user_id");

  if (!mounted) {
    print("WARNING: Widget not mounted, aborting upload");
    return;
  }

  setState(() {
    isUploading = true;
    _isValid = false;
  });
  print("State updated - isUploading: true, _isValid: false");

  String fileName = path.basename(picture.path);
  String firebasePath = 'profilePictures/$user_id/$fileName';
  Reference ref = storage.ref().child(firebasePath);
  
  print("\nUpload details:");
  print("- File name: $fileName");
  print("- Firebase path: $firebasePath");

  try {
    print("\nStarting file operations:");
    final File file = File(picture.path);
    
    // Check if file exists
    bool fileExists = await file.exists();
    print("- File exists: $fileExists");
    if (!fileExists) {
      throw Exception('Image file does not exist at path: ${picture.path}');
    }

    print("Starting Firebase upload...");
    await ref.putFile(file);
    print("File upload completed successfully");

    print("Retrieving download URL...");
    String downloadURL = await ref.getDownloadURL();
    print("Download URL obtained: $downloadURL");

    if (!mounted) {
      print("WARNING: Widget not mounted after upload, aborting state update");
      return;
    }

    print("\nUpdating state and global data:");
    setState(() {
      filePath = picture.path;
      publicURL = downloadURL;
      _isValid = true;
      isUploading = false;
    });
    print("State updated:");
    print("- filePath: $filePath");
    print("- publicURL: $publicURL");
    print("- _isValid: true");
    print("- isUploading: false");

    Map<String, dynamic> _resultMap = {
      widget.questionStep.relatedParameter: publicURL,
    };
    GlobalStateManager().updateData(_resultMap);
    print("Global state updated with new URL");

    print("Adding stability delay...");
    await Future.delayed(const Duration(seconds: 1));
    print("Delay completed");

  } catch (e, stackTrace) {
    print("\n=== FIREBASE UPLOAD ERROR ===");
    print("Error: $e");
    print("Stack trace: $stackTrace");
    
    if (mounted) {
      setState(() {
        isUploading = false;
        _isValid = false;
      });
      print("State reset due to error");
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload image. Please try again.')),
      );
      print("Error snackbar displayed");
    } else {
      print("Widget not mounted, couldn't show error message");
    }
  }
  print("=== FIREBASE UPLOAD FLOW END ===\n");
}
}