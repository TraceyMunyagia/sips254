class Spirit {
  final String id;
  final String name;
  final String? category;
  final bool isKenyan;

  Spirit({
    required this.id,
    required this.name,
    this.category,
    required this.isKenyan,
  });

  factory Spirit.fromMap(Map<String, dynamic> map) => Spirit(
        id: map['id'] as String,
        name: map['name'] as String,
        category: map['category'] as String?,
        isKenyan: map['is_kenyan'] as bool? ?? false,
      );
}