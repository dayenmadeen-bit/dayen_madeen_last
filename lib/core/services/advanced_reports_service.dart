import 'package:get/get.dart';
// لا توجد رسوم بيانية حالياً
import '../../app/data/models/debt.dart';
import '../../app/data/models/payment.dart';
import '../../app/data/models/customer.dart';

/// خدمة التقارير المتقدمة والرسوم البيانية
class AdvancedReportsService extends GetxService {
  static AdvancedReportsService get instance =>
      Get.find<AdvancedReportsService>();

  /// تقرير الأرباح والخسائر
  Map<String, dynamic> generateProfitLossReport(
    List<Debt> debts,
    List<Payment> payments,
    DateTime fromDate,
    DateTime toDate,
  ) {
    final filteredDebts = debts
        .where((debt) =>
            debt.createdAt.isAfter(fromDate) && debt.createdAt.isBefore(toDate))
        .toList();

    final filteredPayments = payments
        .where((payment) =>
            payment.paymentDate.isAfter(fromDate) &&
            payment.paymentDate.isBefore(toDate))
        .toList();

    final totalDebts =
        filteredDebts.fold<double>(0, (sum, debt) => sum + debt.amount);
    final totalPayments = filteredPayments.fold<double>(
        0, (sum, payment) => sum + payment.amount);
    final totalOutstanding = filteredDebts.fold<double>(
        0, (sum, debt) => sum + debt.remainingAmount);

    final collectionRate =
        totalDebts > 0 ? (totalPayments / totalDebts) * 100 : 0;
    final profitMargin = totalPayments > 0
        ? ((totalPayments - totalOutstanding) / totalPayments) * 100
        : 0;

    return {
      'period': {
        'from': fromDate,
        'to': toDate,
      },
      'totals': {
        'debts': totalDebts,
        'payments': totalPayments,
        'outstanding': totalOutstanding,
        'netProfit': totalPayments - totalOutstanding,
      },
      'metrics': {
        'collectionRate': collectionRate,
        'profitMargin': profitMargin,
        'averageDebtSize':
            filteredDebts.isNotEmpty ? totalDebts / filteredDebts.length : 0,
        'averagePaymentSize': filteredPayments.isNotEmpty
            ? totalPayments / filteredPayments.length
            : 0,
      },
      'counts': {
        'totalDebts': filteredDebts.length,
        'totalPayments': filteredPayments.length,
        'paidDebts': filteredDebts.where((d) => d.status == 'paid').length,
        'overdueDebts':
            filteredDebts.where((d) => d.status == 'overdue').length,
      },
    };
  }

  /// تحليل سلوك العملاء
  Map<String, dynamic> analyzeCustomerBehavior(
    List<Customer> customers,
    List<Debt> debts,
    List<Payment> payments,
  ) {
    final customerAnalysis = <String, Map<String, dynamic>>{};

    for (final customer in customers) {
      final customerDebts =
          debts.where((d) => d.customerId == customer.id).toList();
      final customerPayments =
          payments.where((p) => p.customerId == customer.id).toList();

      final totalDebts =
          customerDebts.fold<double>(0, (sum, debt) => sum + debt.amount);
      final totalPayments = customerPayments.fold<double>(
          0, (sum, payment) => sum + payment.amount);
      final avgPaymentTime =
          _calculateAveragePaymentTime(customerDebts, customerPayments);

      customerAnalysis[customer.id] = {
        'customer': customer,
        'totalDebts': totalDebts,
        'totalPayments': totalPayments,
        'outstandingAmount': totalDebts - totalPayments,
        'paymentRate': totalDebts > 0 ? (totalPayments / totalDebts) * 100 : 0,
        'averagePaymentTime': avgPaymentTime,
        'riskLevel': _calculateRiskLevel(customerDebts, customerPayments),
        'lastActivity': _getLastActivity(customerDebts, customerPayments),
        'debtCount': customerDebts.length,
        'paymentCount': customerPayments.length,
      };
    }

    // ترتيب العملاء حسب المخاطر
    final sortedCustomers = customerAnalysis.entries.toList()
      ..sort((a, b) => b.value['riskLevel'].compareTo(a.value['riskLevel']));

    return {
      'customerAnalysis': Map.fromEntries(sortedCustomers),
      'summary': {
        'totalCustomers': customers.length,
        'activeCustomers':
            customerAnalysis.values.where((c) => c['totalDebts'] > 0).length,
        'highRiskCustomers':
            customerAnalysis.values.where((c) => c['riskLevel'] >= 7).length,
        'averagePaymentRate': customerAnalysis.values.isNotEmpty
            ? customerAnalysis.values
                    .map((c) => c['paymentRate'] as double)
                    .reduce((a, b) => a + b) /
                customerAnalysis.length
            : 0,
      },
    };
  }

  /// تم حذف مولد الرسوم البيانية - يعاد استخدام الخدمة للتقارير النصية فقط

  /// تم حذف الرسوم البيانية الدائرية

  /// تم حذف الرسوم البيانية بالأعمدة

  /// حساب متوسط وقت الدفع
  double _calculateAveragePaymentTime(
      List<Debt> debts, List<Payment> payments) {
    if (debts.isEmpty || payments.isEmpty) return 0;

    double totalDays = 0;
    int count = 0;

    for (final debt in debts) {
      final debtPayments = payments.where((p) => p.debtId == debt.id).toList();
      if (debtPayments.isNotEmpty) {
        final firstPayment = debtPayments
            .reduce((a, b) => a.paymentDate.isBefore(b.paymentDate) ? a : b);
        totalDays += firstPayment.paymentDate.difference(debt.createdAt).inDays;
        count++;
      }
    }

    return count > 0 ? totalDays / count : 0;
  }

  /// حساب مستوى المخاطر
  int _calculateRiskLevel(List<Debt> debts, List<Payment> payments) {
    if (debts.isEmpty) return 0;

    final totalDebts = debts.fold<double>(0, (sum, debt) => sum + debt.amount);
    final totalPayments =
        payments.fold<double>(0, (sum, payment) => sum + payment.amount);
    final paymentRate =
        totalDebts > 0 ? (totalPayments / totalDebts) * 100 : 100;

    final overdueDebts = debts.where((d) => d.status == 'overdue').length;
    final overdueRate = (overdueDebts / debts.length) * 100;

    // حساب المخاطر بناءً على معدل الدفع والديون المتأخرة
    if (paymentRate >= 90 && overdueRate <= 10) return 1; // منخفض
    if (paymentRate >= 70 && overdueRate <= 25) return 3; // متوسط منخفض
    if (paymentRate >= 50 && overdueRate <= 40) return 5; // متوسط
    if (paymentRate >= 30 && overdueRate <= 60) return 7; // متوسط عالي
    return 9; // عالي
  }

  /// الحصول على آخر نشاط
  DateTime? _getLastActivity(List<Debt> debts, List<Payment> payments) {
    DateTime? lastActivity;

    for (final debt in debts) {
      if (lastActivity == null || debt.createdAt.isAfter(lastActivity)) {
        lastActivity = debt.createdAt;
      }
    }

    for (final payment in payments) {
      if (lastActivity == null || payment.paymentDate.isAfter(lastActivity)) {
        lastActivity = payment.paymentDate;
      }
    }

    return lastActivity;
  }

  /// حساب عدد الأشهر منذ تاريخ معين
  // لا حاجة لهذه الدالة بعد إزالة الرسوم البيانية
}
