import 'dart:io';

import 'dart:ui';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:widget_mask/widget_mask.dart';

class CustomImageDialog extends StatefulWidget {
  final File? imageFile;
  final List<String?> listValue;
  final int selectedIndex;

  const CustomImageDialog({
    required this.imageFile,
    required this.listValue,
    required this.selectedIndex,
  });

  @override
  _CustomImageDialogState createState() => _CustomImageDialogState();
}

class _CustomImageDialogState extends State<CustomImageDialog> {
  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    selectedIndex = 0;
  }

  @override
  void dispose() {
    super.dispose();
    selectedIndex = 0;
  }
  void updateIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Uploaded Image'),
          IconButton(
            onPressed: () => Navigator.pop(context, widget.selectedIndex),
            icon: const Icon(Icons.cancel),
          ),
        ],
      ),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          (selectedIndex != 0)
              ? WidgetMask(
                  blendMode: BlendMode.dstATop,
                  childSaveLayer: true,
                  mask: Image.asset(
                    widget.listValue[selectedIndex]!,
                    fit: BoxFit.scaleDown,
                  ),
                  child: Image.file(widget.imageFile!),
                )
              : Image.file(widget.imageFile!),
          SizedBox(height: 10),
          Container(
            height: 70,
            width: MediaQuery.of(context).size.width * 0.85,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                GestureDetector(
                  onTap: () => updateIndex(0),
                  child: _buildOptionContainer(null, 0),
                ),
                GestureDetector(
                  onTap: () => updateIndex(1),
                  child: _buildOptionContainer('assets/user_image_frame_1.png', 1),
                ),
                GestureDetector(
                  onTap: () => updateIndex(2),
                  child: _buildOptionContainer('assets/user_image_frame_2.png', 2),
                ),
                GestureDetector(
                  onTap: () => updateIndex(3),
                  child: _buildOptionContainer('assets/user_image_frame_3.png', 3),
                ),
                GestureDetector(
                  onTap: () => updateIndex(4),
                  child: _buildOptionContainer('assets/user_image_frame_4.png', 4),
                ),
              ],
            ),
          ),
        ],
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: () {
            // Implement the logic to use the selected image
            Navigator.pop(context, selectedIndex); // Pass the selected index back
          },
          child: Text('Use this image'),
        ),
      ],
    );
  }

  Widget _buildOptionContainer(String? imagePath, int position) {
    return Container(
      width: 50,
      height: 50,
      margin: EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Colors.black12,
        ),
      ),
      child: (imagePath == null)
          ? Padding(
              padding: const EdgeInsets.all(5.0),
              child: FittedBox(child: Text('Original')),
            )
          : Padding(
              padding: const EdgeInsets.all(5.0),
              child: Image.asset(imagePath),

              // Set onPressed to update the selected image
              // onPressed: () {
              //   setState(() {
              //     _imageFile = File(imagePath);
              //   });
              // },
            ),
    );
  }
}
