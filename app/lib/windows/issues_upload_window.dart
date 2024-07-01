import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:paddy_app/constants/env.dart';
import 'package:paddy_app/constants/styles.dart';
import 'package:paddy_app/models/session_provider.dart';
import 'package:paddy_app/windows/reports_window.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class IssuesUploadWindow extends StatefulWidget {
  const IssuesUploadWindow({Key? key}) : super(key: key);

  @override
  State<IssuesUploadWindow> createState() => _IssuesUploadWindowState();
}

class _IssuesUploadWindowState extends State<IssuesUploadWindow> {
  final TextEditingController _detailsController = TextEditingController();
  final ImagePicker picker = ImagePicker();
  String _selectedCategory = 'BUG';
  XFile? selectedImage;
  int _selectedIndex = 0;
  String? answerNutrition, answerMicro;
  List<dynamic> answerPesticides  = [];

  void showImageOptions() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Theme(
          data: Theme.of(context).copyWith(
            dialogBackgroundColor: Styles.primaryAccent, // Dark green background
          ),
          child: AlertDialog(
            title: const Text(
              "Continue with this image?",
              style: TextStyle(color: Colors.white), // White text
            ),
            content: Image.file(
              File(selectedImage!.path),
              height: 400,
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "Retake",
                  style: TextStyle(color: Colors.white), // White text
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  CroppedFile? croppedFile = await ImageCropper().cropImage(
                    sourcePath: selectedImage!.path,
                    uiSettings: [
                      AndroidUiSettings(
                        toolbarTitle: 'Cropper',
                        toolbarColor: Colors.deepOrange,
                        toolbarWidgetColor: Colors.white,
                        lockAspectRatio: false,
                      ),
                      IOSUiSettings(
                        title: 'Cropper',
                      ),
                      WebUiSettings(
                        context: context,
                      ),
                    ],
                  );
                  if (croppedFile != null) {
                    selectedImage = XFile(croppedFile.path);
                    showImageOptions();
                  }
                },
                child: const Text(
                  "Crop",
                  style: TextStyle(color: Colors.white), // White text
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    _selectedIndex = 1;
                  });
                },
                child: const Text(
                  "Upload",
                  style: TextStyle(color: Colors.white), // White text
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Future<void> getNutritions() async {
    try {
      // EasyLoading.show(status: "Loading...", dismissOnTap: false);
      var request = http.MultipartRequest(
          'POST',
          Uri.parse(
              '${ENVConfig.serverUrl}/predict-paddy-all'));
      request.files
          .add(await http.MultipartFile.fromPath('file', selectedImage!.path));
      await request.send().then(
            (value) {
          if (value.statusCode == 200) {
            value.stream.transform(utf8.decoder).listen((value) {
              var data = jsonDecode(value);
              var text = data['predicted_class'];
              var pesticides = data['fests'];
              var micro = data['micro'];
              print("The received text is : $text");
              print(pesticides);
              setState(() {
                answerNutrition = text;
                answerPesticides = pesticides;
                answerMicro = micro;
              });
              // EasyLoading.dismiss();
            });
          } else {
            print(value.statusCode);
            // EasyLoading.dismiss();
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) {
                return AlertDialog(
                  title: const Text("Upload Failed!"),
                  content:
                  const Text("Unable to upload image. Please try again."),
                  icon: const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Try Again"),
                    ),
                  ],
                );
              },
            );
          }
        },
      );
    } catch (e) {
      // EasyLoading.dismiss();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Unable to upload image. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Styles.primaryColor,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paddy Issues Detector',
              style: TextStyle(color: Colors.white), // Make screen name white
            ),
            Text(
              'Provide Images or evidences to detect issues', // Add your subtitle text here
              style: TextStyle(color: Colors.white, fontSize: 12), // Adjust font size and color as needed
            ),
          ],
        ),
        backgroundColor: Colors.transparent, // Make background transparent
        iconTheme: IconThemeData(color: Colors.white), // Make icons white
        actions: [
          IconButton(
            icon: Icon(Icons.logout), // Logout icon
            onPressed: () async {
              // Clear session
              Provider.of<SessionProvider>(context, listen: false).clearSession();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.remove('accessToken');
              await prefs.remove('refreshToken');
              await prefs.remove('accessTokenExpireDate');
              await prefs.remove('refreshTokenExpireDate');
              await prefs.remove('userRole');
              await prefs.remove('authEmployeeID');
              Navigator.pushReplacementNamed(context, '/landing');
            },
          ),
        ],
      ),
      body: SingleChildScrollView( // Wrap with SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form section
            Card(
              margin: EdgeInsets.all(16.0),
              color: Styles.primaryAccent,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 2.0),
                    // DropdownButtonFormField<String>(
                    //   value: _selectedCategory,
                    //   onChanged: (value) {
                    //     setState(() {
                    //       _selectedCategory = value!;
                    //     });
                    //   },
                    //   items: [
                    //     'BUG',
                    //     'OTHER'
                    //   ].map((category) {
                    //     return DropdownMenuItem<String>(
                    //       value: category,
                    //       child: Text(category),
                    //     );
                    //   }).toList(),
                    //   decoration: InputDecoration(
                    //     labelText: 'Category',
                    //     border: OutlineInputBorder(),
                    //   ),
                    // ),
                    SizedBox(height: 10.0),
                    if (selectedImage == null) Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/upload.png",
                          height: 100,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Upload Image",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Text(
                          "Upload image of Paddy Plant",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FilledButton.icon(
                              onPressed: () async {
                                selectedImage = await picker.pickImage(
                                    source: ImageSource.camera);
                                if (selectedImage != null) {
                                  showImageOptions();
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Styles.warningColor,
                                foregroundColor: Colors.white,
                              ),
                              label: const Text("Camera"),
                              icon: const Icon(Icons.camera_rounded),
                            ),
                            FilledButton.icon(
                              onPressed: () async {
                                selectedImage = await picker.pickImage(
                                    source: ImageSource.gallery);
                                if (selectedImage != null) {
                                  showImageOptions();
                                }
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Styles.warningColor,
                                foregroundColor: Colors.white,
                              ),
                              label: const Text("Gallery"),
                              icon: const Icon(Icons.image_rounded),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (selectedImage != null)
                      Center(
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 10,
                            ),
                            selectedImage != null
                                ? Image.file(
                              File(selectedImage!.path),
                              height: 400,
                              fit: BoxFit.contain,
                            )
                                : const SizedBox(
                              height: 300,
                              width: 300,
                              child: Center(
                                child: Text("No image selected"),
                              ),
                            ),
                            const SizedBox(
                              height: 16,
                            ),
                            FilledButton.icon(
                              onPressed: () async {
                                setState(() {
                                  selectedImage = null;
                                  _selectedIndex = 0;
                                });
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Styles.dangerColor,
                                foregroundColor: Colors.white,
                              ),
                              label: const Text("Remove Image"),
                              icon: const Icon(Icons.highlight_remove_rounded),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            if(selectedImage != null) Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: ElevatedButton(
                                onPressed: () async {
                                  await getNutritions();

                                  if (answerNutrition != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ReportsWindow(
                                          nutrition: answerNutrition,
                                          pesticides: answerPesticides,
                                          selectedFile: selectedImage,
                                          micro: answerMicro,
                                        ),
                                      ),
                                    );
                                  } else {
                                    // ScaffoldMessenger.of(context).showSnackBar(
                                    //   const SnackBar(
                                    //     content: Text("Failed to get nutrition data. Please try again."),
                                    //     backgroundColor: Colors.red,
                                    //   ),
                                    // );
                                  }

                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReportsWindow(nutrition: answerNutrition, pesticides: answerPesticides, micro: answerMicro, selectedFile: selectedImage)
                                    ),
                                  );
                                },
                                // style: ElevatedButton.styleFrom(
                                //   backgroundColor: const Color.fromRGBO(148, 0, 211, 1),
                                //   foregroundColor: Colors.white,
                                //   elevation: 4,
                                //   fixedSize: const Size(200, 40),
                                // ),
                                child: const Text('Submit Image'),
                                style: FilledButton.styleFrom(
                                  backgroundColor: Styles.successColor,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            // if(answerText!='') Text(
                            //   "Answer is $answerText",
                            //   style: TextStyle(
                            //     fontSize: 18,
                            //   ),
                            // ),
                            const SizedBox(
                              height: 4,
                            ),
                          ],
                        ),
                      ),
                    // ElevatedButton(
                    //   onPressed: (){},
                    //   child: Text('Submit'),
                    // ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }
}
