# دليل التطبيق والتنفيذ - Elqalam E-Commerce

هذا الدليل سيساعدك على إعداد وتشغيل تطبيق Elqalam بنجاح.

## 1️⃣ المتطلبات الأساسية

- Flutter SDK 3.11.4 أو أحدث
- حساب Supabase (يمكنك إنشاء واحد مجاناً على https://supabase.com)
- محرر نصوص أو IDE (VS Code, Android Studio, إلخ)

## 2️⃣ خطوات التثبيت الأولية

### أ. استنساخ المشروع
```bash
git clone <repository-url>
cd elqalam
```

### ب. تثبيت الاعتماديات
```bash
flutter pub get
```

## 3️⃣ إعداد Supabase

### أ. إنشاء مشروع جديد
1. قم بزيارة https://app.supabase.com
2. اضغط على "New Project"
3. ملئ البيانات المطلوبة واختر المنطقة الأقرب لك
4. انتظر حتى ينتهي الإنشاء (قد يستغرق عدة دقائق)

### ب. الحصول على بيانات الاتصال
1. اذهب إلى "Settings" > "API"
2. انسخ:
   - **Project URL** → سيكون `supabaseUrl` في `app_constants.dart`
   - **anon public** → سيكون `supabaseAnonKey` في `app_constants.dart`

### ج. تحديث بيانات الاتصال
افتح `lib/core/constants/app_constants.dart` وحدث القيم:
```dart
class AppConstants {
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
}
```

## 4️⃣ إعداد قاعدة البيانات

### أ. إنشاء الجداول
1. في لوحة Supabase، اذهب إلى **SQL Editor**
2. انسخ واللصق كل SQL من الأسفل في SQL Editor
3. اضغط على ▶️ لتنفيذ الأوامر

#### SQL Script - الجدول الأول (profiles):
```sql
-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create profiles table
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email VARCHAR(255) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  phone VARCHAR(20),
  address TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own profile" ON profiles
FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update their own profile" ON profiles
FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Users can insert their own profile" ON profiles
FOR INSERT WITH CHECK (auth.uid() = id);
```

#### SQL Script - الجدول الثاني (categories):
```sql
CREATE TABLE categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  image_url TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view categories" ON categories
FOR SELECT USING (true);
```

#### SQL Script - الجدول الثالث (products):
```sql
CREATE TABLE products (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  name VARCHAR(255) NOT NULL,
  description TEXT,
  price DECIMAL(10, 2) NOT NULL,
  image_url TEXT,
  category_id UUID REFERENCES categories(id) ON DELETE CASCADE,
  stock INTEGER DEFAULT 0,
  is_available BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE products ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view products" ON products
FOR SELECT USING (true);
```

#### SQL Script - الجدول الرابع (cart_items):
```sql
CREATE TABLE cart_items (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  product_id UUID REFERENCES products(id) ON DELETE CASCADE,
  quantity INTEGER NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE cart_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage their own cart" ON cart_items
FOR ALL USING (auth.uid() = user_id);
```

#### SQL Script - الجدول الخامس (orders):
```sql
CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  items JSONB NOT NULL,
  total DECIMAL(10, 2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view their own orders" ON orders
FOR SELECT USING (auth.uid() = user_id);
```

### ب. إضافة بيانات عينة (اختياري)
```sql
-- Insert sample categories
INSERT INTO categories (name, image_url) VALUES
('أقلام', 'https://images.unsplash.com/photo-1611532736579-6b16e2b50449?w=400'),
('دفاتر', 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400'),
('ورق', 'https://images.unsplash.com/photo-1595521624e44-684c85ee6c4a?w=400'),
('أدوات رسم', 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400');

-- Insert sample products
INSERT INTO products (name, description, price, image_url, category_id, stock, is_available) VALUES
('قلم جاف شيفر أسود', 'قلم جاف عالي الجودة مع حبر سائل سلس', 15.00, 'https://images.unsplash.com/photo-1578998125212-3421beda1dd5?w=400', (SELECT id FROM categories WHERE name='أقلام'), 100, true),
('دفتر 100 ورقة', 'دفتر دراسة سميك من الورق الأبيض الفاخر', 25.00, 'https://images.unsplash.com/photo-1481627834876-b7833e8f5570?w=400', (SELECT id FROM categories WHERE name='دفاتر'), 50, true),
('ورق أبيض A4 500 ورقة', 'ورق طباعة عالي الجودة 80 جرام', 12.00, 'https://images.unsplash.com/photo-1595521624e44-684c85ee6c4a?w=400', (SELECT id FROM categories WHERE name='ورق'), 200, true),
('مجموعة أقلام ملونة', '24 لوناً متنوعاً للرسم والكتابة', 35.00, 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?w=400', (SELECT id FROM categories WHERE name='أدوات رسم'), 75, true);
```

## 5️⃣ تشغيل التطبيق

### تشغيل على أندرويد:
```bash
flutter run -d android
```

### تشغيل على iOS:
```bash
flutter run -d ios
```

### تشغيل على تطبيق الويب:
```bash
flutter run -d chrome
```

## 6️⃣ اختبار التطبيق

### ماذا تتوقع عند فتح التطبيق:
1. **الشاشة الرئيسية** - عرض المنتجات والفئات
2. **تسجيل الدخول** - انقر على ملف الشخص لتسجيل الدخول أو الاشتراك
3. **إضافة للسلة** - اضغط على منتج وأضفه للسلة
4. **عرض السلة** - شاهد عناصر السلة وأكمل الشراء
5. **عرض الطلبات** - شاهد سجل طلباتك السابقة

### حساب اختبار موصى به:
- البريد: `test@example.com`
- كلمة المرور: `Test123456`

## 7️⃣ استكشاف الأخطاء

### الخطأ: "Project not initialized"
**الحل:** تأكد من تحديث `supabaseUrl` و `supabaseAnonKey` بشكل صحيح

### الخطأ: "Permission denied" عند الوصول للجداول
**الحل:** تحقق من أن RLS policies تم تفعيلها بشكل صحيح

### الخطأ: صورة لا تحمل
**الحل:** تأكد من أن روابط الصور صحيحة أو استخدم صور من Unsplash

## 8️⃣ إرشادات إضافية

### إعادة تشغيل التطبيق:
```bash
flutter clean
flutter pub get
flutter run
```

### عرض السجلات:
```bash
flutter logs
```

### بناء APK للإصدار:
```bash
flutter build apk --release
```

## 🎯 الخطوات التالية

بعد إعداد التطبيق، يمكنك:
1. تخصيص الألوان والمظهر في `lib/core/themes/app_theme.dart`
2. إضافة المزيد من الميزات مثل البحث عن المنتجات
3. دمج نظام الدفع الفعلي (Stripe, PayPal، إلخ)
4. إضافة نظام التقييمات والتعليقات
5. تحسين الأداء والاستجابة

## 📞 الدعم والمساعدة

إذا واجهت أي مشكلة:
1. تحقق من `DATABASE_SCHEMA.md` للتفاصيل الكاملة
2. راجع `README_AR.md` للمزيد من المعلومات
3. اطلب المساعدة من فريق التطوير

---

🎉 **بارك الله فيك! أنت الآن جاهز لتشغيل Elqalam!**
