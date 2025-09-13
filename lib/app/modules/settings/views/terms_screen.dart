import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_icons.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../widgets/custom_app_bar.dart';

/// شاشة شروط الاستخدام
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'شروط الاستخدام',
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
            
            // محتوى شروط الاستخدام
            _buildTermsContent(),
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
              AppIcons.document,
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
                  'شروط الاستخدام',
                  style: AppTextStyles.titleLarge.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 4),
                
                Text(
                  'الشروط والأحكام لاستخدام تطبيق دين مدين',
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

  Widget _buildTermsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection(
          'مقدمة',
          'مرحباً بك في تطبيق "دين مدين". باستخدامك لهذا التطبيق، فإنك توافق على الالتزام بهذه الشروط والأحكام. يرجى قراءتها بعناية قبل استخدام التطبيق.',
        ),
        
        _buildSection(
          'تعريفات',
          '''في هذه الشروط، تعني المصطلحات التالية:

• "التطبيق": تطبيق دين مدين لإدارة الديون والمدفوعات
• "الخدمة": جميع الخدمات المقدمة من خلال التطبيق
• "المستخدم": أي شخص يستخدم التطبيق
• "المحتوى": جميع المعلومات والبيانات في التطبيق''',
        ),
        
        _buildSection(
          'قبول الشروط',
          '''باستخدام التطبيق، فإنك:

• تؤكد أنك تبلغ من العمر 18 عاماً أو أكثر
• توافق على جميع الشروط والأحكام
• تلتزم بالقوانين المحلية والدولية
• تتحمل المسؤولية الكاملة عن استخدامك للتطبيق''',
        ),
        
        _buildSection(
          'استخدام التطبيق',
          '''يُسمح لك باستخدام التطبيق للأغراض التالية:

• إدارة الديون والمدفوعات الشخصية أو التجارية
• تتبع المعاملات المالية
• إنشاء التقارير والإحصائيات
• التواصل مع العملاء (للمنشآت)

يُمنع استخدام التطبيق لأي أغراض غير قانونية أو ضارة.''',
        ),
        
        _buildSection(
          'حساب المستخدم',
          '''عند إنشاء حساب، يجب عليك:

• تقديم معلومات صحيحة ومحدثة
• الحفاظ على سرية كلمة المرور
• إشعارنا فوراً بأي استخدام غير مصرح به
• تحديث معلوماتك عند الحاجة
• عدم مشاركة حسابك مع الآخرين''',
        ),
        
        _buildSection(
          'الخصوصية والبيانات',
          '''نحن ملتزمون بحماية خصوصيتك:

• جمع البيانات الضرورية فقط لتشغيل الخدمة
• عدم مشاركة معلوماتك مع أطراف ثالثة دون إذن
• استخدام تقنيات التشفير لحماية البيانات
• الامتثال لقوانين حماية البيانات المحلية''',
        ),
        
        _buildSection(
          'المدفوعات والرسوم',
          '''فيما يتعلق بالمدفوعات:

• التطبيق مجاني للاستخدام الأساسي
• قد تطبق رسوم على الميزات المتقدمة
• جميع المدفوعات غير قابلة للاسترداد
• الأسعار قابلة للتغيير مع إشعار مسبق''',
        ),
        
        _buildSection(
          'المسؤوليات والضمانات',
          '''نحن نسعى لتقديم خدمة موثوقة، لكن:

• التطبيق يُقدم "كما هو" دون ضمانات
• لا نضمن عدم انقطاع الخدمة
• المستخدم مسؤول عن نسخ بياناته احتياطياً
• لا نتحمل مسؤولية الأضرار غير المباشرة''',
        ),
        
        _buildSection(
          'الملكية الفكرية',
          '''جميع حقوق الملكية الفكرية للتطبيق محفوظة:

• التطبيق والمحتوى محميان بحقوق الطبع والنشر
• يُمنع نسخ أو توزيع التطبيق دون إذن
• العلامات التجارية مملوكة لنا
• المستخدم يحتفظ بحقوق بياناته الشخصية''',
        ),
        
        _buildSection(
          'إنهاء الخدمة',
          '''يمكن إنهاء الخدمة في الحالات التالية:

• انتهاك شروط الاستخدام
• استخدام التطبيق لأغراض غير قانونية
• عدم دفع الرسوم المستحقة
• طلب المستخدم حذف حسابه''',
        ),
        
        _buildSection(
          'تعديل الشروط',
          'نحتفظ بالحق في تعديل هذه الشروط في أي وقت. سيتم إشعار المستخدمين بأي تغييرات مهمة عبر التطبيق أو البريد الإلكتروني.',
        ),
        
        _buildSection(
          'القانون المطبق',
          'تخضع هذه الشروط لقوانين المملكة العربية السعودية، وأي نزاعات ستحل وفقاً للقوانين المحلية.',
        ),
        
        _buildSection(
          'التواصل',
          '''للاستفسارات حول شروط الاستخدام:

البريد الإلكتروني: legal@dayenmadeen.com
الهاتف: +966 50 123 4567
العنوان: الرياض، المملكة العربية السعودية''',
        ),
        
        const SizedBox(height: 24),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                AppIcons.warning,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'باستخدام التطبيق، فإنك توافق على جميع الشروط والأحكام المذكورة أعلاه.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
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
