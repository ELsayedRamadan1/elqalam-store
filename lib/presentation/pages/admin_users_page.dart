import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/themes/app_theme.dart';
import '../../domain/entities/user.dart';

class AdminUsersPage extends StatefulWidget {
  const AdminUsersPage({super.key});

  @override
  State<AdminUsersPage> createState() => _AdminUsersPageState();
}

class _AdminUsersPageState extends State<AdminUsersPage> {
  // في التطبيق الحقيقي، سيتم جلب هذه البيانات من API
  final List<User> _users = [
    User(
      id: '1',
      email: 'ahmed@example.com',
      name: 'أحمد محمد',
      phone: '+966501234567',
      address: 'الرياض، حي العليا',
      avatarUrl: null,
    ),
    User(
      id: '2',
      email: 'fatima@example.com',
      name: 'فاطمة علي',
      phone: '+966507654321',
      address: 'جدة، حي الصفا',
      avatarUrl: null,
    ),
    User(
      id: '3',
      email: 'omar@example.com',
      name: 'عمر حسن',
      phone: null,
      address: 'الدمام، حي الفيحاء',
      avatarUrl: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('إدارة العملاء'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // يمكن إضافة وظيفة البحث لاحقاً
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // إحصائيات سريعة
          Container(
            padding: const EdgeInsets.all(16),
            color: AppColors.background,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatCard(
                  title: 'إجمالي العملاء',
                  value: '${_users.length}',
                  icon: Icons.people,
                  color: AppColors.primary,
                ),
                _StatCard(
                  title: 'عملاء نشطين',
                  value: '${_users.where((u) => u.phone != null).length}',
                  icon: Icons.check_circle,
                  color: AppColors.success,
                ),
                _StatCard(
                  title: 'بدون رقم هاتف',
                  value: '${_users.where((u) => u.phone == null).length}',
                  icon: Icons.warning,
                  color: Colors.orange,
                ),
              ],
            ),
          ),

          // قائمة العملاء
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _showUserDetails(context, user),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          // صورة الملف الشخصي
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: AppColors.primaryLight,
                            backgroundImage: user.avatarUrl != null
                                ? CachedNetworkImageProvider(user.avatarUrl!)
                                : null,
                            child: user.avatarUrl == null
                                ? Text(
                                    user.name.isNotEmpty
                                        ? user.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),

                          const SizedBox(width: 16),

                          // معلومات العميل
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  user.email,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(
                                      user.phone != null
                                          ? Icons.phone
                                          : Icons.phone_disabled,
                                      size: 16,
                                      color: user.phone != null
                                          ? AppColors.success
                                          : AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      user.phone ?? 'لا يوجد رقم هاتف',
                                      style: TextStyle(
                                        color: user.phone != null
                                            ? AppColors.textPrimary
                                            : AppColors.textSecondary,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // أيقونة التفاصيل
                          Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: AppColors.textSecondary,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس النافذة
              Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primaryLight,
                    backgroundImage: user.avatarUrl != null
                        ? CachedNetworkImageProvider(user.avatarUrl!)
                        : null,
                    child: user.avatarUrl == null
                        ? Text(
                            user.name.isNotEmpty
                                ? user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          user.email,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // معلومات التفصيلية
              const Text(
                'معلومات الاتصال',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _DetailRow(
                icon: Icons.email,
                label: 'البريد الإلكتروني',
                value: user.email,
              ),
              const SizedBox(height: 12),

              _DetailRow(
                icon: user.phone != null ? Icons.phone : Icons.phone_disabled,
                label: 'رقم الهاتف',
                value: user.phone ?? 'لم يتم تحديده',
                valueColor: user.phone != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              const SizedBox(height: 12),

              _DetailRow(
                icon: Icons.location_on,
                label: 'العنوان',
                value: user.address ?? 'لم يتم تحديده',
                valueColor: user.address != null
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),

              const SizedBox(height: 32),

              // معلومات إضافية
              const Text(
                'معلومات إضافية',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _DetailRow(
                icon: Icons.calendar_today,
                label: 'تاريخ الانضمام',
                value: 'منذ ${_calculateDaysSinceJoin(user.id)} أيام',
              ),
              const SizedBox(height: 12),

              _DetailRow(
                icon: Icons.receipt_long,
                label: 'عدد الطلبات',
                value: '${_getUserOrdersCount(user.id)} طلب',
              ),

              const SizedBox(height: 32),

              // أزرار الإجراءات
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // يمكن إضافة وظيفة الاتصال بالعميل
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('الاتصال بـ ${user.name}')),
                        );
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('اتصال'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // يمكن إضافة وظيفة إرسال رسالة
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('إرسال رسالة إلى ${user.name}')),
                        );
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('رسالة'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateDaysSinceJoin(String userId) {
    // في التطبيق الحقيقي، سيتم حساب هذا من تاريخ إنشاء الحساب
    return 45; // قيمة وهمية
  }

  int _getUserOrdersCount(String userId) {
    // في التطبيق الحقيقي، سيتم جلب هذا من قاعدة البيانات
    return 12; // قيمة وهمية
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = AppColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            Text(
              value,
              style: TextStyle(
                color: valueColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
