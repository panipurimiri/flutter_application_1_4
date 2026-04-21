import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'glass_bottom_nav.dart';
import 'main.dart' show BtcDetailPage;

const _fontFamily = 'Hiragino Kaku Gothic Pro';
const _hiraFont = TextStyle(fontFamily: _fontFamily);

// ── 銘柄データ ────────────────────────────────────────────
class _CoinInfo {
  final String symbol;
  final String name;
  final String iconAsset;
  final double price;
  final double changePercent;
  final List<double> spark; // 正規化 0.0–1.0（24h推移）

  const _CoinInfo({
    required this.symbol,
    required this.name,
    required this.iconAsset,
    required this.price,
    required this.changePercent,
    required this.spark,
  });

  bool get isRising => changePercent > 0;
  bool get isFalling => changePercent < 0;
}

final _kCoins = <_CoinInfo>[
  // BTC: 緩やかな上昇、途中小さなディップあり
  _CoinInfo(
    symbol: 'BTC',
    name: 'ビットコイン',
    iconAsset: 'assets/icons/btc.png',
    price: 15230036,
    changePercent: 0.45,
    spark: [0.35, 0.38, 0.42, 0.40, 0.45, 0.48, 0.44, 0.50,
            0.53, 0.52, 0.56, 0.60, 0.58, 0.63, 0.67, 0.65,
            0.70, 0.73, 0.75, 0.80],
  ),
  // ETH: 上昇→プラトー→最後に急伸
  _CoinInfo(
    symbol: 'ETH',
    name: 'イーサリアム',
    iconAsset: 'assets/icons/eth.png',
    price: 366000,
    changePercent: 0.38,
    spark: [0.50, 0.55, 0.60, 0.62, 0.61, 0.63, 0.65, 0.64,
            0.66, 0.65, 0.67, 0.68, 0.70, 0.69, 0.71, 0.72,
            0.74, 0.76, 0.78, 0.80],
  ),
  // DOGE: ほぼフラット、細かい波
  _CoinInfo(
    symbol: 'DOGE',
    name: 'ドージコイン',
    iconAsset: 'assets/icons/doge.png',
    price: 24.65,
    changePercent: 0.00,
    spark: [0.50, 0.52, 0.48, 0.51, 0.53, 0.49, 0.52, 0.50,
            0.51, 0.49, 0.52, 0.50, 0.51, 0.48, 0.50, 0.52,
            0.49, 0.51, 0.50, 0.50],
  ),
  // XRP: V字回復（前半急落→後半回復）
  _CoinInfo(
    symbol: 'XRP',
    name: 'エックスアールピー',
    iconAsset: 'assets/icons/xrp.png',
    price: 429.11,
    changePercent: 0.21,
    spark: [0.70, 0.65, 0.60, 0.55, 0.50, 0.45, 0.40, 0.42,
            0.46, 0.50, 0.54, 0.58, 0.62, 0.65, 0.68, 0.70,
            0.72, 0.74, 0.76, 0.75],
  ),
  // SHIB: 高ボラティリティ＋上昇トレンド
  _CoinInfo(
    symbol: 'SHIB',
    name: 'シバイヌ',
    iconAsset: 'assets/icons/shib.svg',
    price: 0.001507,
    changePercent: 1.20,
    spark: [0.40, 0.55, 0.42, 0.60, 0.45, 0.65, 0.50, 0.68,
            0.52, 0.70, 0.55, 0.72, 0.58, 0.75, 0.60, 0.78,
            0.62, 0.80, 0.65, 0.82],
  ),
  // BCH: 安定した上昇
  _CoinInfo(
    symbol: 'BCH',
    name: 'ビットコインキャッシュ',
    iconAsset: 'assets/icons/bch.png',
    price: 32000,
    changePercent: 0.45,
    spark: [0.30, 0.33, 0.36, 0.40, 0.43, 0.46, 0.50, 0.52,
            0.55, 0.57, 0.60, 0.63, 0.65, 0.67, 0.70, 0.72,
            0.74, 0.76, 0.78, 0.80],
  ),
  // BAT: ★下降トレンド（緑グラデーション）
  _CoinInfo(
    symbol: 'BAT',
    name: 'ベーシックアテンションTKN',
    iconAsset: 'assets/icons/bat.png',
    price: 12.34,
    changePercent: -1.35,
    spark: [0.80, 0.77, 0.74, 0.72, 0.69, 0.67, 0.65, 0.62,
            0.60, 0.58, 0.56, 0.54, 0.52, 0.50, 0.48, 0.46,
            0.44, 0.42, 0.40, 0.38],
  ),
  // LTC: ★下降＋反発試み（緑グラデーション）
  _CoinInfo(
    symbol: 'LTC',
    name: 'ライトコイン',
    iconAsset: 'assets/icons/ltc.png',
    price: 12348,
    changePercent: -0.82,
    spark: [0.75, 0.72, 0.68, 0.65, 0.60, 0.58, 0.62, 0.60,
            0.56, 0.53, 0.50, 0.47, 0.45, 0.48, 0.46, 0.43,
            0.40, 0.38, 0.36, 0.35],
  ),
  // DOT: 上昇途中に調整、再上昇
  _CoinInfo(
    symbol: 'DOT',
    name: 'ポルカドット',
    iconAsset: 'assets/icons/dot.png',
    price: 7045,
    changePercent: 0.67,
    spark: [0.45, 0.48, 0.52, 0.55, 0.58, 0.60, 0.58, 0.56,
            0.58, 0.62, 0.65, 0.67, 0.70, 0.72, 0.74, 0.73,
            0.75, 0.77, 0.78, 0.80],
  ),
  // LINK: ★急落トレンド（緑グラデーション）
  _CoinInfo(
    symbol: 'LINK',
    name: 'チェーンリンク',
    iconAsset: 'assets/icons/link.png',
    price: 2356,
    changePercent: -2.10,
    spark: [0.85, 0.80, 0.76, 0.70, 0.65, 0.68, 0.63, 0.58,
            0.55, 0.50, 0.48, 0.45, 0.42, 0.40, 0.38, 0.36,
            0.34, 0.32, 0.30, 0.28],
  ),
  // TRX: ほぼフラット、微上昇
  _CoinInfo(
    symbol: 'TRX',
    name: 'トロン',
    iconAsset: 'assets/icons/trx.svg',
    price: 51.34,
    changePercent: 0.15,
    spark: [0.48, 0.50, 0.49, 0.52, 0.51, 0.53, 0.52, 0.54,
            0.53, 0.55, 0.54, 0.56, 0.55, 0.57, 0.56, 0.58,
            0.57, 0.59, 0.58, 0.60],
  ),
];


// ── CoinListPage ──────────────────────────────────────────
class CoinListPage extends StatefulWidget {
  const CoinListPage({super.key});

  @override
  State<CoinListPage> createState() => _CoinListPageState();
}

class _CoinListPageState extends State<CoinListPage>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  late final AnimationController _chartAnim;
  late final Animation<double> _chartProgress;

  @override
  void initState() {
    super.initState();
    _chartAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _chartProgress = CurvedAnimation(
      parent: _chartAnim,
      curve: Curves.easeOut,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) => _chartAnim.forward());
  }

  @override
  void dispose() {
    _chartAnim.dispose();
    super.dispose();
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      final s = price.round().toString();
      final buf = StringBuffer();
      for (int i = 0; i < s.length; i++) {
        if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
        buf.write(s[i]);
      }
      return buf.toString();
    } else if (price >= 1) {
      final s = price.toStringAsFixed(2);
      return s.endsWith('.00') ? price.toInt().toString() : s;
    } else {
      return price
          .toStringAsFixed(6)
          .replaceAll(RegExp(r'0+$'), '')
          .replaceAll(RegExp(r'\.$'), '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // ── グラデーション背景 ──────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF4F6F9), Color(0xFFEEF0F4), Color(0xFFD3DAE4)],
              ),
            ),
          ),

          // ── スクロール可能なメインコンテンツ ──────────────────
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: AnimatedBuilder(
                animation: _chartProgress,
                builder: (context, _) => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── ヘッダーバッジ（リキッドグラス） ──────────
                    _buildTopBadge(),

                    // ── タイトル ─────────────────────────────────
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 4, 16, 0),
                      child: Text(
                        '銘柄一覧',
                        style: TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 22,
                          fontFamily: _fontFamily,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── タブ ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 8,
                        children: [
                          _buildTab('ランキング', 0),
                          _buildTab('ピックアップ', 1),
                          _buildTab('お気に入り', 2),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── ソート行 ─────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        spacing: 8,
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Icon(Icons.menu,
                                size: 16, color: Color(0xFF333333)),
                          ),
                          Expanded(
                            child: Container(
                              height: 32,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '時価総額順',
                                    style: _hiraFont.copyWith(
                                      color: const Color(0xFF222222),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      letterSpacing: 0.14,
                                      height: 1,
                                    ),
                                  ),
                                  const Icon(Icons.keyboard_arrow_down,
                                      size: 16, color: Color(0xFF333333)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── コインリスト（ページスクロールのみ） ──────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.60),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: _kCoins
                              .map((coin) => _CoinRow(
                                    coin: coin,
                                    chartProgress: _chartProgress.value,
                                    formatPrice: _formatPrice,
                                  ))
                              .toList(),
                        ),
                      ),
                    ),

                    SizedBox(height: 100 + safeBottom),
                  ],
                ),
              ),
            ),
          ),

          // ── ボトムナビゲーション ────────────────────────────
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

  // ── ヘッダーバッジ（半透明白丸アイコン + 現物テキスト） ─
  Widget _buildTopBadge() {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 6, bottom: 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 3,
          children: [
            Image.asset(
              'assets/icons/Actual-1.png',
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
            const Text(
              '現物',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 10,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String label, int index) {
    final isActive = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        height: 32,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : const Color(0x99D2D6DC),
          borderRadius: BorderRadius.circular(128),
        ),
        child: Text(
          label,
          style: _hiraFont.copyWith(
            color: isActive
                ? const Color(0xFFBF0000)
                : const Color(0xFF555555),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w300,
            height: 1,
            letterSpacing: 0.14,
          ),
        ),
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
      selectedIndex: 1, // 銘柄一覧がアクティブ
      onTap: (i) {
        if (i == 0) {
          Navigator.pop(context);
        } else if (i == 2) {
          Navigator.push(context, PageRouteBuilder(
            pageBuilder: (ctx, a1, a2) => const BtcDetailPage(),
            transitionDuration: const Duration(milliseconds: 250),
            reverseTransitionDuration: const Duration(milliseconds: 200),
            transitionsBuilder: (ctx, anim, a2, child) =>
                FadeTransition(opacity: anim, child: child),
          ));
        }
      },
      items: items,
      bottomPadding: bottomPadding,
    );
  }
}

// ── コイン行 ──────────────────────────────────────────────
class _CoinRow extends StatelessWidget {
  final _CoinInfo coin;
  final double chartProgress;
  final String Function(double) formatPrice;

  const _CoinRow({
    required this.coin,
    required this.chartProgress,
    required this.formatPrice,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = coin.isRising
        ? const Color(0xFFED6286)
        : coin.isFalling
            ? const Color(0xFF268703)
            : const Color(0xFF888888);

    final changeText = coin.changePercent == 0
        ? '0.00%'
        : '${coin.changePercent > 0 ? '+' : ''}${coin.changePercent.toStringAsFixed(2)}%';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _CoinIcon(assetPath: coin.iconAsset, symbol: coin.symbol),
          const SizedBox(width: 8),

          SizedBox(
            width: 108,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 2,
              children: [
                Text(
                  coin.symbol,
                  style: _hiraFont.copyWith(
                    color: const Color(0xFF222222),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    letterSpacing: 0.14,
                  ),
                ),
                Text(
                  coin.name,
                  overflow: TextOverflow.ellipsis,
                  style: _hiraFont.copyWith(
                    color: const Color(0xFF888888),
                    fontSize: 10,
                    fontWeight: FontWeight.w300,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),

          // スパークライン（高さを明示してサイズ確定）
          Expanded(
            child: SizedBox(
              height: 28,
              child: _Sparkline(
                data: coin.spark,
                isRising: coin.isRising,
                isFalling: coin.isFalling,
                progress: chartProgress,
              ),
            ),
          ),

          const SizedBox(width: 8),

          SizedBox(
            width: 90,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              spacing: 2,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        formatPrice(coin.price),
                        overflow: TextOverflow.ellipsis,
                        style: _hiraFont.copyWith(
                          color: const Color(0xFF222222),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          height: 1,
                          letterSpacing: 0.14,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 1),
                      child: Text(
                        '円',
                        style: _hiraFont.copyWith(
                          color: const Color(0xFF888888),
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                          height: 1,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  changeText,
                  style: _hiraFont.copyWith(
                    color: changeColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w300,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── コインアイコン ─────────────────────────────────────────
class _CoinIcon extends StatelessWidget {
  final String assetPath;
  final String symbol;
  const _CoinIcon({required this.assetPath, required this.symbol});

  @override
  Widget build(BuildContext context) {
    if (assetPath.endsWith('.svg')) {
      return SvgPicture.asset(assetPath, width: 24, height: 24,
          fit: BoxFit.contain);
    }
    return Image.asset(
      assetPath,
      width: 24,
      height: 24,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => _FallbackIcon(symbol: symbol),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final String symbol;
  const _FallbackIcon({required this.symbol});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: const BoxDecoration(
          color: Color(0xFFCCCCCC), shape: BoxShape.circle),
      child: Center(
        child: Text(symbol.substring(0, 1),
            style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: Colors.white)),
      ),
    );
  }
}

// ── スパークラインチャート ─────────────────────────────────
class _Sparkline extends StatelessWidget {
  final List<double> data;
  final bool isRising;
  final bool isFalling;
  final double progress;

  const _Sparkline({
    required this.data,
    required this.isRising,
    required this.isFalling,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final w = constraints.maxWidth;
        final h =
            constraints.maxHeight.isFinite ? constraints.maxHeight : 28.0;
        return CustomPaint(
          size: Size(w, h),
          painter: _SparklinePainter(
            data: data,
            isRising: isRising,
            isFalling: isFalling,
            progress: progress,
          ),
        );
      },
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> data;
  final bool isRising;
  final bool isFalling;
  final double progress;

  const _SparklinePainter({
    required this.data,
    required this.isRising,
    required this.isFalling,
    required this.progress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.length < 2 || progress <= 0 || size.isEmpty) return;

    // main.dart と同じチャート色
    final List<Color> colors;
    if (isRising) {
      colors = [const Color(0xFFFFA0B9), const Color(0xFFED1B8B)];
    } else if (isFalling) {
      colors = [const Color(0xFFB3D3A7), const Color(0xFF268703)];
    } else {
      colors = [const Color(0xFFAAAAAA), const Color(0xFF888888)];
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = ui.Gradient.linear(
        Offset.zero,
        Offset(size.width, 0),
        colors,
      );

    // データの min/max で正規化し描画高さを最大活用
    final minVal = data.reduce((a, b) => a < b ? a : b);
    final maxVal = data.reduce((a, b) => a > b ? a : b);
    final range = (maxVal - minVal).clamp(0.01, double.infinity);
    final stepX = size.width / (data.length - 1);
    const pad = 2.0;
    final drawH = size.height - pad * 2;

    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final normalized = (data[i] - minVal) / range;
      final y = pad + drawH * (1.0 - normalized);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevX = (i - 1) * stepX;
        final prevY =
            pad + drawH * (1.0 - (data[i - 1] - minVal) / range);
        final cpX = (prevX + x) / 2;
        path.cubicTo(cpX, prevY, cpX, y, x, y);
      }
    }

    // 左から右へのアニメーション
    canvas.save();
    canvas.clipRect(
        Rect.fromLTWH(0, 0, size.width * progress, size.height));
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_SparklinePainter old) =>
      old.progress != progress ||
      old.isRising != isRising ||
      old.isFalling != isFalling;
}
