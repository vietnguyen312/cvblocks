import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'dart:typed_data';

import '../models/cv_data.dart';
import '../widgets/cv_template.dart';

class CvPreviewPage extends StatefulWidget {
  final CvData data;

  const CvPreviewPage({super.key, required this.data});

  @override
  State<CvPreviewPage> createState() => _CvPreviewPageState();
}

class _CvPreviewPageState extends State<CvPreviewPage> {
  final GlobalKey _printKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("CV Preview"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.print), onPressed: _printCv, tooltip: "Print CV"),
        ],
      ),
      body: Container(
        color: Colors.grey[200],
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 800),
              // We remove the AspectRatio to allow it to grow naturally
              child: RepaintBoundary(
                key: _printKey,
                child: CvTemplate(data: widget.data),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _printCv() async {
    final RenderRepaintBoundary? boundary =
        _printKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

    if (boundary == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Error: Could not capture CV for printing.")));
      return;
    }

    try {
      // 1. Capture the widget as a high-res image
      final ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      final ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData != null) {
        final Uint8List pngBytes = byteData.buffer.asUint8List();

        await Printing.layoutPdf(
          onLayout: (PdfPageFormat format) async {
            final doc = pw.Document();
            final imageProvider = pw.MemoryImage(pngBytes);

            // Calculate dimensions
            final double imageWidth = image.width.toDouble();
            final double imageHeight = image.height.toDouble();

            // We use A4 width as the standard anchor
            final double pdfPageWidth = PdfPageFormat.a4.width;
            final double scale = pdfPageWidth / imageWidth;
            final double pdfTotalHeight = imageHeight * scale;

            // Create a custom page format that fits the whole image height
            // This prevents us from slicing text lines. The printer/viewer can handle
            // tiling or fitting as the user desires.
            final customFormat = PdfPageFormat(pdfPageWidth, pdfTotalHeight, marginAll: 0);

            doc.addPage(
              pw.Page(
                pageFormat: customFormat,
                build: (pw.Context context) {
                  return pw.Image(imageProvider, fit: pw.BoxFit.fill);
                },
              ),
            );

            return doc.save();
          },
          name: 'my_cv_full',
        );
      }
    } catch (e) {
      debugPrint("Error printing CV: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error generating print: $e")));
      }
    }
  }
}
