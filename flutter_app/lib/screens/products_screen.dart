import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<dynamic> _products = [];
  List<dynamic> _categories = [];
  bool _loading = true;
  String? _error;
  String? _selectedCategory;
  final _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final cats = await ApiService.getCategories();
      final prods = await ApiService.getProducts();
      setState(() {
        _categories = cats;
        _products = prods;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load products';
        _loading = false;
      });
    }
  }

  List<dynamic> get _filtered {
    var items = _products;
    if (_selectedCategory != null) {
      items = items
          .where((p) => p['category'] == _selectedCategory)
          .toList();
    }
    final q = _searchCtrl.text.toLowerCase();
    if (q.isNotEmpty) {
      items = items
          .where((p) =>
              (p['name'] ?? '').toString().toLowerCase().contains(q))
          .toList();
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFF48FB1);
    const darkPink = Color(0xFFEC407A);
    const lightPink = Color(0xFFFCE4EC);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                children: [
                  const Text('Browse',
                      style: TextStyle(
                          fontSize: 24, fontWeight: FontWeight.w800)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: lightPink,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_products.length} items',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: darkPink),
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    prefixIcon: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        width: 32, height: 32,
                        decoration: BoxDecoration(
                          color: lightPink,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.search,
                            size: 18, color: pink),
                      ),
                    ),
                    hintText: 'Search products...',
                    hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 14,
                        fontWeight: FontWeight.w500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
            ),

            // Category chips
            SizedBox(
              height: 52,
              child: _loading
                  ? const SizedBox()
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      itemCount: _categories.length + 1,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: 8),
                      itemBuilder: (_, i) {
                        if (i == 0) {
                          final isAll = _selectedCategory == null;
                          return _buildChip('All', isAll);
                        }
                        final cat = _categories[i - 1];
                        final name = cat['name'] ?? '';
                        final isSelected = _selectedCategory == name;
                        return _buildChip(name, isSelected,
                            onTap: () => setState(() =>
                                _selectedCategory =
                                    isSelected ? null : name));
                      },
                    ),
            ),

            const SizedBox(height: 14),

            // Grid
            Expanded(
              child: _loading
                  ? const Center(
                      child: CircularProgressIndicator(color: pink))
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64, height: 64,
                                decoration: const BoxDecoration(
                                  color: lightPink,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.error_outline,
                                    size: 28, color: pink),
                              ),
                              const SizedBox(height: 14),
                              Text(_error!,
                                  style: TextStyle(
                                      color: Colors.grey.shade500,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: pink,
                                  foregroundColor: Colors.white,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(50)),
                                ),
                                icon: const Icon(Icons.refresh, size: 18),
                                label: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : _filtered.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 64, height: 64,
                                    decoration: const BoxDecoration(
                                      color: lightPink,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                        Icons.search_off_rounded,
                                        size: 28,
                                        color: pink),
                                  ),
                                  const SizedBox(height: 14),
                                  const Text('No products found',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text('Try a different search term',
                                      style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade400)),
                                ],
                              ),
                            )
                          : GridView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                  20, 0, 20, 20),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.95,
                                crossAxisSpacing: 14,
                                mainAxisSpacing: 14,
                              ),
                              itemCount: _filtered.length,
                              itemBuilder: (_, i) {
                                final p = _filtered[i];
                                return _buildProductCard(context, p);
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, {VoidCallback? onTap}) {
    const pink = Color(0xFFF48FB1);
    return GestureDetector(
      onTap: onTap ?? () => setState(() => _selectedCategory = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [Color(0xFFF48FB1), Color(0xFFEC407A)])
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(50),
          border: isSelected
              ? null
              : Border.all(color: Colors.grey.shade200),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: pink.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600)),
      ),
    );
  }

  Widget _buildProductCard(
      BuildContext context, Map<String, dynamic> p) {
    const pink = Color(0xFFF48FB1);
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(product: p),
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
                height: 120,
                child: Stack(
                  children: [
                    Container(
                    width: double.infinity,
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCE4EC),
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: _buildProductImage(p['image_url'], 20),
                  ),
                  Positioned(
                    top: 10, right: 10,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: pink.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p['name'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 3),
                  Text(p['description'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey.shade400)),
                  const SizedBox(height: 8),
                  Text('₹${p['price'] ?? '0'}',
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFEC407A))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String? imageUrl, double topRadius) {
    final isUrl = imageUrl != null &&
        (imageUrl.startsWith('http://') || imageUrl.startsWith('https://'));

    if (isUrl) {
      return ClipRRect(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(topRadius)),
        child: Image.network(
          imageUrl,
          width: double.infinity,
          height: double.infinity,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return Container(
              color: const Color(0xFFFCE4EC).withValues(alpha: 0.4),
              child: const Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFF48FB1),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stack) => const Center(
            child: Icon(Icons.image_not_supported_outlined,
                size: 36, color: Color(0xFFF48FB1)),
          ),
        ),
      );
    }

    return Center(
      child: Text(imageUrl ?? '📦', style: const TextStyle(fontSize: 48)),
    );
  }
}
