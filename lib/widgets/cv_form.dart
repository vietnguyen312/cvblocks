import 'package:flutter/material.dart';
import '../models/cv_data.dart';
import 'html_editor_field.dart';

class CvForm extends StatefulWidget {
  final CvData data;
  final ValueChanged<CvData> onChanged;

  const CvForm({super.key, required this.data, required this.onChanged});

  @override
  State<CvForm> createState() => _CvFormState();
}

class _CvFormState extends State<CvForm> {
  late TextEditingController _nameController;
  late TextEditingController _titleController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _skillsController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.name);
    _titleController = TextEditingController(text: widget.data.jobTitle);
    _emailController = TextEditingController(text: widget.data.email);
    _phoneController = TextEditingController(text: widget.data.phone);
    _locationController = TextEditingController(text: widget.data.location);
    _skillsController = TextEditingController(text: widget.data.skills.join(", "));

    // Listeners to update data
    void update() {
      final newData = CvData(
        name: _nameController.text,
        jobTitle: _titleController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        location: _locationController.text,
        about: widget.data.about, // about is updated directly via onChanged callback
        skills: _skillsController.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList(),
        experience: widget.data.experience, // Keep existing experience for now
      );
      widget.onChanged(newData);
    }

    _nameController.addListener(update);
    _titleController.addListener(update);
    _emailController.addListener(update);
    _phoneController.addListener(update);
    _locationController.addListener(update);
    _skillsController.addListener(update);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Personal Information",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField("Full Name", _nameController),
          _buildTextField("Job Title", _titleController),
          _buildTextField("Email", _emailController),
          _buildTextField("Phone", _phoneController),
          _buildTextField("Location", _locationController),
          HtmlEditorField(
            label: "About Me",
            initialValue: widget.data.about,
            onChanged: (v) {
              // Update data directly since controller is local to HtmlEditorField
              final newData = CvData(
                name: _nameController.text,
                jobTitle: _titleController.text,
                email: _emailController.text,
                phone: _phoneController.text,
                location: _locationController.text,
                about: v,
                skills: widget.data.skills,
                experience: widget.data.experience,
              );
              widget.onChanged(newData);
            },
            maxLines: 10,
          ),
          const SizedBox(height: 24),
          const Text(
            "Skills (comma separated)",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildTextField("Skills", _skillsController, hint: "Audit, Accounting, Finance"),

          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Work Experience",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              IconButton(onPressed: _addExperience, icon: const Icon(Icons.add_circle)),
            ],
          ),
          ...widget.data.experience.asMap().entries.map((entry) {
            int idx = entry.key;
            WorkExperience exp = entry.value;
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: exp.company,
                      decoration: const InputDecoration(labelText: "Company"),
                      onChanged: (v) => _updateExperience(idx, exp..company = v),
                    ),
                    TextFormField(
                      initialValue: exp.title,
                      decoration: const InputDecoration(labelText: "Job Title"),
                      onChanged: (v) => _updateExperience(idx, exp..title = v),
                    ),
                    TextFormField(
                      initialValue: exp.dateRange,
                      decoration: const InputDecoration(labelText: "Date Range"),
                      onChanged: (v) => _updateExperience(idx, exp..dateRange = v),
                    ),
                    HtmlEditorField(
                      label: "Description",
                      initialValue: exp.description,
                      maxLines: 15,
                      onChanged: (v) => _updateExperience(idx, exp..description = v),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => _removeExperience(idx),
                        child: const Text("Remove", style: TextStyle(color: Colors.red)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? hint,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        ),
      ),
    );
  }

  void _addExperience() {
    final newExp = WorkExperience(
      company: "Company",
      title: "Role",
      dateRange: "2023 - Present",
      description: "Description...",
    );
    final newData = CvData(
      name: widget.data.name,
      jobTitle: widget.data.jobTitle,
      email: widget.data.email,
      phone: widget.data.phone,
      location: widget.data.location,
      about: widget.data.about,
      skills: widget.data.skills,
      experience: [...widget.data.experience, newExp],
    );
    widget.onChanged(newData);
    // Force rebuild to show new item if parent doesn't rebuild entire widget tree immediately
    // (depending on how parent handles it, but usually calling setState in parent will rebuild this widget).
    // However, since we use controllers for text fields that are initialized in initState,
    // simply rebuilding this widget won't update the text fields if the Key doesn't change.
    // For this simple example, we rely on the parent to rebuild us, but the text controllers won't sync
    // back if we aren't careful.
    // Actually, for the main fields, controllers hold the state.
    // For experience list, it's mapped from widget.data.
    setState(() {});
  }

  void _updateExperience(int index, WorkExperience updatedExp) {
    final List<WorkExperience> newInfo = List.from(widget.data.experience);
    newInfo[index] = updatedExp;

    final newData = CvData(
      name: widget.data.name,
      jobTitle: widget.data.jobTitle,
      email: widget.data.email,
      phone: widget.data.phone,
      location: widget.data.location,
      about: widget.data.about,
      skills: widget.data.skills,
      experience: newInfo,
    );
    widget.onChanged(newData);
  }

  void _removeExperience(int index) {
    final List<WorkExperience> newInfo = List.from(widget.data.experience);
    newInfo.removeAt(index);

    final newData = CvData(
      name: widget.data.name,
      jobTitle: widget.data.jobTitle,
      email: widget.data.email,
      phone: widget.data.phone,
      location: widget.data.location,
      about: widget.data.about,
      skills: widget.data.skills,
      experience: newInfo,
    );
    widget.onChanged(newData);
    setState(() {});
  }
}
