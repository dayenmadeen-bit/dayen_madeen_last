import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'logger_service.dart';
import 'dart:async';

enum AnnouncementAudience {
  ownerHome,
  employeeHome,
  customerHome,
  registration,
}

class AnnouncementsService extends GetxService {
  final RxList<String> ownerHome = <String>[
    'مرحباً بك في داين مدين – تحديثات جديدة قريباً',
    'نصيحة: فعّل الإشعارات لتصلك تذكيرات الديون والمدفوعات',
    'النسخ الاحتياطي يحافظ على بياناتك – لا تنسَ تفعيله',
  ].obs;

  final RxList<String> employeeHome = <String>[
    'إدارة صلاحيات الموظفين من هنا',
    'تذكير: راقب حالة الموظفين النشطين وغير النشطين',
    'قم بتحديث البيانات بشكل دوري للحفاظ على الاتساق',
  ].obs;

  final RxList<String> customerHome = <String>[
    'مرحباً بك! تابع مستجدات حسابك هنا',
    'نصيحة: راقب تواريخ استحقاق الديون لتجنب التأخير',
    'يمكنك الاطلاع على آخر المدفوعات من قسم السجل',
  ].obs;

  final RxList<String> registration = <String>[
    'ابدأ رحلتك معنا خلال دقائق قليلة فقط',
    'تأكد من صحة بريدك لإكمال التسجيل',
    'نلتزم بحفظ بياناتك وأمانها',
  ].obs;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _sub;

  @override
  void onInit() {
    super.onInit();
    _listen();
  }

  Future<void> seedSampleAnnouncements() async {
    try {
      final batch = FirebaseFirestore.instance.batch();
      final col = FirebaseFirestore.instance.collection('announcements');

      final samples = <Map<String, dynamic>>[
        {
          "text": "مرحباً بك في داين مدين – تحديثات جديدة قريباً",
          "audience": "ownerHome",
          "enabled": true
        },
        {
          "text": "نصيحة: فعّل الإشعارات لتصلك تذكيرات الديون والمدفوعات",
          "audience": "ownerHome",
          "enabled": true
        },
        {
          "text": "إدارة صلاحيات الموظفين من هنا",
          "audience": "employeeHome",
          "enabled": true
        },
        {
          "text": "تذكير: راقب حالة الموظفين النشطين وغير النشطين",
          "audience": "employeeHome",
          "enabled": true
        },
        {
          "text": "مرحباً بك! تابع مستجدات حسابك هنا",
          "audience": "customerHome",
          "enabled": true
        },
        {
          "text": "راقب تواريخ استحقاق الديون لتجنب التأخير",
          "audience": "customerHome",
          "enabled": true
        },
        {
          "text": "ابدأ رحلتك معنا خلال دقائق قليلة فقط",
          "audience": "registration",
          "enabled": true
        },
        {
          "text": "تأكد من صحة بريدك لإكمال التسجيل",
          "audience": "registration",
          "enabled": true
        },
      ];

      for (final s in samples) {
        final doc = col.doc();
        batch.set(doc, s);
      }

      await batch.commit();
      LoggerService.success('تمت تهيئة عينات الإعلانات بنجاح');
    } catch (e) {
      LoggerService.error('فشل تهيئة عينات الإعلانات', error: e);
      rethrow;
    }
  }

  void _listen() {
    try {
      _sub = FirebaseFirestore.instance
          .collection('announcements')
          .where('enabled', isEqualTo: true)
          .snapshots()
          .listen((snapshot) {
        // مسح القوائم قبل إعادة البناء
        final Map<AnnouncementAudience, List<String>> bucket = {
          AnnouncementAudience.ownerHome: <String>[],
          AnnouncementAudience.employeeHome: <String>[],
          AnnouncementAudience.customerHome: <String>[],
          AnnouncementAudience.registration: <String>[],
        };

        for (final doc in snapshot.docs) {
          final data = doc.data();
          final text = (data['text'] as String?)?.trim();
          final audience = (data['audience'] as String?)?.trim() ?? 'ownerHome';
          if (text == null || text.isEmpty) continue;
          switch (audience) {
            case 'owner':
            case 'ownerHome':
              bucket[AnnouncementAudience.ownerHome]!.add(text);
              break;
            case 'employee':
            case 'employeeHome':
              bucket[AnnouncementAudience.employeeHome]!.add(text);
              break;
            case 'customer':
            case 'customerHome':
              bucket[AnnouncementAudience.customerHome]!.add(text);
              break;
            case 'registration':
              bucket[AnnouncementAudience.registration]!.add(text);
              break;
            default:
              bucket[AnnouncementAudience.ownerHome]!.add(text);
          }
        }

        // تحديث القوائم مع الحفاظ على بدائل افتراضية إذا كانت فارغة
        _replaceList(ownerHome, bucket[AnnouncementAudience.ownerHome]!);
        _replaceList(employeeHome, bucket[AnnouncementAudience.employeeHome]!);
        _replaceList(customerHome, bucket[AnnouncementAudience.customerHome]!);
        _replaceList(registration, bucket[AnnouncementAudience.registration]!);
      });
    } catch (e) {
      LoggerService.warning('فشل تحميل الإعلانات: $e');
    }
  }

  /// ضمان وجود مستند admin للمستخدم الحالي (يستدعى مرة بعد تسجيل الدخول)
  Future<void> ensureCurrentUserIsAdminIfOwner(String uid,
      {bool isOwner = false}) async {
    try {
      if (!isOwner) return; // لا نضيف إلا للمالك
      final doc = FirebaseFirestore.instance.collection('admins').doc(uid);
      final snap = await doc.get();
      if (!snap.exists) {
        await doc.set({
          'createdAt': FieldValue.serverTimestamp(),
          'note': 'Created automatically for app owner',
        });
        LoggerService.success('تم إضافة المستخدم كـ admin لِلوحة الإعلانات');
      }
    } catch (e) {
      LoggerService.warning('تعذر ضمان admin للمستخدم الحالي: $e');
    }
  }

  void _replaceList(RxList<String> target, List<String> source) {
    if (source.isNotEmpty) {
      target.assignAll(source);
    }
  }

  @override
  void onClose() {
    _sub?.cancel();
    _sub = null;
    super.onClose();
  }
}
