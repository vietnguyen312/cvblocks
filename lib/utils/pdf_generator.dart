import 'dart:typed_data';
import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/cv_data.dart';

class PdfGenerator {
  static Future<Uint8List> generate(CvData data) async {
    final pdf = pw.Document();

    // Load a font if needed, or use default.
    // basics: PdfGoogleFonts can be used but requires internet or bundling.
    // For simplicity, we use standard fonts or await standard ones.
    final ttfRegular = await PdfGoogleFonts.openSansRegular();
    final ttfBold = await PdfGoogleFonts.openSansBold();
    final ttfItalic = await PdfGoogleFonts.openSansItalic();
    final ttfBoldItalic = await PdfGoogleFonts.openSansBoldItalic();

    final theme = pw.ThemeData.withFont(
      base: ttfRegular,
      bold: ttfBold,
      italic: ttfItalic,
      boldItalic: ttfBoldItalic,
    );

    pdf.addPage(
      pw.Page(
        pageTheme: pw.PageTheme(
          theme: theme,
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 24),
        ),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Name Header
              pw.Center(
                child: pw.Container(
                  padding: const pw.EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.deepPurple, width: 3.0),
                  ),
                  child: pw.Text(
                    data.name.toUpperCase(),
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                      letterSpacing: 1.2,
                      color: PdfColors.black,
                    ),
                  ),
                ),
              ),
              pw.SizedBox(height: 8),

              // Job Title
              pw.Center(
                child: pw.Text(
                  data.jobTitle,
                  style: const pw.TextStyle(fontSize: 20, color: PdfColors.black),
                ),
              ),
              pw.SizedBox(height: 8),

              // Contact Info
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  _buildContactItem(data.phone),
                  pw.SizedBox(width: 24),
                  _buildContactItem(data.email),
                  pw.SizedBox(width: 24),
                  _buildContactItem(data.location),
                ],
              ),
              pw.SizedBox(height: 12),
              pw.Divider(color: PdfColors.black, thickness: 1),
              pw.SizedBox(height: 16),

              // About Me
              _buildSectionHeader("ABOUT ME"),
              pw.SizedBox(height: 8),
              _buildHtmlText(data.about),
              pw.SizedBox(height: 16),
              pw.Divider(color: PdfColors.grey300, thickness: 1),
              pw.SizedBox(height: 16),

              // Work Experience
              _buildSectionHeader("WORK EXPERIENCE"),
              pw.SizedBox(height: 12),
              ...data.experience.map((exp) => _buildExperienceItem(exp)),

              if (data.experience.isEmpty)
                pw.Text(
                  "No work experience added.",
                  style: const pw.TextStyle(color: PdfColors.grey),
                ),

              if (data.education.isNotEmpty) ...[
                pw.SizedBox(height: 16),
                pw.Divider(color: PdfColors.black, thickness: 1),
                pw.SizedBox(height: 16),

                // Education
                _buildSectionHeader("EDUCATION"),
                pw.SizedBox(height: 12),
                ...data.education.map((edu) => _buildEducationItem(edu)),
              ],
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildContactItem(String text) {
    // Icons are hard in PDF without loading a font icon or image.
    // We'll skip icons for now or use simple text bullets/emojis if supported (emojis tricky).
    // Let's just output text.
    return pw.Text(text, style: const pw.TextStyle(fontSize: 12, color: PdfColors.black));
  }

  static pw.Widget _buildSectionHeader(String title) {
    return pw.Text(
      title.toUpperCase(),
      style: pw.TextStyle(
        fontSize: 16,
        fontWeight: pw.FontWeight.bold,
        letterSpacing: 1.5,
        color: PdfColors.black,
      ),
    );
  }

  static pw.Widget _buildExperienceItem(WorkExperience exp) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                exp.company,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Text(
                exp.dateRange,
                style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(exp.title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.SizedBox(height: 8),
          _buildHtmlText(exp.description),
        ],
      ),
    );
  }

  static pw.Widget _buildEducationItem(Education edu) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 16.0),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                edu.institution,
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                  color: PdfColors.grey700,
                ),
              ),
              pw.Text(
                edu.dateRange,
                style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey700),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Text(edu.degree, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16)),
          pw.SizedBox(height: 8),
          _buildHtmlText(edu.description),
        ],
      ),
    );
  }

  // Basic HTML parser to converting simple tags to PDF widgets
  static pw.Widget _buildHtmlText(String htmlString) {
    final document = html_parser.parseFragment(htmlString);
    return _parseNode(document);
  }

  static pw.Widget _parseNode(dom.Node node) {
    List<pw.Widget> children = [];

    if (node.nodes.isNotEmpty) {
      for (var child in node.nodes) {
        children.add(_parseNodeToWidget(child));
      }
    }

    // Root fragment usually -> Column
    if (children.isEmpty) return pw.Container();
    if (children.length == 1) return children.first;
    return pw.Column(crossAxisAlignment: pw.CrossAxisAlignment.start, children: children);
  }

  static pw.Widget _parseNodeToWidget(dom.Node node) {
    if (node is dom.Text) {
      if (node.text.trim().isEmpty) return pw.Container();
      return pw.Text(node.text.trim(), style: const pw.TextStyle(fontSize: 14, lineSpacing: 1.5));
    }

    if (node is dom.Element) {
      switch (node.localName) {
        case 'b':
        case 'strong':
          return pw.RichText(text: _buildTextSpan(node, fontWeight: pw.FontWeight.bold));
        case 'i':
        case 'em':
          return pw.RichText(text: _buildTextSpan(node, fontStyle: pw.FontStyle.italic));
        case 'p':
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.RichText(text: _buildTextSpan(node)),
          );
        case 'ul':
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: node.children.map((li) => _buildListItem(li, ordered: false)).toList(),
          );
        case 'ol':
          var i = 0;
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: node.children
                .map((li) => _buildListItem(li, ordered: true, index: ++i))
                .toList(),
          );
        default:
          // Mixed content? simplified approach: just render children as block
          // But what if it's text with some bold parts "Hello <b>World</b>"
          // The structure: Node -> [Text("Hello "), Element(b, Text("World"))]
          // We need a rich text builder if we want inline styles.

          // If the element has mixed children (text + elements), we should treat it as RichText
          if (_hasMixedContent(node)) {
            return pw.RichText(text: _buildTextSpan(node));
          }

          // Otherwise block level generic
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: node.nodes.map((n) => _parseNodeToWidget(n)).toList(),
          );
      }
    }
    return pw.Container();
  }

  static bool _hasMixedContent(dom.Node node) {
    return node.nodes.any(
      (n) =>
          n is dom.Text ||
          (n is dom.Element && ['b', 'i', 'span', 'strong', 'em', 'a'].contains(n.localName)),
    );
  }

  static pw.InlineSpan _buildTextSpan(
    dom.Node node, {
    pw.FontWeight? fontWeight,
    pw.FontStyle? fontStyle,
  }) {
    List<pw.InlineSpan> children = [];

    if (node.nodes.isEmpty) {
      String text = node.text ?? "";
      if (node is dom.Element && node.localName == 'li') {
        // li usually blocks, but if called here, treat as span content
      }
      return pw.TextSpan(
        text: text,
        style: pw.TextStyle(fontWeight: fontWeight, fontStyle: fontStyle),
      );
    }

    for (var child in node.nodes) {
      if (child is dom.Text) {
        children.add(
          pw.TextSpan(
            text: child.text,
            style: pw.TextStyle(fontWeight: fontWeight, fontStyle: fontStyle),
          ),
        );
      } else if (child is dom.Element) {
        pw.FontWeight? fw = fontWeight;
        pw.FontStyle? fs = fontStyle;

        if (child.localName == 'b' || child.localName == 'strong') fw = pw.FontWeight.bold;
        if (child.localName == 'i' || child.localName == 'em') fs = pw.FontStyle.italic;

        children.add(_buildTextSpan(child, fontWeight: fw, fontStyle: fs));
      }
    }
    return pw.TextSpan(children: children, style: pw.TextStyle(fontSize: 14, lineSpacing: 1.5));
  }

  static pw.Widget _buildListItem(dom.Element node, {required bool ordered, int? index}) {
    // Content of LI might be text or mixed
    final content = _buildTextSpan(node);

    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 8),
        pw.Text(ordered ? "$index." : "•", style: const pw.TextStyle(fontSize: 14)),
        pw.SizedBox(width: 8),
        pw.Expanded(child: pw.RichText(text: content)),
      ],
    );
  }
}
