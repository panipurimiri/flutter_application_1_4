// cupertino_native_nav_demo.dart
//
// Demo app using cupertino_native package for iOS Liquid Glass navigation
//
// ============================================================
// 実行方法:
//   flutter run -t lib/cupertino_native_nav_demo.dart
//
// ⚠️ 制約:
//   - iOS 14.0+ / macOS 11.0+ のみ
//   - Xcode 26 beta が必要
//   - Web / Android / Windows / Linux では動作しません
//
// pubspec.yaml に以下を追加してください:
// ─────────────────────────────────────────
// dependencies:
//   cupertino_native: ^0.1.1
// ─────────────────────────────────────────

import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

void main() {
  runApp(const CupertinoNativeDemoApp());
}

class CupertinoNativeDemoApp extends StatelessWidget {
  const CupertinoNativeDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return CupertinoApp(
      title: 'Cupertino Native Demo',
      debugShowCheckedModeBanner: false,
      theme: const CupertinoThemeData(
        brightness: Brightness.light,
        primaryColor: _T.activeColor,
        scaffoldBackgroundColor: Color(0xFFF2F2F7),
      ),
      home: const MainScreen(),
    );
  }
}

// ============================================================
// Design Tokens
// ============================================================

class _T {
  static const Color activeColor = Color(0xFFBF0000);
}

// ============================================================
// Page Theme
// ============================================================

class _PageTheme {
  final Color bg;
  final Color accent;
  final String name;
  const _PageTheme({required this.bg, required this.accent, required this.name});
}

// ============================================================
// Main Screen
// ============================================================

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // CNTabBarItem + SF Symbol でネイティブ Liquid Glass タブバーを構成
  static const _navItems = [
    CNTabBarItem(label: 'ホーム',   icon: CNSymbol('house',                         size: 22)),
    CNTabBarItem(label: '銘柄一覧', icon: CNSymbol('list.bullet.rectangle.portrait', size: 22)),
    CNTabBarItem(label: '注文',     icon: CNSymbol('arrow.up.arrow.down',            size: 22)),
    CNTabBarItem(label: '資産',     icon: CNSymbol('banknote',                       size: 22)),
    CNTabBarItem(label: 'メニュー', icon: CNSymbol('square.grid.2x2',               size: 22)),
  ];

  static const _themes = [
    _PageTheme(bg: Color(0xFFF0E8FF), accent: Color(0xFF6A0DAD), name: 'ホーム'),
    _PageTheme(bg: Color(0xFFE3EEFF), accent: Color(0xFF0D47A1), name: '銘柄一覧'),
    _PageTheme(bg: Color(0xFFE6F4E6), accent: Color(0xFF1B5E20), name: '注文'),
    _PageTheme(bg: Color(0xFFFFF3E0), accent: Color(0xFFBF6000), name: '資産'),
    _PageTheme(bg: Color(0xFFFFE8F2), accent: Color(0xFF880E4F), name: 'メニュー'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = _themes[_currentIndex];

    return CupertinoPageScaffold(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // ── 1. 背景（ガラスに透けて見える）────────────────────
          _Background(theme: theme),

          // ── 2. ページコンテンツ ────────────────────────────
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 120),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: _PageContent(
                    key: ValueKey(_currentIndex),
                    theme: theme,
                  ),
                ),
              ),
            ),
          ),

          // ── 3. CNTabBar（Liquid Glass ネイティブタブバー）───────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Center(
                  child: CNTabBar(
                    items: _navItems,
                    currentIndex: _currentIndex,
                    onTap: (i) => setState(() => _currentIndex = i),
                    tint: _T.activeColor,
                    shrinkCentered: true,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Background
// ============================================================

class _Background extends StatelessWidget {
  final _PageTheme theme;
  const _Background({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(0, -0.3),
              radius: 1.2,
              colors: [
                theme.accent.withValues(alpha: 0.18),
                theme.bg,
              ],
            ),
          ),
        ),
        Positioned(
          top: 60, right: -40,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            width: 240, height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                theme.accent.withValues(alpha: 0.20),
                const Color(0x00000000),
              ]),
            ),
          ),
        ),
        Positioned(
          bottom: 100, left: -60,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            width: 280, height: 280,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(colors: [
                theme.accent.withValues(alpha: 0.14),
                const Color(0x00000000),
              ]),
            ),
          ),
        ),
        // ナビバー直後ろの確認用カード
        Positioned(
          bottom: 68, left: 20, right: 20,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [
                theme.accent.withValues(alpha: 0.30),
                theme.accent.withValues(alpha: 0.10),
              ]),
              border: Border.all(
                color: theme.accent.withValues(alpha: 0.40),
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '↑ ナビバーの背後に透けるコンテンツ',
                  style: TextStyle(
                    color: theme.accent.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Liquid Glass',
                  style: TextStyle(
                    color: theme.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Page Content
// ============================================================

class _PageContent extends StatelessWidget {
  final _PageTheme theme;
  const _PageContent({super.key, required this.theme});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          theme.name,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w700,
            color: theme.accent,
            letterSpacing: -0.8,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
          decoration: BoxDecoration(
            color: theme.accent.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'cupertino_native',
            style: TextStyle(
              fontSize: 12,
              color: theme.accent.withValues(alpha: 0.7),
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        CNButton(label: 'Liquid Glass Button', onPressed: () {}),
        const SizedBox(height: 16),
        CNSegmentedControl(
          labels: const ['Tab 1', 'Tab 2', 'Tab 3'],
          selectedIndex: 0,
          onValueChanged: (i) {},
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Switch: ', style: TextStyle(color: theme.accent)),
            CNSwitch(value: true, onChanged: (v) {}),
          ],
        ),
        const SizedBox(height: 16),
        Column(
          children: [
            Text('Slider:', style: TextStyle(color: theme.accent)),
            CNSlider(value: 50, min: 0, max: 100, onChanged: (v) {}),
          ],
        ),
      ],
    );
  }
}
