# خطة إنتاج تطبيق Mujeeb 24 باستخدام Flutter

## 1. نطاق الوثيقة ومصدر الحقيقة

- **المصدر الوحيد للتحليل:** الملف المرفق `mujeeb24-dashboard-v1.generated.yaml`.
- **اسم عقد API:** `Mujeeb 24 Dashboard API`.
- **إصدار عقد API:** `1.0.0`.
- **إصدار OpenAPI:** `3.0.3`.
- **المسار الأساسي المعرّف في الملف:** `/api/v1`.
- **عدد المسارات:** 125.
- **عدد العمليات HTTP الموثقة:** 151.
- **لغة تطبيق العميل المطلوبة:** Flutter / Dart، لكن **الملف لا يحدد إصدار Flutter أو Dart**؛ لذلك لا أنسب إليه رقم إصدار غير موجود في المصدر. يجب تثبيت إصدار Flutter المعتمد عند بدء التنفيذ وتوثيقه في إعدادات المشروع.
- لا تتضمن هذه الخطة ميزات منتج جديدة. أسماء الشاشات ومراحل التنفيذ أدناه هي تنظيم تنفيذي للعمليات والكيانات الموجودة في عقد API فقط.

> **قاعدة تنفيذ:** لا تُنشأ شاشة أو وظيفة أو endpoint غير موجود في العقد. إذا احتاجت واجهة إلى معلومة أو عملية لا يوفّرها العقد، تُسجّل كفجوة موثقة ولا يتم اختراع API بديلة.

## 2. ما يثبته الملف عن الاتصال والمصادقة

- المصادقة تستخدم `Bearer JWT`، ويصف الملف الرمز بأنه EdDSA/Ed25519.
- توجد جلسة تحديث عبر Cookie باسم `mujeeb_refresh` موصوفة بأنها `HttpOnly` وopaque.
- توجد عمليات تسجيل الدخول والخروج وتحديث الجلسة وقبول الدعوات وفحص رمز الدعوة.
- استجابة المصادقة تحتوي على `access_token` و`token_type` و`expires_at` و`is_platform_admin` و`principal`.
- توجد صلاحيات عضوية النشاط التجاري، ومن ضمنها صلاحيات القراءة والكتابة للمحادثات والعملاء والكتالوج والمبيعات والفريق والقنوات والذكاء الاصطناعي وسجل التدقيق.
- لا يحدد الملف تفاصيل التخزين الآمن داخل Flutter، أو سياسة تجديد الجلسة على مستوى التطبيق، أو آلية الإشعارات الفورية؛ لذلك لا تُفترض هذه التفاصيل كوظائف مكتملة في العقد.

## 3. حدود التطبيق بحسب العقد

### 3.1 مساحة التاجر

تُبنى واجهات التاجر على عمليات:
- تسجيل الدخول وهوية المستخدم والأنشطة التجارية التي يمكنه الوصول إليها.
- نظرة عامة للوحة التحكم.
- المحادثات والرسائل والملاحظات الخاصة والإسناد والتصنيفات والردود الجاهزة.
- العملاء ودمج العملاء وسجل محادثاتهم ومعاملاتهم.
- العملاء المحتملون (Leads) والتأهيل والتسجيل كخسارة ودرجات العميل ومصادر الإسناد.
- المعاملات التجارية ومسوداتها ومراجعتها واعتمادها أو رفضها أو إلغاؤها.
- الكتالوج وعناصره ومتغيراته وعروضه ومخططات السمات.
- اتصالات القنوات وإعادة الاتصال وفصل الاتصال وفحص القدرات وإدارة سجل المحادثات المحلي المرتبط بالقناة.
- سياسات النشاط التجاري وسلوك الذكاء الاصطناعي وقراراته وطلب مراجعة بشرية.
- قواعد الأتمتة والردود الجاهزة.
- أعضاء الفريق والدعوات والأدوار والصلاحيات.
- أحداث التدقيق الخاصة بالنشاط التجاري.

### 3.2 مساحة إدارة المنصة

يحتوي العقد أيضًا على عمليات إدارية للمنصة، تشمل:
- الأنشطة التجارية: الإنشاء، العرض، الإسناد إلى مالك، التعليق، إعادة التفعيل والأرشفة.
- القنوات ومزودي الخدمة وفحوصات الصحة.
- إعدادات مزودي الذكاء الاصطناعي وبيانات الاعتماد والنماذج واختبار الاتصال، وإعدادات التشغيل وحدود الإدخال والإخراج.
- خطط الاشتراك وإصدارات الخطط وتفعيلها وإيقافها.
- الاشتراكات والمدفوعات والاستخدام وميزانية تكلفة الذكاء الاصطناعي.
- تذاكر الدعم ورسائلها وحالاتها.
- سجل تدقيق المنصة واستخدام الذكاء الاصطناعي على مستوى المنصة.

هذه الواجهات لا تظهر إلا في مساحة وصلاحيات إدارة المنصة، ولا تُعرض لمستخدم التاجر العادي.

### 3.3 عمليات ليست شاشات مستخدم نهائية

- `GET /health/live` و`GET /health/ready`: فحوصات تشغيلية.
- `GET /metrics`: مؤشرات تشغيلية داخلية.
- `POST /webhooks/socialapi/{route_key}`: استقبال Webhook من مزود خارجي.
- لا تُعامل هذه العمليات كشاشات مستخدم؛ تظل ضمن التكامل والتشغيل.

## 4. بنية Flutter المقترحة للتنفيذ

هذه بنية تنظيم للكود وليست إضافة وظائف منتج:

```text
lib/
  app/
    app.dart
    router.dart
    localization/
    theme/
  core/
    api/
    auth/
    errors/
    permissions/
    models/
  features/
    auth/
    workspace/
    dashboard/
    conversations/
    customers/
    leads/
    transactions/
    catalog/
    channels/
    merchant_ai/
    automation/
    team/
    business_settings/
    audit/
    platform/
```

- افصل استدعاءات HTTP عن واجهات العرض.
- اربط كل شاشة بالعمليات الموثقة المناسبة فقط.
- حافظ على أسماء الحقول والأنواع والقيم enum كما وردت في OpenAPI، مع تحويل العرض للمستخدم عند الحاجة دون تغيير قيم API.
- استخدم `resource_version` حيث يظهر في نماذج الموارد؛ افحص العقد لكل عملية تحديث لمعرفة طريقة تمريره بدل افتراض آلية موحدة.
- طبّق إظهار/إخفاء عناصر الواجهة وفق الصلاحيات المعادة من عضوية النشاط التجاري، مع اعتبار تحقق الخادم هو الحسم النهائي.
- العربية والإنجليزية وتخطيط RTL/LTR مطلب واجهة تنفيذية، لكن الملف لا يحدد نصوص الترجمة أو خطوطًا أو ألوانًا؛ لا تُختلق هوية بصرية من هذا الملف.

## 5. خريطة الشاشات وتدفقات الاستخدام

### A. الدخول والتهيئة
1. تسجيل الدخول — `POST /auth/login`.
2. فحص دعوة — `POST /auth/invitations/inspect`.
3. قبول دعوة مستخدم جديد — `POST /auth/invitations/accept-new-account`.
4. قبول دعوة لعضو موجود — `POST /team/invitations/accept`.
5. جلب المستخدم الحالي — `GET /me`.
6. جلب الأنشطة التجارية المتاحة — `GET /me/businesses`.
7. تجديد الجلسة والخروج — `POST /auth/refresh` و`POST /auth/logout`.

**التدفق:** دخول ← قراءة هوية المستخدم ← قراءة الأنشطة التجارية المسموح بها ← اختيار النشاط عند الحاجة ← تحميل واجهات النشاط بحسب الصلاحيات.

### B. لوحة التاجر
- نظرة عامة — `GET /businesses/{business_id}/dashboard/overview`.
- بيانات النشاط التجاري — `GET /businesses/{business_id}`.
- تعديل بيانات النشاط — `PATCH /businesses/{business_id}`.
- سياسة النشاط — `GET/PATCH /businesses/{business_id}/policy`.

### C. صندوق المحادثات
- قائمة المحادثات — `GET /businesses/{business_id}/conversations`.
- تفاصيل محادثة — `GET /businesses/{business_id}/conversations/{conversation_id}`.
- الرسائل — `GET/POST /businesses/{business_id}/conversations/{conversation_id}/messages`.
- إسناد محادثة — `POST .../assign`.
- تعديل حالة/بيانات المحادثة — `PATCH .../{conversation_id}`.
- تحديث التصنيفات — `POST .../labels`.
- إضافة ملاحظة خاصة — `POST .../notes`.
- تعليم المحادثة كمقروءة — `POST .../read`.
- إرسال رد جاهز — `POST .../canned-replies/{canned_reply_id}/send`.

**التدفق:** قائمة المحادثات ← فتح محادثة ← تحميل تفاصيلها ورسائلها ← قراءة المحادثة ← إرسال رسالة أو ملاحظة خاصة أو تغيير الإسناد/التصنيفات بحسب الصلاحيات.

### D. العملاء
- قائمة العملاء وإنشاء عميل — `GET/POST /businesses/{business_id}/customers`.
- تفاصيل وتحديث العميل — `GET/PATCH .../customers/{customer_id}`.
- محادثات العميل — `GET .../customers/{customer_id}/conversations`.
- معاملات العميل — `GET .../customers/{customer_id}/transactions`.
- دمج العملاء — `POST .../customers/{customer_id}/merge`.

### E. العملاء المحتملون
- قائمة/إنشاء/عرض/تحديث Lead.
- تأهيل Lead — `POST .../leads/{lead_id}/qualify`.
- تعليم Lead كخاسر — `POST .../leads/{lead_id}/mark-lost`.
- الدرجات والإسنادات — `GET .../scores` و`GET .../attributions`.

### F. المعاملات
- قائمة وإنشاء مسودة — `GET/POST /businesses/{business_id}/transactions`.
- تفاصيل وتحديث المسودة — `GET/PATCH .../transactions/{transaction_id}`.
- إرسال للمراجعة — `POST .../submit-review`.
- قراءة المراجعة — `GET .../reviews`.
- اعتماد أو رفض المراجعة — `POST .../reviews/approve` و`POST .../reviews/reject`.
- تأكيد أو إلغاء المعاملة — `POST .../confirm` و`POST .../cancel`.

**التدفق:** إنشاء مسودة ← تحديث البنود ← إرسال للمراجعة عند الحاجة ← عرض نتيجة المراجعة ← اعتماد/رفض أو تأكيد/إلغاء بحسب الحالة والصلاحية. لا تفترض أن كل انتقال متاح في كل حالة؛ التزم باستجابة API.

### G. الكتالوج
- قوائم الكتالوج وإنشاؤها وتفاصيلها وتعديلها.
- قائمة عناصر الكتالوج وإنشاء عنصر وعرضه وتحديثه.
- مخططات السمات وقراءة عقد قيم الكتالوج.
- المتغيرات والعروض: عرض وإنشاء وتحديث ما تدعمه العمليات.
- مساعد كتالوج التاجر: `POST .../merchant-ai/turns`، ثم تنفيذ مقترح مخزّن عبر `POST .../merchant-ai/executions`.

**التدفق:** اختيار كتالوج ← قائمة العناصر ← تفاصيل العنصر/إنشاءه أو تعديله ← إدارة المتغيرات والعروض. بالنسبة إلى مقترح الذكاء الاصطناعي، لا تنفّذ المقترح إلا عبر عملية التنفيذ الموثقة وبعد موافقة المستخدم وفق تدفق العقد.

### H. القنوات
- قائمة الاتصالات وتفاصيلها وقدراتها.
- بدء الاتصال — `POST .../channel-connections`.
- إعادة الاتصال أو الفصل.
- معاينة حذف سجل المحادثات المحلي ثم تأكيد العملية الصريحة عند طلب الحذف.

**تنبيه من العقد:** حذف سجل المحادثات المحلي عملية غير قابلة للعكس. يجب عرض نتيجة المعاينة والتحذير الواضح قبل تنفيذ `POST .../history-purge`، دون اعتبارها مجرد فصل للقناة.

### I. الذكاء الاصطناعي والأتمتة
- قائمة قرارات الذكاء الاصطناعي وتفاصيل القرار.
- طلب مراجعة بشرية.
- عرض/تعديل سياسة الذكاء الاصطناعي الخاصة بالنشاط.
- عرض وإنشاء وتحديث قواعد الأتمتة وفق أنواع المشغلات والأفعال التي يقبلها العقد.
- عرض/إنشاء/تحديث الردود الجاهزة.

### J. الفريق والتدقيق
- قائمة أعضاء الفريق والدعوات.
- إنشاء دعوة وإعادة إرسالها وإلغاؤها.
- تحديث الدور والصلاحيات أو إلغاء عضوية عضو وفق القيود في العقد.
- قائمة أحداث التدقيق وتفاصيل الحدث.

### K. إدارة المنصة
- الأعمال التجارية وحالاتها ومالكها.
- القنوات ومزودو الخدمة وفحوصات الصحة.
- إعدادات AI ومزودوه واعتماداته ونماذجه واختبارات الاتصال.
- الخطط وإصداراتها.
- الاشتراكات والمدفوعات والاستخدام وميزانيات التكلفة.
- تذاكر الدعم ورسائلها وحالاتها.
- تدقيق المنصة.

## 6. خطة الإنتاج على مراحل

المراحل أدناه ترتيب تنفيذ لتغطية العقد، وليست وعدًا بمدة محددة. لا يحتوي الملف على حجم فريق أو ميزانية أو موعد إطلاق، لذلك لا أضع تقديرات زمنية مختلقة.

### المرحلة 0 — تثبيت العقد والتحقق
- اعتماد ملف OpenAPI المرفق كمصدر API.
- مراجعة المسارات، نماذج الطلب والاستجابة، enums، الحقول المطلوبة، رموز الخطأ والصلاحيات.
- تحديد إصدار Flutter/Dart الذي سيُعتمد في مستودع التطبيق؛ الإصدار غير موجود في ملف المصدر.
- تحديد متغيرات بيئة التطوير والاختبار والإنتاج دون تضمين أسرار في تطبيق العميل.
- مخرجات المرحلة: سجل ربط كل شاشة بعمليات API، وقائمة أي نقاط غير محسومة في العقد.

### المرحلة 1 — أساس التطبيق والمصادقة
- إعداد مشروع Flutter والبنية الأساسية والملاحة والتعريب.
- تنفيذ login، refresh، logout، current principal، accessible businesses.
- معالجة أخطاء API باستخدام شكل `ErrorEnvelope` و`request_id`.
- اختبارات تدفقات الجلسة والدخول وقبول الدعوات.

### المرحلة 2 — مساحة التاجر الأساسية
- لوحة التحكم.
- بيانات النشاط وسياساته.
- المحادثات والرسائل والملاحظات والإسناد والتصنيفات والردود الجاهزة.
- اختبارات صلاحيات القراءة والرد والإسناد وحالات عدم وجود بيانات والأخطاء.

### المرحلة 3 — العملاء والعملاء المحتملون
- العملاء وتفاصيلهم ووسائل الاتصال ودمج العملاء.
- محادثات ومعاملات العميل.
- Leads والتأهيل والخسارة والدرجات والإسنادات.
- اختبارات العلاقات بين العميل والمحادثة والـ Lead والمعاملة وفق المعرفات التي يعيدها الخادم.

### المرحلة 4 — المعاملات والمراجعات
- مسودات المعاملات وبنودها وتحديثها.
- إرسال المعاملة للمراجعة وقراءة المراجعة والاعتماد والرفض والتأكيد والإلغاء.
- اختبار حالات التعارض والحالات غير المسموحة حسب رد الخادم.
- عدم إنشاء حالات أعمال غير معرفة في العقد.

### المرحلة 5 — الكتالوج
- الكتالوجات وعناصرها ومخططات السمات.
- المتغيرات والعروض وعقد قيم الكتالوج.
- مساعد الذكاء الاصطناعي للكتالوج وتنفيذ المقترحات.
- اختبارات إنشاء وتعديل العناصر والنسخ والحقول المطلوبة بحسب نماذج OpenAPI.

### المرحلة 6 — القنوات والأتمتة والذكاء الاصطناعي
- بدء الاتصال ومتابعة الحالة والقدرات وإعادة الاتصال والفصل.
- معاينة حذف سجل القناة والحذف الصريح بعد تأكيد المستخدم.
- قرارات AI وطلب المراجعة البشرية وسياسات AI.
- قواعد الأتمتة والردود الجاهزة.
- اختبارات انقطاع القناة، الأخطاء، الصلاحيات، والعمليات غير القابلة للعكس.

### المرحلة 7 — الفريق والتدقيق
- الدعوات وأعضاء الفريق والأدوار والصلاحيات والإلغاء.
- سجل تدقيق النشاط التجاري.
- اختبارات أن المالك النشط لا يُلغى بطريقة تخالف قيد العقد، وأن واجهات الإدارة لا تتجاوز الصلاحيات.

### المرحلة 8 — مساحة إدارة المنصة
- تنفيذ شاشات المنصة المقابلة لمجموعات `Platform.*`.
- قصرها على المستخدم الذي يشير رد المصادقة إلى أنه مسؤول منصة، مع بقاء تحقق الخادم هو المرجع.
- تضمين الأعمال التجارية والقنوات والمزودين وإعدادات AI والخطط والاشتراكات والمدفوعات والدعم والتدقيق.
- اختبارات الأدوار والوصول المرفوض والتغييرات الحساسة.

### المرحلة 9 — التحقق قبل الإطلاق
- اختبار كل عملية API مستخدمة مقابل العقد.
- اختبار العربية RTL والإنجليزية LTR وتبديل اللغة دون تغيير قيم API.
- اختبار أحجام الشاشات وحالات التحميل والفراغ والخطأ وإعادة المحاولة.
- اختبار صلاحيات المستخدم، انتهاء الجلسة، الشبكة المنقطعة، وأخطاء الخادم.
- اختبار تدفقات العمليات الحساسة: حذف سجل القناة، اعتماد المعاملة، تغييرات الفريق، إعدادات AI.
- التحقق من أن الشاشات لا تعرض حقولًا أو إجراءات غير مدعومة.
- إعداد إصدار بناءً على نسخة Flutter المعتمدة فعليًا؛ لا يمكن تحديد رقم إصدار من الملف المرفق.

## 7. شروط القبول

يُعد التنفيذ مطابقًا لهذه الخطة عندما:
1. تكون كل شاشة مرتبطة بعملية موثقة في ملف OpenAPI.
2. لا توجد وظائف أو مسارات API مخترعة.
3. تتطابق أسماء الحقول وأنواعها والقيم المرسلة مع العقد.
4. تُحترم الصلاحيات والقيود المعادة من الخادم.
5. تُعرض الأخطاء وفق بنية الخطأ الموثقة مع الاحتفاظ بـ `request_id` للتشخيص.
6. تُحمى العمليات غير القابلة للعكس بتدفق تأكيد واضح.
7. تعمل الواجهات بالعربية والإنجليزية مع اتجاه التخطيط الصحيح.
8. تبقى عمليات التشغيل والـ webhooks خارج واجهات المستخدم النهائية.

## 8. ما لا يمكن حسمه من الملف وحده

- إصدار Flutter وDart المطلوب.
- نظام إدارة الحالة أو مكتبات الشبكة التي يجب استخدامها.
- تفاصيل تصميم الموقع، الألوان، الخطوط، الأيقونات، والأصول البصرية.
- سياسة التخزين الآمن وتفاصيل تجديد Cookie على كل منصة.
- آلية التحديث الفوري للرسائل أو الإشعارات.
- مواعيد التنفيذ، حجم الفريق، والميزانية.
- أي endpoint أو ميزة غير مدرجة في العقد.

لا تُعامل هذه النقاط على أنها ميزات مطلوب بناؤها؛ إنها معلومات غير محددة في المصدر.

## 9. جرد عمليات API كما وردت في الملف

هذا الجرد يربط الخطة مباشرةً بالعمليات الموثقة في المصدر، دون إضافة عمليات جديدة.

### Auth
- `POST /auth/invitations/accept-new-account` — Create a new principal from a valid invitation
- `POST /auth/invitations/inspect` — Inspect a one-time invitation token
- `POST /auth/login` — Authenticate and issue JWT access token
- `POST /auth/logout` — Revoke refresh session
- `POST /auth/refresh` — Rotate refresh session

### Me
- `GET /me` — Get the authenticated principal
- `GET /me/businesses` — List businesses accessible to the principal

### Business
- `GET /businesses/{business_id}` — Get a business projection
- `PATCH /businesses/{business_id}` — Update editable business profile fields
- `GET /businesses/{business_id}/policy` — Get business policy
- `PATCH /businesses/{business_id}/policy` — Update business policy

### Dashboard
- `GET /businesses/{business_id}/dashboard/overview` — Get the merchant dashboard overview

### Conversations
- `GET /businesses/{business_id}/conversations` — List merchant conversations
- `GET /businesses/{business_id}/conversations/{conversation_id}` — Get a conversation projection
- `PATCH /businesses/{business_id}/conversations/{conversation_id}` — Update conversation
- `POST /businesses/{business_id}/conversations/{conversation_id}/assign` — Assign conversation
- `POST /businesses/{business_id}/conversations/{conversation_id}/labels` — Update conversation labels
- `GET /businesses/{business_id}/conversations/{conversation_id}/messages` — List conversation messages
- `POST /businesses/{business_id}/conversations/{conversation_id}/messages` — Create an outbound message intent
- `POST /businesses/{business_id}/conversations/{conversation_id}/notes` — Add private note
- `POST /businesses/{business_id}/conversations/{conversation_id}/read` — Mark conversation read for current principal

### Inbox
- `GET /businesses/{business_id}/automation-rules` — List constrained inbound automation rules
- `POST /businesses/{business_id}/automation-rules` — Create constrained inbound automation rule
- `PATCH /businesses/{business_id}/automation-rules/{automation_rule_id}` — Update constrained inbound automation rule
- `GET /businesses/{business_id}/canned-replies` — List reusable merchant replies
- `POST /businesses/{business_id}/canned-replies` — Create reusable merchant reply
- `PATCH /businesses/{business_id}/canned-replies/{canned_reply_id}` — Update reusable merchant reply
- `POST /businesses/{business_id}/conversations/{conversation_id}/canned-replies/{canned_reply_id}/send` — Queue a reusable reply for delivery

### Customers
- `GET /businesses/{business_id}/customers` — List customers
- `POST /businesses/{business_id}/customers` — Create a customer
- `GET /businesses/{business_id}/customers/{customer_id}` — Get a customer projection
- `PATCH /businesses/{business_id}/customers/{customer_id}` — Update customer
- `GET /businesses/{business_id}/customers/{customer_id}/conversations` — List customer conversations
- `POST /businesses/{business_id}/customers/{customer_id}/merge` — Merge customer
- `GET /businesses/{business_id}/customers/{customer_id}/transactions` — List customer transactions

### Leads
- `GET /businesses/{business_id}/leads` — List leads
- `POST /businesses/{business_id}/leads` — Create lead
- `GET /businesses/{business_id}/leads/{lead_id}` — Get lead
- `PATCH /businesses/{business_id}/leads/{lead_id}` — Update lead
- `GET /businesses/{business_id}/leads/{lead_id}/attributions` — List lead attributions
- `POST /businesses/{business_id}/leads/{lead_id}/mark-lost` — Mark lead lost
- `POST /businesses/{business_id}/leads/{lead_id}/qualify` — Qualify lead
- `GET /businesses/{business_id}/leads/{lead_id}/scores` — List lead scores

### Transactions
- `GET /businesses/{business_id}/transactions` — List transactions
- `POST /businesses/{business_id}/transactions` — Create transaction draft
- `GET /businesses/{business_id}/transactions/{transaction_id}` — Get transaction
- `PATCH /businesses/{business_id}/transactions/{transaction_id}` — Update transaction draft
- `POST /businesses/{business_id}/transactions/{transaction_id}/cancel` — Cancel transaction
- `POST /businesses/{business_id}/transactions/{transaction_id}/confirm` — Confirm transaction
- `GET /businesses/{business_id}/transactions/{transaction_id}/reviews` — Get transaction review
- `POST /businesses/{business_id}/transactions/{transaction_id}/reviews/approve` — Approve transaction review
- `POST /businesses/{business_id}/transactions/{transaction_id}/reviews/reject` — Reject transaction review
- `POST /businesses/{business_id}/transactions/{transaction_id}/submit-review` — Submit transaction review

### Catalog
- `GET /businesses/{business_id}/attribute-schemas` — List attribute schemas
- `POST /businesses/{business_id}/attribute-schemas` — Create attribute schema
- `GET /businesses/{business_id}/attribute-schemas/{schema_id}` — Get attribute schema
- `GET /businesses/{business_id}/catalog-items/{item_id}/offers` — List offers
- `POST /businesses/{business_id}/catalog-items/{item_id}/offers` — Create offer
- `GET /businesses/{business_id}/catalog-items/{item_id}/variants` — List variants
- `POST /businesses/{business_id}/catalog-items/{item_id}/variants` — Create variant
- `GET /businesses/{business_id}/catalogs` — List catalogs
- `POST /businesses/{business_id}/catalogs` — Create catalog
- `GET /businesses/{business_id}/catalogs/entity-contract` — Get catalog entity contract (enum Arabic labels)
- `GET /businesses/{business_id}/catalogs/{catalog_id}` — Get catalog
- `PATCH /businesses/{business_id}/catalogs/{catalog_id}` — Update catalog
- `GET /businesses/{business_id}/catalogs/{catalog_id}/items` — List catalog items
- `POST /businesses/{business_id}/catalogs/{catalog_id}/items` — Create catalog item
- `GET /businesses/{business_id}/catalogs/{catalog_id}/items/{item_id}` — Get catalog item
- `PATCH /businesses/{business_id}/catalogs/{catalog_id}/items/{item_id}` — Update catalog item
- `PATCH /businesses/{business_id}/offers/{offer_id}` — Update offer
- `PATCH /businesses/{business_id}/variants/{variant_id}` — Update variant

### Connections
- `GET /businesses/{business_id}/channel-connections` — List channel connections
- `POST /businesses/{business_id}/channel-connections` — Begin channel provisioning
- `GET /businesses/{business_id}/channel-connections/{connection_id}` — Get channel connection
- `GET /businesses/{business_id}/channel-connections/{connection_id}/capabilities` — List connection capabilities
- `POST /businesses/{business_id}/channel-connections/{connection_id}/disconnect` — Disconnect channel
- `GET /businesses/{business_id}/channel-connections/{connection_id}/history-purge` — Preview irreversible local channel history deletion
- `POST /businesses/{business_id}/channel-connections/{connection_id}/history-purge` — Irreversibly delete entire local conversation history for one connection without disconnecting
- `POST /businesses/{business_id}/channel-connections/{connection_id}/reconnect` — Reconnect channel

### AI
- `GET /businesses/{business_id}/ai-decisions` — List structured AI decisions
- `GET /businesses/{business_id}/ai-decisions/{decision_id}` — Get structured AI decision
- `POST /businesses/{business_id}/ai-decisions/{decision_id}/request-human` — Request human review

### MerchantCatalogAI
- `POST /businesses/{business_id}/merchant-ai/executions` — Approve and atomically execute a stored catalog proposal
- `POST /businesses/{business_id}/merchant-ai/turns` — Process one Merchant Catalog AI turn

### Team
- `GET /businesses/{business_id}/team/invitations` — List team invitations without exposing tokens
- `POST /businesses/{business_id}/team/invitations` — Create a one-time team invitation
- `POST /businesses/{business_id}/team/invitations/{invitation_id}/resend` — Issue a new token and invitation
- `POST /businesses/{business_id}/team/invitations/{invitation_id}/revoke` — Revoke a pending invitation
- `GET /businesses/{business_id}/team/members` — List active and revoked team memberships
- `PATCH /businesses/{business_id}/team/members/{principal_id}/access` — Update a non-owner team member role and permissions
- `POST /businesses/{business_id}/team/members/{principal_id}/revoke` — Revoke a membership while preserving one active owner
- `PATCH /businesses/{business_id}/team/members/{principal_id}/role` — Update a non-owner team member role
- `POST /team/invitations/accept` — Accept an invitation using the authenticated principal

### Audit
- `GET /businesses/{business_id}/audit-events` — List audit events
- `GET /businesses/{business_id}/audit-events/{audit_event_id}` — Get audit event

## 10. جرد عمليات إدارة المنصة

### Platform.Businesses
- `GET /platform/businesses` — List businesses.
- `POST /platform/businesses` — Create a new business (status=pending_setup). Per Contract §9, §13.
- `GET /platform/businesses/{business_id}` — Get a business.
- `POST /platform/businesses/{business_id}/archive` — Archive a business.
- `POST /platform/businesses/{business_id}/owner` — Assign the business owner and activate a pending business.
- `POST /platform/businesses/{business_id}/reactivate` — Reactivate a business.
- `POST /platform/businesses/{business_id}/suspend` — Suspend a business.
- `POST /platform/businesses/{business_id}/team/invitations` — Create an audited employee invitation for a business.

### Platform.Channels
- `GET /platform/channels` — List all channel connections.
- `GET /platform/channels/{connection_id}` — Get a channel connection.
- `POST /platform/channels/{connection_id}/health-check` — Run channel health check.

### Platform.AI
- `GET /platform/ai` — AI runtime + provider overview.
- `POST /platform/ai/disable` — AI Emergency Kill Switch.
- `POST /platform/ai/enable` — Re-enable AI Runtime.
- `POST /platform/ai/health-check` — AI health check.
- `GET /platform/ai/providers` — List AI providers.
- `GET /platform/ai/providers/{provider_id}` — Get a single AI provider.
- `GET /platform/ai/usage` — Platform-wide AI usage aggregate.
- `GET /platform/ai/usage/by-business` — AI usage by business.
- `GET /platform/ai/usage/by-subscription` — AI usage by subscription.

### Platform.AIConfig
- `GET /platform/operations/ai/configuration` — Get current active AI configuration.
- `PUT /platform/operations/ai/configuration` — Update active AI configuration (model, limits).
- `GET /platform/operations/ai/providers` — List AI providers with credential status.
- `POST /platform/operations/ai/providers/{provider}/credentials` — Add/rotate AI provider credential.
- `POST /platform/operations/ai/providers/{provider}/models` — Discover available models from provider.
- `POST /platform/operations/ai/providers/{provider}/test` — Test AI provider connection.

### Platform.Audit
- `GET /platform/audit-events` — List platform audit events.
- `GET /platform/audit-events/{event_id}` — Get a platform audit event.

### Platform.Plans
- `GET /platform/plans` — List plans.
- `POST /platform/plans` — Create a new plan (DRAFT).
- `GET /platform/plans/{plan_id}` — Get a plan.
- `POST /platform/plans/{plan_id}/activate` — Activate a DRAFT plan.
- `POST /platform/plans/{plan_id}/retire` — Retire an ACTIVE plan.
- `POST /platform/plans/{plan_id}/versions` — Create a new plan version.

### Platform.Providers
- `GET /platform/providers` — List all external providers.
- `GET /platform/providers/{provider_id}` — Get a single provider.
- `POST /platform/providers/{provider_id}/health-check` — Run provider health check.

### Platform.Subscriptions
- `POST /platform/businesses/{business_id}/subscriptions` — Create a subscription.
- `GET /platform/subscriptions` — List subscriptions.
- `GET /platform/subscriptions/{subscription_id}` — Get a subscription.
- `POST /platform/subscriptions/{subscription_id}/ai-cost-budget` — Override subscription cost budget.
- `GET /platform/subscriptions/{subscription_id}/ai-usage` — Get subscription AI usage.
- `POST /platform/subscriptions/{subscription_id}/cancel` — Cancel a subscription.

### Platform.Payments
- `GET /platform/subscriptions/{subscription_id}/payments` — List payments.
- `POST /platform/subscriptions/{subscription_id}/payments` — Record a manual payment.

### Platform.Support
- `POST /platform/businesses/{business_id}/support/tickets` — Create a support ticket.
- `GET /platform/support/tickets` — List support tickets.
- `GET /platform/support/tickets/{ticket_id}` — Get a support ticket.
- `POST /platform/support/tickets/{ticket_id}/close` — Close a resolved ticket.
- `POST /platform/support/tickets/{ticket_id}/messages` — Append a message to a ticket.
- `POST /platform/support/tickets/{ticket_id}/resolve` — Resolve a ticket.
- `POST /platform/support/tickets/{ticket_id}/start` — Start working on a ticket.

## 11. العمليات التشغيلية والتكاملات الخلفية

### Operational
- `GET /health/live` — Process liveness
- `GET /health/ready` — Dependency readiness
- `GET /metrics` — Internal metrics

### Webhooks
- `POST /webhooks/socialapi/{route_key}` — Ingest SocialAPI webhook