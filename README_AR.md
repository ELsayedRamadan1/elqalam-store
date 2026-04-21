# Elqalam - متجر الكتروني للمكتبة القرطاسية

مشروع متجر إلكتروني احترافي وشامل في Flutter للعلماء لعرض منتجات المكتبة القرطاسية "Elqalam"

## المميزات

- ✨ **تصميم احترافي وسهل الاستخدام** - واجهة مستخدم جميلة وبديهية باللغة العربية
- 🔐 **نظام المصادقة الآمن** - تسجيل الدخول والتسجيل عبر Supabase Auth
- 📦 **إدارة المنتجات** - عرض المنتجات مع تصنيفات وتفاصيل شاملة
- 🛒 **سلة التسوق المتقدمة** - إضافة وتعديل وحذف المنتجات من السلة
- 📋 **إدارة الطلبات** - عرض سجل الطلبات والحالة
- 👤 **ملف الحساب الشخصي** - إدارة بيانات المستخدم
- 🏛️ **معمارية نظيفة** - استخدام Clean Architecture
- 📊 **إدارة الحالة بـ Bloc** - استخدام Bloc Pattern للتحكم بحالة التطبيق
- ☁️ **Backend قوي** - Supabase للقاعدة البيانات والمصادقة

## تقنيات المستخدمة

- **Flutter** - إطار عمل تطوير تطبيقات الهاتف
- **Bloc** - مكتبة لإدارة حالة التطبيق
- **Clean Architecture** - معمارية تطبيق نظيفة وقابلة للصيانة
- **Supabase** - منصة Backend كخدمة (Database + Auth + Storage)
- **GetRouter** - توجيه متقدم بين الشاشات

## المتطلبات

- Flutter SDK 3.11.4 أو أحدث
- Dart 3.x
- حساب Supabase

## التثبيت والإعداد

### 1. استنساخ المشروع
```bash
git clone <repository-url>
cd elqalam
```

### 2. تثبيت الاعتماديات
```bash
flutter pub get
```

### 3. إعداد Supabase
- انتقل إلى [Supabase Dashboard](https://app.supabase.com)
- أنشئ مشروع جديد أو استخدم المشروع الموجود
- انسخ URL و ANON KEY
- حدث الثوابت في `lib/core/constants/app_constants.dart`

### 4. إنشاء جداول قاعدة البيانات
- اتبع التعليمات في `DATABASE_SCHEMA.md` لإنشاء جميع الجداول المطلوبة
- تأكد من تفعيل RLS (Row Level Security)

### 5. تشغيل التطبيق
```bash
flutter run
```

## هيكل المشروع

```
lib/
├── main.dart                 # نقطة البداية للتطبيق
├── config/                   # مقاييس التطبيق
├── core/                     # مكونات أساسية
│   ├── constants/            # الثوابت
│   ├── errors/               # معالجة الأخطاء
│   ├── network/              # إدارة الشبكة
│   ├── themes/               # المظهر والألوان
│   └── utils/                # أدوات مساعدة
├── data/                     # طبقة البيانات
│   ├── datasources/          # مصادر الحصول على البيانات
│   ├── models/               # نماذج البيانات
│   └── repositories/         # تطبيق الـ Repositories
├── domain/                   # طبقة المجال (Logic)
│   ├── entities/             # كائنات النطاق
│   ├── repositories/         # واجهات الـ Repositories
│   └── usecases/             # حالات الاستخدام
└── presentation/             # طبقة العرض (UI)
    ├── blocs/                # Blocs
    ├── pages/                # الصفحات الرئيسية
    └── widgets/              # المكونات الصغيرة

```

## الأوامر المفيدة

```bash
# تنظيف الفلاتر
flutter clean

# إعادة الحصول على الاعتماديات
flutter pub get

# تشغيل التحليل الثابت
flutter analyze

# تشغيل الاختبارات
flutter test

# بناء APK للإصدار
flutter build apk --release

# بناء IPA لـ iOS
flutter build ios --release
```

## إدارة الحالة (Bloc)

التطبيق يستخدم Bloc Pattern لإدارة الحالة مع BLoCs التالية:

1. **AuthBloc** - إدارة حالة المصادقة والمستخدم
2. **ProductBloc** - إدارة حالة المنتجات والفئات
3. **CartBloc** - إدارة حالة سلة التسوق
4. **OrderBloc** - إدارة حالة الطلبات

## الصفحات الرئيسية

1. **HomePage** - الصفحة الرئيسية لعرض المنتجات والفئات
2. **CartPage** - صفحة سلة التسوق
3. **OrdersPage** - صفحة الطلبات السابقة
4. **ProfilePage** - صفحة الملف الشخصي
5. **LoginPage** - صفحة تسجيل الدخول/التسجيل

## العمليات الرئيسية

### التسجيل والدخول
```dart
// تسجيل الدخول
context.read<AuthBloc>().add(LoginEvent(email, password));

// إنشاء حساب
context.read<AuthBloc>().add(RegisterEvent(email, password, name));

// تسجيل الخروج
context.read<AuthBloc>().add(LogoutEvent());
```

### إدارة المنتجات
```dart
// الحصول على جميع المنتجات
context.read<ProductBloc>().add(GetProductsEvent());

// الحصول على المنتجات حسب الفئة
context.read<ProductBloc>().add(GetProductsByCategoryEvent(categoryId));

// الحصول على الفئات
context.read<ProductBloc>().add(GetCategoriesEvent());
```

### إدارة سلة التسوق
```dart
// إضافة منتج للسلة
context.read<CartBloc>().add(AddToCartEvent(userId, productId, quantity));

// الحصول على عناصر السلة
context.read<CartBloc>().add(GetCartItemsEvent(userId));

// إتمام الشراء
context.read<OrderBloc>().add(CreateOrderEvent(userId, cartItems));
```

## الملفات الهامة

- `DATABASE_SCHEMA.md` - شرح شامل لجداول قاعدة البيانات
- `lib/core/constants/app_constants.dart` - ثوابت التطبيق
- `lib/core/themes/app_theme.dart` - المظهر والألوان
- `pubspec.yaml` - الاعتماديات والإعدادات

## الدعم والمساهمة

للإبلاغ عن مشاكل أو المساهمة في المشروع، يرجى إنشاء issue أو pull request.

## الترخيص

هذا المشروع مرخص تحت رخصة MIT.

## المؤلف

تم تطوير هذا المشروع بواسطة فريق التطوير.

---

شكراً لاستخدام Elqalam! 🎉
