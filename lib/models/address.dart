class Address {
  final String id;
  final String fullName;
  final String phoneNumber;
  final String streetAddress;
  final String ward;          // Phường/Xã
  final String district;      // Quận/Huyện
  final String city;          // Thành phố
  final String label;         // Nhà, Công ty, Khác
  final bool isDefault;
  final DateTime createdAt;

  Address({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    required this.streetAddress,
    required this.ward,
    required this.district,
    required this.city,
    required this.label,
    this.isDefault = false,
    required this.createdAt,
  });

  // Địa chỉ đầy đủ
  String get fullAddress {
    return '$streetAddress, $ward, $district, $city';
  }

  // Convert to Map để lưu vào Firestore
  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'streetAddress': streetAddress,
      'ward': ward,
      'district': district,
      'city': city,
      'label': label,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Convert từ Firestore Map thành Address object
  factory Address.fromMap(String id, Map<String, dynamic> map) {
    return Address(
      id: id,
      fullName: map['fullName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      streetAddress: map['streetAddress'] ?? '',
      ward: map['ward'] ?? '',
      district: map['district'] ?? '',
      city: map['city'] ?? '',
      label: map['label'] ?? 'Nhà',
      isDefault: map['isDefault'] ?? false,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'])
          : DateTime.now(),
    );
  }

  // Copy with method để tạo bản sao với các thuộc tính mới
  Address copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? streetAddress,
    String? ward,
    String? district,
    String? city,
    String? label,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Address(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      streetAddress: streetAddress ?? this.streetAddress,
      ward: ward ?? this.ward,
      district: district ?? this.district,
      city: city ?? this.city,
      label: label ?? this.label,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
