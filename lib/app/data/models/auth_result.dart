/// نتيجة عملية المصادقة
class AuthResult {
  final bool isSuccess;
  final String? error;
  final dynamic user;
  final String? token;
  final Map<String, dynamic>? data;

  const AuthResult._({
    required this.isSuccess,
    this.error,
    this.user,
    this.token,
    this.data,
  });

  /// نتيجة نجح
  factory AuthResult.success(dynamic user, {String? token, Map<String, dynamic>? data}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      token: token,
      data: data,
    );
  }

  /// نتيجة فشل
  factory AuthResult.failure(String error, {Map<String, dynamic>? data}) {
    return AuthResult._(
      isSuccess: false,
      error: error,
      data: data,
    );
  }

  /// نتيجة فشل مع استثناء
  factory AuthResult.exception(Exception exception) {
    return AuthResult._(
      isSuccess: false,
      error: exception.toString(),
    );
  }

  @override
  String toString() {
    if (isSuccess) {
      return 'AuthResult.success(user: $user, token: $token)';
    } else {
      return 'AuthResult.failure(error: $error)';
    }
  }
}

/// أنواع المصادقة
enum AuthType {
  email('email', 'البريد الإلكتروني'),
  biometric('biometric', 'البصمة'),
  faceId('face_id', 'Face ID'),
  password('password', 'كلمة المرور');

  const AuthType(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

/// حالة المصادقة
enum AuthStatus {
  authenticated('authenticated', 'مصادق'),
  unauthenticated('unauthenticated', 'غير مصادق'),
  loading('loading', 'جاري التحميل'),
  error('error', 'خطأ');

  const AuthStatus(this.value, this.displayName);
  
  final String value;
  final String displayName;
}

/// بيانات تسجيل الدخول
class LoginCredentials {
  final String email;
  final String password;
  final bool rememberMe;
  final AuthType authType;

  const LoginCredentials({
    required this.email,
    required this.password,
    this.rememberMe = false,
    this.authType = AuthType.email,
  });

  /// التحقق من صحة البيانات
  bool get isValid {
    return email.isNotEmpty && 
           password.isNotEmpty && 
           RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// الحصول على رسائل الأخطاء
  List<String> get validationErrors {
    final errors = <String>[];
    
    if (email.isEmpty) {
      errors.add('البريد الإلكتروني مطلوب');
    } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      errors.add('البريد الإلكتروني غير صحيح');
    }
    
    if (password.isEmpty) {
      errors.add('كلمة المرور مطلوبة');
    }
    
    return errors;
  }

  @override
  String toString() {
    return 'LoginCredentials(email: $email, authType: $authType, rememberMe: $rememberMe)';
  }
}

/// بيانات إعادة تعيين كلمة المرور
class PasswordResetData {
  final String email;
  final String? token;
  final String? newPassword;

  const PasswordResetData({
    required this.email,
    this.token,
    this.newPassword,
  });

  /// التحقق من صحة البيانات للطلب
  bool get isValidForRequest {
    return email.isNotEmpty && 
           RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  /// التحقق من صحة البيانات للإعادة تعيين
  bool get isValidForReset {
    return isValidForRequest && 
           token != null && 
           token!.isNotEmpty && 
           newPassword != null && 
           newPassword!.length >= 6;
  }

  @override
  String toString() {
    return 'PasswordResetData(email: $email, hasToken: ${token != null})';
  }
}

/// جلسة المستخدم
class UserSession {
  final String userId;
  final String email;
  final String name;
  final String userType;
  final String? token;
  final DateTime loginTime;
  final DateTime? expiryTime;
  final Map<String, dynamic>? metadata;

  const UserSession({
    required this.userId,
    required this.email,
    required this.name,
    required this.userType,
    this.token,
    required this.loginTime,
    this.expiryTime,
    this.metadata,
  });

  /// تحويل من JSON
  factory UserSession.fromJson(Map<String, dynamic> json) {
    return UserSession(
      userId: json['user_id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      userType: json['user_type'] as String,
      token: json['token'] as String?,
      loginTime: DateTime.parse(json['login_time'] as String),
      expiryTime: json['expiry_time'] != null 
          ? DateTime.parse(json['expiry_time'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// تحويل إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'name': name,
      'user_type': userType,
      'token': token,
      'login_time': loginTime.toIso8601String(),
      'expiry_time': expiryTime?.toIso8601String(),
      'metadata': metadata,
    };
  }

  /// التحقق من صحة الجلسة
  bool get isValid {
    if (expiryTime == null) return true;
    return DateTime.now().isBefore(expiryTime!);
  }

  /// التحقق من انتهاء الجلسة
  bool get isExpired => !isValid;

  /// الوقت المتبقي للجلسة
  Duration? get remainingTime {
    if (expiryTime == null) return null;
    final now = DateTime.now();
    if (now.isAfter(expiryTime!)) return Duration.zero;
    return expiryTime!.difference(now);
  }

  @override
  String toString() {
    return 'UserSession(userId: $userId, email: $email, userType: $userType, isValid: $isValid)';
  }
}
