class CvData {
  String name;
  String jobTitle;
  String email;
  String phone;
  String location;
  String about;
  List<WorkExperience> experience;
  List<String> skills;

  CvData({
    this.name = "VIET NGUYEN NGUYEN",
    this.jobTitle = "Senior mobile engineer",
    this.email = "nguyenvietnguyen88@gmail.com",
    this.phone = "+84 392734512",
    this.location = "Ho Chi Minh city, Vietnam",
    this.about =
        "Senior Mobile Engineer with <b>14+ years of experience</b> building and scaling mobile applications using <i>Flutter</i> and native Android...",
    this.experience = const [],
    this.skills = const ["Auditing", "Financial Accounting", "Financial Reporting"],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'jobTitle': jobTitle,
      'email': email,
      'phone': phone,
      'location': location,
      'about': about,
      'experience': experience.map((e) => e.toJson()).toList(),
      'skills': skills,
    };
  }

  factory CvData.fromJson(Map<String, dynamic> json) {
    return CvData(
      name: json['name'] ?? "",
      jobTitle: json['jobTitle'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      location: json['location'] ?? "",
      about: json['about'] ?? "",
      experience:
          (json['experience'] as List<dynamic>?)?.map((e) => WorkExperience.fromJson(e)).toList() ??
          [],
      skills: (json['skills'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}

class WorkExperience {
  String title;
  String company;
  String dateRange;
  String description;

  WorkExperience({
    required this.title,
    required this.company,
    required this.dateRange,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {'title': title, 'company': company, 'dateRange': dateRange, 'description': description};
  }

  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      title: json['title'] ?? "",
      company: json['company'] ?? "",
      dateRange: json['dateRange'] ?? "",
      description: json['description'] ?? "",
    );
  }
}
