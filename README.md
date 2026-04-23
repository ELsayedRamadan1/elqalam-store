# القلم - Elqalam v3

تطبيق تجارة إلكترونية لبيع الأدوات المكتبية مبني بـ Flutter + Supabase.

## المتطلبات
- Flutter SDK ^3.10.0
- حساب Supabase مع قاعدة بيانات مُعدّة

## التشغيل

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOiJ...
```

## VS Code (launch.json)

```json
{
  "configurations": [
    {
      "name": "elqalam",
      "request": "launch",
      "type": "dart",
      "args": [
        "--dart-define=SUPABASE_URL=https://xxxx.supabase.co",
        "--dart-define=SUPABASE_ANON_KEY=eyJ..."
      ]
    }
  ]
}
```

## البنية

```
lib/
├── config/          # Service Locator (DI)
├── core/
│   ├── constants/   # AppConstants + validate()
│   ├── errors/      # Failures
│   └── themes/      # AppTheme (Material 3 + RTL)
├── data/
│   ├── datasources/ # Supabase queries
│   ├── models/      # JSON parsing
│   └── repositories/
├── domain/
│   ├── entities/    # Pure Dart entities
│   ├── repositories/# Abstract interfaces
│   └── usecases/    # Business logic
└── presentation/
    ├── blocs/       # AuthBloc, ProductBloc, CartBloc, OrderBloc
    ├── pages/       # Home, Cart, Orders, Profile, Login, ProductDetail
    └── widgets/     # ProductCard, CategoryChip
```

## جداول Supabase المطلوبة

```sql
-- profiles
create table profiles (
  id uuid primary key references auth.users,
  email text not null,
  name text,
  phone text,
  address text
);

-- categories
create table categories (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  image_url text
);

-- products
create table products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  description text,
  price numeric not null,
  image_url text,
  category_id uuid references categories(id),
  stock int default 0,
  is_available boolean default true
);

-- cart_items
create table cart_items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id) on delete cascade,
  product_id uuid references products(id),
  quantity int not null default 1
);

-- orders
create table orders (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references profiles(id),
  items jsonb not null,
  total numeric not null,
  status text default 'pending',
  created_at timestamptz default now()
);
```

## التحديثات في v3

### إصلاحات
- ✅ `assert` → `throw StateError` يعمل في debug و release معاً
- ✅ RTL كامل للتطبيق
- ✅ إزالة `debugShowCheckedModeBanner`

### تحسينات UI
- ✅ Material 3 مع ألوان احترافية
- ✅ شريط بحث في الصفحة الرئيسية
- ✅ Chips فلترة مع حالة "مختار"
- ✅ Pull-to-refresh في كل الصفحات
- ✅ Sliver AppBar مع صورة المنتج
- ✅ Dismissible (سحب لحذف) في السلة
- ✅ تأكيد الطلب بـ Dialog
- ✅ Badge عدد المنتجات في السلة
- ✅ SnackBar مع زر "عرض السلة"
- ✅ صفحة الملف الشخصي مع إحصائيات
- ✅ Expandable cards في الطلبات
- ✅ تاريخ مُنسَّق بالعربية
- ✅ تأكيد تسجيل الخروج بـ Dialog
- ✅ أيقونات الحالات في الطلبات
- ✅ إغلاق رأسي فقط (portrait)

# Elqalam - تطبيق القلم للتجارة الإلكترونية

## 🌟 الميزات الجديدة (تحديث 2026)

### 👤 **نظام الملف الشخصي المحسن**
- ✅ **إضافة صورة الملف الشخصي** - اختيار من الكاميرا أو المعرض
- ✅ **تعديل رقم الهاتف** - حفظ وتحديث رقم الهاتف
- ✅ **إضافة العنوان** - إمكانية إضافة عنوان التوصيل
- ✅ **حفظ البيانات تلقائياً** - في قاعدة البيانات Supabase
- ✅ **واجهة سهلة الاستخدام** - تصميم عصري ومتجاوب

### 👨‍💼 **لوحة تحكم المسؤول**
- ✅ **عرض جميع العملاء** - قائمة شاملة بجميع المستخدمين
- ✅ **إحصائيات سريعة** - عدد العملاء والعملاء النشطين
- ✅ **تفاصيل العميل** - عرض معلومات مفصلة لكل عميل
- ✅ **إجراءات سريعة** - اتصال أو إرسال رسالة للعملاء
- ✅ **فلترة وبحث** - إمكانية البحث في قائمة العملاء

### 🗄️ **تحديث قاعدة البيانات**
```sql
-- إضافة حقل avatar_url للجدول profiles
ALTER TABLE profiles ADD COLUMN avatar_url TEXT;
```

## 📱 الميزات الأساسية

### 🛒 **التسوق**
- تصفح المنتجات بالفئات
- البحث المتقدم مع الفلاتر
- إضافة إلى السلة وحفظ المفضلة
- نظام تقييم المنتجات

### 👤 **إدارة الحساب**
- تسجيل الدخول والتسجيل
- إدارة الملف الشخصي الكامل
- تتبع الطلبات والتاريخ
- حفظ الجلسة تلقائياً

### 📦 **إدارة الطلبات**
- إنشاء وتتبع الطلبات
- حالات مختلفة للطلبات
- تاريخ شامل للطلبات
- إشعارات حالة الطلب

### 👨‍💼 **إدارة النظام (للمسؤولين)**
- عرض إحصائيات المبيعات
- إدارة المنتجات والفئات
- عرض وإدارة الطلبات
- **جديد:** عرض وإدارة بيانات العملاء

## 🛠️ التقنيات المستخدمة

- **Flutter** - إطار العمل الأساسي
- **Dart** - لغة البرمجة
- **Supabase** - قاعدة البيانات والمصادقة
- **Bloc** - إدارة الحالة
- **Go Router** - التنقل بين الصفحات
- **Cached Network Image** - تحميل وعرض الصور
- **Image Picker** - اختيار الصور من الجهاز
- **Permission Handler** - إدارة الأذونات

## 🚀 التثبيت والتشغيل

### متطلبات النظام
- Flutter SDK >= 3.10.0
- Dart SDK >= 3.0.0
- Android Studio / VS Code
- حساب Supabase

### خطوات التثبيت

1. **استنساخ المشروع**
```bash
git clone https://github.com/your-repo/elqalam.git
cd elqalam
```

2. **تثبيت الاعتمادات**
```bash
flutter pub get
```

3. **إعداد Supabase**
```bash
# إنشاء مشروع جديد في https://app.supabase.com
# نسخ URL المشروع ومفتاح API
```

4. **تشغيل التطبيق**
```bash
flutter run --dart-define=SUPABASE_URL=your_supabase_url --dart-define=SUPABASE_ANON_KEY=your_anon_key
```

## 📊 إعداد قاعدة البيانات

### الجداول المطلوبة

1. **profiles** - ملفات المستخدمين
2. **categories** - فئات المنتجات  
3. **products** - المنتجات
4. **cart_items** - عناصر سلة التسوق
5. **orders** - الطلبات

### أوامر SQL لإنشاء الجداول

```sql
-- إنشاء جدول profiles
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  address TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- إنشاء الجداول الأخرى...
```

## 🔐 الأذونات والأمان

### أذونات التطبيق
- **الكاميرا**: لالتقاط صور الملف الشخصي
- **معرض الصور**: لاختيار الصور المحفوظة
- **التخزين**: لحفظ الصور المؤقتة

### سياسات RLS (Row Level Security)
```sql
-- المستخدمون يمكنهم قراءة ملفاتهم الشخصية فقط
CREATE POLICY "Users can view own profile" ON profiles
FOR SELECT USING (auth.uid() = id);

-- المستخدمون يمكنهم تحديث ملفاتهم الشخصية فقط
CREATE POLICY "Users can update own profile" ON profiles
FOR UPDATE USING (auth.uid() = id);
```

## 🎨 التصميم والواجهة

### الألوان الرئيسية
- **الأساسي**: أزرق داكن (#1976D2)
- **الثانوي**: أزرق فاتح (#42A5F5)
- **النجاح**: أخضر (#4CAF50)
- **الخطر**: أحمر (#F44336)
- **الخلفية**: رمادي فاتح (#F5F5F5)

### الخطوط والنصوص
- **الخط الرئيسي**: Cairo (عربي)
- **الحجم الافتراضي**: 14px
- **اتجاه النص**: من اليمين لليسار (RTL)

## 📱 دعم الأجهزة

- ✅ **Android**: API 21+
- ✅ **iOS**: 12.0+
- ✅ **Web**: Chrome, Firefox, Safari
- ✅ **Windows**: 10+
- ✅ **macOS**: 10.14+
- ✅ **Linux**: Ubuntu 18.04+

## 🔄 التحديثات المستقبلية

### قيد التطوير
- [ ] نظام الدفع الإلكتروني
- [ ] تطبيق الويب التفاعلي
- [ ] تطبيق سطح المكتب
- [ ] نظام الإشعارات الدفعية
- [ ] تقارير المبيعات المتقدمة

### مخطط لها
- [ ] تطبيق الواقع المعزز للمنتجات
- [ ] دعم اللغات المتعددة
- [ ] تطبيق الهاتف الذكي للمسؤولين
- [ ] نظام الولاء والنقاط
- [ ] دمج مع منصات التوصيل

## 📞 الدعم والمساعدة

### التواصل
- **البريد الإلكتروني**: support@elqalam.com
- **الهاتف**: +966 50 123 4567
- **الموقع**: https://elqalam.com

### المساعدة الفنية
- **الوثائق**: https://docs.elqalam.com
- **منتدى المطورين**: https://forum.elqalam.com
- **GitHub Issues**: https://github.com/elqalam/app/issues

## 📄 الترخيص

هذا المشروع مرخص تحت رخصة MIT - راجع ملف [LICENSE](LICENSE) للتفاصيل.

---

**تم تطوير تطبيق القلم بكل ❤️ للمجتمع العربي**
