import 'package:flutter/material.dart';
import '../services/api_service.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen>
    with SingleTickerProviderStateMixin {
  List<dynamic> _items = [];
  bool _loading = true;
  String? _error;
  bool _placingOrder = false;
  final _promoCtrl = TextEditingController();
  bool _promoApplied = false;
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;

  static const pink = Color(0xFFF48FB1);
  static const darkPink = Color(0xFFEC407A);
  static const lightPink = Color(0xFFFCE4EC);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeIn =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _loadCart();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    _promoCtrl.dispose();
    super.dispose();
  }

  Future<void> reload() => _loadCart();

  Future<void> _loadCart() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final items = await ApiService.getCart();
      setState(() {
        _items = items;
        _loading = false;
      });
      _animCtrl.forward(from: 0);
    } catch (e) {
      setState(() {
        _error = 'Failed to load cart';
        _loading = false;
      });
      _animCtrl.forward(from: 0);
    }
  }

  Future<void> _removeItem(int productId) async {
    try {
      await ApiService.removeFromCart(productId);
      setState(() {
        _items.removeWhere((i) => i['product_id'] == productId);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to remove item'),
            backgroundColor: darkPink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  double get _subtotal => _items.fold(0.0, (sum, item) {
        final price = (item['product_price'] ?? 0).toDouble();
        final qty = (item['quantity'] ?? 1) as int;
        return sum + price * qty;
      });

  double get _delivery => _items.isEmpty ? 0 : (_subtotal > 500 ? 0 : 40);
  double get _discount => _promoApplied ? _subtotal * 0.2 : 0;
  double get _total => _subtotal + _delivery - _discount;

  Future<void> _placeOrder() async {
    setState(() => _placingOrder = true);
    try {
      await ApiService.createOrder();
      if (mounted) {
        setState(() {
          _items = [];
          _placingOrder = false;
        });
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() => _placingOrder = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to place order'),
            backgroundColor: Colors.red.shade400,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28)),
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF66BB6A), Color(0xFF43A047)],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    size: 40, color: Colors.white),
              ),
              const SizedBox(height: 24),
              const Text('Order Placed!',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5)),
              const SizedBox(height: 10),
              Text(
                'Your order has been placed\nsuccessfully. Track it in Orders.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                    height: 1.6),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: darkPink,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Done',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFEC407A),
                  Color(0xFFF48FB1),
                  Color(0xFFFFB3C6)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius:
                  BorderRadius.vertical(bottom: Radius.circular(32)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.shopping_bag_rounded,
                          size: 22, color: Colors.white),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Text('My Cart',
                          style: TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.5)),
                    ),
                    if (_items.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 7),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4)),
                        ),
                        child: Text(
                          '${_items.length} ${_items.length == 1 ? 'item' : 'items'}',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.white),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: _loading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: pink, strokeWidth: 2.5))
                : _error != null
                    ? _buildErrorState()
                    : _items.isEmpty
                        ? _buildEmptyState()
                        : FadeTransition(
                            opacity: _fadeIn,
                            child: ListView(
                              physics: const BouncingScrollPhysics(),
                              padding:
                                  const EdgeInsets.fromLTRB(20, 16, 20, 24),
                              children: [
                                ..._items.asMap().entries.map((e) =>
                                    _buildCartItem(e.value, e.key)),
                                const SizedBox(height: 8),
                                _buildPromoSection(),
                                const SizedBox(height: 16),
                                _buildOrderSummary(),
                                const SizedBox(height: 20),
                                _buildPlaceOrderButton(),
                              ],
                            ),
                          ),
          ),
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
                    child: Text('🛒', style: TextStyle(fontSize: 46)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            const Text('Your cart is empty',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5)),
            const SizedBox(height: 10),
            Text(
              'Add items to your cart\nto get started',
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

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.wifi_off_rounded,
                size: 36, color: Colors.red.shade300),
          ),
          const SizedBox(height: 16),
          Text(_error!,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadCart,
            style: ElevatedButton.styleFrom(
              backgroundColor: pink,
              foregroundColor: Colors.white,
              elevation: 0,
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

  Widget _buildCartItem(Map<String, dynamic> item, int index) {
    final qty = item['quantity'] ?? 1;
    final price = (item['product_price'] ?? 0).toDouble();

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 70),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: Dismissible(
        key: ValueKey(item['product_id']),
        direction: DismissDirection.endToStart,
        onDismissed: (_) => _removeItem(item['product_id']),
        background: Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Colors.red.shade400,
            borderRadius: BorderRadius.circular(22),
          ),
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 24),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: Colors.white, size: 26),
              SizedBox(height: 4),
              Text('Remove',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        child: Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      lightPink,
                      pink.withValues(alpha: 0.25),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: pink.withValues(alpha: 0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.shopping_bag_outlined,
                    size: 32,
                    color: darkPink,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['product_name'] ?? 'Item',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.w700),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _removeItem(item['product_id']),
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.close,
                                size: 14, color: Colors.red.shade400),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text('₹${price.toStringAsFixed(0)} each',
                        style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: lightPink.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _buildQtyBtn(Icons.remove, () {}, pink),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14),
                                child: Text('$qty',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w800)),
                              ),
                              _buildQtyBtn(Icons.add, () {}, pink),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '₹${(price * qty).toStringAsFixed(0)}',
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: darkPink),
                        ),
                      ],
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

  Widget _buildQtyBtn(IconData icon, VoidCallback onTap, Color color) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 14, color: color),
      ),
    );
  }

  Widget _buildPromoSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: lightPink,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.local_offer_outlined,
                size: 18, color: darkPink),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _promoCtrl,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                hintText: 'Enter promo code',
                hintStyle: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade400,
                    fontWeight: FontWeight.w400),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (_promoCtrl.text.trim().toUpperCase() == 'FRESH20') {
                setState(() => _promoApplied = true);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.check_circle, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text('Promo applied! 20% off'),
                      ],
                    ),
                    backgroundColor: Colors.green.shade500,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Invalid promo code'),
                    backgroundColor: Colors.red.shade400,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                gradient: _promoApplied
                    ? const LinearGradient(
                        colors: [Color(0xFF66BB6A), Color(0xFF43A047)])
                    : const LinearGradient(
                        colors: [Color(0xFFF48FB1), Color(0xFFEC407A)]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _promoApplied ? 'Applied ✓' : 'Apply',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Order Summary',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          _summaryRow('Subtotal', '₹${_subtotal.toStringAsFixed(0)}',
              false),
          const SizedBox(height: 10),
          _summaryRow(
              'Delivery Fee',
              _delivery == 0 ? 'FREE' : '₹${_delivery.toStringAsFixed(0)}',
              false,
              valueColor:
                  _delivery == 0 ? Colors.green.shade600 : null),
          if (_promoApplied) ...[
            const SizedBox(height: 10),
            _summaryRow('Promo (FRESH20)',
                '-₹${_discount.toStringAsFixed(0)}', false,
                valueColor: Colors.green.shade600),
          ],
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
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
          _summaryRow(
              'Total', '₹${_total.toStringAsFixed(0)}', true),
          if (_delivery == 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.local_shipping_outlined,
                      size: 14, color: Colors.green.shade600),
                  const SizedBox(width: 6),
                  Text('Free delivery on orders above ₹500',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.green.shade700)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value, bool isTotal,
      {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: isTotal ? 16 : 14,
                fontWeight:
                    isTotal ? FontWeight.w800 : FontWeight.w500,
                color: isTotal ? Colors.black87 : Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
                fontSize: isTotal ? 22 : 14,
                fontWeight:
                    isTotal ? FontWeight.w900 : FontWeight.w600,
                color: valueColor ??
                    (isTotal ? darkPink : Colors.black87),
                letterSpacing: isTotal ? -0.5 : 0)),
      ],
    );
  }

  Widget _buildPlaceOrderButton() {
    return Container(
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: pink.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _placingOrder ? null : _placeOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
        ),
        child: _placingOrder
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.shopping_cart_checkout,
                      size: 20, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    'Place Order  •  ₹${_total.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white),
                  ),
                ],
              ),
      ),
    );
  }
}
