import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'products_screen.dart';
import 'cart_screen.dart';
import 'orders_screen.dart';
import 'profile_screen.dart';
import 'product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _navIndex = 0;
  final _cartKey = GlobalKey<CartScreenState>();

  @override
  Widget build(BuildContext context) {
    final screens = [
      _HomeTab(onSearchTap: () => setState(() => _navIndex = 1)),
      const ProductsScreen(),
      CartScreen(key: _cartKey),
      const OrdersScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _navIndex, children: screens),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const pink = Color(0xFFF48FB1);
    const darkPink = Color(0xFFEC407A);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, Icons.home_outlined, 'Home', 0, darkPink, pink),
              _navItem(Icons.search_rounded, Icons.search_outlined, 'Browse', 1, darkPink, pink),
              _navItem(Icons.shopping_bag_rounded, Icons.shopping_bag_outlined, 'Cart', 2, darkPink, pink),
              _navItem(Icons.receipt_long_rounded, Icons.receipt_long_outlined, 'Orders', 3, darkPink, pink),
              _navItem(Icons.person_rounded, Icons.person_outlined, 'Profile', 4, darkPink, pink),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData activeIcon, IconData inactiveIcon, String label,
      int index, Color darkPink, Color pink) {
    final isActive = _navIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _navIndex = index);
        if (index == 2) _cartKey.currentState?.reload();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isActive
                    ? LinearGradient(
                        colors: [
                          pink.withValues(alpha: 0.15),
                          darkPink.withValues(alpha: 0.08)
                        ],
                      )
                    : null,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                isActive ? activeIcon : inactiveIcon,
                size: 24,
                color: isActive ? darkPink : Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                  fontSize: 10,
                  fontWeight:
                      isActive ? FontWeight.w800 : FontWeight.w500,
                  color: isActive ? darkPink : Colors.grey.shade400),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTab extends StatefulWidget {
  final VoidCallback? onSearchTap;
  const _HomeTab({this.onSearchTap});

  @override
  State<_HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<_HomeTab> with TickerProviderStateMixin {
  List<dynamic> _categories = [];
  List<dynamic> _products = [];
  bool _loading = true;
  String? _error;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadData();
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
        _error = 'Failed to load data';
        _loading = false;
      });
    }
  }

  List<dynamic> get _filteredProducts {
    if (_selectedCategory == null) return _products.take(12).toList();
    return _products
        .where((p) => p['category'] == _selectedCategory)
        .toList();
  }

  static const _catEmojis = <String, String>{
    'Fruits & Vegetables': '🥬',
    'Dairy & Bakery': '🧈',
    'Snacks & Beverages': '🍿',
    'Meat & Fish': '🥩',
  };

  static const _catIcons = <String, IconData>{
    'Fruits & Vegetables': Icons.eco_rounded,
    'Dairy & Bakery': Icons.bakery_dining_rounded,
    'Snacks & Beverages': Icons.fastfood_rounded,
    'Meat & Fish': Icons.set_meal_rounded,
  };

  static const _catColors = <String, Color>{
    'Fruits & Vegetables': Color(0xFF43A047),
    'Dairy & Bakery': Color(0xFFF57C00),
    'Snacks & Beverages': Color(0xFF8E24AA),
    'Meat & Fish': Color(0xFFE53935),
  };

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFF48FB1);
    const darkPink = Color(0xFFEC407A);
    const lightPink = Color(0xFFFCE4EC);

    if (_loading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F8FC),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: darkPink, strokeWidth: 2.5),
              SizedBox(height: 16),
              Text('Loading fresh picks...',
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500)),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF7F8FC),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: lightPink,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    size: 36, color: pink),
              ),
              const SizedBox(height: 16),
              Text(_error!,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600)),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _loadData,
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
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: RefreshIndicator(
          color: pink,
          onRefresh: _loadData,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
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
                              blurRadius: 14,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.location_on_rounded,
                            size: 22, color: Colors.white),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DELIVERING TO',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: pink,
                                    letterSpacing: 1.2)),
                            const SizedBox(height: 2),
                            const Row(
                              children: [
                                Text('Home – 123 Street',
                                    style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(width: 4),
                                Icon(Icons.keyboard_arrow_down_rounded,
                                    size: 18, color: Colors.black54),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.06),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Stack(
                          children: [
                            Center(
                              child: Icon(Icons.notifications_outlined,
                                  size: 22, color: Colors.grey.shade700),
                            ),
                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: darkPink,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                  child: GestureDetector(
                    onTap: widget.onSearchTap,
                    child: Container(
                      height: 54,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xFFFCE4EC),
                                  Color(0xFFF8BBD0)
                                ],
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.search,
                                size: 18, color: darkPink),
                          ),
                          const SizedBox(width: 12),
                          Text('Search groceries, snacks...',
                              style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade400,
                                  fontWeight: FontWeight.w500)),
                          const Spacer(),
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: lightPink,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.tune_rounded,
                                    size: 14, color: darkPink),
                                SizedBox(width: 4),
                                Text('Filter',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: darkPink)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  height: 160,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEC407A),
                        Color(0xFFF48FB1),
                        Color(0xFFFFB3C6)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: pink.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 130,
                          height: 130,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.08),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        bottom: -20,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 20,
                        top: 18,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3)),
                          ),
                          child: const Text('🔥 HOT DEAL',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Get 20% OFF',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    height: 1.1,
                                    letterSpacing: -0.5)),
                            const SizedBox(height: 4),
                            Text('on your first order!',
                                style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white
                                        .withValues(alpha: 0.9))),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.black.withValues(alpha: 0.12),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Text('FRESH20',
                                  style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: Color(0xFFEC407A),
                                      letterSpacing: 1.5)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Categories',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      Text('See all',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: darkPink)),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 108,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                    itemCount: _categories.length + 1,
                    separatorBuilder: (_, _) => const SizedBox(width: 14),
                    itemBuilder: (_, i) {
                      if (i == 0) {
                        final isAll = _selectedCategory == null;
                        return _buildCatChip(
                            'All', '🛒', Icons.grid_view_rounded,
                            isAll, darkPink, null, () {
                          setState(() => _selectedCategory = null);
                        });
                      }
                      final cat = _categories[i - 1];
                      final name = cat['name'] ?? '';
                      final isSelected = _selectedCategory == name;
                      return _buildCatChip(
                        name.length > 10 ? '${name.substring(0, 9)}…' : name,
                        _catEmojis[name] ?? '📦',
                        _catIcons[name] ?? Icons.category_rounded,
                        isSelected,
                        _catColors[name] ?? darkPink,
                        _catColors[name],
                        () {
                          setState(() =>
                              _selectedCategory = isSelected ? null : name);
                        },
                      );
                    },
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Popular Products',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800)),
                      GestureDetector(
                        onTap: widget.onSearchTap,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 7),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFFCE4EC),
                                Color(0xFFF8BBD0)
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('See all',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: darkPink)),
                              const SizedBox(width: 4),
                              Icon(Icons.arrow_forward_ios,
                                  size: 10, color: darkPink),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.78,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final p = _filteredProducts[index];
                      return _ProductCard(product: p, index: index);
                    },
                    childCount: _filteredProducts.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCatChip(String label, String emoji, IconData icon,
      bool isSelected, Color activeColor, Color? catColor, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        activeColor,
                        activeColor.withValues(alpha: 0.7)
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                if (isSelected)
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  )
                else
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
              ],
            ),
            child: Center(
              child: isSelected
                  ? Icon(icon, size: 26, color: Colors.white)
                  : Text(emoji, style: const TextStyle(fontSize: 26)),
            ),
          ),
          const SizedBox(height: 8),
          Text(label,
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight:
                      isSelected ? FontWeight.w800 : FontWeight.w500,
                  color: isSelected
                      ? activeColor
                      : Colors.grey.shade600)),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final int index;

  const _ProductCard({required this.product, required this.index});

  @override
  Widget build(BuildContext context) {
    const pink = Color(0xFFF48FB1);
    const darkPink = Color(0xFFEC407A);
    const lightPink = Color(0xFFFCE4EC);

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + index * 60),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - value)),
          child: child,
        ),
      ),
      child: GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 18,
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
                      decoration: BoxDecoration(
                        color: lightPink.withValues(alpha: 0.3),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(22)),
                      ),
                      child: _buildProductImage(product['image_url'], 22),
                    ),
                    Positioned(
                      top: 10,
                      right: 10,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.favorite_border_rounded,
                            size: 16, color: Colors.grey),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 10,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFFF48FB1),
                              Color(0xFFEC407A)
                            ],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: pink.withValues(alpha: 0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
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
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(product['name'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(product['description'] ?? '',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade400,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${product['price'] ?? '0'}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: darkPink,
                                letterSpacing: -0.3)),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: lightPink,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            product['unit'] ?? '1 kg',
                            style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: darkPink),
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
      ),
    );
  }

  static Widget _buildProductImage(String? imageUrl, double topRadius) {
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
              color: const Color(0xFFFCE4EC).withValues(alpha: 0.3),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFF48FB1),
                  ),
                ),
              ),
            );
          },
          errorBuilder: (context, error, stack) => Container(
            color: const Color(0xFFFCE4EC).withValues(alpha: 0.3),
            child: const Center(
              child: Icon(Icons.image_not_supported_outlined,
                  size: 36, color: Color(0xFFF48FB1)),
            ),
          ),
        ),
      );
    }

    return Center(
      child: Text(
        imageUrl ?? '📦',
        style: const TextStyle(fontSize: 48),
      ),
    );
  }
}
