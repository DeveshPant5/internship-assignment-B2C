import 'package:flutter/material.dart';
import 'order_tracking_screen.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFF48FB1);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),

              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: pink.withValues(alpha: 0.35),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(Icons.check_rounded,
                    size: 50, color: Colors.white),
              ),
              const SizedBox(height: 32),

              const Text('Order Placed\nSuccessfully! 🎉',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                      letterSpacing: -0.5)),
              const SizedBox(height: 14),
              Text(
                'Your order has been received and is\ncurrently being processed by our team.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 14,
                    height: 1.6,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 36),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade100),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildRow(
                      'Order ID',
                      order['order_ref'] ?? '#${order['id']}',
                      isBadge: true,
                    ),
                    const SizedBox(height: 16),
                    Container(height: 1, color: Colors.grey.shade100),
                    const SizedBox(height: 16),
                    _buildRow('Total', '₹${order['total'] ?? '-'}'),
                    const SizedBox(height: 16),
                    Container(height: 1, color: Colors.grey.shade100),
                    const SizedBox(height: 16),
                    _buildRow('Status', 'PLACED'),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    final orderId = order['id'] ?? order['order_id'];
                    if (orderId != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              OrderTrackingScreen(orderId: orderId),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: pink.withValues(alpha: 0.35),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Container(
                      alignment: Alignment.center,
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.local_shipping_outlined, size: 20),
                          SizedBox(width: 10),
                          Text('Track Order',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              GestureDetector(
                onTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text('Continue Shopping',
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87)),
                ),
              ),

              const SizedBox(height: 36),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isBadge = false}) {
    const pink = Color(0xFFF48FB1);
    const darkPink = Color(0xFFEC407A);
    const lightPink = Color(0xFFFCE4EC);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                fontWeight: FontWeight.w500)),
        isBadge
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: lightPink,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: pink.withValues(alpha: 0.3)),
                ),
                child: Text(value,
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: darkPink)),
              )
            : Text(value,
                style: const TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
