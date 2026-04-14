import 'package:flutter/material.dart';
import 'btc_price_card.dart';
import 'survey_section.dart';
import 'buy.dart';

const _fontFamily = 'Hiragino Kaku Gothic Pro';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BtcDetailPage(),
    );
  }
}

class BtcDetailPage extends StatefulWidget {
  const BtcDetailPage({super.key});

  @override
  State<BtcDetailPage> createState() => _BtcDetailPageState();
}

class _BtcDetailPageState extends State<BtcDetailPage> {
  int _navIndex = 2;
  // kCoins[0]=XRP, kCoins[1]=BTC(初期), kCoins[2]=ETH
  int _currentPage = 1;
  int _previousPage = 1;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // initialPage:1 で BTC を中央に、左(XRP)・右(ETH)が見切れる
    _pageController = PageController(initialPage: 1, viewportFraction: 0.85);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
          _previousPage = _currentPage;
          _currentPage = page;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  CoinData get _coin => kCoins[_currentPage];
  CoinData get _prevCoin => kCoins[_previousPage];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // ── 背景グラデーション（コイン切り替え時にアニメーション） ──
          Positioned.fill(
            child: TweenAnimationBuilder<double>(
              key: ValueKey(_currentPage),
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeInOut,
              builder: (context, t, _) {
                final c1 = Color.lerp(
                  _prevCoin.accentColor,
                  _coin.accentColor,
                  t,
                )!;
                final c2 = Color.lerp(
                  _prevCoin.primaryColor,
                  _coin.primaryColor,
                  t,
                )!;
                // 上半分: コインカラーグラデーション
                // 下半分: グレー（SurveySection と繋がる）
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [c1, c2],
                    ),
                  ),
                );
              },
            ),
          ),

          // ── コンテンツ ──
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                // 上部バッジ（コインシンボル）
                _buildTopBadge(),

                // スクロール可能なメインコンテンツ
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        // ── カードPageView（見切れ付き横スクロール） ──
                        _buildChartSection(),
                        const SizedBox(height: 12),

                        // ページドット
                        _buildPageDots(),
                        const SizedBox(height: 8),

                        // アンケート・情報セクション
                        const SurveySection(),

                        // ボトムバー分の余白
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── 固定ボトムエリア ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomArea(context),
          ),
        ],
      ),
    );
  }

  // 現物バッジ（右上）
  Widget _buildTopBadge() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 8, bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '₿',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              '現物',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // カードPageView（見切れ効果: viewportFraction=0.85, 内側padding 4px）
  Widget _buildChartSection() {
    return SizedBox(
      height: 580,
      child: PageView.builder(
        controller: _pageController,
        itemCount: kCoins.length,
        itemBuilder: (context, i) {
          return Padding(
            // 左右4pxずつ = カード間16px (4+4+4+4) の間隔
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: CoinPriceCard(coin: kCoins[i]),
          );
        },
      ),
    );
  }

  // ページドット
  Widget _buildPageDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(kCoins.length, (i) {
        final isActive = i == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: isActive ? 10 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive
                ? _coin.primaryColor
                : Colors.white.withValues(alpha: 0.9),
            shape: BoxShape.circle,
          ),
        );
      }),
    );
  }

  // ── ボトムエリア全体 ────────────────────────────────────
  // レイアウト:
  //   [売る/買いカード: 76px]
  //   [gap: 20px]
  //   [ナビゲーションピル: 62px]
  //   [bottom gap: 16px + SafeArea]
  Widget _buildBottomArea(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    const buttonHeight = 76.0;
    const buttonNavGap = 8.0;
    const navPillHeight = 62.0; // top padding 4 + items 58
    const bottomGap = 16.0;

    // 売買カード下端 → ナビ上端の距離
    const navTop = buttonHeight + buttonNavGap;
    final totalHeight = navTop + navPillHeight + bottomGap + bottomPadding;

    return SizedBox(
      height: totalHeight,
      child: Stack(
        children: [
          // ── ナビゲーションバー（売買カードの下 20px から配置） ──
          Positioned(
            left: 0,
            right: 0,
            top: navTop,
            bottom: 0,
            child: _buildBottomNav(bottomPadding),
          ),
          // ── 売る/買うカード（最上部に配置） ──
          Positioned(left: 0, right: 0, top: 0, child: _buildSellBuyBar()),
        ],
      ),
    );
  }

  // 売る/買うカード（Figma準拠）
  Widget _buildSellBuyBar() {
    final price = _formatPrice(_coin.price);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        spacing: 8,
        children: [
          // 売るカード
          Expanded(
            child: _buildTradeCard(
              price: price,
              priceColor: const Color(0xFF0BA596),
              label: '売る',
              buttonColor: const Color(0xFF0BA596),
              onTap: () {},
            ),
          ),
          // 買うカード
          Expanded(
            child: _buildTradeCard(
              price: price,
              priceColor: const Color(0xFFED6286),
              label: '買う',
              buttonColor: const Color(0xFFED6286),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BuyPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeCard({
    required String price,
    required Color priceColor,
    required String label,
    required Color buttonColor,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 76,
      padding: const EdgeInsets.only(top: 10, left: 8, right: 8, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.80),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        spacing: 4,
        children: [
          // 価格表示
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                price,
                style: TextStyle(
                  color: priceColor,
                  fontSize: 14,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: 0.14,
                ),
              ),
              const Text(
                '円',
                style: TextStyle(
                  color: Color(0xFF4D4D4D),
                  fontSize: 10,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w300,
                  height: 1,
                ),
              ),
            ],
          ),
          // ボタン
          GestureDetector(
            onTap: onTap,
            child: Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: buttonColor,
                borderRadius: BorderRadius.circular(1000),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x14000000),
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w300,
                  height: 1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // フローティングナビゲーションバー（Figma準拠）
  Widget _buildBottomNav(double bottomPadding) {
    const items = [
      _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'ホーム'),
      _NavItem(
        icon: Icons.format_list_bulleted_outlined,
        activeIcon: Icons.format_list_bulleted,
        label: '銘柄一覧',
      ),
      _NavItem(
        icon: Icons.currency_exchange_outlined,
        activeIcon: Icons.currency_exchange,
        label: '注文',
      ),
      _NavItem(
        icon: Icons.savings_outlined,
        activeIcon: Icons.savings,
        label: '資産',
      ),
      _NavItem(
        icon: Icons.grid_view_outlined,
        activeIcon: Icons.grid_view,
        label: 'メニュー',
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 1),
      padding: EdgeInsets.only(
        top: 4,
        left: 16,
        right: 16,
        bottom: bottomPadding, // SafeArea 分のみ（16px gap は Stack が担当）
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.58, 1.24),
          end: Alignment(0.58, -0.15),
          colors: [Color(0xFFEEF1F4), Color(0x0CD3DBE4)],
        ),
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        children: [
          // グレー丸角ピル背景（ナビアイテム下）
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.60),
                borderRadius: BorderRadius.circular(40),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x1E000000),
                    blurRadius: 8,
                    offset: Offset(0, 1),
                  ),
                  BoxShadow(color: Color(0x19000000), blurRadius: 2),
                ],
              ),
            ),
          ),
          // ナビアイテム
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 58,
              child: Row(
                children: List.generate(items.length, (i) {
                  final isActive = i == _navIndex;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _navIndex = i),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: isActive
                            ? BoxDecoration(
                                color: const Color(0x21939393),
                                borderRadius: BorderRadius.circular(40),
                              )
                            : null,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 2,
                          children: [
                            Icon(
                              isActive ? items[i].activeIcon : items[i].icon,
                              size: 22,
                              color: isActive
                                  ? const Color(0xFFBF0000)
                                  : const Color(0xFF4D4D4D),
                            ),
                            Text(
                              items[i].label,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: isActive
                                    ? const Color(0xFFBF0000)
                                    : const Color(0xFF4D4D4D),
                                fontSize: 10,
                                fontFamily: _fontFamily,
                                fontWeight: isActive
                                    ? FontWeight.w600
                                    : FontWeight.w300,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    final s = price.toInt().toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
