import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'glass_bottom_nav.dart';
import 'coin_list.dart';
import 'main.dart' show BtcDetailPage;
import 'account_panel.dart';

const _fontFamily = 'Hiragino Kaku Gothic Pro';

// ── 銘柄一覧データ ─────────────────────────────────────────
class _CoinRow {
  final String iconAsset;
  final bool isSvg;
  final String symbol;
  final String name;
  final String? badge;
  final String price;
  final String change;
  final bool isRising;
  final List<double> spark;
  const _CoinRow({
    required this.iconAsset,
    this.isSvg = false,
    required this.symbol,
    required this.name,
    this.badge,
    required this.price,
    required this.change,
    required this.isRising,
    required this.spark,
  });
}

const _kCoins = [
  _CoinRow(
    iconAsset: 'assets/icons/btc.png',
    symbol: 'BTC',
    name: 'ビットコイン',
    price: '15,230,036円',
    change: '+0.45%',
    isRising: true,
    spark: [
      0.35,
      0.42,
      0.40,
      0.48,
      0.44,
      0.53,
      0.56,
      0.60,
      0.63,
      0.67,
      0.70,
      0.73,
      0.75,
      0.80,
    ],
  ),
  _CoinRow(
    iconAsset: 'assets/icons/eth.png',
    symbol: 'ETH',
    name: 'イーサリアム',
    badge: 'ステーキング',
    price: '366,000円',
    change: '+0.45%',
    isRising: true,
    spark: [
      0.50,
      0.55,
      0.60,
      0.62,
      0.63,
      0.65,
      0.67,
      0.68,
      0.70,
      0.69,
      0.71,
      0.74,
      0.76,
      0.80,
    ],
  ),
  _CoinRow(
    iconAsset: 'assets/icons/doge.png',
    symbol: 'DOGE',
    name: 'ドージコイン',
    price: '24.65円',
    change: '0.00%',
    isRising: false,
    spark: [
      0.50,
      0.51,
      0.49,
      0.50,
      0.52,
      0.50,
      0.49,
      0.51,
      0.50,
      0.52,
      0.51,
      0.50,
      0.49,
      0.50,
    ],
  ),
  _CoinRow(
    iconAsset: 'assets/icons/xrp.png',
    symbol: 'XRP',
    name: 'エックスアールビー',
    price: '429.11円',
    change: '+0.45%',
    isRising: true,
    spark: [
      0.40,
      0.42,
      0.45,
      0.44,
      0.46,
      0.50,
      0.52,
      0.55,
      0.58,
      0.60,
      0.63,
      0.65,
      0.68,
      0.70,
    ],
  ),
  _CoinRow(
    iconAsset: 'assets/icons/shib.svg',
    isSvg: true,
    symbol: 'SHIB',
    name: 'シバイヌ',
    price: '0.001507円',
    change: '+0.45%',
    isRising: true,
    spark: [
      0.30,
      0.35,
      0.32,
      0.38,
      0.40,
      0.44,
      0.42,
      0.48,
      0.50,
      0.54,
      0.52,
      0.58,
      0.60,
      0.65,
    ],
  ),
];

// ── ニュースデータ ─────────────────────────────────────────
class _NewsItem {
  final String title;
  final String source;
  final String date;
  final bool hasImage;
  const _NewsItem({
    required this.title,
    required this.source,
    required this.date,
    this.hasImage = false,
  });
}

const _kNews = [
  _NewsItem(
    title: 'ビットコイン、関税に日本と韓国、通商問題はヤマを越した？',
    source: '楽天ウォレット',
    date: '2025/06/19 14:20',
    hasImage: true,
  ),
  _NewsItem(
    title: 'ビットコイン、関税に日本と韓国、通商問題はヤマを越した？',
    source: '楽天ウォレット',
    date: '2025/06/19 14:20',
    hasImage: true,
  ),
  _NewsItem(
    title: 'イーサリアム、ネットワークアップデートが完了',
    source: '楽天ウォレット',
    date: '2025/06/19 14:20',
    hasImage: true,
  ),
  _NewsItem(
    title: '株式市場、テクノロジー株が急上昇',
    source: '楽天ウォレット',
    date: '2025/06/19 14:20',
    hasImage: true,
  ),
];

// ─────────────────────────────────────────────────────────
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  // ── アカウントパネル用 ──────────────────────────────────
  final _avatarKey = GlobalKey();
  late final AnimationController _avatarBounceCtrl;
  late final Animation<double> _avatarBounce;

  @override
  void initState() {
    super.initState();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _fadeCtrl.forward());

    _avatarBounceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _avatarBounce =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.72), weight: 14),
          TweenSequenceItem(tween: Tween(begin: 0.72, end: 1.18), weight: 28),
          TweenSequenceItem(tween: Tween(begin: 1.18, end: 0.94), weight: 26),
          TweenSequenceItem(tween: Tween(begin: 0.94, end: 1.0), weight: 32),
        ]).animate(
          CurvedAnimation(parent: _avatarBounceCtrl, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    _avatarBounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF4F6F9),
                  Color(0xFFEEF0F4),
                  Color(0xFFD3DAE4),
                ],
              ),
            ),
          ),
          FadeTransition(
            opacity: _fade,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  SizedBox(height: safeTop),
                  _buildHeader(),
                  const SizedBox(height: 16),
                  _buildToggle(),
                  const SizedBox(height: 24),
                  _buildBalance(),
                  const SizedBox(height: 24),
                  _buildAssetButton(),
                  const SizedBox(height: 24),
                  _buildQuickActions(),
                  const SizedBox(height: 24),
                  _buildBalanceCards(),
                  const SizedBox(height: 24),
                  _buildFavorites(),
                  const SizedBox(height: 24),
                  _buildCoinList(),
                  const SizedBox(height: 24),
                  _buildNews(),
                  SizedBox(height: 120 + safeBottom),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _buildBottomNav(safeBottom, context),
          ),
        ],
      ),
    );
  }

  // ── ヘッダー（アバタータップ → AccountPanel）──────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              await AccountPanel.show(context, _avatarKey);
              _avatarBounceCtrl.forward(from: 0);
            },
            child: AnimatedBuilder(
              animation: _avatarBounce,
              builder: (context, child) =>
                  Transform.scale(scale: _avatarBounce.value, child: child),
              child: Container(
                key: _avatarKey,
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFFFA0B9), Color(0xFFED1B8B)],
                  ),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'TR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.notifications_outlined,
              size: 20,
              color: Color(0xFF444444),
            ),
          ),
        ],
      ),
    );
  }

  // ── 以下すべて元の home_page.dart と同一 ────────────────

  Widget _buildToggle() {
    return Container(
      width: 140,
      padding: const EdgeInsets.all(2),
      decoration: ShapeDecoration(
        color: const Color(0x99D2D6DC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: ShapeDecoration(
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(128),
                ),
              ),
              alignment: Alignment.center,
              child: const Text(
                '現物',
                style: TextStyle(
                  color: Color(0xFFBF0000),
                  fontSize: 14,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  letterSpacing: 0.14,
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              alignment: Alignment.center,
              child: const Text(
                '証拠金',
                style: TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 14,
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

  Widget _buildBalance() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Column(
          children: [
            const Text(
              '預かり残高',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 12,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w300,
                height: 1,
                letterSpacing: 0.12,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: const [
                Text(
                  '18,937,150',
                  style: TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 42,
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w600,
                    height: 0.76,
                  ),
                ),
                SizedBox(width: 4),
                Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Text(
                    '円',
                    style: TextStyle(
                      color: Color(0xFF222222),
                      fontSize: 12,
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text(
                  '評価損益',
                  style: TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 10,
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w300,
                    height: 1,
                  ),
                ),
                SizedBox(width: 4),
                Text(
                  '+',
                  style: TextStyle(
                    color: Color(0xFFEA0541),
                    fontSize: 10,
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w300,
                    height: 1,
                  ),
                ),
                SizedBox(width: 2),
                Text(
                  '15,230,036',
                  style: TextStyle(
                    color: Color(0xFFEA0541),
                    fontSize: 12,
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    letterSpacing: 0.12,
                  ),
                ),
                SizedBox(width: 2),
                Text(
                  '円',
                  style: TextStyle(
                    color: Color(0xFFEA0541),
                    fontSize: 10,
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w300,
                    height: 1,
                  ),
                ),
              ],
            ),
          ],
        ),
        Positioned(
          right: 16,
          top: 0,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.visibility_off_outlined,
              size: 16,
              color: Color(0xFF444444),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAssetButton() {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(128)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset('assets/icons/wallet.png', width: 16, height: 16),
          const SizedBox(width: 8),
          const Text(
            '資産を見る',
            style: TextStyle(
              color: Color(0xFF222222),
              fontSize: 16,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w300,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    final actions = [
      ('assets/icons/in.png', '入金', false),
      ('assets/icons/history.png', '入出金履歴', false),
      ('assets/icons/Order history.png', '注文履歴', false),
      ('assets/icons/Horizontal dots.png', 'すべて表示', false),
    ];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: actions.map((a) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Image.asset(a.$1, width: 24, height: 24),
              ),
              const SizedBox(height: 6),
              Text(
                a.$2,
                style: const TextStyle(
                  color: Color(0xFF444444),
                  fontSize: 11,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBalanceCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildBalanceCard(
              icon: 'assets/icons/yen.png',
              label: '日本円残高',
              value: '¥ 4,310,000',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildBalanceCard(
              icon: 'assets/icons/point.png',
              label: '楽天ポイント',
              value: 'P 2,124,000',
              valueColor: const Color(0xFFBF0000),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard({
    required String icon,
    required String label,
    required String value,
    Color valueColor = const Color(0xFF222222),
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Image.asset(icon, width: 16, height: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 11,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavorites() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              const Text(
                'お気に入り',
                style: TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 16,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: Color(0xFF888888),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 130,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildFavoriteCard(
                icon: 'assets/icons/bat.png',
                symbol: 'ベーシックア…',
                name: 'BAT',
                price: '429.11円',
                change: '+ 1.75%',
                isRising: true,
                spark: [
                  0.4,
                  0.5,
                  0.45,
                  0.55,
                  0.52,
                  0.6,
                  0.58,
                  0.65,
                  0.63,
                  0.70,
                ],
              ),
              const SizedBox(width: 12),
              _buildFavoriteCard(
                icon: 'assets/icons/bat.png',
                symbol: 'ベーシックア…',
                name: 'BAT',
                price: '429.11円',
                change: '- 0.45%',
                isRising: false,
                spark: [
                  0.65,
                  0.60,
                  0.63,
                  0.58,
                  0.55,
                  0.52,
                  0.48,
                  0.45,
                  0.42,
                  0.40,
                ],
              ),
              const SizedBox(width: 12),
              _buildFavoriteCard(
                icon: 'assets/icons/bat.png',
                symbol: 'ベーシックア…',
                name: 'BAT',
                price: '429.11円',
                change: '+ 0.90%',
                isRising: true,
                spark: [
                  0.3,
                  0.35,
                  0.4,
                  0.38,
                  0.45,
                  0.50,
                  0.55,
                  0.60,
                  0.58,
                  0.65,
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _dot(true),
            const SizedBox(width: 4),
            _dot(false),
            const SizedBox(width: 4),
            _dot(false),
          ],
        ),
      ],
    );
  }

  Widget _dot(bool active) => Container(
    width: active ? 8 : 6,
    height: active ? 8 : 6,
    decoration: BoxDecoration(
      color: active ? const Color(0xFFBF0000) : Colors.white,
      shape: BoxShape.circle,
    ),
  );

  Widget _buildFavoriteCard({
    required String icon,
    required String symbol,
    required String name,
    required String price,
    required String change,
    required bool isRising,
    required List<double> spark,
  }) {
    final color = isRising ? const Color(0xFFEA0541) : const Color(0xFF00A896);
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Image.asset(icon, width: 20, height: 20),
              const SizedBox(width: 6),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    symbol,
                    style: const TextStyle(
                      color: Color(0xFF777777),
                      fontSize: 10,
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Color(0xFF222222),
                      fontSize: 12,
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 28,
            child: CustomPaint(
              painter: _SparkPainter(spark, color),
              size: const Size(double.infinity, 28),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            price,
            style: const TextStyle(
              color: Color(0xFF222222),
              fontSize: 12,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            change,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinList() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Row(
                children: [
                  const Text(
                    '銘柄一覧',
                    style: TextStyle(
                      color: Color(0xFF222222),
                      fontSize: 16,
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFF888888),
                  ),
                ],
              ),
            ),
            ..._kCoins.asMap().entries.map((e) {
              final i = e.key;
              final coin = e.value;
              return Column(
                children: [
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFEEEEEE),
                    ),
                  _buildCoinRow(coin),
                ],
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCoinRow(_CoinRow coin) {
    final color = coin.isRising
        ? const Color(0xFFEA0541)
        : coin.change == '0.00%'
        ? const Color(0xFF888888)
        : const Color(0xFF00A896);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            height: 32,
            child: coin.isSvg
                ? SvgPicture.asset(coin.iconAsset, width: 32, height: 32)
                : Image.asset(coin.iconAsset, width: 32, height: 32),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      coin.symbol,
                      style: const TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 14,
                        fontFamily: _fontFamily,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (coin.badge != null) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEEF4FF),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          coin.badge!,
                          style: const TextStyle(
                            color: Color(0xFF3366CC),
                            fontSize: 9,
                            fontFamily: _fontFamily,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  coin.name,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 11,
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            height: 28,
            child: coin.change == '0.00%'
                ? Center(
                    child: Container(
                      height: 1.5,
                      color: const Color(0xFFBBBBBB),
                    ),
                  )
                : CustomPaint(painter: _SparkPainter(coin.spark, color)),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                coin.price,
                style: const TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 13,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                coin.change,
                style: TextStyle(
                  color: color,
                  fontSize: 12,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNews() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Row(
                children: [
                  const Text(
                    'ニュース',
                    style: TextStyle(
                      color: Color(0xFF222222),
                      fontSize: 16,
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  const Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: Color(0xFF888888),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 8),
              child: Row(
                children: const [
                  Icon(Icons.info_outline, size: 12, color: Color(0xFF888888)),
                  SizedBox(width: 4),
                  Text(
                    'ニュースの免責事項',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                  Text(
                    'をご確認ください',
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Align(
                alignment: Alignment.centerRight,
                child: const Text(
                  '2025年 10月 22日',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 11,
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                width: double.infinity,
                height: 72,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8F0),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFFFDDAA),
                    width: 0.5,
                  ),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Text(
                          'マーケット情報',
                          style: TextStyle(
                            color: Color(0xFFBF0000),
                            fontSize: 10,
                            fontFamily: _fontFamily,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        Text(
                          'Daily Report',
                          style: TextStyle(
                            color: Color(0xFFBF0000),
                            fontSize: 22,
                            fontFamily: _fontFamily,
                            fontWeight: FontWeight.w600,
                            height: 1.1,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFDDAA),
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const Text('🪙', style: TextStyle(fontSize: 24)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            ..._kNews.asMap().entries.map((e) {
              final i = e.key;
              final news = e.value;
              return Column(
                children: [
                  if (i > 0)
                    const Divider(
                      height: 1,
                      indent: 16,
                      endIndent: 16,
                      color: Color(0xFFEEEEEE),
                    ),
                  _buildNewsItem(news),
                ],
              );
            }),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsItem(_NewsItem news) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  news.title,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 13,
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w300,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${news.source}  ${news.date}',
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 10,
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFEEEEEE),
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.image_outlined,
              color: Color(0xFFBBBBBB),
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav(double bottomPadding, BuildContext context) {
    const items = [
      GlassNavItem(asset: 'assets/icons/Home.svg', label: 'ホーム'),
      GlassNavItem(asset: 'assets/icons/listsearch.svg', label: '銘柄一覧'),
      GlassNavItem(asset: 'assets/icons/order.svg', label: '注文'),
      GlassNavItem(asset: 'assets/icons/assets.svg', label: '資産'),
      GlassNavItem(asset: 'assets/icons/Othermenu.svg', label: 'メニュー'),
    ];
    return LiquidGlassBottomNav(
      selectedIndex: 0,
      onTap: (i) {
        if (i == 1) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (ctx, a1, a2) => const CoinListPage(),
              transitionDuration: const Duration(milliseconds: 250),
              reverseTransitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (ctx, anim, a2, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        } else if (i == 2) {
          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (ctx, a1, a2) => const BtcDetailPage(),
              transitionDuration: const Duration(milliseconds: 250),
              reverseTransitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (ctx, anim, a2, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
          );
        }
      },
      items: items,
      bottomPadding: bottomPadding,
    );
  }
}

// ── スパークラインペインター ───────────────────────────────
class _SparkPainter extends CustomPainter {
  final List<double> points;
  final Color color;
  const _SparkPainter(this.points, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final x = i / (points.length - 1) * size.width;
      final y = (1 - points[i]) * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_SparkPainter old) => false;
}
