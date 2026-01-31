import 'package:flutter/material.dart';
import '../models/cv_data.dart';
import '../widgets/cv_form.dart';
import '../widgets/cv_template.dart';
import '../utils/pdf_generator.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:printing/printing.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CvData _data = CvData();

  @override
  Widget build(BuildContext context) {
    // Basic responsive check
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      appBar: AppBar(
        title: const Text("CV Builder"),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: _importJson,
            tooltip: "Import JSON",
          ),
          IconButton(icon: const Icon(Icons.save), onPressed: _exportJson, tooltip: "Export JSON"),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final pdfBytes = await PdfGenerator.generate(_data);
              await Printing.sharePdf(bytes: pdfBytes, filename: 'my_cv.pdf');
            },
            tooltip: "Export PDF",
          ),
        ],
      ),
      body: isWide ? _buildSplitView() : _buildTabView(),
    );
  }

  Widget _buildSplitView() {
    return Row(
      children: [
        // Editor Panel
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.grey[50],
            child: CvForm(
              key: ValueKey(_data), // Force rebuild when data changes
              data: _data,
              onChanged: (newData) {
                setState(() {
                  _data = newData;
                });
              },
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        // Preview Panel
        Expanded(
          flex: 3,
          child: Container(
            color: Colors.grey[200],
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AspectRatio(
                    aspectRatio: 1 / 1.414, // A4 aspect ratio approximation or just auto
                    child: CvTemplate(data: _data),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.edit), text: "Edit"),
              Tab(icon: Icon(Icons.visibility), text: "Preview"),
            ],
            labelColor: Colors.deepPurple,
          ),
          Expanded(
            child: TabBarView(
              children: [
                CvForm(
                  key: ValueKey(_data),
                  data: _data,
                  onChanged: (newData) {
                    setState(() {
                      _data = newData;
                    });
                  },
                ),
                Container(
                  color: Colors.grey[200],
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: CvTemplate(data: _data),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _exportJson() async {
    final jsonString = jsonEncode(_data.toJson());
    await Printing.sharePdf(
      bytes: Uint8List.fromList(utf8.encode(jsonString)),
      filename: 'cv_data.json',
    );
  }

  Future<void> _importJson() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
      withData: true,
    );

    if (result != null) {
      try {
        String content;
        if (result.files.first.bytes != null) {
          content = utf8.decode(result.files.first.bytes!);
        } else {
          // Fallback if needed, but keeping simple for now
          throw Exception("Could not read file content");
        }

        final jsonData = jsonDecode(content);
        setState(() {
          _data = CvData.fromJson(jsonData);
        });

        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text("CV Imported successfully!")));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text("Error importing JSON: $e")));
        }
      }
    }
  }
}
