# دليل البداية السريعة - Elqalam ⚡

**اتبع هذه الخطوات البسيطة لتشغيل التطبيق في دقائق!**

## 🎯 متطلبات سريعة

- ✅ Flutter 3.11.4+
- ✅ حساب Supabase مجاني
- ✅ محرر أكواد (VS Code)

## 1️⃣ الخطوة الأولى: Supabase

### أ) إنشاء حساب
1. اذهب إلى https://supabase.com
2. انقر "Start for free"
3. سجل دخول بـ GitHub أو البريد

### ب) إنشاء مشروع
1. اختر "New Project"
2. ملئ البيانات واختر المنطقة الأقرب
3. اضغط "Create new project"
4. انتظر حوالي 3 دقائق

### ج) الحصول على البيانات
1. في لوحة التحكم، اذهب إلى **Settings** → **API**
2. انسخ:
   - **Project URL**
   - **anon public key**

## 2️⃣ تحديث بيانات الـ Supabase

افتح الملف: `lib/core/constants/app_constants.dart`

```dart
class AppConstants {
  static const String supabaseUrl = 'PASTE_YOUR_URL_HERE';
  static const String supabaseAnonKey = 'PASTE_YOUR_KEY_HERE';
}
```

## 3️⃣ إنشاء جداول قاعدة البيانات

### الطريقة الأسهل:
1. في Supabase Dashboard، اذهب إلى **SQL Editor**
2. اضغط **New Query**
3. انسخ واللصق الأكواد من `IMPLEMENTATION_GUIDE.md`
4. اضغط **▶️** لتنفيذ كل أمر

**قائمة الأوامر يجب تنفيذها بالترتيب:**
1. profiles (جدول المستخدمين)
2. categories (الفئات)
3. products (المنتجات)
4. cart_items (السلة)
5. orders (الطلبات)

## 4️⃣ تشغيل التطبيق

```bash
# 1. نظف الملفات القديمة
flutter clean

# 2. حدّث الحزم
flutter pub get

# 3. شغّل التطبيق
flutter run
```

## 5️⃣ اختبار التطبيق

### أول ما تفتح التطبيق:
1. **الشاشة الرئيسية** - ستظهر فارغة (لا توجد منتجات بعد)
2. **اضغط على ملف الشخص** - لتسجيل الدخول
3. **اختر "إنشاء حساب"** - سجل حسابك
4. **عود للرئيسية** - أضف بيانات عينة (اختياري)

### إضافة منتجات تجريبية:
اذهب إلى Supabase Dashboard → SQL Editor وشغّل:

```sql
-- أولاً: أضف الفئات
INSERT INTO categories (name) VALUES
('أقلام'),
('دفاتر'),
('ورق');

-- ثانياً: أضف المنتجات
INSERT INTO products (name, description, price, category_id, stock, is_available) VALUES
('قلم جاف', 'قلم عالي الجودة', 10, (SELECT id FROM categories WHERE name='أقلام' LIMIT 1), 100, true),
('دفتر 100 ورقة', 'دفتر دراسة', 20, (SELECT id FROM categories WHERE name='دفاتر' LIMIT 1), 50, true),
('ورق A4', 'ورق طباعة', 15, (SELECT id FROM categories WHERE name='ورق' LIMIT 1), 200, true);
```

## ⚠️ المشاكل الشائعة والحل

### ❌ "Project not initialized"
✅ **الحل:** تأكد من تحديث `supabaseUrl` و `supabaseAnonKey` بشكل صحيح

### ❌ "Permission denied"
✅ **الحل:** تأكد من أن SQL تم تنفيذها بنجاح (سترى ✓ إذا نجحت)

### ❌ "Packages not found"
✅ **الحل:** جرّب `flutter pub get` أو `flutter clean && flutter pub get`

### ❌ "Build error"
✅ **الحل:** استخدم `flutter clean` ثم `flutter pub get`

### ❌ المنتجات لا تظهر
✅ **الحل:** أضف منتجات عينة باستخدام الأمر في القسم 5

## 🎮 اختبر الميزات

| الميزة | كيف تختبرها |
|--------|-----------|
| **تسجيل الدخول** | اضغط على ملف الشخص → سجل |
| **عرض المنتجات** | الشاشة الرئيسية بعد إضافة بيانات |
| **تصفية بالفئة** | اضغط على فئة من الأعلى |
| **تفاصيل المنتج** | اضغط على أي منتج |
| **إضافة للسلة** | اختر كمية واضغط "أضف للسلة" |
| **عرض السلة** | اضغط على بطاقة السلة |
| **إتمام الشراء** | في صفحة السلة اضغط الزر الأخضر |
| **عرض الطلبات** | اتمم عملية شراء ثم اذهب لـ "الطلبات" |

## 📚 المستندات المهمة

| المستند | الغرض |
|--------|------|
| `PROJECT_SUMMARY.md` | ملخص المشروع الشامل |
| `DATABASE_SCHEMA.md` | شرح الجداول التفصيلي |
| `IMPLEMENTATION_GUIDE.md` | دليل الإعداد الكامل |
| `FEATURES.md` | قائمة الميزات |
| `README_AR.md` | التوثيق الكامل |

## 🆘 تحتاج مساعدة؟

1. اقرأ `IMPLEMENTATION_GUIDE.md`
2. تحقق من `PROJECT_SUMMARY.md`
3. اطلع على `DATABASE_SCHEMA.md` لفهم الجداول

## 🎉 الآن أنت جاهز!

بعد تشغيل تطبيقك بنجاح:
1. اختبر التسجيل والدخول
2. أضف منتجات للسلة
3. أتمم عملية شراء
4. شاهد الطلبات السابقة

---

**استمتع ببناء متجرك الإلكتروني! 🚀**
