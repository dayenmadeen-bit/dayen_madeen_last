import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/credentials_vault_service.dart';

/// ويدجت خزنة بيانات الاعتماد
class CredentialsVaultWidget extends StatefulWidget {
  final Function(String username, String password) onCredentialSelected;
  final TextEditingController usernameController;
  final TextEditingController passwordController;

  const CredentialsVaultWidget({
    super.key,
    required this.onCredentialSelected,
    required this.usernameController,
    required this.passwordController,
  });

  @override
  State<CredentialsVaultWidget> createState() => _CredentialsVaultWidgetState();
}

class _CredentialsVaultWidgetState extends State<CredentialsVaultWidget> {
  late final CredentialsVaultService _vaultService;
  bool _isExpanded = false;
  SavedCredential? _selectedCredential;

  @override
  void initState() {
    super.initState();

    // تسجيل الخدمة إذا لم تكن مسجلة
    if (!Get.isRegistered<CredentialsVaultService>()) {
      Get.put(CredentialsVaultService(), permanent: true);
    }

    _vaultService = Get.find<CredentialsVaultService>();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Obx(() {
        if (_vaultService.savedCredentials.isEmpty) {
          return _buildAddCredentialButton();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // زر توسيع/طي خزنة بيانات الاعتماد
            _buildVaultToggle(),

            if (_isExpanded) ...[
              const SizedBox(height: 12),
              _buildCredentialsList(),
              const SizedBox(height: 12),
              _buildVaultActions(),
            ],
          ],
        );
      });
    } catch (e) {
      print('خطأ في CredentialsVaultWidget: $e');
      return _buildAddCredentialButton();
    }
  }

  Widget _buildVaultToggle() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _isExpanded = !_isExpanded;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(
                Icons.security,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'خزنة بيانات الاعتماد (${_vaultService.savedCredentials.length})',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: AppColors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCredentialsList() {
    return Container(
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: _vaultService.savedCredentials.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
        itemBuilder: (context, index) {
          final credential = _vaultService.savedCredentials[index];
          final isSelected = _selectedCredential?.id == credential.id;
          
          return ListTile(
            dense: true,
            selected: isSelected,
            selectedTileColor: AppColors.primary.withValues(alpha: 0.1),
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.2),
              child: Text(
                credential.storeName.isNotEmpty 
                    ? credential.storeName[0].toUpperCase()
                    : 'M',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              credential.storeName,
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              credential.username,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
                const SizedBox(width: 4),
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 16, color: AppColors.info),
                          const SizedBox(width: 8),
                          const Text('تعديل'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 16, color: AppColors.error),
                          const SizedBox(width: 8),
                          const Text('حذف'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditCredentialDialog(credential);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(credential);
                    }
                  },
                ),
              ],
            ),
            onTap: () {
              setState(() {
                _selectedCredential = credential;
              });
              
              // تحديث حقول تسجيل الدخول
              widget.usernameController.text = credential.username;
              widget.passwordController.text = credential.password;
              widget.onCredentialSelected(credential.username, credential.password);
              
              // تحديث وقت آخر استخدام
              _vaultService.updateLastUsed(credential.id);
              
              Get.snackbar(
                'تم التحديد',
                'تم تحديد بيانات ${credential.storeName}',
                backgroundColor: AppColors.success,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildVaultActions() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showAddCredentialDialog,
            icon: Icon(Icons.add, size: 16),
            label: const Text('إضافة جديد'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: BorderSide(color: AppColors.primary),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showSaveCurrentDialog,
            icon: Icon(Icons.save, size: 16),
            label: const Text('حفظ الحالي'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.success,
              side: BorderSide(color: AppColors.success),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddCredentialButton() {
    return OutlinedButton.icon(
      onPressed: _showAddCredentialDialog,
      icon: Icon(Icons.security, size: 16),
      label: const Text('إنشاء خزنة بيانات الاعتماد'),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary,
        side: BorderSide(color: AppColors.primary),
      ),
    );
  }

  void _showAddCredentialDialog() {
    final storeNameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('إضافة بيانات اعتماد جديدة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: storeNameController,
              decoration: const InputDecoration(
                labelText: 'اسم المتجر',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (storeNameController.text.isNotEmpty &&
                  usernameController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                await _vaultService.addCredential(
                  storeName: storeNameController.text,
                  username: usernameController.text,
                  password: passwordController.text,
                );
                Get.back();
                Get.snackbar(
                  'تم الحفظ',
                  'تم حفظ بيانات الاعتماد بنجاح',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showSaveCurrentDialog() {
    final storeNameController = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text('حفظ البيانات الحالية'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: storeNameController,
              decoration: const InputDecoration(
                labelText: 'اسم المتجر',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'اسم المستخدم: ${widget.usernameController.text}',
              style: AppTextStyles.bodySmall,
            ),
            Text(
              'كلمة المرور: ${'*' * widget.passwordController.text.length}',
              style: AppTextStyles.bodySmall,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (storeNameController.text.isNotEmpty &&
                  widget.usernameController.text.isNotEmpty &&
                  widget.passwordController.text.isNotEmpty) {
                await _vaultService.addCredential(
                  storeName: storeNameController.text,
                  username: widget.usernameController.text,
                  password: widget.passwordController.text,
                );
                Get.back();
                Get.snackbar(
                  'تم الحفظ',
                  'تم حفظ بيانات الاعتماد بنجاح',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _showEditCredentialDialog(SavedCredential credential) {
    final storeNameController = TextEditingController(text: credential.storeName);
    final usernameController = TextEditingController(text: credential.username);
    final passwordController = TextEditingController(text: credential.password);

    Get.dialog(
      AlertDialog(
        title: const Text('تعديل بيانات الاعتماد'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: storeNameController,
              decoration: const InputDecoration(
                labelText: 'اسم المتجر',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'اسم المستخدم',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'كلمة المرور',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (storeNameController.text.isNotEmpty &&
                  usernameController.text.isNotEmpty &&
                  passwordController.text.isNotEmpty) {
                await _vaultService.updateCredential(
                  credentialId: credential.id,
                  storeName: storeNameController.text,
                  username: usernameController.text,
                  password: passwordController.text,
                );
                Get.back();
                Get.snackbar(
                  'تم التحديث',
                  'تم تحديث بيانات الاعتماد بنجاح',
                  backgroundColor: AppColors.success,
                  colorText: Colors.white,
                );
              }
            },
            child: const Text('تحديث'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(SavedCredential credential) {
    Get.dialog(
      AlertDialog(
        title: const Text('تأكيد الحذف'),
        content: Text('هل أنت متأكد من حذف بيانات ${credential.storeName}؟'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _vaultService.deleteCredential(credential.id);
              Get.back();
              Get.snackbar(
                'تم الحذف',
                'تم حذف بيانات الاعتماد',
                backgroundColor: AppColors.error,
                colorText: Colors.white,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }
}
