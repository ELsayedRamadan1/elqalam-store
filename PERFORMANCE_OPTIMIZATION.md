# ⚡ نصائح تحسينات الأداء والتحسينات

## 1. تحسين حجم التطبيق 📦

### إزالة الملفات غير المستخدمة:
```bash
# فحص المكتبات غير المستخدمة
flutter clean
flutter pub get
```

### استخدام ProGuard (للـ Android):
```gradle
// في android/app/build.gradle
android {
    buildTypes {
        release {
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
    }
}
```

### تقليل حجم الصور:
```dart
// استخدام CachedNetworkImage:
CachedNetworkImage(
  imageUrl: product.imageUrl,
  cacheManager: CacheManager(
    Config(
      'customCacheKey',
      stalePeriod: const Duration(days: 7),
      maxNrOfCacheObjects: 20,
    ),
  ),
  placeholder: (context, url) => const ShimmerLoading(),
  errorWidget: (context, url, error) => const Icon(Icons.error),
)
```

---

## 2. تحميل كسول (Lazy Loading) 📱

### تطبيق Lazy Loading للمنتجات:
```dart
class LazyLoadProductList extends StatefulWidget {
  const LazyLoadProductList({Key? key}) : super(key: key);

  @override
  State<LazyLoadProductList> createState() => _LazyLoadProductListState();
}

class _LazyLoadProductListState extends State<LazyLoadProductList> {
  final ScrollController _scrollController = ScrollController();
  List<Product> products = [];
  bool isLoading = false;
  int page = 1;

  @override
  void initState() {
    super.initState();
    _loadMoreProducts();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  Future<void> _loadMoreProducts() async {
    if (isLoading) return;
    setState(() => isLoading = true);
    
    // تحميل المنتجات
    // context.read<ProductBloc>().add(GetProductsPageEvent(page));
    
    setState(() => isLoading = false);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollController,
      itemCount: products.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == products.length) {
          return const Center(child: CircularProgressIndicator());
        }
        return ProductCard(product: products[index]);
      },
    );
  }
}
```

---

## 3. تخزين مؤقت ذكي (Caching) 💾

### إضافة Hive للتخزين المحلي:
```yaml
# pubspec.yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  hive_generator: ^2.0.0
  build_runner: ^2.4.0
```

### التطبيق:
```dart
// lib/core/local_cache/cache_helper.dart
class CacheHelper {
  static late Box<Product> _productBox;
  
  static Future<void> init() async {
    _productBox = await Hive.openBox<Product>('products');
  }
  
  static Future<void> cacheProducts(List<Product> products) async {
    await _productBox.clear();
    for (var product in products) {
      await _productBox.put(product.id, product);
    }
  }
  
  static List<Product> getCachedProducts() {
    return _productBox.values.toList();
  }
  
  static bool isCacheValid() {
    // تحقق من صحة الـ Cache
    return _productBox.isNotEmpty;
  }
}
```

---

## 4. تحسينات الشبكة 🌐

### استخدام HTTP مع وقت انتظار (Timeout):
```dart
// lib/core/network/api_client.dart
class ApiClient {
  final http.Client _httpClient;
  
  ApiClient(this._httpClient);
  
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await _httpClient.get(
        Uri.parse(endpoint),
        headers: _getHeaders(),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw TimeoutException('Connection timeout'),
      );
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw ServerException();
      }
    } catch (e) {
      rethrow;
    }
  }
  
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
  }
}
```

---

## 5. تحسين حالة الـ UI 🎨

### استخدام const Widgets:
```dart
// قبل:
Widget _buildLoadingState() {
  return SizedBox(
    child: Center(child: CircularProgressIndicator()),
  );
}

// بعد:
const Widget _loadingState = SizedBox(
  child: Center(child: CircularProgressIndicator()),
);
```

### استخدام RepaintBoundary:
```dart
class OptimizedProductCard extends StatelessWidget {
  final Product product;

  const OptimizedProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Card(
        child: // ... your card content
      ),
    );
  }
}
```

---

## 6. استراتيجيات البناء المحسنة 🔨

### استخدام BuildContext.select (BLoC):
```dart
// قبل:
BlocBuilder<ProductBloc, ProductState>(
  builder: (context, state) {
    return Text(state.products.length.toString());
  },
)

// بعد:
BlocSelector<ProductBloc, ProductState, int>(
  selector: (state) => state.products.length,
  builder: (context, count) {
    return Text(count.toString());
  },
)
```

---

## 7. تحسينات الذاكرة 🧠

### تجنب تسريب الذاكرة:
```dart
// قبل:
@override
void initState() {
  super.initState();
  _controller = StreamController();
  _subscription = stream.listen((_) {});
}

// بعد:
@override
void initState() {
  super.initState();
  _controller = StreamController();
  _subscription = stream.listen((_) {});
}

@override
void dispose() {
  _controller.close();
  _subscription.cancel();
  super.dispose();
}
```

---

## 8. قائمة فحص الأداء ✅

قبل إطلاق النسخة:
- [ ] تحليل حجم التطبيق (`flutter build apk --analyze-size`)
- [ ] اختبار على جهاز حقيقي بطيء
- [ ] فحص تسرب الذاكرة (`flutter run --profile`)
- [ ] قياس FPS والأداء
- [ ] اختبار البطارية
- [ ] اختبار النطاق الترددي المنخفض

---

## 9. أدوات الاختبار المفيدة 🧪

### DevTools:
```bash
flutter pub global activate devtools
devtools
```

### Profiler:
```bash
flutter run --profile
# قم بفتح DevTools والانتقال إلى Performance tab
```

### Memory monitoring:
```bash
# استخدام Memory Profiler في DevTools
```

---

## 10. أفضل الممارسات 🏆

### استخدم const حيث أمكن:
```dart
const SizedBox(height: 16);
const EdgeInsets.all(16);
const Color(0xFF0F172A);
```

### تجنب عمليات حسابية في Build:
```dart
// قبل:
@override
Widget build(BuildContext context) {
  final total = items.fold(0, (a, b) => a + b.price); // ❌
  return Text('$total');
}

// بعد:
@override
Widget build(BuildContext context) {
  final total = _calculateTotal(); // ✅
  return Text('$total');
}

num _calculateTotal() => items.fold(0, (a, b) => a + b.price);
```

---

**آخر تحديث: 2026-04-21**

