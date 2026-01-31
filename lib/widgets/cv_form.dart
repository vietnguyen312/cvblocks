import 'package:flutter/material.dart';
import 'dart:async';
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

  late CvData _localData;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.data.name);
    _titleController = TextEditingController(text: widget.data.jobTitle);
    _emailController = TextEditingController(text: widget.data.email);
    _phoneController = TextEditingController(text: widget.data.phone);
    _locationController = TextEditingController(text: widget.data.location);
    _localData = widget.data; // Initialize local state

    // Listeners to update data
    void update() {
      final newData = CvData(
        name: _nameController.text,
        jobTitle: _titleController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        location: _locationController.text,
        about: _localData.about,
        education: _localData.education,
        experience: _localData.experience,
      );
      _updateLocalData(newData);
    }

    _nameController.addListener(update);
    _titleController.addListener(update);
    _emailController.addListener(update);
    _phoneController.addListener(update);
    _locationController.addListener(update);
  }

  @override
  void didUpdateWidget(CvForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parent passes new data (e.g. from JSON import), force sync local state
    // We check if it is different object to avoid resetting on self-triggered updates if using ValueKey logic upstream
    if (widget.data != oldWidget.data) {
      setState(() {
        _localData = widget.data;
        _nameController.text = _localData.name;
        _titleController.text = _localData.jobTitle;
        _emailController.text = _localData.email;
        _phoneController.text = _localData.phone;
        _locationController.text = _localData.location;
      });
    }
  }

  void _updateLocalData(CvData newData) {
    setState(() {
      _localData = newData;
    });

    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      widget.onChanged(_localData);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _titleController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            title: const Text(
              "Personal Information",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            initiallyExpanded: true, // Open by default
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildTextField("Full Name", _nameController),
                    _buildTextField("Job Title", _titleController),
                    _buildTextField("Email", _emailController),
                    _buildTextField("Phone", _phoneController),
                    _buildTextField("Location", _locationController),
                    HtmlEditorField(
                      label: "About Me",
                      initialValue: _localData.about,
                      onChanged: (v) {
                        final newData = CvData(
                          name: _nameController.text,
                          jobTitle: _titleController.text,
                          email: _emailController.text,
                          phone: _phoneController.text,
                          location: _locationController.text,
                          about: v,

                          education: _localData.education,
                          experience: _localData.experience,
                        );
                        _updateLocalData(newData);
                      },
                      maxLines: 10,
                    ),
                  ],
                ),
              ),
            ],
          ),

          ExpansionTile(
            title: const Text(
              "Work Experience",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _addExperience,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Position"),
                      ),
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
              ),
            ],
          ),
          ExpansionTile(
            title: const Text(
              "Education",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton.icon(
                        onPressed: _addEducation,
                        icon: const Icon(Icons.add),
                        label: const Text("Add Education"),
                      ),
                    ),
                    ...widget.data.education.asMap().entries.map((entry) {
                      int idx = entry.key;
                      Education edu = entry.value;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: edu.institution,
                                decoration: const InputDecoration(labelText: "Institution"),
                                onChanged: (v) => _updateEducation(idx, edu..institution = v),
                              ),
                              TextFormField(
                                initialValue: edu.degree,
                                decoration: const InputDecoration(labelText: "Degree"),
                                onChanged: (v) => _updateEducation(idx, edu..degree = v),
                              ),
                              TextFormField(
                                initialValue: edu.dateRange,
                                decoration: const InputDecoration(labelText: "Date Range"),
                                onChanged: (v) => _updateEducation(idx, edu..dateRange = v),
                              ),
                              HtmlEditorField(
                                label: "Description",
                                initialValue: edu.description,
                                maxLines: 5,
                                onChanged: (v) => _updateEducation(idx, edu..description = v),
                              ),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: () => _removeEducation(idx),
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
              ),
            ],
          ),
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
      name: _localData.name,
      jobTitle: _localData.jobTitle,
      email: _localData.email,
      phone: _localData.phone,
      location: _localData.location,
      about: _localData.about,
      education: _localData.education,
      experience: [..._localData.experience, newExp],
    );
    _updateLocalData(newData);
    // Explicitly rebuild locally is handled by _updateLocalData's setState
  }

  void _updateExperience(int index, WorkExperience updatedExp) {
    // Ensure we don't mutate the list in place if it's shared, but here we replace the list
    final List<WorkExperience> newInfo = List.from(_localData.experience);
    newInfo[index] = updatedExp;

    final newData = CvData(
      name: _localData.name,
      jobTitle: _localData.jobTitle,
      email: _localData.email,
      phone: _localData.phone,
      location: _localData.location,
      about: _localData.about,
      education: _localData.education,
      experience: newInfo,
    );
    _updateLocalData(newData);
  }

  void _removeExperience(int index) {
    final List<WorkExperience> newInfo = List.from(_localData.experience);
    newInfo.removeAt(index);

    final newData = CvData(
      name: _localData.name,
      jobTitle: _localData.jobTitle,
      email: _localData.email,
      phone: _localData.phone,
      location: _localData.location,
      about: _localData.about,
      education: _localData.education,
      experience: newInfo,
    );
    _updateLocalData(newData);
  }

  void _addEducation() {
    final newEdu = Education(
      institution: "University",
      degree: "Bachelor's Degree",
      dateRange: "2019 - 2023",
      description: "Description...",
    );
    final newData = CvData(
      name: _localData.name,
      jobTitle: _localData.jobTitle,
      email: _localData.email,
      phone: _localData.phone,
      location: _localData.location,
      about: _localData.about,
      education: [..._localData.education, newEdu],
      experience: _localData.experience,
    );
    _updateLocalData(newData);
  }

  void _updateEducation(int index, Education updatedEdu) {
    // Ensure we don't mutate the list in place if it's shared, but here we replace the list
    final List<Education> newInfo = List.from(_localData.education);
    newInfo[index] = updatedEdu;

    final newData = CvData(
      name: _localData.name,
      jobTitle: _localData.jobTitle,
      email: _localData.email,
      phone: _localData.phone,
      location: _localData.location,
      about: _localData.about,
      education: newInfo,
      experience: _localData.experience,
    );
    _updateLocalData(newData);
  }

  void _removeEducation(int index) {
    final List<Education> newInfo = List.from(_localData.education);
    newInfo.removeAt(index);

    final newData = CvData(
      name: _localData.name,
      jobTitle: _localData.jobTitle,
      email: _localData.email,
      phone: _localData.phone,
      location: _localData.location,
      about: _localData.about,
      education: newInfo,
      experience: _localData.experience,
    );
    _updateLocalData(newData);
  }
}
