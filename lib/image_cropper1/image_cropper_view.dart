// library image_crop_view;
//
// import 'dart:async';
// import 'dart:html'as html;
// import 'dart:io';
// import 'dart:math' as math;
// import 'dart:ui' as ui;
// import 'dart:typed_data' show ByteData;
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import 'clipper.dart';
//
// class ImageCropper extends StatefulWidget {
//   const ImageCropper({
//     Key? key,
//     required this.image,
//     this.fit = BoxFit.cover,
//     this.exportSize = const Size(500, 500),
//     this.exportBackgroundColor,
//     this.clipShape = ClipShape.circle,
//     this.clipImage = false,
//     this.clipRRectRadius = const Radius.circular(10),
//   }) : super(key: key);
//
//   final Image image;
//   final Size exportSize;
//   final BoxFit fit;
//   final Color? exportBackgroundColor;
//   final bool clipImage;
//   final ClipShape clipShape;
//   final Radius clipRRectRadius;
//
//   @override
//   State<ImageCropper> createState() => _ImageCropperState();
// }
//
// class _ImageCropperState extends State<ImageCropper> {
//   Matrix4 sessionMatrix = Matrix4.identity();
//   Matrix4 matrix = Matrix4.identity();
//   ui.Image? bitImage;
//   Size? clipSize;
//   Matrix4? txMatrix;
//   Offset initialFocalPoint = Offset.zero;
//
//   @override
//   initState() {
//     super.initState();
//     WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
//       loadImage();
//     });
//   }
//
//
//   Future<File> writeToFile(ByteData data) async {
//     final buffer = data.buffer;
//     Directory tempDir = await getTemporaryDirectory();
//     String tempPath = tempDir.path;
//     var filePath = tempPath + '/file_01.tmp'; // file_01.tmp is dump file, can be anything
//     return new File(filePath).writeAsBytes(
//         buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
//   }
//
//   loadImage() async {
//     var img = await getImageData();
//     setState(() {
//       bitImage = img;
//     });
//   }
//
//   // get image data from underlying image
//   Future<ui.Image> getImageData() async {
//     var completer = Completer<ui.Image>();
//     widget.image.image.resolve(ImageConfiguration.empty).addListener(
//           ImageStreamListener(
//             (ImageInfo info, _) => completer.complete(info.image),
//           ),
//         );
//     return completer.future;
//   }
//
//   Widget _buildImageView(
//     BuildContext context,
//     Size clipSize,
//     Size viewSize,
//     Matrix4 txMatrix,
//   ) {
//     // These two are used in image export
//     this.clipSize = clipSize;
//     this.txMatrix = txMatrix;
//
//     var clipExportRatio = clipSize.width / widget.exportSize.width;
//     return Stack(
//       fit: StackFit.expand,
//       alignment: Alignment.topLeft,
//       children: [
//         Positioned(
//           left: viewSize.width / 2,
//           top: viewSize.height / 2,
//           child: Transform(
//             transform: txMatrix,
//             alignment: Alignment.topLeft,
//             child: widget.image,
//           ),
//         ),
//         // black overlay on image
//         ClipPath(
//           clipper: InvertedClipper(
//             clipSize: clipSize,
//             shape: widget.clipShape,
//             rrectRadius: widget.clipRRectRadius * clipExportRatio,
//           ),
//           child: Container(
//             color: Colors.black54,
//           ),
//         ),
//       ],
//     );
//   }
//
//   _cancelEdit() {
//     Navigator.pop(context);
//   }
//
//   _vFlipImage() {
//     setState(() {
//       var xf = Matrix4.identity()..scale(1.0, -1.0);
//       matrix = xf * matrix;
//     });
//   }
//
//   _hFlipImage() {
//     setState(() {
//       var xf = Matrix4.identity()..scale(-1.0, 1.0);
//       matrix = xf * matrix;
//     });
//   }
//
//   _rotateImage(double angle) {
//     setState(() {
//       var xf = Matrix4.identity()..rotateZ(angle);
//       matrix = xf * matrix;
//     });
//   }
//
//   _saveEdit() async {
//     var edited = await _exportImage();
//     Navigator.pop(
//       context,
//       edited,
//     );
//   }
//
//   _onScaleStart(ScaleStartDetails d) {
//     initialFocalPoint = d.focalPoint;
//   }
//
//   _onScaleUpdate(ScaleUpdateDetails d) {
//     var center = context.size!.center(Offset.zero);
//     var focal = d.localFocalPoint.translate(-center.dx, -center.dy);
//     var focalDelta = d.focalPoint - initialFocalPoint;
//     setState(() {
//       sessionMatrix = Matrix4.identity()
//         ..translate(focal.dx, focal.dy)
//         ..scale(d.scale)
//         ..rotateZ(d.rotation)
//         ..translate(focalDelta.dx, focalDelta.dy)
//         ..translate(-focal.dx, -focal.dy);
//     });
//   }
//
//   _onScaleEnd(ScaleEndDetails d) {
//     setState(() {
//       // merge sessionMatrix into matrix
//       matrix = sessionMatrix * matrix;
//       sessionMatrix = Matrix4.identity();
//     });
//   }
//
//   Future<ByteData?> _exportImage() async {
//     if (bitImage == null || clipSize == null || txMatrix == null) {
//       throw 'Image cannot be loaded';
//     }
//
//     var exportSize = widget.exportSize;
//     ui.PictureRecorder recorder = ui.PictureRecorder();
//
//     Canvas canvas = Canvas(recorder);
//     var exportRect = Rect.fromLTWH(
//       0,
//       0,
//       exportSize.width.toDouble(),
//       exportSize.height.toDouble(),
//     );
//     // draw background
//     if (widget.exportBackgroundColor != null) {
//       canvas.drawRect(
//           exportRect, Paint()..color = widget.exportBackgroundColor!);
//     }
//     // clip export image
//     if (widget.clipImage) {
//       Path? path;
//       if (widget.clipShape == ClipShape.circle) {
//         path = Path()..addOval(exportRect);
//       } else if (widget.clipShape == ClipShape.rrect) {
//         path = Path()
//           ..addRRect(
//             RRect.fromRectAndRadius(
//               exportRect,
//               widget.clipRRectRadius,
//             ),
//           );
//       }
//       if (path != null) {
//         canvas.clipPath(path);
//       }
//     }
//     // exportSize may be quite bigger than clipSize, hence this final scale
//     var exportScale = exportSize.width / clipSize!.width;
//     // Scale clip box to the size of exportSize
//     canvas.scale(exportScale);
//     // Move origin to center of clip box
//     canvas.translate(clipSize!.width / 2, clipSize!.height / 2);
//     canvas.transform(txMatrix!.storage);
//     canvas.drawImage(
//       bitImage!,
//       Offset.zero,
//       Paint(),
//     );
//
//     // var exportSize = const Size(100, 100);
//     var img = await recorder.endRecording().toImage(
//           exportSize.width.floor(),
//           exportSize.height.floor(),
//         );
//     var buf = await img.toByteData(format: ui.ImageByteFormat.png);
//     return buf;
//   }
//
//   Widget _buildClipper(BuildContext context) {
//     return LayoutBuilder(builder: (context, constraints) {
//       var exportSize = widget.exportSize;
//       var viewSize = constraints.biggest;
//       var clipSize = constraints.deflate(const EdgeInsets.all(20)).biggest;
//
//       if (bitImage == null) {
//         return const Center(child: CircularProgressIndicator());
//       }
//
//       // Load the reference asset image
//       AssetImage assetImage = AssetImage('assets/images/custom_shape.png');
//       ImageProvider imageProvider = assetImage;
//       Widget referenceImageWidget = Image(
//         image: imageProvider,
//         width: exportSize.width,
//         height: exportSize.height,
//         fit: BoxFit.cover,
//       );
//
//       // Create an instance of your custom clipper class
//       DarkPortionClipper darkPortionClipper = DarkPortionClipper(referenceImage: referenceImageWidget);
//
//       // Use the custom clipper in the ClipPath widget
//       Widget clippedReferenceImage = ClipPath(
//         clipper: darkPortionClipper,
//         child: Container(
//           color: Colors.black54,
//         ),
//       );
//
//       return GestureDetector(
//         onScaleStart: _onScaleStart,
//         onScaleUpdate: _onScaleUpdate,
//         onScaleEnd: _onScaleEnd,
//         child: Stack(
//           fit: StackFit.expand,
//           alignment: Alignment.topLeft,
//           children: [
//             Positioned(
//               left: viewSize.width / 2,
//               top: viewSize.height / 2,
//               child: Transform(
//                 transform: sessionMatrix * matrix,
//                 alignment: Alignment.topLeft,
//                 child: widget.image,
//               ),
//             ),
//             clippedReferenceImage,
//           ],
//         ),
//       );
//     });
//   }
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     Widget imageView;
//     if (bitImage != null) {
//       imageView = _buildClipper(context);
//     } else {
//       imageView = const Center(child: CircularProgressIndicator());
//     }
//
//     return Scaffold(
//       body: imageView,
//       bottomNavigationBar: Container(
//           color: Colors.white,
//           child: Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Container(
//               height: 100,
//               child: ListView(
//                 scrollDirection: Axis.horizontal,
//                 //mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   TextButton(
//                     child: const Text('Cancel'),
//                     onPressed: _cancelEdit,
//                   ),
//                   IconButton(
//                     tooltip: 'Horizontal flip',
//                     onPressed: _hFlipImage,
//                     icon: const Icon(Icons.flip),
//                   ),
//                   IconButton(
//                     tooltip: 'Vertical flip',
//                     onPressed: _vFlipImage,
//                     icon: const RotatedBox(
//                       quarterTurns: 1,
//                       child: Icon(Icons.flip_rounded),
//                     ),
//                   ),
//                   IconButton(
//                     tooltip: 'Rotate left',
//                     onPressed: () => _rotateImage(math.pi / 2),
//                     icon: const Icon(Icons.rotate_90_degrees_ccw),
//                   ),
//                   IconButton(
//                     tooltip: 'Rotate right',
//                     onPressed: () => _rotateImage(-math.pi / 2),
//                     icon: Transform(
//                       alignment: Alignment.center,
//                       transform: Matrix4.identity()..scale(-1.0, 1.0),
//                       child: const Icon(Icons.rotate_90_degrees_ccw),
//                     ),
//                   ),
//                   IconButton(
//                     tooltip: 'Rotate',
//                     onPressed: () {},
//                     icon: const Icon(Icons.rotate_right),
//                   ),
//                   IconButton(
//                     tooltip: 'Zoom',
//                     onPressed: () {},
//                     icon: const Icon(Icons.zoom_in),
//                   ),
//                   ElevatedButton.icon(
//                     icon: const Icon(Icons.save),
//                     label: const Text('Save'),
//                     onPressed: _saveEdit,
//                   ),
//                 ],
//               ),
//             ),
//
//         ),
//       ),
//     );
//   }
// }
//
// Matrix4 _layoutImage(
//     Size imageSize, Size clipSize, Size viewSize, BoxFit layout) {
//   Matrix4 mat = Matrix4.identity();
//   var scale = 1.0;
//   if (layout == BoxFit.contain) {
//     if (imageSize.aspectRatio > clipSize.aspectRatio) {
//       scale = clipSize.width / imageSize.width;
//     } else {
//       scale = clipSize.height / imageSize.height;
//     }
//   } else if (layout == BoxFit.cover) {
//     if (imageSize.aspectRatio > clipSize.aspectRatio) {
//       scale = clipSize.height / imageSize.height;
//     } else {
//       scale = clipSize.width / imageSize.width;
//     }
//   } else {
//     throw 'Not supported BoxFit type';
//   }
//   mat.scale(scale);
//   // Offset transform origin, so that origin is now at center of canvas
//   mat.translate(
//     -imageSize.width / 2,
//     -imageSize.height / 2,
//   );
//
//   return mat;
// }
