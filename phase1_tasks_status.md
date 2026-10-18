# سجل حالة المهام — المرحلة الأولى من Mujeeb24

تاريخ التحديث: 2026-10-14
الإصدار المعتمد والمستخدم: Flutter 3.47.5 • Dart 3.13.4
المصادر المعتمدة:
1. `mujeeb24_flutter_production_plan.md`
2. `mujeeb24-dashboard-v1.generated.yaml` (الموجود في `D:\mujeeb24-backend-go\api\openapi\`)
3. `design.md` و Stitch Design System الموجود في مجلد `stitch_mujeeb_24_mobile_design_system`

---

## جدول حالة المهام

| المعرف | وصف المهمة | المصدر | الملفات المتأثرة | الحالة | طريقة التحقق | دليل الإنجاز / النتيجة |
|---|---|---|---|---|---|---|
| P1-ENV-01 | التحقق من بيئة Flutter و Dart وتوافقها | البرومبت §3 + خطة المرحلة 1 | `pubspec.yaml` | VERIFIED | `flutter --version`, `dart --version` | Flutter 3.47.5, Dart 3.13.4 (كود الخروج 0) |
| P1-ENV-02 | تهيئة مشروع Flutter وبنية المجلدات الرسمية | خطة الإنتاج §4 | `lib/` | VERIFIED | هيكل المجلدات lib/core, lib/app, lib/features | البنية كاملة ومفصولة ومطابقة للمواصفات |
| P1-ERR-01 | نماذج الخطأ ومعالجة ErrorEnvelope و request_id | OpenAPI `#ErrorEnvelope` | `lib/core/errors/api_error.dart` | VERIFIED | Unit tests في `models_and_errors_test.dart` | نجاح تحليل `ErrorEnvelope`, `ErrorBody`, `fields`, `request_id` |
| P1-NET-01 | عميل الشبكة المخصص وإدارة Cookie/Bearer | OpenAPI + الخطة §2, §5.4 | `lib/core/api/api_client.dart` | VERIFIED | Integration tests في `api_and_repositories_test.dart` | دعم Bearer Auth، استخراج وتمرير Cookie `mujeeb_refresh` |
| P1-MOD-01 | نماذج المصادقة والمستخدم والأنشطة والدعوات | OpenAPI Schemas | `lib/core/models/auth_models.dart` | VERIFIED | Unit tests في `models_and_errors_test.dart` | نماذج `Principal`, `AuthResponse`, `Business`, `BusinessMembership`, `TeamInvitation` |
| P1-AUT-01 | خدمة ومنطق تسجيل الدخول POST /auth/login | OpenAPI `/auth/login` | `lib/core/auth/auth_repository.dart` | VERIFIED | Integration & Mock tests | إرسال email/password، استقبال 200 و 401، واستخراج التوكن |
| P1-AUT-02 | خدمة ومنطق تحديث الجلسة POST /auth/refresh | OpenAPI `/auth/refresh` | `lib/core/auth/auth_repository.dart` | VERIFIED | Integration tests | إرسال `Cookie: mujeeb_refresh` واستقبال التوكن المحدث وتدويره |
| P1-AUT-03 | خدمة ومنطق تسجيل الخروج POST /auth/logout | OpenAPI `/auth/logout` | `lib/core/auth/auth_repository.dart` | VERIFIED | Integration tests | استدعاء الخادم وتفريغ الجلسة المحلية بالكامل |
| P1-ME-01 | خدمة استرجاع هوية المستخدم GET /me | OpenAPI `/me` | `lib/core/auth/auth_repository.dart` | VERIFIED | Integration tests | فك ترميز `Principal` من رد الخادم |
| P1-BUS-01 | خدمة استرجاع الأنشطة GET /me/businesses | OpenAPI `/me/businesses` | `lib/core/auth/workspace_repository.dart` | VERIFIED | Integration tests | استرجاع قائمة العضويات والصلاحيات المخصصة |
| P1-INV-01 | فحص وقبول الدعوات /auth/invitations | OpenAPI `/auth/invitations/*` | `lib/core/auth/auth_repository.dart` | VERIFIED | Integration tests | فحص الرمز، قبول حساب جديد، وقبول عضو حالي |
| P1-UI-01 | الثيم والتصميم المتوافق مع Stitch | design.md + Stitch system | `lib/app/theme/app_theme.dart` | VERIFIED | Analysis & Widget tests | ألوان Mujeeb24 الأساسية، بطاقات، حقول الإدخال والأزرار |
| P1-UI-02 | التعريب ودعم RTL/LTR | متطلبات الواجهة | `lib/app/localization/app_localizations.dart` | VERIFIED | Widget tests | قاموس نصوص بالعربية والإنجليزية مع تبديل الاتجاه |
| P1-UI-03 | شاشة تسجيل الدخول التفاعلية وحالاتها | stitch design system/login | `lib/features/auth/presentation/login_screen.dart` | VERIFIED | Widget tests في `login_screen_test.dart` | الحالات: الابتدائية، التحقق، تعبئة تجريبية، خطأ الخادم، النجاح |
| P1-UI-04 | شاشة فحص وقبول الدعوات | الخطة §5.8 | `lib/features/auth/presentation/invitation_screen.dart` | VERIFIED | Flutter analyze & compile | فحص الرمز وعرض بيانات النشاط وإكمال الحساب |
| P1-UI-05 | شاشة اختيار النشاط ومساحة العمل | الخطة §5.7 | `lib/features/workspace/presentation/business_selection_screen.dart` | VERIFIED | Flutter analyze & compile | عرض الأنشطة، حالة الفراغ، واختيار مساحة العمل |
| P1-ROU-01 | الملاحة وحالات التطبيق والجلسة | الخطة §5.2 | `lib/app/app.dart` | VERIFIED | Flutter analyze & build bundle | إدارة المسارات والحالة التلقائية بناءً على الجلسة والأنشطة |
| P1-TST-01 | حزمة الاختبارات الشاملة والتحليل | متطلبات ضمان الجودة §8 | `test/` | VERIFIED | `flutter test` & `flutter analyze` | 19 اختبار ناجح بنسبة 100%، 0 أخطاء تحليل |
