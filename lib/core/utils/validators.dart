/// مجموعة من دوال التحقق من صحة البيانات
class Validators {
  // منع إنشاء instance من الكلاس
  Validators._();

  /// التحقق من البريد الإلكتروني
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'البريد الإلكتروني مطلوب';
    }

    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    if (!emailRegex.hasMatch(value)) {
      return 'البريد الإلكتروني غير صحيح';
    }

    return null;
  }

  /// التحقق من كلمة المرور
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < 6) {
      return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
    }
    
    return null;
  }

  /// التحقق من كلمة المرور القوية
  static String? strongPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'كلمة المرور مطلوبة';
    }
    
    if (value.length < 8) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل';
    }
    
    // التحقق من وجود حرف كبير
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف كبير';
    }
    
    // التحقق من وجود حرف صغير
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على حرف صغير';
    }
    
    // التحقق من وجود رقم
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'كلمة المرور يجب أن تحتوي على رقم';
    }
    
    return null;
  }

  /// التحقق من تطابق كلمة المرور
  static String? confirmPassword(String? value, String? originalPassword) {
    if (value == null || value.isEmpty) {
      return 'تأكيد كلمة المرور مطلوب';
    }
    
    if (value != originalPassword) {
      return 'كلمة المرور غير متطابقة';
    }
    
    return null;
  }

  /// التحقق من الاسم
  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'الاسم مطلوب';
    }
    
    if (value.trim().length < 2) {
      return 'الاسم يجب أن يكون حرفين على الأقل';
    }
    
    if (value.trim().length > 50) {
      return 'الاسم يجب أن يكون أقل من 50 حرف';
    }
    
    return null;
  }

  /// التحقق من رقم الهاتف
  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return 'رقم الهاتف مطلوب';
    }
    
    // إزالة المسافات والرموز
    final cleanPhone = value.replaceAll(RegExp(r'[^\d+]'), '');
    
    // التحقق من الطول
    if (cleanPhone.length < 10 || cleanPhone.length > 15) {
      return 'رقم الهاتف غير صحيح';
    }
    
    // التحقق من الصيغة السعودية
    if (cleanPhone.startsWith('966') || cleanPhone.startsWith('+966')) {
      final saudiPhone = cleanPhone.replaceFirst(RegExp(r'^\+?966'), '');
      if (saudiPhone.length != 9 || !saudiPhone.startsWith('5')) {
        return 'رقم الهاتف السعودي غير صحيح';
      }
    }
    
    return null;
  }

  /// التحقق من رقم الهاتف (اختياري)
  static String? optionalPhone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // اختياري
    }

    return phone(value);
  }

  /// التحقق من المبلغ
  static String? amount(String? value) {
    if (value == null || value.isEmpty) {
      return 'المبلغ مطلوب';
    }
    
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'المبلغ غير صحيح';
    }
    
    if (amount <= 0) {
      return 'المبلغ يجب أن يكون أكبر من صفر';
    }
    
    if (amount > 1000000) {
      return 'المبلغ كبير جداً';
    }
    
    return null;
  }

  /// التحقق من المبلغ (اختياري)
  static String? optionalAmount(String? value) {
    if (value == null || value.isEmpty) {
      return null; // اختياري
    }
    
    return amount(value);
  }

  /// التحقق من النص المطلوب
  static String? required(String? value, [String? fieldName]) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'هذا الحقل'} مطلوب';
    }
    
    return null;
  }

  /// التحقق من الطول الأدنى
  static String? minLength(String? value, int minLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null; // سيتم التحقق من المطلوب في مكان آخر
    }
    
    if (value.length < minLength) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون $minLength أحرف على الأقل';
    }
    
    return null;
  }

  /// التحقق من الطول الأقصى
  static String? maxLength(String? value, int maxLength, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null; // سيتم التحقق من المطلوب في مكان آخر
    }
    
    if (value.length > maxLength) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يكون أقل من $maxLength حرف';
    }
    
    return null;
  }

  /// التحقق من الأرقام فقط
  static String? numbersOnly(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null; // سيتم التحقق من المطلوب في مكان آخر
    }
    
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يحتوي على أرقام فقط';
    }
    
    return null;
  }

  /// التحقق من الأحرف فقط
  static String? lettersOnly(String? value, [String? fieldName]) {
    if (value == null || value.isEmpty) {
      return null; // سيتم التحقق من المطلوب في مكان آخر
    }
    
    if (!RegExp(r'^[a-zA-Zأ-ي\s]+$').hasMatch(value)) {
      return '${fieldName ?? 'هذا الحقل'} يجب أن يحتوي على أحرف فقط';
    }
    
    return null;
  }

  /// التحقق من اسم المنشأة
  static String? businessName(String? value) {
    if (value == null || value.isEmpty) {
      return 'اسم المنشأة مطلوب';
    }
    
    if (value.trim().length < 2) {
      return 'اسم المنشأة يجب أن يكون حرفين على الأقل';
    }
    
    if (value.trim().length > 100) {
      return 'اسم المنشأة يجب أن يكون أقل من 100 حرف';
    }
    
    return null;
  }

  /// التحقق من العنوان
  static String? address(String? value) {
    if (value == null || value.isEmpty) {
      return null; // العنوان اختياري
    }
    
    if (value.trim().length < 5) {
      return 'العنوان يجب أن يكون 5 أحرف على الأقل';
    }
    
    if (value.trim().length > 200) {
      return 'العنوان يجب أن يكون أقل من 200 حرف';
    }
    
    return null;
  }

  /// التحقق من الوصف
  static String? description(String? value) {
    if (value == null || value.isEmpty) {
      return null; // الوصف اختياري
    }
    
    if (value.trim().length > 500) {
      return 'الوصف يجب أن يكون أقل من 500 حرف';
    }
    
    return null;
  }

  /// دمج عدة validators
  static String? combine(List<String? Function(String?)> validators, String? value) {
    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        return result;
      }
    }
    return null;
  }
}
