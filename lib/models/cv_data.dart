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
}
