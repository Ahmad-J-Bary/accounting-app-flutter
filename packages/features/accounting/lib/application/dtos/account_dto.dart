class AccountDto {
  final String id;
  final String code;
  final String name;
  final String? description;
  final String type;
  final String? parentId;
  final double balance;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  AccountDto({
    required this.id,
    required this.code,
    required this.name,
    this.description,
    required this.type,
    this.parentId,
    required this.balance,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AccountDto.fromJson(Map<String, dynamic> json) {
    return AccountDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String,
      parentId: json['parentId'] as String?,
      balance: (json['balance'] as num).toDouble(),
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'description': description,
      'type': type,
      'parentId': parentId,
      'balance': balance,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
