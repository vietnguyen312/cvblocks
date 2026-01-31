import 'package:flutter/material.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../models/cv_data.dart';

class CvTemplate extends StatelessWidget {
  final CvData data;

  const CvTemplate({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                data.name.toUpperCase(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Center(
              child: Text(
                data.jobTitle,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildContactItem(Icons.phone, data.phone),
                const SizedBox(width: 24),
                _buildContactItem(Icons.email, data.email),
                const SizedBox(width: 24),
                _buildContactItem(Icons.location_on, data.location),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(color: Colors.black54, thickness: 1),
            const SizedBox(height: 8),
            _buildSectionHeader("ABOUT ME"),
            const SizedBox(height: 8),
            HtmlWidget(
              data.about,
              textStyle: const TextStyle(fontSize: 14, height: 1.5, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.black54, thickness: 1),
            const SizedBox(height: 16),
            _buildSectionHeader("WORK EXPERIENCE"),
            const SizedBox(height: 16),
            ...data.experience.map((exp) => _buildExperienceItem(exp)),
            if (data.experience.isEmpty)
              const Text("No work experience added.", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            if (data.education.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Divider(color: Colors.black54, thickness: 1),
              const SizedBox(height: 16),
              _buildSectionHeader("EDUCATION"),
              const SizedBox(height: 16),
              ...data.education.map((edu) => _buildEducationItem(edu)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.black87),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title.toUpperCase(),
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.5,
        color: Colors.black,
      ),
    );
  }

  Widget _buildExperienceItem(WorkExperience exp) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                exp.company,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(exp.dateRange, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Text(exp.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          HtmlWidget(exp.description, textStyle: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }

  Widget _buildEducationItem(Education edu) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                edu.institution,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              Text(edu.dateRange, style: const TextStyle(fontSize: 14, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 4),
          Text(edu.degree, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          HtmlWidget(edu.description, textStyle: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
