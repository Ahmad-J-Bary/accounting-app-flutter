class CustomerDto {
  final String id;
  final String code;
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final double creditLimit;
  final double currentBalance;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  CustomerDto({
    required this.id,
    required this.code,
    required this.name,
    this.email,
    this.phone,
    this.address,
    required this.creditLimit,
    required this.currentBalance,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CustomerDto.fromJson(Map<String, dynamic> json) {
    return CustomerDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      creditLimit: (json['creditLimit'] as num).toDouble(),
      currentBalance: (json['currentBalance'] as num).toDouble(),
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
      'email': email,
      'phone': phone,
      'address': address,
      'creditLimit': creditLimit,
      'currentBalance': currentBalance,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}
