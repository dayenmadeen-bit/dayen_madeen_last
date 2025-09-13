import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/services/device_service.dart';
import '../../../widgets/custom_app_bar.dart';
import '../../../widgets/custom_button.dart';

/// شاشة التواصل والدعم المخصصة لمالك المنشأة
class BusinessOwnerSupportScreen extends StatelessWidget {
  const BusinessOwnerSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: const CustomAppBar(
        title: 'دعم مالك المنشأة',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // بطاقة الترحيب المخصصة
            _buildBusinessOwnerWelcomeCard(),
            
            const SizedBox(height: 24),
            
            // معرف الجهاز
            _buildDeviceIdCard(),
            
            const SizedBox(height: 24),
            
            // قنوات التواصل المخصصة
            _buildBusinessContactChannels(),
            
            const SizedBox(height: 24),
            
            // الأسئلة الشائعة لمالك المنشأة
            _buildBusinessOwnerFAQ(),
            
            const SizedBox(height: 24),
            
            // موارد إضافية
            _buildAdditionalResources(),
          ],
        ),
      ),
    );
  }

  /// بطاقة الترحيب المخصصة لمالك المنشأة
  Widget _buildBusinessOwnerWelcomeCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDecorations.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.business_center,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'دعم مالك المنشأة',
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'فريق الدعم المتخصص',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'نحن هنا لمساعدتك في إدارة منشأتك بكفاءة. تواصل معنا للحصول على الدعم الفني المتخصص وحلول الأعمال المناسبة لك.',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// بطاقة معرف الجهاز
  Widget _buildDeviceIdCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration.copyWith(
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.smartphone,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'معرف الجهاز',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.warning,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'يرجى تضمين معرف الجهاز عند التواصل مع الدعم الفني لتسريع عملية المساعدة',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          
          // معرف الجهاز مع زر النسخ
          FutureBuilder<String>(
            future: DeviceService.getDeviceId(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          snapshot.data!,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontFamily: 'monospace',
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _copyDeviceId(snapshot.data!),
                        icon: Icon(
                          Icons.copy,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        tooltip: 'نسخ معرف الجهاز',
                      ),
                    ],
                  ),
                );
              }
              return const Center(child: CircularProgressIndicator());
            },
          ),
        ],
      ),
    );
  }

  /// قنوات التواصل المخصصة للأعمال
  Widget _buildBusinessContactChannels() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'قنوات التواصل المتخصصة',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // واتساب الأعمال
          _buildContactChannel(
            icon: Icons.chat,
            title: 'واتساب الأعمال',
            subtitle: 'دعم فوري للاستفسارات العاجلة',
            color: Colors.green,
            onTap: () => _launchWhatsAppBusiness(),
          ),
          
          const SizedBox(height: 12),
          
          // البريد الإلكتروني للأعمال
          _buildContactChannel(
            icon: Icons.email,
            title: 'البريد الإلكتروني للأعمال',
            subtitle: 'business-support@deanmdean.com',
            color: AppColors.info,
            onTap: () => _launchBusinessEmail(),
          ),
          
          const SizedBox(height: 12),
          
          // الهاتف المخصص للأعمال
          _buildContactChannel(
            icon: Icons.phone,
            title: 'خط الأعمال المباشر',
            subtitle: '+966 11 234 5678',
            color: AppColors.warning,
            onTap: () => _launchBusinessPhone(),
          ),
          
          const SizedBox(height: 12),
          
          // جدولة مكالمة
          _buildContactChannel(
            icon: Icons.calendar_today,
            title: 'جدولة مكالمة استشارية',
            subtitle: 'احجز موعد مع مستشار الأعمال',
            color: AppColors.secondary,
            onTap: () => _scheduleConsultation(),
          ),
        ],
      ),
    );
  }

  /// قناة تواصل واحدة
  Widget _buildContactChannel({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: color,
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
                      fontWeight: FontWeight.bold,
                      color: color,
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
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  /// الأسئلة الشائعة لمالك المنشأة
  Widget _buildBusinessOwnerFAQ() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'الأسئلة الشائعة للأعمال',
                style: AppTextStyles.titleMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          _buildFAQItem(
            'كيف أضيف عملاء جدد لمنشأتي؟',
            'يمكنك إضافة العملاء من خلال قسم "إدارة العملاء" في التطبيق...',
          ),
          
          _buildFAQItem(
            'كيف أتابع المعاملات والديون؟',
            'استخدم قسم "المعاملات" لمتابعة جميع العمليات المالية...',
          ),
          
          _buildFAQItem(
            'كيف أنشئ تقارير مالية؟',
            'يمكنك إنشاء التقارير من قسم "التقارير" واختيار الفترة المطلوبة...',
          ),
          
          _buildFAQItem(
            'كيف أدير صلاحيات الموظفين؟',
            'من خلال قسم "إدارة الموظفين" يمكنك تحديد الصلاحيات لكل موظف...',
          ),
          
          const SizedBox(height: 16),
          
          CustomButton(
            text: 'عرض جميع الأسئلة الشائعة',
            onPressed: () => _showAllFAQ(),
            type: ButtonType.outlined,
            icon: Icons.list,
          ),
        ],
      ),
    );
  }

  /// عنصر سؤال شائع
  Widget _buildFAQItem(String question, String answer) {
    return ExpansionTile(
      title: Text(
        question,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            answer,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// موارد إضافية
  Widget _buildAdditionalResources() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppDecorations.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'موارد إضافية',
            style: AppTextStyles.titleMedium.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildResourceItem(
            Icons.video_library,
            'دليل الاستخدام المرئي',
            'شاهد فيديوهات تعليمية لاستخدام التطبيق',
            () => _openVideoGuide(),
          ),
          
          const SizedBox(height: 12),
          
          _buildResourceItem(
            Icons.article,
            'دليل المستخدم',
            'اقرأ الدليل الشامل لاستخدام التطبيق',
            () => _openUserGuide(),
          ),
          
          const SizedBox(height: 12),
          
          _buildResourceItem(
            Icons.update,
            'آخر التحديثات',
            'تعرف على أحدث الميزات والتحسينات',
            () => _showUpdates(),
          ),
        ],
      ),
    );
  }

  /// عنصر مورد
  Widget _buildResourceItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: AppColors.textSecondary, size: 16),
          ],
        ),
      ),
    );
  }

  // الدوال المساعدة
  void _copyDeviceId(String deviceId) {
    Clipboard.setData(ClipboardData(text: deviceId));
    Get.snackbar(
      'تم النسخ',
      'تم نسخ معرف الجهاز إلى الحافظة',
      backgroundColor: AppColors.success,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  void _launchWhatsAppBusiness() async {
    const url = 'https://wa.me/966112345678?text=مرحباً، أحتاج مساعدة في إدارة منشأتي';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchBusinessEmail() async {
    const url = 'mailto:business-support@deanmdean.com?subject=استفسار مالك منشأة';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchBusinessPhone() async {
    const url = 'tel:+966112345678';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _scheduleConsultation() {
    Get.snackbar(
      'قريباً',
      'ميزة جدولة المكالمات ستكون متاحة قريباً',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  void _showAllFAQ() {
    // Navigate to full FAQ screen
    Get.toNamed('/business-faq');
  }

  void _openVideoGuide() {
    Get.snackbar(
      'قريباً',
      'دليل الفيديو سيكون متاحاً قريباً',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  void _openUserGuide() {
    Get.snackbar(
      'قريباً',
      'دليل المستخدم سيكون متاحاً قريباً',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }

  void _showUpdates() {
    Get.snackbar(
      'قريباً',
      'صفحة التحديثات ستكون متاحة قريباً',
      backgroundColor: AppColors.info,
      colorText: Colors.white,
    );
  }
}
