import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'orders_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  Map<String, dynamic>? _profile;
  bool _loading = true;
  String _userName = '';
  String _userEmail = '';
  late AnimationController _animCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideIn;

  static const pink = Color(0xFFF48FB1);
  static const darkPink = Color(0xFFEC407A);
  static const lightPink = Color(0xFFFCE4EC);

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeIn =
        CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic);
    _slideIn = Tween<Offset>(
            begin: const Offset(0, 0.15), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _animCtrl, curve: Curves.easeOutCubic));
    _loadProfile();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() => _loading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      _userName = prefs.getString('user_name') ?? '';
      _userEmail = '';

      final p = await ApiService.getProfile();
      setState(() {
        _profile = p;
        _userName = p['name'] ?? _userName;
        _userEmail = p['email'] ?? '';
        _loading = false;
      });
      _animCtrl.forward();
    } catch (_) {
      setState(() => _loading = false);
      _animCtrl.forward();
    }
  }

  String get _initials {
    final name = _userName.isNotEmpty ? _userName : (_profile?['name'] ?? 'U');
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String get _greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  void _showComingSoon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Text('$feature — coming soon!'),
          ],
        ),
        backgroundColor: darkPink,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: pink))
          : FadeTransition(
              opacity: _fadeIn,
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ── Premium gradient header ──
                  SliverToBoxAdapter(
                    child: Container(
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
                        borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(36)),
                      ),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
                          child: Column(
                            children: [
                              // Top bar
                              Row(
                                children: [
                                  const Text('My Profile',
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: -0.5)),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () =>
                                        _showComingSoon('Settings'),
                                    child: Container(
                                      width: 42,
                                      height: 42,
                                      decoration: BoxDecoration(
                                        color: Colors.white
                                            .withValues(alpha: 0.2),
                                        borderRadius:
                                            BorderRadius.circular(14),
                                        border: Border.all(
                                            color: Colors.white
                                                .withValues(alpha: 0.3)),
                                      ),
                                      child: const Icon(
                                          Icons.settings_outlined,
                                          size: 20,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // Avatar with edit button
                              Stack(
                                children: [
                                  Container(
                                    width: 96,
                                    height: 96,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                      border: Border.all(
                                          color: Colors.white
                                              .withValues(alpha: 0.7),
                                          width: 4),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.18),
                                          blurRadius: 24,
                                          offset: const Offset(0, 10),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Text(
                                        _initials,
                                        style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w900,
                                            color: darkPink),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 30,
                                      height: 30,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black
                                                .withValues(alpha: 0.12),
                                            blurRadius: 8,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                          Icons.camera_alt_outlined,
                                          size: 14,
                                          color: darkPink),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              // Greeting + Name
                              Text('$_greeting,',
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white
                                          .withValues(alpha: 0.8))),
                              const SizedBox(height: 4),
                              Text(
                                _userName.isNotEmpty ? _userName : 'User',
                                style: const TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: -0.5),
                              ),
                              if (_userEmail.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    color:
                                        Colors.white.withValues(alpha: 0.2),
                                    borderRadius:
                                        BorderRadius.circular(20),
                                    border: Border.all(
                                        color: Colors.white
                                            .withValues(alpha: 0.3)),
                                  ),
                                  child: Text(_userEmail,
                                      style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white
                                              .withValues(alpha: 0.9))),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Stats row (floating card) ──
                  SliverToBoxAdapter(
                    child: SlideTransition(
                      position: _slideIn,
                      child: Transform.translate(
                        offset: const Offset(0, -24),
                        child: Padding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black
                                      .withValues(alpha: 0.08),
                                  blurRadius: 24,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                _buildStat(
                                    Icons.shopping_bag_outlined,
                                    'Orders',
                                    '${_profile?['order_count'] ?? 0}',
                                    darkPink),
                                _buildStatDivider(),
                                _buildStat(
                                    Icons.favorite_outline,
                                    'Wishlist',
                                    '${_profile?['wishlist_count'] ?? 0}',
                                    Colors.redAccent),
                                _buildStatDivider(),
                                _buildStat(
                                    Icons.local_offer_outlined,
                                    'Coupons',
                                    '${_profile?['coupon_count'] ?? 3}',
                                    Colors.orange),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── Account section ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                      child: Text('ACCOUNT',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade400,
                              letterSpacing: 1.5)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildMenuCard([
                        _MenuItemData(
                          icon: Icons.person_outline,
                          label: 'Edit Profile',
                          bgColor: lightPink,
                          iconColor: darkPink,
                          onTap: () => _showComingSoon('Edit Profile'),
                        ),
                        _MenuItemData(
                          icon: Icons.location_on_outlined,
                          label: 'Delivery Address',
                          bgColor: lightPink,
                          iconColor: darkPink,
                          onTap: () =>
                              _showComingSoon('Delivery Address'),
                        ),
                        _MenuItemData(
                          icon: Icons.payment_outlined,
                          label: 'Payment Methods',
                          bgColor: lightPink,
                          iconColor: darkPink,
                          onTap: () =>
                              _showComingSoon('Payment Methods'),
                        ),
                      ]),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 20)),

                  // ── General section ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
                      child: Text('GENERAL',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.shade400,
                              letterSpacing: 1.5)),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: _buildMenuCard([
                        _MenuItemData(
                          icon: Icons.receipt_long_outlined,
                          label: 'Order History',
                          bgColor: const Color(0xFFE8F5E9),
                          iconColor: Colors.green.shade600,
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const OrdersScreen()),
                          ),
                        ),
                        _MenuItemData(
                          icon: Icons.notifications_outlined,
                          label: 'Notifications',
                          bgColor: const Color(0xFFFFF3E0),
                          iconColor: Colors.orange.shade600,
                          onTap: () => _showComingSoon('Notifications'),
                        ),
                        _MenuItemData(
                          icon: Icons.help_outline,
                          label: 'Help Center',
                          bgColor: const Color(0xFFE3F2FD),
                          iconColor: Colors.blue.shade600,
                          onTap: () => _showComingSoon('Help Center'),
                        ),
                        _MenuItemData(
                          icon: Icons.shield_outlined,
                          label: 'Privacy Policy',
                          bgColor: const Color(0xFFF3E5F5),
                          iconColor: Colors.purple.shade400,
                          onTap: () =>
                              _showComingSoon('Privacy Policy'),
                        ),
                      ]),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 24)),

                  // ── Logout button ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 24),
                      child: GestureDetector(
                        onTap: () async {
                          final navigator = Navigator.of(context);
                          await ApiService.clearAuth();
                          if (mounted) {
                            navigator.pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                              (route) => false,
                            );
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.red.shade100, width: 1.5),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout,
                                  size: 20, color: Colors.red.shade400),
                              const SizedBox(width: 10),
                              Text('Log Out',
                                  style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red.shade400)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ── App version ──
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text('ThriftApp v1.0.0',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade400,
                                fontWeight: FontWeight.w500)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildMenuCard(List<_MenuItemData> items) {
    return Container(
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
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Column(
            children: [
              _buildMenuItem(item),
              if (i < items.length - 1)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(height: 1, color: Colors.grey.shade100),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStat(
      IconData icon, String label, String value, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500)),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 48,
      color: Colors.grey.shade100,
    );
  }

  Widget _buildMenuItem(_MenuItemData item) {
    return GestureDetector(
      onTap: item.onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: item.bgColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(item.icon, size: 20, color: item.iconColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(item.label,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600)),
            ),
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_forward_ios,
                  size: 12, color: Colors.grey.shade400),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItemData {
  final IconData icon;
  final String label;
  final Color bgColor;
  final Color iconColor;
  final VoidCallback onTap;

  const _MenuItemData({
    required this.icon,
    required this.label,
    required this.bgColor,
    required this.iconColor,
    required this.onTap,
  });
}
