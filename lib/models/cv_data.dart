class CvData {
  String name;
  String jobTitle;
  String email;
  String phone;
  String location;
  String contactAdditionalInformation;
  String about;
  List<WorkExperience> experience;
  List<Education> education;

  CvData({
    this.name = "",
    this.jobTitle = "",
    this.email = "",
    this.phone = "",
    this.location = "",
    this.contactAdditionalInformation = "",
    this.about = "",
    this.experience = const [],
    this.education = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'jobTitle': jobTitle,
      'email': email,
      'phone': phone,
      'location': location,
      'website': contactAdditionalInformation,
      'about': about,
      'experience': experience.map((e) => e.toJson()).toList(),
      'education': education.map((e) => e.toJson()).toList(),
    };
  }

  factory CvData.fromJson(Map<String, dynamic> json) {
    return CvData(
      name: json['name'] ?? "",
      jobTitle: json['jobTitle'] ?? "",
      email: json['email'] ?? "",
      phone: json['phone'] ?? "",
      location: json['location'] ?? "",
      contactAdditionalInformation: json['website'] ?? "",
      about: json['about'] ?? "",
      experience:
          (json['experience'] as List<dynamic>?)?.map((e) => WorkExperience.fromJson(e)).toList() ??
          [],
      education:
          (json['education'] as List<dynamic>?)?.map((e) => Education.fromJson(e)).toList() ?? [],
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

class Education {
  String institution;
  String degree;
  String dateRange;
  String description;

  Education({
    required this.institution,
    required this.degree,
    required this.dateRange,
    required this.description,
  });

  Map<String, dynamic> toJson() {
    return {
      'institution': institution,
      'degree': degree,
      'dateRange': dateRange,
      'description': description,
    };
  }

  factory Education.fromJson(Map<String, dynamic> json) {
    return Education(
      institution: json['institution'] ?? "",
      degree: json['degree'] ?? "",
      dateRange: json['dateRange'] ?? "",
      description: json['description'] ?? "",
    );
  }
}
