import 'package:cupertino_native/cupertino_native.dart';
import 'package:flutter/cupertino.dart' show CupertinoTheme, CupertinoThemeData;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page.dart';
import 'coin_list.dart';
import 'main.dart' show BtcDetailPage;
import 'assets_page.dart';

// ── Public widget ──────────────────────────────────────────────────────────

class LiquidGlassBottomNav extends StatefulWidget {
  final int selectedIndex;
  final double bottomPadding;

  const LiquidGlassBottomNav({
    super.key,
    required this.selectedIndex,
    this.bottomPadding = 0,
  });

  @override
  State<LiquidGlassBottomNav> createState() => _LiquidGlassBottomNavState();
}

class _LiquidGlassBottomNavState extends State<LiquidGlassBottomNav> {
  // CNTabBarItem + SF Symbol でネイティブ Liquid Glass タブバーを構成
  static const _navItems = [
    CNTabBarItem(label: 'ホーム', icon: CNSymbol('house', size: 22)),
    CNTabBarItem(
      label: '銘柄一覧',
      icon: CNSymbol('list.bullet.rectangle.portrait', size: 22),
    ),
    CNTabBarItem(label: '注文', icon: CNSymbol('arrow.up.arrow.down', size: 22)),
    CNTabBarItem(label: '資産', icon: CNSymbol('banknote', size: 22)),
    CNTabBarItem(label: 'メニュー', icon: CNSymbol('square.grid.2x2', size: 22)),
  ];

  void _onTap(int i) {
    if (i == widget.selectedIndex) return;
    HapticFeedback.selectionClick();
    _navigate(i);
  }

  void _navigate(int i) {
    Widget? targetPage;

    switch (i) {
      case 0:
        Navigator.pushAndRemoveUntil(
          context,
          _fadeRoute(const HomePage()),
          (route) => false,
        );
        return;
      case 1:
        targetPage = const CoinListPage();
        break;
      case 2:
        targetPage = const BtcDetailPage();
        break;
      case 3:
        targetPage = const AssetsPage();
        break;
      case 4:
        return;
    }

    if (targetPage != null) {
      Navigator.push(context, _fadeRoute(targetPage));
    }
  }

  PageRouteBuilder _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (ctx, a1, a2) => page,
      transitionDuration: const Duration(milliseconds: 250),
      reverseTransitionDuration: const Duration(milliseconds: 200),
      transitionsBuilder: (ctx, anim, a2, child) =>
          FadeTransition(opacity: anim, child: child),
    );
  }

  @override
  Widget build(BuildContext context) {
    // CupertinoTheme でラップ
    return CupertinoTheme(
      data: const CupertinoThemeData(brightness: Brightness.light),
      child: Padding(
        padding: EdgeInsets.only(bottom: widget.bottomPadding),
        child: SizedBox(
          height: 82, // 重ならず、かつ広すぎない高さに調整
          child: CNTabBar(
            items: _navItems,
            currentIndex: widget.selectedIndex,
            onTap: _onTap,
            tint: const Color(0xFFBF0000), // ブランドレッド
            shrinkCentered: true,
          ),
        ),
      ),
    );
  }
}
