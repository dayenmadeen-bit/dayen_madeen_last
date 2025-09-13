import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';

/// شاشة التواصل والدعم الفني
class ContactSupportScreen extends StatelessWidget {
  const ContactSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text(
          'التواصل والدعم',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // بطاقة الترحيب
            _buildWelcomeCard(),
            
            const SizedBox(height: 24),
            
            // قنوات التواصل
            _buildContactChannels(),
            
            const SizedBox(height: 24),
            
            // الأسئلة الشائعة
            _buildFAQSection(),
            
            const SizedBox(height: 24),
            
            // معلومات التطبيق
            _buildAppInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'نحن هنا لمساعدتك',
                  style: AppTextStyles.headlineSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'فريق الدعم الفني متاح لمساعدتك في حل أي مشكلة أو الإجابة على استفساراتك حول التطبيق.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactChannels() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'قنوات التواصل',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        // واتساب
        _buildContactOption(
          icon: Icons.chat,
          title: 'واتساب',
          subtitle: 'تواصل معنا عبر الواتساب',
          color: Colors.green,
          onTap: () => _launchWhatsApp(),
        ),
        
        // البريد الإلكتروني
        _buildContactOption(
          icon: Icons.email,
          title: 'البريد الإلكتروني',
          subtitle: 'support@dayenmadeen.com',
          color: AppColors.info,
          onTap: () => _launchEmail(),
        ),
        
        // الهاتف
        _buildContactOption(
          icon: Icons.phone,
          title: 'الهاتف',
          subtitle: '+966 50 123 4567',
          color: AppColors.success,
          onTap: () => _launchPhone(),
        ),
        
        // الموقع الإلكتروني
        _buildContactOption(
          icon: Icons.language,
          title: 'الموقع الإلكتروني',
          subtitle: 'www.dayenmadeen.com',
          color: AppColors.primary,
          onTap: () => _launchWebsite(),
        ),
      ],
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        elevation: 2,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأسئلة الشائعة',
          style: AppTextStyles.titleLarge.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        
        _buildFAQItem(
          'كيف يمكنني إنشاء حساب جديد؟',
          'يمكنك التواصل مع مالك المتجر لإنشاء حساب جديد لك.',
        ),
        
        _buildFAQItem(
          'نسيت كلمة المرور، ماذا أفعل؟',
          'يمكنك التواصل مع مالك المتجر لإعادة تعيين كلمة المرور.',
        ),
        
        _buildFAQItem(
          'كيف يمكنني حفظ بيانات تسجيل الدخول؟',
          'يمكنك استخدام خزنة بيانات الاعتماد في شاشة تسجيل الدخول لحفظ بيانات متاجر متعددة.',
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: AppTextStyles.titleSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'تطبيق دين مدين',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'الإصدار 1.0.0',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '© 2024 جميع الحقوق محفوظة',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // دوال التواصل
  Future<void> _launchWhatsApp() async {
    const String phoneNumber = '+966501234567';
    const String message = 'مرحباً، أحتاج مساعدة في تطبيق دين مدين';
    final Uri whatsappUri = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح الواتساب',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _launchEmail() async {
    final Uri emailUri = Uri.parse('mailto:support@dayenmadeen.com?subject=طلب دعم فني');
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح تطبيق البريد الإلكتروني',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _launchPhone() async {
    final Uri phoneUri = Uri.parse('tel:+966501234567');
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن إجراء المكالمة',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _launchWebsite() async {
    final Uri websiteUri = Uri.parse('https://www.dayenmadeen.com');
    
    if (await canLaunchUrl(websiteUri)) {
      await launchUrl(websiteUri);
    } else {
      Get.snackbar(
        'خطأ',
        'لا يمكن فتح الموقع الإلكتروني',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }
}
