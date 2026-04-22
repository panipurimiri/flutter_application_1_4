import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'dart:ui'; // BackdropFilterとImageFilterに必要

import 'glass_bottom_nav.dart';
import 'main.dart' show BtcDetailPage;
import 'coin_list.dart';
import 'home_page.dart';

const _fontFamily = 'Hiragino Kaku Gothic Pro';

// ── 資産データ ─────────────────────────────────────────────
class _AssetRow {
  final String symbol;
  final String name;
  final String iconAsset;
  final bool isSvg;
  final String value;
  final String gain;
  final bool isRising;
  const _AssetRow({
    required this.symbol,
    required this.name,
    required this.iconAsset,
    this.isSvg = false,
    required this.value,
    required this.gain,
    required this.isRising,
  });
}

const _kAssets = [
  _AssetRow(
    symbol: 'BTC',
    name: 'ビットコイン',
    iconAsset: 'assets/icons/btc.png',
    value: '15,230,036円',
    gain: '- 136円',
    isRising: false,
  ),
  _AssetRow(
    symbol: 'ETH',
    name: 'イーサリアム',
    iconAsset: 'assets/icons/eth.png',
    value: '366,000円',
    gain: '+ 150,036円',
    isRising: true,
  ),
  _AssetRow(
    symbol: 'DOGE',
    name: 'ドージコイン',
    iconAsset: 'assets/icons/doge.png',
    value: '24.65円',
    gain: '+ 10,036円',
    isRising: true,
  ),
  _AssetRow(
    symbol: 'XRP',
    name: 'エックスアールビー',
    iconAsset: 'assets/icons/xrp.png',
    value: '429.11円',
    gain: '+ 40,036円',
    isRising: true,
  ),
  _AssetRow(
    symbol: 'SHIB',
    name: 'シバイヌ',
    iconAsset: 'assets/icons/shib.svg',
    isSvg: true,
    value: '0.001507円',
    gain: '- 9,400円',
    isRising: false,
  ),
  _AssetRow(
    symbol: 'BCH',
    name: 'ビットコインキャッシュ',
    iconAsset: 'assets/icons/bch.png',
    value: '32,000円',
    gain: '+ 80,000円',
    isRising: true,
  ),
  _AssetRow(
    symbol: 'BAT',
    name: 'ベーシックアテンショントークン',
    iconAsset: 'assets/icons/bat.png',
    value: '12.34円',
    gain: '+ 700円',
    isRising: true,
  ),
  _AssetRow(
    symbol: 'LTC',
    name: 'ライトコイン',
    iconAsset: 'assets/icons/ltc.png',
    value: '12,348円',
    gain: '+ 4,890円',
    isRising: true,
  ),
  _AssetRow(
    symbol: 'DOT',
    name: 'ポルカドット',
    iconAsset: 'assets/icons/dot.png',
    value: '7,045円',
    gain: '- 1,500円',
    isRising: false,
  ),
  _AssetRow(
    symbol: 'LINK',
    name: 'チェーンリンク',
    iconAsset: 'assets/icons/link.png',
    value: '2,356円',
    gain: '+ 700円',
    isRising: true,
  ),
  _AssetRow(
    symbol: 'TRX',
    name: 'トロン',
    iconAsset: 'assets/icons/trx.svg',
    isSvg: true,
    value: '51.34円',
    gain: '+ 20,000円',
    isRising: true,
  ),
];

// ── チャートデータ（資産推移 正規化 0–1） ────────────────────
const _kChartData = [
  0.18,
  0.16,
  0.14,
  0.18,
  0.20,
  0.22,
  0.25,
  0.30,
  0.28,
  0.32,
  0.35,
  0.40,
  0.38,
  0.42,
  0.45,
  0.50,
  0.55,
  0.52,
  0.58,
  0.62,
  0.60,
  0.65,
  0.68,
  0.72,
  0.70,
  0.74,
  0.78,
  0.75,
  0.80,
  0.82,
  0.85,
  0.88,
  0.86,
  0.90,
  0.93,
  0.96,
  0.92,
  0.95,
  0.97,
  1.00,
];

// ── チャートの X 軸ラベル ──────────────────────────────────
const _kChartLabels = ['2025\n1/21', '2026\n1/20'];
const _kPeriodTabs = ['週', '月', '年'];

class AssetsPage extends StatefulWidget {
  const AssetsPage({super.key});

  @override
  State<AssetsPage> createState() => _AssetsPageState();
}

class _AssetsPageState extends State<AssetsPage> {
  int _topTab = 0;
  int _periodTab = 2;

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Stack(
        children: [
          // ── グラデーション背景 ────────────────────────────
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

          // ── スクロール可能コンテンツ ──────────────────────
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // タイトル
                  const Padding(
                    padding: EdgeInsets.fromLTRB(24, 0, 16, 0),
                    child: Text(
                      '資産',
                      style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 22,
                        fontFamily: _fontFamily,
                        fontWeight: FontWeight.w600,
                        height: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // トップタブ
                  _buildTopTabs(),
                  const SizedBox(height: 24),

                  // 残高＋評価損益
                  _buildBalanceSection(),
                  const SizedBox(height: 24),

                  // チャート + 期間タブ（状態保持）
                  _ChartSection(
                    periodTab: _periodTab,
                    onPeriodTap: (i) => setState(() => _periodTab = i),
                  ),
                  const SizedBox(height: 16),

                  // JPY 行
                  _buildJpyRow(),
                  const SizedBox(height: 16),

                  // 資産リスト ヘッダ
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: const [
                        Expanded(
                          child: Text(
                            '評価額',
                            style: TextStyle(
                              color: Color(0xFFBF0000),
                              fontSize: 12,
                              fontFamily: _fontFamily,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                        Text(
                          '評価損益',
                          style: TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 12,
                            fontFamily: _fontFamily,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),

                  // 資産行リスト
                  ..._kAssets.map((a) => _AssetRowWidget(asset: a)),

                  // ボトムバー分の余白
                  const SizedBox(height: 120),
                ],
              ),
            ),
          ),

          // ── ボトムナビ ────────────────────────────────────
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

  Widget _buildTopTabs() {
    const labels = ['資産状況', '実現損益', '取引累計', '推移'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 8,
        children: List.generate(labels.length, (i) {
          final isActive = _topTab == i;
          return GestureDetector(
            onTap: () => setState(() => _topTab = i),
            child: Container(
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? Colors.white : const Color(0x99D2D6DC),
                borderRadius: BorderRadius.circular(128),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: isActive
                      ? const Color(0xFFBF0000)
                      : const Color(0xFF555555),
                  fontSize: 14,
                  fontFamily: _fontFamily,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w300,
                  height: 1,
                  letterSpacing: 0.14,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBalanceSection() {
    return Column(
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
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: const [
            Text(
              '18,937,150',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 42,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w600,
                height: 0.9,
              ),
            ),
            SizedBox(width: 4),
            Padding(
              padding: EdgeInsets.only(bottom: 2),
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
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Text(
              '評価損益 ',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 10,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              '+',
              style: TextStyle(
                color: Color(0xFFEA0541),
                fontSize: 10,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              ' 15,230,036',
              style: TextStyle(
                color: Color(0xFFEA0541),
                fontSize: 12,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.12,
              ),
            ),
            Text(
              '円',
              style: TextStyle(
                color: Color(0xFFEA0541),
                fontSize: 10,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildJpyRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.70),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Color(0xFFE60012),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Text(
                '¥',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w600,
                  height: 1,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'JPY',
                    style: TextStyle(
                      color: Color(0xFF222222),
                      fontSize: 14,
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '日本円',
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
            const Text(
              '15,230,036円',
              style: TextStyle(
                color: Color(0xFF222222),
                fontSize: 14,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
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
      selectedIndex: 3,
      onTap: (i) {
        if (i == 3) return;
        if (i == 0) {
          Navigator.pushAndRemoveUntil(
            context,
            PageRouteBuilder(
              pageBuilder: (ctx, a1, a2) => const HomePage(),
              transitionDuration: const Duration(milliseconds: 250),
              reverseTransitionDuration: const Duration(milliseconds: 200),
              transitionsBuilder: (ctx, anim, a2, child) =>
                  FadeTransition(opacity: anim, child: child),
            ),
            (route) => false,
          );
        } else if (i == 1) {
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

// ── チャートセクション（状態保持） ───────────────────────────
class _ChartSection extends StatefulWidget {
  final int periodTab;
  final ValueChanged<int> onPeriodTap;
  const _ChartSection({required this.periodTab, required this.onPeriodTap});

  @override
  State<_ChartSection> createState() => _ChartSectionState();
}

class _ChartSectionState extends State<_ChartSection>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late final AnimationController _chartAnim;
  late final Animation<double> _chartProgress;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _chartAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _chartProgress = CurvedAnimation(parent: _chartAnim, curve: Curves.easeOut);
    WidgetsBinding.instance.addPostFrameCallback((_) => _chartAnim.forward());
  }

  @override
  void dispose() {
    _chartAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _chartProgress,
            builder: (_, _) => SizedBox(
              height: 120,
              child: CustomPaint(
                painter: _ChartPainter(
                  data: _kChartData,
                  progress: _chartProgress.value,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _kChartLabels
                .map(
                  (l) => Text(
                    l,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 10,
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w300,
                      height: 1.3,
                    ),
                  ),
                )
                .toList(),
          ),
          const SizedBox(height: 12),
          _LiquidPeriodTabs(
            labels: _kPeriodTabs,
            selectedIndex: widget.periodTab,
            onTap: widget.onPeriodTap,
          ),
        ],
      ),
    );
  }
}

// ── ゴムアニメーション付き期間タブ（全体リキッドグラス化） ───────────────
class _LiquidPeriodTabs extends StatefulWidget {
  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  const _LiquidPeriodTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<_LiquidPeriodTabs> createState() => _LiquidPeriodTabsState();
}

class _LiquidPeriodTabsState extends State<_LiquidPeriodTabs>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  late Animation<double> _leadAnim;
  late Animation<double> _trailAnim;
  late Animation<double> _fadeAnim;
  late Animation<double> _bounceAnim;
  late Animation<double> _scaleAnim;

  int _prev = 0;
  int _cur = 0;
  bool _movingRight = true;

  static const _kBarH = 36.0;
  static const _kInset = 3.0;
  static const _kRadius = 128.0;

  void _startAnim(int from, int to) {
    _movingRight = to > from;
    final f = from.toDouble();
    final t = to.toDouble();

    _leadAnim = Tween<double>(begin: f, end: t).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.42, curve: Curves.easeOut),
      ),
    );
    _trailAnim = Tween<double>(begin: f, end: t).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.28, 0.82, curve: Curves.easeOut),
      ),
    );
    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.30, 0.65, curve: Curves.easeInOut),
    );
    _bounceAnim = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 75),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.0,
          end: 1.07,
        ).chain(CurveTween(curve: Curves.easeOut)),
        weight: 12,
      ),
      TweenSequenceItem(
        tween: Tween(
          begin: 1.07,
          end: 1.0,
        ).chain(CurveTween(curve: Curves.easeInOut)),
        weight: 13,
      ),
    ]).animate(_ctrl);
    _scaleAnim =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween(
              begin: 1.0,
              end: 1.18,
            ).chain(CurveTween(curve: Curves.easeOut)),
            weight: 40,
          ),
          TweenSequenceItem(
            tween: Tween(
              begin: 1.18,
              end: 1.0,
            ).chain(CurveTween(curve: Curves.easeInOut)),
            weight: 60,
          ),
        ]).animate(
          CurvedAnimation(parent: _ctrl, curve: const Interval(0.35, 0.88)),
        );

    _ctrl.forward(from: 0);
  }

  @override
  void initState() {
    super.initState();
    _cur = widget.selectedIndex;
    _prev = widget.selectedIndex;
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 720),
    );
    _ctrl.value = 1.0;
    final d = _cur.toDouble();
    _leadAnim = AlwaysStoppedAnimation(d);
    _trailAnim = AlwaysStoppedAnimation(d);
    _fadeAnim = AlwaysStoppedAnimation(1.0);
    _bounceAnim = AlwaysStoppedAnimation(1.0);
    _scaleAnim = AlwaysStoppedAnimation(1.0);
  }

  @override
  void didUpdateWidget(_LiquidPeriodTabs old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _prev = _cur;
      _cur = widget.selectedIndex;
      _startAnim(_prev, _cur);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final totalW = constraints.maxWidth;
        final tabW = totalW / widget.labels.length;

        // 【背景の全体トラック】リキッドグラス表現
        return ClipRRect(
          borderRadius: BorderRadius.circular(_kRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12.0, sigmaY: 12.0),
            child: Container(
              height: _kBarH,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFFD2D6DC).withValues(alpha: 0.4),
                    const Color(0xFFD2D6DC).withValues(alpha: 0.1),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.5),
                  width: 1.0,
                ),
                borderRadius: BorderRadius.circular(_kRadius),
              ),
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (context, _) {
                  final lead = _leadAnim.value;
                  final trail = _trailAnim.value;

                  final double pillLeft;
                  final double pillRight;
                  if (_movingRight) {
                    pillLeft = trail * tabW + _kInset;
                    pillRight = lead * tabW + tabW - _kInset;
                  } else {
                    pillLeft = lead * tabW + _kInset;
                    pillRight = trail * tabW + tabW - _kInset;
                  }
                  final pillW = (pillRight - pillLeft).clamp(0.0, totalW);

                  return Stack(
                    children: [
                      // 【選択チップ（動くゴムピル）】リキッドグラス表現
                      Positioned(
                        left: pillLeft,
                        top: _kInset,
                        bottom: _kInset,
                        width: pillW,
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(_kRadius),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_kRadius),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(
                                sigmaX: 8.0,
                                sigmaY: 8.0,
                              ),
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Colors.white.withValues(alpha: 0.85),
                                      Colors.white.withValues(alpha: 0.35),
                                    ],
                                  ),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.6),
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(_kRadius),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // ── タブラベル ────────────────────────────────
                      Row(
                        children: List.generate(widget.labels.length, (i) {
                          const active = Color(0xFFBF0000);
                          const inactive = Color(0xFF555555);
                          final Color labelColor;
                          if (_prev == _cur) {
                            labelColor = i == _cur ? active : inactive;
                          } else if (i == _cur) {
                            labelColor = Color.lerp(
                              inactive,
                              active,
                              _fadeAnim.value,
                            )!;
                          } else if (i == _prev) {
                            labelColor = Color.lerp(
                              active,
                              inactive,
                              _fadeAnim.value,
                            )!;
                          } else {
                            labelColor = inactive;
                          }

                          final fw =
                              (i == _cur ||
                                  (_prev != _cur &&
                                      i == _prev &&
                                      _fadeAnim.value < 0.5))
                              ? FontWeight.w600
                              : FontWeight.w300;

                          final double scale = (i == _cur && _prev != _cur)
                              ? _scaleAnim.value
                              : 1.0;

                          return Expanded(
                            child: GestureDetector(
                              onTap: () => widget.onTap(i),
                              behavior: HitTestBehavior.opaque,
                              child: SizedBox(
                                height: _kBarH,
                                child: Center(
                                  child: Transform.scale(
                                    scale: scale,
                                    child: Text(
                                      widget.labels[i],
                                      style: TextStyle(
                                        color: labelColor,
                                        fontSize: 14,
                                        fontFamily: _fontFamily,
                                        fontWeight: fw,
                                        height: 1,
                                        letterSpacing: 0.14,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── チャートペインター（左→右グラデーションラインのみ） ────────────
class _ChartPainter extends CustomPainter {
  final List<double> data;
  final double progress;

  const _ChartPainter({required this.data, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final totalPoints = data.length;
    final visibleCount = (totalPoints * progress).ceil().clamp(2, totalPoints);
    final pts = data.sublist(0, visibleCount);

    final path = Path();
    // ▼▼▼ 修正: 背景塗りつぶし用Pathを削除しました ▼▼▼
    // final fillPath = Path();
    // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    for (int i = 0; i < pts.length; i++) {
      final x = (i / (totalPoints - 1)) * size.width;
      final y = size.height - pts[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
        // fillPath.moveTo(x, size.height); // 削除
        // fillPath.lineTo(x, y); // 削除
      } else {
        path.lineTo(x, y);
        // fillPath.lineTo(x, y); // 削除
      }
    }

    // ▼▼▼ 修正: 背景塗りつぶし処理を削除しました ▼▼▼
    // グラデーション塗りつぶし
    /*
    final lastX = ((pts.length - 1) / (totalPoints - 1)) * size.width;
    fillPath.lineTo(lastX, size.height);
    fillPath.close();

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFEA0541).withValues(alpha: 0.18),
          const Color(0xFFEA0541).withValues(alpha: 0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.fill;
    canvas.drawPath(fillPath, fillPaint);
    */
    // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲

    // ▼▼▼ 修正: ラインをグラデーションに変更 ▼▼▼
    // ライン
    final linePaint = Paint()
      // ..color = const Color(0xFFEA0541) // 単色を削除
      ..strokeWidth =
          3.0 // 若干太くしました（グラデーションを見えやすくするため）
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // 左から右への線形グラデーションShaderを作成してセット
    final gradientRect = Rect.fromLTWH(0, 0, size.width, size.height);
    linePaint.shader = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [
        const Color(0xFFFFA0B9), // 指定色1：薄いピンク
        const Color(0xFFED1B8B), // 指定色2：濃いピンク
      ],
    ).createShader(gradientRect);

    canvas.drawPath(path, linePaint);
    // ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
  }

  @override
  bool shouldRepaint(_ChartPainter old) =>
      old.progress != progress || old.data != data;
}

// ── 資産行ウィジェット ────────────────────────────────────
class _AssetRowWidget extends StatelessWidget {
  final _AssetRow asset;
  const _AssetRowWidget({required this.asset});

  @override
  Widget build(BuildContext context) {
    final gainColor = asset.isRising
        ? const Color(0xFFEA0541)
        : const Color(0xFF0066CC);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                SizedBox(
                  width: 36,
                  height: 36,
                  child: asset.isSvg
                      ? SvgPicture.asset(asset.iconAsset, width: 36, height: 36)
                      : Image.asset(asset.iconAsset, width: 36, height: 36),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        asset.symbol,
                        style: const TextStyle(
                          color: Color(0xFF222222),
                          fontSize: 14,
                          fontFamily: _fontFamily,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        asset.name,
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 11,
                          fontFamily: _fontFamily,
                          fontWeight: FontWeight.w300,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      asset.value,
                      style: const TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 14,
                        fontFamily: _fontFamily,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      asset.gain,
                      style: TextStyle(
                        color: gainColor,
                        fontSize: 12,
                        fontFamily: _fontFamily,
                        fontWeight: FontWeight.w300,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE8E8E8)),
        ],
      ),
    );
  }
}
