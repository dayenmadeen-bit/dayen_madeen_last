import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_decorations.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../controllers/customer_import_controller.dart';

class CustomerImportScreen extends GetView<CustomerImportController> {
  const CustomerImportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('استيراد العملاء من ملف CSV'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.reset,
            tooltip: 'البدء من جديد',
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.importProgress.value > 0) {
          return _buildImportingState();
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStep1Card(),
              if (controller.tableHeaders.isNotEmpty) ...[
                const SizedBox(height: 24),
                _buildStep2Card(),
              ],
              if (controller.columnMapping.containsValue('name')) ...[
                const SizedBox(height: 24),
                _buildStep3Card(),
              ]
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStep1Card() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الخطوة 1: اختيار ملف', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'اختر ملف بصيغة CSV يحتوي على بيانات عملائك. يجب أن يكون السطر الأول هو عناوين الأعمدة (مثل: الاسم، الهاتف، البريد الإلكتروني).',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('اختيار ملف CSV'),
                onPressed: controller.pickAndParseFile,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              ),
            ),
            if (controller.selectedFile.value != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Center(
                  child: Text(
                    'الملف المختار: ${controller.selectedFile.value!.path.split('/').last}',
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.success),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2Card() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الخطوة 2: ربط الأعمدة', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'قم بربط كل عمود من ملفك بالحقل المناسب في التطبيق. حقل "الاسم" إجباري.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            _buildMappingTable(),
            const SizedBox(height: 16),
            Text('معاينة أول 3 صفوف:', style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _buildPreviewTable(),
          ],
        ),
      ),
    );
  }

  Widget _buildMappingTable() {
    return Column(
      children: List.generate(controller.tableHeaders.length, (index) {
        final header = controller.tableHeaders[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            children: [
              Expanded(flex: 2, child: Text(header, style: AppTextStyles.bodyMedium)),
              const Icon(Icons.arrow_forward, color: AppColors.textHintLight),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  decoration: AppDecorations.getInputDecoration(label: header, hint: 'تجاهل هذا العمود'),
                  hint: const Text('تجاهل هذا العمود'),
                  value: controller.columnMapping[index],
                  onChanged: (newValue) {
                    controller.setColumnMapping(index, newValue);
                  },
                  items: controller.customerFields.map((field) {
                    bool isUsed = controller.columnMapping.containsValue(field) && controller.columnMapping[index] != field;
                    return DropdownMenuItem(
                      value: field,
                      enabled: !isUsed,
                      child: Text(
                        _translateFieldName(field),
                        style: TextStyle(color: isUsed ? Colors.grey : Colors.black),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPreviewTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: controller.tableHeaders.map((h) => DataColumn(label: Text(h))).toList(),
        rows: controller.tableRows.take(3).map((row) {
          return DataRow(cells: row.map((cell) => DataCell(Text(cell))).toList());
        }).toList(),
      ),
    );
  }

  Widget _buildStep3Card() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('الخطوة 3: بدء الاستيراد', style: AppTextStyles.titleMedium.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'أنت جاهز الآن لبدء عملية الاستيراد. سيتم تجاهل أي عمود لم يتم ربطه.',
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.downloading),
                label: const Text('بدء الاستيراد الآن'),
                onPressed: controller.startImport,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.success, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImportingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text('جاري الاستيراد...', style: AppTextStyles.titleLarge),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: controller.importProgress.value),
            const SizedBox(height: 16),
            Text(controller.importMessage.value, style: AppTextStyles.bodyMedium),
          ],
        ),
      ),
    );
  }

  String _translateFieldName(String field) {
    switch (field) {
      case 'name':
        return 'الاسم الكامل';
      case 'phone':
        return 'رقم الهاتف';
      case 'email':
        return 'البريد الإلكتروني';
      case 'address':
        return 'العنوان';
      default:
        return field;
    }
  }
}
