import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_app_bar.dart';

/// شاشة سياسة الخصوصية
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'سياسة الخصوصية',
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
            
            // محتوى سياسة الخصوصية
            _buildPrivacyContent(),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              AppIcons.security,
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
                  'حماية خصوصيتك',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'نحن ملتزمون بحماية بياناتك الشخصية',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'مقدمة',
          'نحن في تطبيق "دين مدين" نقدر خصوصيتك ونلتزم بحماية معلوماتك الشخصية. توضح سياسة الخصوصية هذه كيفية جمع واستخدام وحماية المعلومات التي تقدمها لنا.',
        ),
        
        _buildSection(
          'المعلومات التي نجمعها',
          '''نقوم بجمع الأنواع التالية من المعلومات:

• معلومات الحساب: الاسم، البريد الإلكتروني، رقم الهاتف
• معلومات المنشأة: اسم المنشأة، العنوان، نوع النشاط
• بيانات الاستخدام: كيفية استخدامك للتطبيق والميزات المستخدمة
• معلومات الجهاز: نوع الجهاز، نظام التشغيل، معرف الجهاز''',
        ),
        
        _buildSection(
          'كيفية استخدام المعلومات',
          '''نستخدم المعلومات المجمعة للأغراض التالية:

• تقديم وتحسين خدماتنا
• إنشاء وإدارة حسابك
• معالجة المعاملات والمدفوعات
• إرسال الإشعارات والتحديثات المهمة
• تقديم الدعم الفني
• تحليل استخدام التطبيق لتحسين الأداء''',
        ),
        
        _buildSection(
          'مشاركة المعلومات',
          '''نحن لا نبيع أو نؤجر معلوماتك الشخصية لأطراف ثالثة. قد نشارك معلوماتك في الحالات التالية:

• مع مقدمي الخدمات الموثوقين لتشغيل التطبيق
• عند الحاجة للامتثال للقوانين واللوائح
• لحماية حقوقنا وسلامة المستخدمين
• في حالة دمج أو بيع الشركة (بعد إشعارك)''',
        ),
        
        _buildSection(
          'أمان المعلومات',
          '''نتخذ تدابير أمنية صارمة لحماية معلوماتك:

• تشفير البيانات أثناء النقل والتخزين
• استخدام خوادم آمنة ومحمية
• مراقبة مستمرة للأنشطة المشبوهة
• تحديث أنظمة الأمان بانتظام
• تدريب الموظفين على أفضل ممارسات الأمان''',
        ),
        
        _buildSection(
          'حقوقك',
          '''لديك الحقوق التالية فيما يتعلق بمعلوماتك:

• الوصول إلى معلوماتك الشخصية
• تصحيح أو تحديث المعلومات غير الصحيحة
• حذف حسابك ومعلوماتك
• تقييد معالجة معلوماتك
• نقل معلوماتك إلى خدمة أخرى
• الاعتراض على معالجة معلوماتك''',
        ),
        
        _buildSection(
          'ملفات تعريف الارتباط',
          'نستخدم ملفات تعريف الارتباط وتقنيات مشابهة لتحسين تجربتك وتحليل استخدام التطبيق. يمكنك التحكم في هذه الملفات من خلال إعدادات المتصفح.',
        ),
        
        _buildSection(
          'التحديثات',
          'قد نقوم بتحديث سياسة الخصوصية من وقت لآخر. سنقوم بإشعارك بأي تغييرات مهمة عبر التطبيق أو البريد الإلكتروني.',
        ),
        
        _buildSection(
          'التواصل معنا',
          '''إذا كان لديك أي أسئلة حول سياسة الخصوصية، يمكنك التواصل معنا:

البريد الإلكتروني: privacy@dayenmadeen.com
الهاتف: +966 50 123 4567
العنوان: الرياض، المملكة العربية السعودية''',
        ),
        
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.info.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.info,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'آخر تحديث: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.info,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTextStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          content,
          style: AppTextStyles.bodyMedium.copyWith(
            height: 1.6,
            color: AppColors.textPrimary,
          ),
        ),
        
        const SizedBox(height: 20),
      ],
    );
  }
}
