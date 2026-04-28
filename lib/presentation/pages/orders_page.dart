import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/themes/app_theme.dart';
import '../../domain/entities/order.dart';
import '../../presentation/blocs/order/order_bloc.dart';
import '../../presentation/blocs/order/order_event.dart';
import '../../presentation/blocs/order/order_state.dart';
import '../../presentation/blocs/auth/auth_bloc.dart';
import '../../presentation/blocs/auth/auth_state.dart' as app_auth;

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState.user != null) {
      context.read<OrderBloc>().add(GetOrdersEvent(authState.user!.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, app_auth.AuthState>(
      builder: (context, authState) {
        if (authState.user == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                const Text('يرجى تسجيل الدخول لعرض الطلبات',
                    style: TextStyle(fontSize: 16)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('تسجيل الدخول'),
                ),
              ],
            ),
          );
        }

        return BlocBuilder<OrderBloc, OrderState>(
          builder: (context, orderState) {
            if (orderState.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (orderState.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 60, color: AppColors.error),
                    const SizedBox(height: 12),
                    Text('خطأ: ${orderState.error}',
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<OrderBloc>()
                          .add(GetOrdersEvent(authState.user!.id)),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }

            if (orderState.orders.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_outlined,
                        size: 80, color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    const Text('لا توجد طلبات بعد',
                        style: TextStyle(
                            fontSize: 18, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    const Text('ابدأ التسوق وأضف منتجات للسلة',
                        style: TextStyle(color: AppColors.textSecondary)),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () => context.go('/'),
                      icon: const Icon(Icons.store),
                      label: const Text('تصفح المنتجات'),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<OrderBloc>()
                    .add(GetOrdersEvent(authState.user!.id));
              },
              color: AppColors.primary,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: orderState.orders.length,
                itemBuilder: (context, index) {
                  final order = orderState.orders[index];
                  return _OrderCard(order: order);
                },
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────
// Order status helpers
// ─────────────────────────────────────────────────────
const _statusSteps = ['pending', 'processing', 'shipped', 'delivered'];

const _statusLabels = {
  'pending':    'في الانتظار',
  'processing': 'قيد المعالجة',
  'shipped':    'تم الشحن',
  'delivered':  'تم التسليم',
  'cancelled':  'ملغي',
};

const _statusIcons = {
  'pending':    Icons.hourglass_empty_rounded,
  'processing': Icons.settings_rounded,
  'shipped':    Icons.local_shipping_rounded,
  'delivered':  Icons.check_circle_rounded,
  'cancelled':  Icons.cancel_rounded,
};

const _statusColors = {
  'pending':    Color(0xFFFF8F00),
  'processing': Color(0xFF1565C0),
  'shipped':    Color(0xFF6A1B9A),
  'delivered':  AppColors.success,
  'cancelled':  AppColors.error,
};

// ─────────────────────────────────────────────────────
// Order Card with Stepper
// ─────────────────────────────────────────────────────
class _OrderCard extends StatefulWidget {
  final Order order;
  const _OrderCard({required this.order});

  @override
  State<_OrderCard> createState() => _OrderCardState();
}

class _OrderCardState extends State<_OrderCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late AnimationController _animCtrl;
  late Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _animCtrl.forward() : _animCtrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final isCancelled = order.status == 'cancelled';
    final statusColor =
        _statusColors[order.status] ?? AppColors.textSecondary;
    final statusIcon = _statusIcons[order.status] ?? Icons.help_outline;
    final statusLabel = _statusLabels[order.status] ?? order.status;
    final shortId =
        order.id.length > 8 ? order.id.substring(0, 8).toUpperCase() : order.id;
    final dateFormat = DateFormat('d MMM yyyy – hh:mm a', 'ar');

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Header ──
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      // Status circle icon
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(31),
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(statusIcon, color: statusColor, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'طلب #$shortId',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              dateFormat.format(order.createdAt),
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${order.total.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: AppColors.success,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(31),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 300),
                        child: const Icon(Icons.keyboard_arrow_down,
                            color: AppColors.textSecondary),
                      ),
                    ],
                  ),

                  // ── Progress Stepper (always visible) ──
                  if (!isCancelled) ...[
                    const SizedBox(height: 16),
                    _OrderStepper(currentStatus: order.status),
                  ],
                ],
              ),
            ),
          ),

          // ── Expandable Details ──
          SizeTransition(
            sizeFactor: _expandAnim,
            child: Column(
              children: [
                const Divider(
                    height: 1, color: AppColors.divider, indent: 16, endIndent: 16),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'تفاصيل المنتجات',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...order.items.map((item) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    item.productName,
                                    style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontSize: 13),
                                  ),
                                ),
                                Text(
                                  '× ${item.quantity}',
                                  style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: 12),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '${(item.price * item.quantity).toStringAsFixed(2)} ر.س',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 10),
                      const Divider(color: AppColors.divider),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('المجموع الكلي:',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14)),
                          Text(
                            '${order.total.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.success,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────
// Order Progress Stepper Widget
// ─────────────────────────────────────────────────────
class _OrderStepper extends StatelessWidget {
  final String currentStatus;

  const _OrderStepper({required this.currentStatus});

  @override
  Widget build(BuildContext context) {
    final currentIdx = _statusSteps.indexOf(currentStatus);

    final stepData = [
      (icon: Icons.hourglass_empty_rounded, label: 'الانتظار'),
      (icon: Icons.settings_rounded,        label: 'المعالجة'),
      (icon: Icons.local_shipping_rounded,  label: 'الشحن'),
      (icon: Icons.check_circle_rounded,    label: 'التسليم'),
    ];

    return Row(
      children: List.generate(stepData.length * 2 - 1, (i) {
        // Even indices → step circles
        if (i % 2 == 0) {
          final stepIdx = i ~/ 2;
          final isDone = stepIdx <= currentIdx;
          final isActive = stepIdx == currentIdx;
          final color = isDone
              ? (isActive
                  ? (_statusColors[currentStatus] ?? AppColors.primary)
                  : AppColors.success)
              : const Color(0xFFDDD6CF);

          return Flexible(
            flex: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  width: isActive ? 36 : 28,
                  height: isActive ? 36 : 28,
                  decoration: BoxDecoration(
                    color: isDone ? color : color.withAlpha(76),
                    shape: BoxShape.circle,
                    boxShadow: isActive
                        ? [
                            BoxShadow(
                              color: color.withAlpha(102),
                              blurRadius: 8,
                              spreadRadius: 1,
                            )
                          ]
                        : [],
                  ),
                  child: Icon(
                    isDone && !isActive
                        ? Icons.check
                        : stepData[stepIdx].icon,
                    color: isDone ? Colors.white : Colors.white70,
                    size: isActive ? 18 : 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stepData[stepIdx].label,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal,
                    color: isDone ? color : const Color(0xFFBBB0A8),
                  ),
                ),
              ],
            ),
          );
        }

        // Odd indices → connector lines
        final lineIdx = i ~/ 2;
        final isDone = lineIdx < currentIdx;
        return Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: isDone ? AppColors.success : const Color(0xFFDDD6CF),
            ),
          ),
        );
      }),
    );
  }
}
