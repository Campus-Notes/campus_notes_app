class UserModel {
  final String uid;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  final String university;
  final double walletBalance;
  final int points;
  final bool isUPIProvided;
  final bool isBankDetailsProvided;
  final String? upiId;
  final String? bankAccountNumber;
  final String? ifscCode;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.university,
    this.walletBalance = 0.0,
    this.points = 0,
    this.isUPIProvided = false,
    this.isBankDetailsProvided = false,
    this.upiId,
    this.bankAccountNumber,
    this.ifscCode,
    required this.createdAt,
  });

  // Computed property for full name
  String get fullName => firstName;

  // Legacy getter for backwards compatibility
  String get name => fullName;

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'mobile': mobile,
      'university': university,
      'walletBalance': walletBalance,
      'points': points,
      'isUPIProvided': isUPIProvided,
      'isBankDetailsProvided': isBankDetailsProvided,
      'upiId': upiId,
      'bankAccountNumber': bankAccountNumber,
      'ifscCode': ifscCode,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      firstName: map['firstName'] ?? '',
      lastName: map['lastName'] ?? '',
      email: map['email'] ?? '',
      mobile: map['mobile'] ?? '',
      university: map['university'] ?? '',
      walletBalance: (map['walletBalance'] ?? 0.0).toDouble(),
      points: map['points'] ?? 0,
      isUPIProvided: map['isUPIProvided'] ?? false,
      isBankDetailsProvided: map['isBankDetailsProvided'] ?? false,
      upiId: map['upiId'],
      bankAccountNumber: map['bankAccountNumber'],
      ifscCode: map['ifscCode'],
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Method to copy with new values (useful for updates)
  UserModel copyWith({
    String? firstName,
    String? lastName,
    String? mobile,
    String? university,
    double? walletBalance,
    int? points,
    bool? isUPIProvided,
    bool? isBankDetailsProvided,
    String? upiId,
    String? bankAccountNumber,
    String? ifscCode,
  }) {
    return UserModel(
      uid: uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email, // Email cannot be changed
      mobile: mobile ?? this.mobile,
      university: university ?? this.university,
      walletBalance: walletBalance ?? this.walletBalance,
      points: points ?? this.points,
      isUPIProvided: isUPIProvided ?? this.isUPIProvided,
      isBankDetailsProvided: isBankDetailsProvided ?? this.isBankDetailsProvided,
      upiId: upiId ?? this.upiId,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      ifscCode: ifscCode ?? this.ifscCode,
      createdAt: createdAt,
    );
  }
}
