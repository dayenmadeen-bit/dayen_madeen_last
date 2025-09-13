import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// شاشة المساعدة والأسئلة الشائعة
class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  int? expandedIndex;

  final List<Map<String, String>> faqData = [
    {
      'question': 'كيف أضيف عميل جديد؟',
      'answer': 'اذهب إلى قسم العملاء واضغط على زر "إضافة عميل جديد". املأ البيانات المطلوبة واضغط حفظ.',
    },
    {
      'question': 'كيف أسجل دين جديد؟',
      'answer': 'من الشاشة الرئيسية، اضغط على "إضافة دين جديد" أو اذهب لقسم الديون واختر العميل المطلوب.',
    },
    {
      'question': 'كيف أسجل مدفوعة؟',
      'answer': 'اذهب إلى تفاصيل الدين واضغط على "إضافة مدفوعة" أو من قسم المدفوعات اختر "مدفوعة جديدة".',
    },
    {
      'question': 'كيف أنشئ تقرير؟',
      'answer': 'اذهب إلى قسم التقارير واختر نوع التقرير المطلوب (يومي، شهري، أو مخصص) وحدد الفترة الزمنية.',
    },
    {
      'question': 'كيف أعمل نسخة احتياطية؟',
      'answer': 'اذهب إلى الإعدادات > النسخ الاحتياطي واضغط على "إنشاء نسخة احتياطية جديدة".',
    },
    {
      'question': 'كيف أستعيد النسخة الاحتياطية؟',
      'answer': 'من قسم النسخ الاحتياطي، اختر النسخة المطلوبة واضغط على "استعادة".',
    },
    {
      'question': 'كيف أغير كلمة المرور؟',
      'answer': 'اذهب إلى الإعدادات > الأمان وحدد "تغيير كلمة المرور".',
    },
    {
      'question': 'كيف أفعل الإشعارات؟',
      'answer': 'من الإعدادات > الإشعارات، يمكنك تفعيل أو إلغاء تفعيل أنواع الإشعارات المختلفة.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المساعدة'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // مقدمة
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'مرحباً بك في مركز المساعدة',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'هنا ستجد إجابات للأسئلة الشائعة وإرشادات لاستخدام التطبيق بفعالية.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // الأسئلة الشائعة
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'الأسئلة الشائعة',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  ...faqData.asMap().entries.map((entry) {
                    final index = entry.key;
                    final faq = entry.value;
                    return _buildFAQItem(index, faq['question']!, faq['answer']!);
                  }),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // تواصل معنا
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.support_agent,
                        color: Colors.blue[700],
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'تحتاج مساعدة إضافية؟',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.blue[700],
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'فريق الدعم الفني متاح لمساعدتك في أي وقت.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            // فتح البريد الإلكتروني
                          },
                          icon: const Icon(Icons.email),
                          label: const Text('راسلنا'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue[700],
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // فتح الواتساب
                          },
                          icon: const Icon(Icons.chat),
                          label: const Text('واتساب'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue[700],
                            side: BorderSide(color: Colors.blue[700]!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(int index, String question, String answer) {
    final isExpanded = expandedIndex == index;
    
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: index == 0 ? BorderSide.none : BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: ExpansionTile(
        title: Text(
          question,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[800],
            fontWeight: FontWeight.w500,
          ),
        ),
        trailing: Icon(
          isExpanded ? Icons.expand_less : Icons.expand_more,
          color: Colors.blue[700],
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            expandedIndex = expanded ? index : null;
          });
        },
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Text(
              answer,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
