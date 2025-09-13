import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../controllers/settings_controller.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../widgets/custom_button.dart';

/// شاشة تواصل معنا
class ContactScreen extends GetView<SettingsController> {
  const ContactScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'تواصل معنا',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // رأس الصفحة
            _buildHeader(),
            
            const SizedBox(height: 24),
            
            // معلومات التواصل
            _buildContactInfo(),
            
            const SizedBox(height: 24),
            
            // نموذج التواصل
            _buildContactForm(),
            
            const SizedBox(height: 24),
            
            // وسائل التواصل الاجتماعي
            _buildSocialMedia(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  AppIcons.support,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              
              const SizedBox(width: 16),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نحن هنا لمساعدتك',
                      style: AppTextStyles.titleLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    Text(
                      'تواصل معنا في أي وقت وسنكون سعداء لمساعدتك',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معلومات التواصل',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // البريد الإلكتروني
        _buildContactItem(
          icon: AppIcons.email,
          title: 'البريد الإلكتروني',
          subtitle: 'support@dayenmadeen.com',
          onTap: () => _launchEmail('support@dayenmadeen.com'),
        ),
        
        const SizedBox(height: 12),
        
        // رقم الهاتف
        _buildContactItem(
          icon: AppIcons.phone,
          title: 'رقم الهاتف',
          subtitle: '+966 50 123 4567',
          onTap: () => _launchPhone('+966501234567'),
        ),
        
        const SizedBox(height: 12),
        
        // واتساب
        _buildContactItem(
          icon: AppIcons.whatsapp,
          title: 'واتساب',
          subtitle: '+966 50 123 4567',
          onTap: () => _launchWhatsApp('+966501234567'),
        ),
        
        const SizedBox(height: 12),
        
        // العنوان
        _buildContactItem(
          icon: AppIcons.location,
          title: 'العنوان',
          subtitle: 'الرياض، المملكة العربية السعودية',
          onTap: () => _launchMaps(),
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            
            const SizedBox(width: 12),
            
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  
                  const SizedBox(height: 2),
                  
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
              AppIcons.arrowForward,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'أرسل لنا رسالة',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Form(
          key: controller.contactFormKey,
          child: Column(
            children: [
              // الاسم
              CustomTextField(
                controller: controller.contactNameController,
                label: 'الاسم',
                hint: 'أدخل اسمك',
                prefixIcon: AppIcons.person,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الاسم مطلوب';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // البريد الإلكتروني
              CustomTextField(
                controller: controller.contactEmailController,
                label: 'البريد الإلكتروني',
                hint: 'أدخل بريدك الإلكتروني',
                prefixIcon: AppIcons.email,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'البريد الإلكتروني مطلوب';
                  }
                  if (!GetUtils.isEmail(value)) {
                    return 'البريد الإلكتروني غير صحيح';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // الموضوع
              CustomTextField(
                controller: controller.contactSubjectController,
                label: 'الموضوع',
                hint: 'أدخل موضوع الرسالة',
                prefixIcon: AppIcons.subject,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الموضوع مطلوب';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 16),
              
              // الرسالة
              CustomTextField(
                controller: controller.contactMessageController,
                label: 'الرسالة',
                hint: 'اكتب رسالتك هنا...',
                prefixIcon: AppIcons.message,
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرسالة مطلوبة';
                  }
                  if (value.length < 10) {
                    return 'الرسالة يجب أن تكون 10 أحرف على الأقل';
                  }
                  return null;
                },
              ),
              
              const SizedBox(height: 24),
              
              // زر الإرسال
              Obx(() => CustomButton(
                text: 'إرسال الرسالة',
                onPressed: controller.isSendingMessage.value 
                    ? null 
                    : controller.sendContactMessage,
                isLoading: controller.isSendingMessage.value,
                icon: AppIcons.send,
              )),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSocialMedia() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تابعنا على',
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 16),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildSocialButton(
              icon: AppIcons.twitter,
              label: 'تويتر',
              color: const Color(0xFF1DA1F2),
              onTap: () => _launchSocial('https://twitter.com/dayenmadeen'),
            ),
            
            _buildSocialButton(
              icon: AppIcons.instagram,
              label: 'إنستغرام',
              color: const Color(0xFFE4405F),
              onTap: () => _launchSocial('https://instagram.com/dayenmadeen'),
            ),
            
            _buildSocialButton(
              icon: AppIcons.linkedin,
              label: 'لينكد إن',
              color: const Color(0xFF0077B5),
              onTap: () => _launchSocial('https://linkedin.com/company/dayenmadeen'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // دوال التشغيل
  void _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: 'subject=استفسار من تطبيق دين مدين',
    );
    
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  void _launchPhone(String phone) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phone);
    
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  void _launchWhatsApp(String phone) async {
    final Uri whatsappUri = Uri.parse('https://wa.me/$phone');
    
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri);
    }
  }

  void _launchMaps() async {
    final Uri mapsUri = Uri.parse('https://maps.google.com/?q=Riyadh,Saudi+Arabia');
    
    if (await canLaunchUrl(mapsUri)) {
      await launchUrl(mapsUri);
    }
  }

  void _launchSocial(String url) async {
    final Uri socialUri = Uri.parse(url);
    
    if (await canLaunchUrl(socialUri)) {
      await launchUrl(socialUri);
    }
  }
}
