import 'dart:convert';
import 'dart:io';

import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/customer.dart';
import 'customers_controller.dart';

class CustomerImportController extends GetxController {
  // -- State
  var selectedFile = Rxn<File>();
  var tableHeaders = <String>[].obs;
  var tableRows = <List<String>>[].obs;
  var columnMapping = <int, String>{}.obs; // Map<columnIndex, fieldName>

  var isLoading = false.obs;
  var importProgress = 0.0.obs;
  var importMessage = ''.obs;

  final CustomersController _customersController = Get.find();

  // -- Mapped Customer Fields
  final List<String> customerFields = [
    'name', // required
    'phone',
    'email',
    'address',
    // 'username', // Let's keep it simple for now
    // 'currentBalance',
  ];

  // -- Actions

  /// يفتح نافذة اختيار الملفات ويقرأ الملف المختار
  Future<void> pickAndParseFile() async {
    try {
      isLoading.value = true;
      // 1. اختيار الملف
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result == null || result.files.single.path == null) {
        Get.snackbar('لم يتم اختيار ملف', 'الرجاء اختيار ملف CSV صالح.');
        return;
      }

      selectedFile.value = File(result.files.single.path!);

      // 2. قراءة وتحليل الملف
      final fileContent =
          await selectedFile.value!.readAsString(encoding: utf8);
      final rowsAsListOfValues =
          const CsvToListConverter(shouldParseNumbers: false)
              .convert(fileContent);

      if (rowsAsListOfValues.isEmpty) {
        tableHeaders.clear();
        tableRows.clear();
        Get.snackbar('خطأ', 'الملف فارغ أو غير صالح.');
        return;
      }

      // 3. تحديث الحالة بالبيانات المقروءة
      tableHeaders.value =
          rowsAsListOfValues[0].map((e) => e.toString()).toList();
      tableRows.value = rowsAsListOfValues
          .sublist(1)
          .map((row) => row.map((cell) => cell.toString()).toList())
          .toList();
      columnMapping.clear(); // Reset mapping on new file
    } catch (e) {
      // print("File Picking/Parsing Error: $e");
      Get.snackbar('خطأ في قراءة الملف',
          'تأكد من أن الملف بصيغة CSV ويستخدم ترميز UTF-8.');
    } finally {
      isLoading.value = false;
    }
  }

  /// تحديث ربط العمود بحقل العميل
  void setColumnMapping(int columnIndex, String? fieldName) {
    if (fieldName == null) {
      columnMapping.remove(columnIndex);
    } else {
      // Ensure one-to-one mapping
      columnMapping.removeWhere((key, value) => value == fieldName);
      columnMapping[columnIndex] = fieldName;
    }
  }

  /// بدء عملية الاستيراد النهائية
  Future<void> startImport() async {
    // التحقق من ربط حقل الاسم الإجباري
    if (!columnMapping.containsValue('name')) {
      Get.snackbar('خطأ', 'الرجاء ربط حقل "الاسم" على الأقل.',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    isLoading.value = true;
    importMessage.value = 'بدء عملية الاستيراد...';
    int successCount = 0;
    int failedCount = 0;

    final nameIndex =
        columnMapping.entries.firstWhere((e) => e.value == 'name').key;
    final passwordIndex =
        columnMapping.entries.firstWhere((e) => e.value == 'password').key;
    final phoneIndex = columnMapping.entries
        .firstWhere((e) => e.value == 'phone',
            orElse: () => const MapEntry(-1, ''))
        .key;
    final emailIndex = columnMapping.entries
        .firstWhere((e) => e.value == 'email',
            orElse: () => const MapEntry(-1, ''))
        .key;
    final addressIndex = columnMapping.entries
        .firstWhere((e) => e.value == 'address',
            orElse: () => const MapEntry(-1, ''))
        .key;

    for (int i = 0; i < tableRows.length; i++) {
      final row = tableRows[i];
      importProgress.value = (i + 1) / tableRows.length;
      importMessage.value = 'جاري استيراد ${i + 1} من ${tableRows.length}';
      await Future.delayed(
          const Duration(milliseconds: 50)); // To make progress visible

      try {
        final customer = Customer(
          id: DateTime.now().millisecondsSinceEpoch.toString() + i.toString(),
          businessOwnerId: 'mock_owner_id', // Replace with actual owner ID
          name: row[nameIndex],
          uniqueId:
              '${DateTime.now().millisecondsSinceEpoch}$i', // Generate unique ID
          password: row[passwordIndex],
          email: emailIndex != -1 ? row[emailIndex] : null,
          address: addressIndex != -1 ? row[addressIndex] : null,
          currentBalance: 0,
          isActive: true,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final result = await _customersController.addNewCustomer(customer);
        if (result) {
          successCount++;
        } else {
          failedCount++;
        }
      } catch (e) {
        failedCount++;
        // print('Error importing row $i: $e');
      }
    }

    isLoading.value = false;
    importMessage.value = 'اكتمل الاستيراد!';

    // عرض نتائج العملية
    Get.defaultDialog(
      title: 'اكتمل الاستيراد',
      content: Text(
          'تم استيراد $successCount عملاء بنجاح.\nفشل استيراد $failedCount عملاء.'),
      confirm:
          TextButton(onPressed: () => Get.back(), child: const Text('حسناً')),
    );

    // العودة بعد نجاح العملية
    if (failedCount == 0) {
      Get.back();
    }
  }

  void reset() {
    selectedFile.value = null;
    tableHeaders.clear();
    tableRows.clear();
    columnMapping.clear();
    isLoading.value = false;
    importProgress.value = 0.0;
    importMessage.value = '';
  }

  @override
  void onClose() {
    reset();
    super.onClose();
  }
}
