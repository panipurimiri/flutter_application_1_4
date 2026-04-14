import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'btc_price_card.dart';
import 'survey_section.dart';
import 'buy.dart';
import 'mesh_background.dart';

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
  // kCoins[0]=BTC(初期), kCoins[1]=BAT, kCoins[2]=BCH, kCoins[3]=XRP
  int _currentPage = 0;

  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    // initialPage:0 で BTC を先頭に表示、右(BAT)が見切れる
    _pageController = PageController(initialPage: 0, viewportFraction: 0.85);
    _pageController.addListener(() {
      final page = _pageController.page?.round() ?? 0;
      if (page != _currentPage) {
        setState(() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          // ── 背景メッシュグラデーション（スワイプに完全同期） ──
          Positioned.fill(
            child: MeshBackground(pageController: _pageController),
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
                        _buildChartSection(context),
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

  // 現物バッジ（右上）: コインアイコン + 現物テキスト
  Widget _buildTopBadge() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 8, bottom: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/icons/header.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
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
  // カード高さ = 画面高さから固定UI要素を除いた領域の約62%
  Widget _buildChartSection(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    // 固定要素: 上部バッジ約60px + ドット約28px + ボトムエリア約162px
    const fixedHeight = 60.0 + 28.0 + 162.0;
    final cardHeight = (screenHeight - safeTop - safeBottom - fixedHeight)
        .clamp(320.0, 600.0);
    return SizedBox(
      height: cardHeight,
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
      _NavItem(asset: 'assets/icons/Home.svg', label: 'ホーム'),
      _NavItem(asset: 'assets/icons/listsearch.svg', label: '銘柄一覧'),
      _NavItem(asset: 'assets/icons/order.svg', label: '注文'),
      _NavItem(asset: 'assets/icons/assets.svg', label: '資産'),
      _NavItem(asset: 'assets/icons/Othermenu.svg', label: 'メニュー'),
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
                            SvgPicture.asset(
                              items[i].asset,
                              width: 22,
                              height: 22,
                              colorFilter: ColorFilter.mode(
                                isActive
                                    ? const Color(0xFFBF0000)
                                    : const Color(0xFF4D4D4D),
                                BlendMode.srcIn,
                              ),
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
  final String asset;
  final String label;
  const _NavItem({required this.asset, required this.label});
}
