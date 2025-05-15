import 'package:peregrine_app_taha/models/accident_models.dart';
import 'package:peregrine_app_taha/services/auth_service.dart';
import 'package:peregrine_app_taha/utils/logger.dart';

/// Service for handling accident-related operations
class AccidentService {
  // API endpoints - to be configured based on actual backend
  // ignore: unused_field
  static const String _baseUrl = 'https://api.example.com'; // Replace with actual API URL
  // ignore: unused_field
  static const String _accidentsEndpoint = '/client/accidents';
  // ignore: unused_field
  static const String _accidentDetailsEndpoint = '/client/accidents/';
  
  /// Get all accident reports for the client
  static Future<AccidentReportsResponse> getAccidentReports() async {
    try {
      AppLogger.i('Fetching accident reports');
      
      // Get auth token for API request
      final token = await AuthService.getAuthToken();
      if (token == null) {
        return AccidentReportsResponse.error('غير مصرح لك بالوصول. الرجاء تسجيل الدخول مرة أخرى.');
      }
      
      // TODO: Replace with actual API call when backend is ready
      // For now, return mock data
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      return AccidentReportsResponse.success(_getMockAccidentReports());
    } catch (e) {
      AppLogger.e('Error fetching accident reports: $e');
      return AccidentReportsResponse.error('حدث خطأ أثناء تحميل البيانات');
    }
  }
  
  /// Get details of a specific accident report
  static Future<AccidentReport?> getAccidentDetails(String accidentId) async {
    try {
      AppLogger.i('Fetching accident details for ID: $accidentId');
      
      // Get auth token for API request
      final token = await AuthService.getAuthToken();
      if (token == null) {
        return null;
      }
      
      // TODO: Replace with actual API call when backend is ready
      // For now, return mock data
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate network delay
      
      final mockReports = _getMockAccidentReports();
      return mockReports.firstWhere(
        (report) => report.id == accidentId,
        orElse: () => throw Exception('Accident report not found'),
      );
    } catch (e) {
      AppLogger.e('Error fetching accident details: $e');
      return null;
    }
  }
  
  /// Submit a new accident report
  static Future<bool> submitAccidentReport({
    required String title,
    required String description,
    required String type,
    required DateTime dateTime,
    String? location,
    String? branchId,
    String? branchName,
    List<String> mediaUrls = const [],
  }) async {
    try {
      AppLogger.i('Submitting new accident report: $title');
      
      // Get auth token for API request
      final token = await AuthService.getAuthToken();
      if (token == null) {
        return false;
      }
      
      // TODO: Replace with actual API call when backend is ready
      // For now, simulate a successful submission
      await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
      
      return true;
    } catch (e) {
      AppLogger.e('Error submitting accident report: $e');
      return false;
    }
  }
  
  /// Get mock accident reports for testing
  static List<AccidentReport> _getMockAccidentReports() {
    return [
      AccidentReport(
        id: '1',
        title: 'سرقة معدات من المستودع',
        description: 'تم اكتشاف سرقة بعض المعدات من المستودع الرئيسي. المعدات المفقودة تشمل جهازي كمبيوتر محمول وثلاث شاشات. تم ملاحظة آثار كسر في القفل الخارجي للمستودع.',
        type: 'سرقة',
        dateTime: DateTime.now().subtract(const Duration(days: 2)),
        status: 'قيد المراجعة',
        location: 'المستودع الرئيسي - الطابق الأرضي',
        mediaUrls: ['https://example.com/image1.jpg'],
        comments: [
          AccidentComment(
            id: '1',
            content: 'تم استلام البلاغ وسيتم إرسال فريق للتحقيق',
            author: 'أحمد محمد',
            dateTime: DateTime.now().subtract(const Duration(days: 1, hours: 12)),
            isAdminComment: true,
          ),
          AccidentComment(
            id: '2',
            content: 'تم العثور على بعض الأدلة وجاري التحقيق',
            author: 'خالد عبدالله',
            dateTime: DateTime.now().subtract(const Duration(hours: 6)),
            isAdminComment: true,
          ),
        ],
      ),
      AccidentReport(
        id: '2',
        title: 'حريق في المطبخ',
        description: 'نشب حريق صغير في مطبخ الطابق الثاني بسبب ماس كهربائي في أحد الأجهزة. تم إخماد الحريق باستخدام طفاية الحريق قبل أن ينتشر.',
        type: 'حريق',
        dateTime: DateTime.now().subtract(const Duration(days: 5)),
        status: 'تم المعالجة',
        location: 'المطبخ - الطابق الثاني',
        mediaUrls: ['https://example.com/image2.jpg', 'https://example.com/image3.jpg'],
        comments: [
          AccidentComment(
            id: '3',
            content: 'تم إرسال فريق الصيانة لفحص التمديدات الكهربائية',
            author: 'سارة أحمد',
            dateTime: DateTime.now().subtract(const Duration(days: 4)),
            isAdminComment: true,
          ),
          AccidentComment(
            id: '4',
            content: 'تم استبدال الأسلاك التالفة وفحص جميع الأجهزة',
            author: 'محمد علي',
            dateTime: DateTime.now().subtract(const Duration(days: 3)),
            isAdminComment: true,
          ),
          AccidentComment(
            id: '5',
            content: 'تم إغلاق البلاغ بعد التأكد من سلامة المكان',
            author: 'سارة أحمد',
            dateTime: DateTime.now().subtract(const Duration(days: 2)),
            isAdminComment: true,
          ),
        ],
      ),
      AccidentReport(
        id: '3',
        title: 'دخول شخص غير مصرح له',
        description: 'تم رصد شخص غير معروف يحاول الدخول إلى مبنى الإدارة بعد ساعات العمل. قام الحارس بمنعه من الدخول وطلب منه مغادرة المكان.',
        type: 'دخول غير مصرح',
        dateTime: DateTime.now().subtract(const Duration(days: 1)),
        status: 'معلق',
        location: 'مبنى الإدارة - المدخل الرئيسي',
        comments: [
          AccidentComment(
            id: '6',
            content: 'تم مراجعة كاميرات المراقبة وجاري التحقق من هوية الشخص',
            author: 'فهد سعيد',
            dateTime: DateTime.now().subtract(const Duration(hours: 18)),
            isAdminComment: true,
          ),
        ],
      ),
      AccidentReport(
        id: '4',
        title: 'تخريب في موقف السيارات',
        description: 'تم العثور على بعض السيارات وقد تعرضت للخدوش والتخريب في موقف السيارات الخلفي. يبدو أن الحادث وقع خلال الليل.',
        type: 'تخريب',
        dateTime: DateTime.now().subtract(const Duration(days: 7)),
        status: 'مرفوض',
        location: 'موقف السيارات الخلفي',
        mediaUrls: ['https://example.com/image4.jpg'],
        comments: [
          AccidentComment(
            id: '7',
            content: 'بعد التحقيق تبين أن الخدوش ناتجة عن سوء الأحوال الجوية وليس تخريباً متعمداً',
            author: 'عبدالله محمد',
            dateTime: DateTime.now().subtract(const Duration(days: 6)),
            isAdminComment: true,
          ),
          AccidentComment(
            id: '8',
            content: 'تم رفض البلاغ لعدم وجود دليل على التخريب المتعمد',
            author: 'عبدالله محمد',
            dateTime: DateTime.now().subtract(const Duration(days: 5)),
            isAdminComment: true,
          ),
        ],
      ),
      AccidentReport(
        id: '5',
        title: 'إصابة موظف في المستودع',
        description: 'تعرض أحد الموظفين لإصابة طفيفة أثناء نقل بعض المعدات في المستودع. تم تقديم الإسعافات الأولية له ونقله للمستشفى للاطمئنان.',
        type: 'طارئ طبي',
        dateTime: DateTime.now().subtract(const Duration(days: 3)),
        status: 'تم المعالجة',
        location: 'المستودع الرئيسي',
        comments: [
          AccidentComment(
            id: '9',
            content: 'تم التواصل مع الموظف والاطمئنان على حالته',
            author: 'نورة سعد',
            dateTime: DateTime.now().subtract(const Duration(days: 2)),
            isAdminComment: true,
          ),
          AccidentComment(
            id: '10',
            content: 'تم إجراء تدريب للموظفين حول إجراءات السلامة في المستودع',
            author: 'نورة سعد',
            dateTime: DateTime.now().subtract(const Duration(days: 1)),
            isAdminComment: true,
          ),
        ],
      ),
    ];
  }
}