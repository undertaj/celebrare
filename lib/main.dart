import 'dart:async';
import 'dart:io';
import 'dart:io' as io;
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:celebrare/custom_image_dialog.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart' as widgets;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:widget_mask/widget_mask.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff00986f)),
        useMaterial3: false,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xff00986f),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;
  String path = "assets/user_image_frame_1.png";
  List<String?> listValue = [
    null,
    'assets/user_image_frame_1.png',
    'assets/user_image_frame_2.png',
    'assets/user_image_frame_3.png',
    'assets/user_image_frame_4.png',
  ];
  int index = 0;

  @override
  void initState() {
    super.initState();
    index = 0;
    _imageFile = null;
  }

  Future<ui.Image> loadUiImage(String imageAssetPath) async {
    widgets.Image widgetsImage =
        widgets.Image.asset(imageAssetPath, scale: 0.5);
    Completer<ui.Image> completer = Completer<ui.Image>();
    widgetsImage.image
        .resolve(widgets.ImageConfiguration(size: ui.Size(10, 10)))
        .addListener(
            widgets.ImageStreamListener((widgets.ImageInfo info, bool _) {
      completer.complete(info.image);
    }));
    return completer.future;
  }

  Future<File> writeToFile(ByteData data) async {
    final buffer = data.buffer;
    Directory tempDir = await getTemporaryDirectory();
    String tempPath = tempDir.path;
    var filePath =
        tempPath + '/file_01.tmp'; // file_01.tmp is dump file, can be anything
    return new File(filePath).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<void> _pickImage1() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
        index = 0;
      });
      _showImageDialog();
      // _cropImage1();
    }
  }

  Future<void> _cropImage1() async {

    if (_imageFile != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: _imageFile!.path,
        uiSettings: [
          AndroidUiSettings(
              toolbarTitle: 'Cropper',
              toolbarColor: Colors.black,
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false),
          IOSUiSettings(
            title: 'Cropper',
          ),

        ],
      );
      if (croppedFile != null) {
        setState(() {
          _imageFile = croppedFile as File?;
        });
        _showImageDialog();
      }
    }
  }

  Future<void> _showImageDialog() async {
    int? result = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return CustomImageDialog(
          imageFile: _imageFile,
          listValue: listValue,
          selectedIndex: index,
        );
      },
    );

    if (result != null) {
      // Use the selected index here
      setState(() {
        index = result;
      });
    }
  }



  void update(setState, int position) {
    setState(() {
      index = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 20.0,
          shadowColor: Colors.black,
          centerTitle: true,
          backgroundColor: Theme.of(context).colorScheme.background,
          title: Text(
            "Add Image/ Icon",
            style: GoogleFonts.playfairDisplay(
              textStyle: TextStyle(color: Colors.black87),
            ),
          ),
          leading: IconButton(
            icon: const Icon(
              Icons.chevron_left,
              size: 40,
              color: Colors.black87,
            ),
            onPressed: () {
              SystemNavigator.pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  width: MediaQuery.of(context).size.width * 0.95,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.black12,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text("Upload Image", style: TextStyle(fontSize: 17)),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _pickImage1,
                        child: Text("Choose from Device", style: TextStyle(fontSize: 15),),
                      ),
                    ],
                  ),
                ),
                (_imageFile == null) ?
                Container()
                    :
                (index != 0)
                    ? widgets.Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: WidgetMask(
                          blendMode: BlendMode.dstATop,
                          childSaveLayer: true,
                          mask: Image.asset(
                            listValue[index]!,
                            fit: BoxFit.scaleDown,
                          ),
                          child: Image.file(_imageFile!),
                        ),
                    )
                    : widgets.Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Image.file(_imageFile!),
                    ),
              ],
            ),
          ),
        ),
        floatingActionButton: widgets.Padding(


          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0, right: 8, top: 8),

          child: FloatingActionButton(
            backgroundColor: Color(0xff00986f),
            shape: RoundedRectangleBorder(

              borderRadius: BorderRadius.circular(10),
            ),
            onPressed: (_imageFile != null) ? _showImageDialog : () {SnackBar(content: Text("Please select image first") );},
            tooltip: 'Change crop filter',
            child: const Text("Edit photo", textAlign: TextAlign.center,),
          ),
        ),
      );
  }
}
