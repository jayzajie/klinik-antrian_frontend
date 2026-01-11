class Department {
  final int id;
  final String name;
  final String? description;
  final bool isActive;

  Department({
    required this.id,
    required this.name,
    this.description,
    required this.isActive,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
    );
  }
}
