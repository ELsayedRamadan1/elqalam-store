# سجل التعديلات — elqalam v1.1.0

## 🔴 إصلاحات عاجلة

### 1. أمان — إزالة API Keys المكشوفة
- **الملف:** `lib/core/constants/app_constants.dart`
- حذف `defaultValue` من `String.fromEnvironment` لكلا المفتاحين.
- أضفنا `AppConstants.validate()` تُشغَّل في `main()` وتُوقف التطبيق فوراً في debug mode إذا نسيت تمرير المفاتيح.
- **طريقة التشغيل الصحيحة:**
  ```bash
  flutter run \
    --dart-define=SUPABASE_URL=https://your-project.supabase.co \
    --dart-define=SUPABASE_ANON_KEY=your-anon-key
  ```

### 2. أداء — إصلاح N+1 Query
- **الملفات:** `lib/data/datasources/order_datasource.dart`, `lib/presentation/blocs/cart/cart_bloc.dart`
- الـ CartBloc كان يعمل query منفصلة لكل منتج لجلب السعر. الآن يحسب الإجمالي مباشرة من `CartItem.price` الذي يُجلب مع الـ JOIN في datasource.
- الـ OrderDatasource كان يعمل N query لجلب تفاصيل كل منتج. الآن يستخدم البيانات الموجودة مسبقاً في CartItem.
- `GetProductUseCase` أُزيل نهائياً من `CartBloc`.

### 3. UX — Feedback بعد إتمام الطلب
- **الملف:** `lib/presentation/pages/cart_page.dart`
- أضفنا `BlocListener<OrderBloc>` يراقب `orderCreated` flag.
- عند النجاح: SnackBar أخضر + navigate تلقائي لصفحة الطلبات.
- عند الفشل: SnackBar أحمر برسالة الخطأ.
- زر "إتمام الطلب" يُعطَّل ويُظهر loading أثناء إنشاء الطلب.

---

## 🟡 تحسينات

### 4. كود — إزالة print() من Production
- **الملفات:** `lib/data/datasources/auth_datasource.dart`, `lib/presentation/blocs/auth/auth_bloc.dart`
- استبدلنا `print()` بـ `debugPrint()` الذي لا يُطبع في release builds.

### 5. معمارية — فصل Models عن Entities
- **الملفات الجديدة:** `lib/data/models/` (product_model, category_model, cart_item_model, order_model, user_model)
- Domain Entities أصبحت pure Dart — لا تعرف شيئاً عن JSON أو Supabase.
- كل `fromJson` / `toJson` انتقلت للـ Models في طبقة Data.

### 6. أداء — UpdateCartItem يحدّث الـ total
- **الملف:** `lib/presentation/blocs/cart/cart_bloc.dart`
- `_onUpdateCartItem` و `_onRemoveFromCart` يستدعيان `_refreshCart()` بعد التعديل.
- `UpdateCartItemEvent` و `RemoveFromCartEvent` يحملان `userId` الآن.

### 7. أمان — Stock Validation
- **الملف:** `lib/data/datasources/cart_datasource.dart`
- `addToCart` يتحقق من `stock` و `is_available` قبل الإضافة.

### 8. OrderBloc — Refresh بعد إنشاء الطلب
- **الملف:** `lib/presentation/blocs/order/order_bloc.dart`
- بعد `CreateOrderEvent` يُحدَّث `orders` list تلقائياً.
- `OrderState` فيها field جديد `orderCreated` للـ one-shot notification.

### 9. UI — CachedNetworkImage
- **الملف:** `lib/presentation/widgets/product_card.dart`
- استبدلنا `Image.network` بـ `CachedNetworkImage` — الصور تُخزَّن محلياً وتتحمل مرة واحدة فقط.

---

## 💡 إضافات جديدة

### 10. Unit Tests
- **الملفات:** `test/blocs/auth_bloc_test.dart`, `test/blocs/cart_bloc_test.dart`
- 6 test cases تغطي: login success/failure، logout، register، getCartItems، clearCart.
- Dependencies جديدة: `bloc_test: ^9.1.5`, `mocktail: ^1.0.1`
- **تشغيل الاختبارات:**
  ```bash
  flutter test
  ```
