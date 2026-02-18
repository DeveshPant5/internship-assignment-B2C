import 'package:flutter/material.dart';
import '../services/api_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final int orderId;

  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _status;
  bool _loading = true;
  String? _error;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  static const _steps = ['PLACED', 'PACKED', 'OUT_FOR_DELIVERY', 'DELIVERED'];
  static const _stepLabels = [
    'Order Placed',
    'Order Packed',
    'Out for Delivery',
    'Delivered',
  ];
  static const _stepDescriptions = [
    'We have received your order',
    'Your order is being prepared',
    'On the way to your location',
    'Your order has been delivered',
  ];
  static const _stepIcons = [
    Icons.receipt_long_outlined,
    Icons.inventory_2_outlined,
    Icons.local_shipping_outlined,
    Icons.check_circle_outline,
  ];

  static const pink = Color(0xFFF48FB1);
  static const darkPink = Color(0xFFEC407A);
  static const lightPink = Color(0xFFFCE4EC);

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1200))
      ..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.85, end: 1.15).animate(
        CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    _loadStatus();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadStatus() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final status = await ApiService.getOrderStatus(widget.orderId);
      setState(() {
        _status = status;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load status';
        _loading = false;
      });
    }
  }

  int get _currentStep {
    final currentStatus = _status?['status'] ?? 'PLACED';
    final index = _steps.indexOf(currentStatus);
    return index >= 0 ? index : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: pink))
          : _error != null
              ? SafeArea(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: lightPink,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.error_outline,
                              size: 32, color: pink),
                        ),
                        const SizedBox(height: 16),
                        Text(_error!,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600)),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _loadStatus,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: pink,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50)),
                          ),
                          icon: const Icon(Icons.refresh, size: 18),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : Column(
                  children: [
                    // ── Map / Hero area ──
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 300,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFFE8EAF6),
                                Color(0xFFD1D5E8)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.vertical(
                                bottom: Radius.circular(36)),
                          ),
                          child: Stack(
                            children: [
                              // Grid lines
                              ...List.generate(
                                  8,
                                  (i) => Positioned(
                                        top: i * 38.0,
                                        left: 0,
                                        right: 0,
                                        child: Container(
                                            height: 0.5,
                                            color: Colors.grey.shade300
                                                .withValues(alpha: 0.4)),
                                      )),
                              ...List.generate(
                                  6,
                                  (i) => Positioned(
                                        left: i * 80.0,
                                        top: 0,
                                        bottom: 0,
                                        child: Container(
                                            width: 0.5,
                                            color: Colors.grey.shade300
                                                .withValues(alpha: 0.4)),
                                      )),
                              // Route line
                              Center(
                                child: Container(
                                  width: 3,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        darkPink.withValues(alpha: 0.3),
                                        darkPink,
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              ),
                              // Delivery icon with pulse
                              Center(
                                child: ScaleTransition(
                                  scale: _pulse,
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFFF48FB1),
                                          Color(0xFFEC407A)
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                          color: Colors.white, width: 3),
                                      boxShadow: [
                                        BoxShadow(
                                          color:
                                              pink.withValues(alpha: 0.4),
                                          blurRadius: 20,
                                          spreadRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: const Icon(
                                        Icons.delivery_dining,
                                        size: 28,
                                        color: Colors.white),
                                  ),
                                ),
                              ),
                              // LIVE badge
                              Positioned(
                                top: 155,
                                left: MediaQuery.of(context).size.width /
                                        2 -
                                    28,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A1A2E),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.circle,
                                          size: 6,
                                          color: Colors.greenAccent),
                                      SizedBox(width: 5),
                                      Text('LIVE',
                                          style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: 1.2)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Back button
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 12,
                          left: 16,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.1),
                                    blurRadius: 12,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.arrow_back_ios_new,
                                  size: 16, color: Colors.black87),
                            ),
                          ),
                        ),

                        // Order ID pill
                        Positioned(
                          top: MediaQuery.of(context).padding.top + 12,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 9),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 12,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 26,
                                  height: 26,
                                  decoration: BoxDecoration(
                                    color: lightPink,
                                    borderRadius:
                                        BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.tag,
                                      size: 14, color: darkPink),
                                ),
                                const SizedBox(width: 8),
                                Text('#${widget.orderId}',
                                    style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800)),
                              ],
                            ),
                          ),
                        ),

                        // ETA banner
                        Positioned(
                          bottom: 16,
                          left: 20,
                          right: 20,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 14),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFF1A1A2E),
                                  Color(0xFF16213E)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(22),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFF48FB1),
                                        Color(0xFFEC407A)
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                      Icons.access_time_rounded,
                                      size: 22,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Estimated Arrival',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade500,
                                              fontWeight:
                                                  FontWeight.w500)),
                                      const Row(
                                        children: [
                                          Text('10 mins',
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight:
                                                      FontWeight.w900,
                                                  color: Colors.white)),
                                          SizedBox(width: 10),
                                          Text('•  2.4 km',
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.white54,
                                                  fontWeight:
                                                      FontWeight.w500)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: Colors.white
                                        .withValues(alpha: 0.1),
                                    borderRadius:
                                        BorderRadius.circular(12),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.15)),
                                  ),
                                  child: const Text('LIVE',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w800,
                                          color: Colors.greenAccent,
                                          letterSpacing: 1)),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── Status stepper ──
                    Expanded(
                      child: ListView(
                        physics: const BouncingScrollPhysics(),
                        padding:
                            const EdgeInsets.fromLTRB(24, 24, 24, 20),
                        children: [
                          // Title
                          const Text('Order Status',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3)),
                          const SizedBox(height: 20),

                          ...List.generate(_steps.length, (i) {
                            final isCompleted = i <= _currentStep;
                            final isCurrent = i == _currentStep;
                            final isLast = i == _steps.length - 1;
                            final isPast = i < _currentStep;

                            return Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Column(
                                  children: [
                                    AnimatedContainer(
                                      duration: const Duration(
                                          milliseconds: 400),
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        gradient: isCompleted
                                            ? const LinearGradient(
                                                colors: [
                                                    Color(0xFFF48FB1),
                                                    Color(0xFFEC407A)
                                                  ])
                                            : null,
                                        color: isCompleted
                                            ? null
                                            : const Color(0xFFF0F0F0),
                                        borderRadius:
                                            BorderRadius.circular(16),
                                        boxShadow: isCurrent
                                            ? [
                                                BoxShadow(
                                                  color: pink.withValues(
                                                      alpha: 0.35),
                                                  blurRadius: 14,
                                                  offset: const Offset(
                                                      0, 4),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Icon(
                                        isPast
                                            ? Icons.check_rounded
                                            : _stepIcons[i],
                                        size: 20,
                                        color: isCompleted
                                            ? Colors.white
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                    if (!isLast)
                                      Container(
                                        width: 2,
                                        height: 44,
                                        margin: const EdgeInsets.symmetric(
                                            vertical: 4),
                                        decoration: BoxDecoration(
                                          gradient: isPast
                                              ? const LinearGradient(
                                                  colors: [
                                                      Color(0xFFF48FB1),
                                                      Color(0xFFEC407A)
                                                    ],
                                                  begin: Alignment.topCenter,
                                                  end: Alignment
                                                      .bottomCenter)
                                              : null,
                                          color: isPast
                                              ? null
                                              : Colors.grey.shade200,
                                          borderRadius:
                                              BorderRadius.circular(1),
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(_stepLabels[i],
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: isCompleted
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: isCompleted
                                                      ? Colors.black87
                                                      : Colors
                                                          .grey.shade400,
                                                )),
                                            if (isCurrent) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets
                                                    .symmetric(
                                                    horizontal: 8,
                                                    vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: lightPink,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          20),
                                                ),
                                                child: const Text(
                                                    'Current',
                                                    style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: darkPink)),
                                              ),
                                            ],
                                          ],
                                        ),
                                        const SizedBox(height: 3),
                                        Text(_stepDescriptions[i],
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: isCompleted
                                                  ? Colors.grey.shade500
                                                  : Colors.grey.shade400,
                                              fontWeight: FontWeight.w500,
                                            )),
                                        SizedBox(height: isLast ? 0 : 16),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }),

                          const SizedBox(height: 24),

                          // Address card
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color:
                                      Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: lightPink,
                                    borderRadius:
                                        BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                      Icons.location_on_outlined,
                                      size: 22,
                                      color: darkPink),
                                ),
                                const SizedBox(width: 14),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Delivery Address',
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500,
                                              color: Colors.grey)),
                                      SizedBox(height: 2),
                                      Text('Home — 123 Street',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight:
                                                  FontWeight.w700)),
                                    ],
                                  ),
                                ),
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F5F5),
                                    borderRadius:
                                        BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.arrow_forward_ios,
                                      size: 12,
                                      color: Colors.grey.shade400),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Refresh button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: _loadStatus,
                              icon: const Icon(Icons.refresh, size: 18),
                              label: const Text('Refresh Status',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w700)),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: darkPink,
                                side: BorderSide(
                                    color: pink.withValues(alpha: 0.4),
                                    width: 1.5),
                                shape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(16)),
                              ),
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
