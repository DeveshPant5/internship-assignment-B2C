import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProductDetailScreen extends StatefulWidget {
  final Map<String, dynamic> product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _qty = 1;
  bool _adding = false;

  Future<void> _addToCart() async {
    setState(() => _adding = true);
    try {
      await ApiService.addToCart(
        widget.product['id'],
        widget.product['name'] ?? '',
        (widget.product['price'] as num?)?.toDouble() ?? 0,
        quantity: _qty,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 10),
                Text('${widget.product['name']} added to cart'),
              ],
            ),
            backgroundColor: const Color(0xFFEC407A),
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final price = (p['price'] as num?)?.toDouble() ?? 0;
    const pink = Color(0xFFF48FB1);
    const darkPink = Color(0xFFEC407A);
    const lightPink = Color(0xFFFCE4EC);
    final available = p['available'] ?? true;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Image area
                SliverToBoxAdapter(
                  child: Stack(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 280,
                        child: Hero(
                          tag: 'product_${p['id']}',
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(32)),
                            child: _buildProductImage(
                                p['image_url'] as String?),
                          ),
                        ),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        left: 16,
                        child: _buildCircleButton(
                            Icons.arrow_back_ios_new, () => Navigator.pop(context)),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: 56,
                        child: _buildCircleButton(Icons.share_outlined, () {}),
                      ),
                      Positioned(
                        top: MediaQuery.of(context).padding.top + 10,
                        right: 16,
                        child: _buildCircleButton(Icons.favorite_outline, () {}),
                      ),
                    ],
                  ),
                ),

                // Product info
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category badge
                        if (p['category'] != null)
                          Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            decoration: BoxDecoration(
                              color: lightPink,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(p['category'],
                                style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: darkPink)),
                          ),

                        // Name
                        Text(p['name'] ?? '',
                            style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.w900,
                                height: 1.2,
                                letterSpacing: -0.5)),
                        const SizedBox(height: 16),

                        // Price row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: pink.withValues(alpha: 0.25),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Text(
                                '₹${price.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 14),
                            // Availability badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: available
                                    ? Colors.green.shade50
                                    : Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: available
                                      ? Colors.green.shade200
                                      : Colors.red.shade200,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    available
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    size: 14,
                                    color: available
                                        ? Colors.green.shade600
                                        : Colors.red.shade600,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    available ? 'In Stock' : 'Out of Stock',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: available
                                          ? Colors.green.shade600
                                          : Colors.red.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 28),

                        // Description section
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 32, height: 32,
                                    decoration: BoxDecoration(
                                      color: lightPink,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.info_outline,
                                        size: 16, color: darkPink),
                                  ),
                                  const SizedBox(width: 10),
                                  const Text('Product Details',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                p['description'] ??
                                    'No description available.',
                                style: TextStyle(
                                    fontSize: 14,
                                    height: 1.6,
                                    color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Quantity selector
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF9F9F9),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.grey.shade100),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32, height: 32,
                                decoration: BoxDecoration(
                                  color: lightPink,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.shopping_bag_outlined,
                                    size: 16, color: darkPink),
                              ),
                              const SizedBox(width: 10),
                              const Text('Quantity',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700)),
                              const Spacer(),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(50),
                                  border: Border.all(
                                      color: Colors.grey.shade200,
                                      width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    _buildQtyButton(Icons.remove, () {
                                      if (_qty > 1) setState(() => _qty--);
                                    }),
                                    SizedBox(
                                      width: 44,
                                      child: Text('$_qty',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                              fontSize: 17,
                                              fontWeight: FontWeight.w800)),
                                    ),
                                    _buildQtyButton(Icons.add, () {
                                      setState(() => _qty++);
                                    }),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Add to Cart bar
          Container(
            padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: (!available || _adding) ? null : _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: Colors.grey.shade200,
                  elevation: 0,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                ),
                child: Ink(
                  decoration: BoxDecoration(
                    gradient: available
                        ? const LinearGradient(
                            colors: [Color(0xFFF48FB1), Color(0xFFEC407A)])
                        : null,
                    color: available ? null : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: available
                        ? [
                            BoxShadow(
                              color: pink.withValues(alpha: 0.35),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : null,
                  ),
                  child: Container(
                    alignment: Alignment.center,
                    child: _adding
                        ? const SizedBox(
                            height: 22, width: 22,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: Colors.white))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.shopping_bag_rounded,
                                  size: 20, color: Colors.white),
                              const SizedBox(width: 10),
                              Text(
                                  'Add to Cart  •  ₹${(price * _qty).toStringAsFixed(0)}',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildProductImage(String? imageUrl) {
    const bg = Color(0xFFFCE4EC);
    const pink = Color(0xFFF48FB1);
    final isUrl = imageUrl != null &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));
    if (isUrl) {
      return Image.network(
        imageUrl,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            color: bg,
            child: const Center(
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: pink,
                ),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stack) => Container(
          color: bg,
          child: const Center(
            child: Icon(Icons.image_not_supported_outlined,
                size: 56, color: pink),
          ),
        ),
      );
    }
    return Container(
      color: bg,
      child: const Center(
        child: Icon(Icons.shopping_bag_outlined, size: 72, color: pink),
      ),
    );
  }

  Widget _buildCircleButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.black87),
      ),
    );
  }

  Widget _buildQtyButton(IconData icon, VoidCallback onTap) {
    const pink = Color(0xFFF48FB1);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38, height: 38,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: pink.withValues(alpha: 0.3),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: Colors.white),
      ),
    );
  }
}

