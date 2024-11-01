class Post {
  final String authorName;
  final String applyLink;
  final String companyName;
  final String deadline; // New field for deadline
   final String internshipRole;

  Post({
    required this.authorName,
    required this.applyLink,
    required this.companyName,
    required this.deadline, // New field for deadline
    required this.internshipRole,
  });
}