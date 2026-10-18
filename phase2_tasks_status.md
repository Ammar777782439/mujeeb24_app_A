# سجل حالة المهام — المرحلة الثانية من Mujeeb24

تاريخ التحديث: 2026-10-16
الإصدار المعتمد والمستخدم: Flutter 3.47.5 • Dart 3.13.4
المصادر المعتمدة:
1. `mujeeb24_flutter_production_plan.md` (المرحلة الثانية — مساحة التاجر الأساسية)
2. `mujeeb24-dashboard-v1.generated.yaml` (عقد OpenAPI في `D:\mujeeb24-backend-go\api\openapi\`)
3. `design.md` وملفات نظام تصميم Stitch في `stitch_mujeeb_24_mobile_design_system`

---

## جدول مهام المرحلة الثانية

| المعرف | وصف المهمة | المصدر | الملفات المتأثرة | الحالة | طريقة التحقق | دليل الإنجاز / النتيجة |
|---|---|---|---|---|---|---|
| P2-MOD-01 | نماذج البيانات للمرحلة الثانية (Dashboard, Policy, Conversations, Messages, Notes, Canned Replies) | OpenAPI Schemas | `lib/core/models/merchant_models.dart` | VERIFIED | Unit tests | فك وتركيب JSON لكافة النماذج الموثقة |
| P2-DSH-01 | خدمة ونموذج لوحة التحكم GET /businesses/{business_id}/dashboard/overview | OpenAPI /dashboard/overview | `lib/core/merchant/merchant_repository.dart` | VERIFIED | Integration & Mock tests | استرجاع المقاييس والقنوات بدقة وبدون مؤشرات وهمية |
| P2-BIZ-01 | استرجاع وتحديث بيانات النشاط GET & PATCH /businesses/{business_id} | OpenAPI /businesses/{business_id} | `lib/core/merchant/merchant_repository.dart` | VERIFIED | Integration tests | إرسال حقول `BusinessUpdateRequest` المسموحة فقط |
| P2-POL-01 | استرجاع وتحديث سياسة النشاط GET & PATCH /businesses/{business_id}/policy | OpenAPI /businesses/{business_id}/policy | `lib/core/merchant/merchant_repository.dart` | VERIFIED | Integration tests | استرجاع وتحديث `BusinessPolicyUpdateRequest` |
| P2-CNV-01 | قائمة المحادثات مع عوامل التصفية والترقيم GET /conversations | OpenAPI /conversations | `lib/core/merchant/merchant_repository.dart` | VERIFIED | Integration tests | دعم الترقيم بالـ cursor، والتصفية بالحالة والمالك والقناة |
| P2-CNV-02 | تفاصيل المحادثة وتعديلها GET & PATCH /conversations/{conversation_id} | OpenAPI /conversations/{id} | `lib/core/merchant/merchant_repository.dart` | VERIFIED | Integration tests | جلب تفاصيل المحادثة وتحديث الحالة والأولية والملكية |
| P2-MSG-01 | جلب رسائل المحادثة وإرسال رسالة GET & POST /messages | OpenAPI /messages | `lib/core/merchant/merchant_repository.dart` | VERIFIED | Integration tests | إرسال `SendMessageRequest` وتحديث القائمة بدون وهمية |
| P2-ASN-01 | إسناد المحادثة إلى عضو فريق POST /assign | OpenAPI .../assign | `lib/core/merchant/merchant_repository.dart` | VERIFIED | Integration tests | إرسال `AssignConversationRequest` ومعالجة الاستجابة |
| P2-LBL-01 | تحديث تصنيفات المحادثة POST /labels | OpenAPI .../labels | `lib/core/merchant/merchant_repository.dart` | VERIFIED | Integration tests | إرسال `LabelsRequest` بحقول add و remove |
| P2-NOT-01 | إضافة ملاحظة خاصة داخل المحادثة POST /notes | OpenAPI .../notes | `lib/core/merchant/merchant_repository.dart` | VERIFIED | Integration tests | إرسال `PrivateNoteRequest` والتمييز عن الرسائل العامة |
| P2-RED-01 | تعليم المحادثة كمقروءة POST /read | OpenAPI .../read | `lib/core/merchant/merchant_repository.dart` | VERIFIED | Integration tests | استدعاء نقطة النهاية عند فتح المحادثة وتحديث الحالة |
| P2-CNR-01 | جلب الردود الجاهزة وإرسالها GET /canned-replies & POST .../send | OpenAPI .../canned-replies | `lib/core/merchant/merchant_repository.dart` | VERIFIED | Integration tests | استرجاع القائمة وإرسال الرد المختار إلى المحادثة |
| P2-PRV-01 | إدارة الحالة للمرحلة الثانية (MerchantProvider) | بنية إدارة الحالة | `lib/features/merchant/providers/merchant_provider.dart` | VERIFIED | Unit / State tests | تنسيق البيانات، التخزين المؤقت، ومعالجة أخطاء API |
| P2-UI-DSH | واجهة لوحة التحكم التفاعلية للتاجر | Stitch `home_dashboard` | `lib/features/merchant/presentation/dashboard_tab.dart` | VERIFIED | Widget tests | عرض مؤشرات الأداء الحقيقية، القنوات، الإجراءات السريعة |
| P2-UI-INB | واجهة صندوق المحادثات وتصفيتها | Stitch `inbox` | `lib/features/merchant/presentation/inbox_tab.dart` | VERIFIED | Widget tests | عرض القائمة، شارات القنوات، الحالات، والبحث والتصفية |
| P2-UI-DET | واجهة تفاصيل المحادثة والرسائل والملاحظات | Stitch `_1` | `lib/features/merchant/presentation/conversation_detail_screen.dart` | VERIFIED | Widget tests | تبادل الرسائل، الملاحظات الخاصة، الإسناد، والتصنيفات |
| P2-UI-SET | واجهة بيانات النشاط والسياسات | الخطة §6.2 & §6.3 | `lib/features/merchant/presentation/business_settings_tab.dart` | VERIFIED | Widget tests | تعديل اسم النشاط والعملة، وإعدادات سياسة الذكاء الاصطناعي |
| P2-UI-NAV | شل الملاحة السفلي المتجاوب مع مساحة التاجر | design.md §4 | `lib/features/merchant/presentation/merchant_home_screen.dart` | VERIFIED | Widget tests | التنقل بين لوحة التحكم، المحادثات، والإعدادات |
| P2-TST-02 | حزمة الاختبارات الشاملة للمرحلة الثانية | ضمان الجودة §10 | `test/` | VERIFIED | flutter test & analyze | اجتياز جميع اختبارات الوحدات والتكامل والواجهات |
