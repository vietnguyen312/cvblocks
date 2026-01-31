import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

class HtmlEditorField extends StatefulWidget {
  final String label;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final int maxLines;

  const HtmlEditorField({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.maxLines = 5,
  });

  @override
  State<HtmlEditorField> createState() => _HtmlEditorFieldState();
}

class _HtmlEditorFieldState extends State<HtmlEditorField> {
  late TextEditingController _controller;
  bool _showPreview = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(() {
      // Basic debounce could be added here if needed, but for now direct update
      // We only notify parent if value changed to avoid loops if parent rebuilds
      // (Parent updates usually won't trigger this unless initialValue changes)
    });
  }

  @override
  void didUpdateWidget(HtmlEditorField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != _controller.text) {
      // Keep cursor position if possible? No, usually external update means reset
      _controller.text = widget.initialValue;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertTag(String openTag, String closeTag) {
    final text = _controller.text;
    final selection = _controller.selection;

    if (selection.start < 0) {
      // No selection, append to end
      final newText = "$text$openTag$closeTag";
      _controller.text = newText;
      widget.onChanged(newText);
      return;
    }

    final newText = text.replaceRange(
      selection.start,
      selection.end,
      "$openTag${text.substring(selection.start, selection.end)}$closeTag",
    );

    _controller.value = TextEditingValue(
      text: newText,
      selection: TextSelection(
        baseOffset: selection.start + openTag.length,
        extentOffset: selection.end + openTag.length,
      ),
    );
    widget.onChanged(newText);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label + Toggle Row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: Theme.of(context).textTheme.bodyLarge),
            IconButton(
              icon: Icon(_showPreview ? Icons.edit : Icons.visibility),
              onPressed: () => setState(() => _showPreview = !_showPreview),
              tooltip: _showPreview ? "Edit HTML" : "Preview Format",
            ),
          ],
        ),

        if (_showPreview)
          Container(
            height: (widget.maxLines * 24.0).clamp(
              120.0,
              500.0,
            ), // Approximate height match or min 120
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(4),
              color: Colors.grey[100],
            ),
            child: SingleChildScrollView(
              child: HtmlWidget(
                _controller.text.isEmpty ? "<i>No content</i>" : _controller.text,
                textStyle: const TextStyle(fontSize: 14),
              ),
            ),
          )
        else
          Column(
            children: [
              // Toolbar
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border(
                    top: BorderSide(color: Colors.grey.shade400),
                    left: BorderSide(color: Colors.grey.shade400),
                    right: BorderSide(color: Colors.grey.shade400),
                  ),
                ),
                child: Row(
                  children: [
                    _ToolbarBtn(
                      icon: Icons.format_bold,
                      tooltip: "Bold",
                      onTap: () => _insertTag("<b>", "</b>"),
                    ),
                    _ToolbarBtn(
                      icon: Icons.format_italic,
                      tooltip: "Italic",
                      onTap: () => _insertTag("<i>", "</i>"),
                    ),
                    _ToolbarBtn(
                      icon: Icons.format_list_bulleted,
                      tooltip: "Bullet List",
                      onTap: () => _insertTag("<ul>\n  <li>", "</li>\n</ul>"),
                    ),
                    _ToolbarBtn(
                      icon: Icons.list,
                      tooltip: "Numbered List",
                      onTap: () => _insertTag("<ol>\n  <li>", "</li>\n</ol>"),
                    ),
                    // Simple list item adder for convenience
                    _ToolbarBtn(
                      icon: Icons.add,
                      tooltip: "Add List Item",
                      onTap: () => _insertTag("  <li>", "</li>\n"),
                    ),
                  ],
                ),
              ),
              TextField(
                controller: _controller,
                maxLines: widget.maxLines,
                onChanged: widget.onChanged,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(4),
                      bottomRight: Radius.circular(4),
                    ),
                  ),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _ToolbarBtn({required this.icon, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      onPressed: onTap,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(),
    );
  }
}
