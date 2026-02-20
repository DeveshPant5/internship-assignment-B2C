import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'order_tracking_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen>
    with TickerProviderStateMixin {
  List<dynamic> _orders = [];
  bool _loading = true;
  String? _error;
  String _filter = 'All';
  late AnimationController _headerCtrl;
  late AnimationController _listCtrl;
  late Animation<double> _headerFade;
  late Animation<Offset> _headerSlide;

  static const _filters = ['All', 'Active', 'Delivered'];

  static const pink = Color(0xFFF48FB1);
  static const darkPink = Color(0xFFEC407A);
  static const lightPink = Color(0xFFFCE4EC);

  @override
  void initState() {
    super.initState();
    _headerCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _listCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _headerFade =
        CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic);
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.3), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOutCubic));
    _loadOrders();
  }

  @override
  void dispose() {
    _headerCtrl.dispose();
    _listCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final orders = await ApiService.getOrders();
      setState(() {
        _orders = orders;
        _loading = false;
      });
      _headerCtrl.forward(from: 0);
      _listCtrl.forward(from: 0);
    } catch (e) {
      setState(() {
        _error = 'Failed to load orders';
        _loading = false;
      });
      _headerCtrl.forward(from: 0);
    }
  }

  List<dynamic> get _filteredOrders {
    if (_filter == 'Active') {
      return _orders
          .where((o) => (o['status'] ?? 'PLACED') != 'DELIVERED')
          .toList();
    } else if (_filter == 'Delivered') {
      return _orders
          .where((o) => (o['status'] ?? '') == 'DELIVERED')
          .toList();
    }
    return _orders;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Column(
        children: [
          SlideTransition(
            position: _headerSlide,
            child: FadeTransition(
              opacity: _headerFade,
              child: _buildHeader(),
            ),
          ),

          if (_orders.isNotEmpty)
            FadeTransition(
              opacity: _headerFade,
              child: _buildFilterRow(),
            ),

          Expanded(
            child: _loading
                ? _buildLoadingState()
                : _error != null
                    ? _buildErrorState()
                    : _orders.isEmpty
                        ? _buildEmptyState()
                        : _filteredOrders.isEmpty
                            ? _buildNoResults()
                            : RefreshIndicator(
                                color: pink,
                                onRefresh: _loadOrders,
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(
                                      parent:
                                          AlwaysScrollableScrollPhysics()),
                                  padding: const EdgeInsets.fromLTRB(
                                      20, 8, 20, 24),
                                  itemCount: _filteredOrders.length,
                                  itemBuilder: (_, i) => _buildOrderCard(
                                      context, _filteredOrders[i], i),
                                ),
                              ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFEC407A), Color(0xFFF48FB1), Color(0xFFFFB3C6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.receipt_long_rounded,
                        size: 22, color: Colors.white),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Text('My Orders',
                        style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                            letterSpacing: -0.5)),
                  ),
                  if (_orders.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.4),
                            width: 1),
                      ),
                      child: Text(
                        '${_orders.length} orders',
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white),
                      ),
                    ),
                ],
              ),
              if (_orders.isNotEmpty) ...[
                const SizedBox(height: 20),
                Row(
                  children: [
                    _buildHeaderStat(
                        '${_orders.where((o) => (o['status'] ?? '') != 'DELIVERED').length}',
                        'Active'),
                    const SizedBox(width: 24),
                    _buildHeaderStat(
                        '${_orders.where((o) => (o['status'] ?? '') == 'DELIVERED').length}',
                        'Delivered'),
                    const SizedBox(width: 24),
                    _buildHeaderStat('${_orders.length}', 'Total'),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white)),
        Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white.withValues(alpha: 0.75))),
      ],
    );
  }

  Widget _buildFilterRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: _filters.map((f) {
          final isActive = _filter == f;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 10),
                decoration: BoxDecoration(
                  gradient: isActive
                      ? const LinearGradient(colors: [
                          Color(0xFFF48FB1),
                          Color(0xFFEC407A)
                        ])
                      : null,
                  color: isActive ? null : Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  border: isActive
                      ? null
                      : Border.all(color: Colors.grey.shade200),
                  boxShadow: isActive
                      ? [
                          BoxShadow(
                            color: pink.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: Text(f,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? Colors.white
                            : Colors.grey.shade600)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: lightPink,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                  color: darkPink, strokeWidth: 2.5),
            ),
          ),
          const SizedBox(height: 16),
          Text('Loading orders...',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade500,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        lightPink,
                        pink.withValues(alpha: 0.1)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: pink.withValues(alpha: 0.15),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('📋', style: TextStyle(fontSize: 46)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('No orders yet',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5)),
            const SizedBox(height: 10),
            Text(
              'When you place an order,\nit will appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500,
                  height: 1.6),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: lightPink,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.filter_list_off_rounded,
                size: 36, color: pink),
          ),
          const SizedBox(height: 16),
          Text('No $_filter orders',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded,
                size: 36, color: Colors.red.shade300),
          ),
          const SizedBox(height: 20),
          Text(_error!,
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text('Please check your connection',
              style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade400,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadOrders,
            style: ElevatedButton.styleFrom(
              backgroundColor: pink,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(
                  horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50)),
            ),
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Try Again',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(
      BuildContext context, Map<String, dynamic> order, int index) {
    final status = order['status'] ?? 'PLACED';
    final isDelivered = status == 'DELIVERED';
    final items = order['items'] as List<dynamic>? ?? [];
    final orderRef = order['order_ref'] ?? 'Order #${order['id']}';
    final total = order['total'] ?? 0;
    final statusConfig = _getStatusConfig(status);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 400 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () {
          final orderId = order['id'] ?? order['order_id'];
          if (orderId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => OrderTrackingScreen(orderId: orderId),
              ),
            );
          }
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      statusConfig.color.withValues(alpha: 0.7),
                      statusConfig.color,
                    ],
                  ),
                  borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24)),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            statusConfig.color.withValues(alpha: 0.15),
                            statusConfig.color.withValues(alpha: 0.06),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Icon(statusConfig.icon,
                          size: 26, color: statusConfig.color),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(orderRef,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3)),
                          const SizedBox(height: 4),
                          Text(
                            '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusConfig.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: statusConfig.color.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              color: statusConfig.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(statusConfig.label,
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: statusConfig.color)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              if (items.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
                  child: SizedBox(
                    height: 32,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: items.length > 3 ? 4 : items.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        if (i == 3 && items.length > 3) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF0F0F0),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text('+${items.length - 3} more',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600)),
                          );
                        }
                        final item = items[i];
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: lightPink.withValues(alpha: 0.6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            item['product_name'] ?? 'Item',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: darkPink),
                          ),
                        );
                      },
                    ),
                  ),
                ),

              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 18, vertical: 14),
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        Colors.grey.shade200,
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Amount',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey.shade400,
                                letterSpacing: 0.3)),
                        const SizedBox(height: 2),
                        Text(
                            '₹${total is double ? total.toStringAsFixed(0) : total}',
                            style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: darkPink,
                                letterSpacing: -0.5)),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: isDelivered
                            ? LinearGradient(colors: [
                                Colors.green.shade400,
                                Colors.green.shade600,
                              ])
                            : const LinearGradient(colors: [
                                Color(0xFFF48FB1),
                                Color(0xFFEC407A),
                              ]),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (isDelivered
                                    ? Colors.green
                                    : pink)
                                .withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                              isDelivered
                                  ? Icons.check_circle_outline
                                  : Icons.local_shipping_outlined,
                              size: 16,
                              color: Colors.white),
                          const SizedBox(width: 8),
                          Text(
                              isDelivered ? 'Delivered' : 'Track Order',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  _StatusConfig _getStatusConfig(String status) {
    switch (status.toUpperCase()) {
      case 'DELIVERED':
        return _StatusConfig(
          icon: Icons.check_circle_outline,
          color: const Color(0xFF2E7D32),
          label: 'Delivered',
        );
      case 'IN_TRANSIT':
      case 'SHIPPED':
        return _StatusConfig(
          icon: Icons.local_shipping_outlined,
          color: const Color(0xFF1565C0),
          label: 'In Transit',
        );
      case 'PROCESSING':
        return _StatusConfig(
          icon: Icons.hourglass_bottom_rounded,
          color: const Color(0xFFE65100),
          label: 'Processing',
        );
      case 'CANCELLED':
        return _StatusConfig(
          icon: Icons.cancel_outlined,
          color: const Color(0xFFC62828),
          label: 'Cancelled',
        );
      default:
        return _StatusConfig(
          icon: Icons.inventory_2_outlined,
          color: const Color(0xFFEC407A),
          label: 'Placed',
        );
    }
  }
}

class _StatusConfig {
  final IconData icon;
  final Color color;
  final String label;

  _StatusConfig({
    required this.icon,
    required this.color,
    required this.label,
  });
}
