import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'dart:math' as math;

const _fontFamily = 'Hiragino Kaku Gothic Pro';

// ── OHLCデータ ────────────────────────────────────────────
class OhlcData {
  final double open, high, low, close;
  const OhlcData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
  });
}

// ── コインデータモデル ────────────────────────────────────
class CoinData {
  final String symbol;
  final String name;
  final String symbolChar;
  final String iconAsset;
  final Color primaryColor;
  final Color accentColor;
  final double price;
  final double changePercent;
  final List<double> lineData;
  final List<OhlcData> candleData;

  const CoinData({
    required this.symbol,
    required this.name,
    required this.symbolChar,
    required this.iconAsset,
    required this.primaryColor,
    required this.accentColor,
    required this.price,
    required this.changePercent,
    required this.lineData,
    required this.candleData,
  });
}

// ── 期間別 X軸ラベル ──────────────────────────────────────
// インデックスは _selectedPeriod (0=時, 1=日, 2=週, 3=月, 4=年) に対応
const List<List<String>> kPeriodXLabels = [
  ['12:00', '4:00', '8:00', '12:00'],
  ['6:00', '12:00', '18:00', '0:00'],
  ['月', '水', '金', '日'],
  ['1日', '10日', '20日', '30日'],
  ['1月', '4月', '7月', '10月'],
];

// ── コインリスト ─────────────────────────────────────────
// [0] BTC (初期表示) / [1] BAT / [2] BCH / [3] XRP
final List<CoinData> kCoins = [
  // ─── 0: BTC ─────────────────────────────────────────
  CoinData(
    symbol: 'BTC',
    name: 'ビットコイン',
    symbolChar: '₿',
    iconAsset: 'assets/icons/btc.png',
    primaryColor: const Color(0xFFF7931A),
    accentColor: const Color(0xFFFCC31F),
    price: 16845997,
    changePercent: 0.45,
    lineData: const [
      188200,
      188000,
      187600,
      187800,
      187200,
      186800,
      186500,
      186200,
      185800,
      185500,
      185800,
      187200,
      189500,
      191800,
      192500,
      191200,
      190800,
      191500,
      193000,
      195500,
      197800,
      196200,
      197400,
      197200,
    ],
    candleData: const [
      OhlcData(open: 188200, high: 189500, low: 187200, close: 187800),
      OhlcData(open: 187800, high: 188500, low: 186200, close: 186800),
      OhlcData(open: 186800, high: 187500, low: 185500, close: 185800),
      OhlcData(open: 185800, high: 188000, low: 185200, close: 187200),
      OhlcData(open: 187200, high: 191500, low: 186800, close: 190800),
      OhlcData(open: 190800, high: 193200, low: 189500, close: 192500),
      OhlcData(open: 192500, high: 194000, low: 190500, close: 191500),
      OhlcData(open: 191500, high: 194500, low: 191000, close: 193000),
      OhlcData(open: 193000, high: 197500, low: 192500, close: 196000),
      OhlcData(open: 196000, high: 198800, low: 194500, close: 195500),
      OhlcData(open: 195500, high: 198500, low: 195000, close: 197800),
      OhlcData(open: 197800, high: 198500, low: 196000, close: 197200),
    ],
  ),
  // ─── 1: BAT ─────────────────────────────────────────
  CoinData(
    symbol: 'BAT',
    name: 'ベーシックアテンション',
    symbolChar: 'B',
    iconAsset: 'assets/icons/bat.png',
    primaryColor: const Color(0xFFE84142),
    accentColor: const Color(0xFFF08384),
    price: 25,
    changePercent: 1.23,
    lineData: const [
      23.5,
      23.8,
      23.6,
      24.0,
      24.2,
      24.5,
      24.3,
      24.7,
      24.9,
      25.1,
      24.8,
      25.0,
      25.2,
      25.5,
      25.3,
      25.6,
      25.4,
      25.7,
      25.5,
      25.8,
      25.6,
      25.4,
      25.2,
      25.0,
    ],
    candleData: const [
      OhlcData(open: 23.5, high: 24.0, low: 23.2, close: 23.8),
      OhlcData(open: 23.8, high: 24.3, low: 23.6, close: 24.1),
      OhlcData(open: 24.1, high: 24.6, low: 23.9, close: 24.4),
      OhlcData(open: 24.4, high: 24.9, low: 24.2, close: 24.7),
      OhlcData(open: 24.7, high: 25.2, low: 24.5, close: 25.0),
      OhlcData(open: 25.0, high: 25.5, low: 24.8, close: 25.3),
      OhlcData(open: 25.3, high: 25.8, low: 25.1, close: 25.6),
      OhlcData(open: 25.6, high: 26.0, low: 25.4, close: 25.8),
      OhlcData(open: 25.8, high: 26.1, low: 25.3, close: 25.5),
      OhlcData(open: 25.5, high: 25.9, low: 25.1, close: 25.3),
      OhlcData(open: 25.3, high: 25.6, low: 24.9, close: 25.1),
      OhlcData(open: 25.1, high: 25.3, low: 24.8, close: 25.0),
    ],
  ),
  // ─── 2: BCH ─────────────────────────────────────────
  CoinData(
    symbol: 'BCH',
    name: 'ビットコインキャッシュ',
    symbolChar: 'Ƀ',
    iconAsset: 'assets/icons/bch.png',
    primaryColor: const Color(0xFF0AC18E),
    accentColor: const Color(0xFF5FD6B5),
    price: 45230,
    changePercent: -0.87,
    lineData: const [
      44500,
      44800,
      44600,
      45000,
      45200,
      45500,
      45300,
      45600,
      45800,
      46000,
      45700,
      45900,
      46100,
      46300,
      46000,
      45800,
      45600,
      45400,
      45200,
      45000,
      45100,
      45300,
      45200,
      45230,
    ],
    candleData: const [
      OhlcData(open: 44500, high: 45000, low: 44200, close: 44800),
      OhlcData(open: 44800, high: 45300, low: 44600, close: 45100),
      OhlcData(open: 45100, high: 45600, low: 44900, close: 45400),
      OhlcData(open: 45400, high: 45900, low: 45200, close: 45700),
      OhlcData(open: 45700, high: 46200, low: 45500, close: 46000),
      OhlcData(open: 46000, high: 46400, low: 45700, close: 46200),
      OhlcData(open: 46200, high: 46500, low: 45800, close: 46000),
      OhlcData(open: 46000, high: 46200, low: 45500, close: 45700),
      OhlcData(open: 45700, high: 45900, low: 45200, close: 45400),
      OhlcData(open: 45400, high: 45600, low: 45000, close: 45200),
      OhlcData(open: 45200, high: 45500, low: 45000, close: 45300),
      OhlcData(open: 45300, high: 45500, low: 45100, close: 45230),
    ],
  ),
  // ─── 3: XRP ─────────────────────────────────────────
  CoinData(
    symbol: 'XRP',
    name: 'リップル',
    symbolChar: 'X',
    iconAsset: 'assets/icons/xrp.png',
    primaryColor: const Color(0xFF00AAE4),
    accentColor: const Color(0xFF4DC8F0),
    price: 328,
    changePercent: -1.54,
    lineData: const [
      310,
      312,
      315,
      318,
      316,
      320,
      322,
      319,
      321,
      325,
      323,
      326,
      328,
      330,
      327,
      325,
      323,
      326,
      329,
      331,
      328,
      326,
      327,
      328,
    ],
    candleData: const [
      OhlcData(open: 310, high: 318, low: 308, close: 315),
      OhlcData(open: 315, high: 322, low: 313, close: 320),
      OhlcData(open: 320, high: 326, low: 318, close: 323),
      OhlcData(open: 323, high: 329, low: 321, close: 326),
      OhlcData(open: 326, high: 333, low: 324, close: 330),
      OhlcData(open: 330, high: 334, low: 326, close: 328),
      OhlcData(open: 328, high: 332, low: 324, close: 325),
      OhlcData(open: 325, high: 330, low: 322, close: 327),
      OhlcData(open: 327, high: 333, low: 325, close: 331),
      OhlcData(open: 331, high: 335, low: 327, close: 329),
      OhlcData(open: 329, high: 332, low: 325, close: 327),
      OhlcData(open: 327, high: 331, low: 325, close: 328),
    ],
  ),
];

// ── CoinPriceCard ─────────────────────────────────────────
class CoinPriceCard extends StatefulWidget {
  final CoinData coin;
  const CoinPriceCard({super.key, required this.coin});

  @override
  State<CoinPriceCard> createState() => _CoinPriceCardState();
}

class _CoinPriceCardState extends State<CoinPriceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _chartProgress;
  bool _showCandlestick = false;
  int _selectedPeriod = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _chartProgress = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void didUpdateWidget(CoinPriceCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.coin.symbol != widget.coin.symbol) {
      _animController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleChartType() {
    setState(() => _showCandlestick = !_showCandlestick);
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.coin;
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(coin),
          _buildPrice(coin),
          Expanded(
            child: ClipRect(
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AnimatedBuilder(
                  animation: _chartProgress,
                  builder: (context, _) {
                    final xLabels = kPeriodXLabels[_selectedPeriod];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        if (_showCandlestick) {
                          return CustomPaint(
                            painter: _CandlePainter(
                              data: coin.candleData,
                              progress: _chartProgress.value,
                              xLabels: xLabels,
                            ),
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                          );
                        } else {
                          // 最初と最後のデータを比較してトレンドを判定
                          final isRising =
                              coin.lineData.last >= coin.lineData.first;
                          return CustomPaint(
                            painter: _LineChartPainter(
                              data: coin.lineData,
                              progress: _chartProgress.value,
                              isRising: isRising,
                              xLabels: xLabels,
                            ),
                            size: Size(
                              constraints.maxWidth,
                              constraints.maxHeight,
                            ),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
          _buildTimePeriodSelector(coin),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── ヘッダー ────────────────────────────────────────────
  Widget _buildHeader(CoinData coin) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 6,
            children: [
              // コインアイコン
              Image.asset(
                coin.iconAsset,
                width: 28,
                height: 28,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        coin.symbol,
                        style: const TextStyle(
                          color: Color(0xFF4D4D4D),
                          fontSize: 20,
                          fontFamily: _fontFamily,
                          fontWeight: FontWeight.w600,
                          height: 1,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 18,
                        color: Color(0xFF4D4D4D),
                      ),
                    ],
                  ),
                  Text(
                    coin.name,
                    style: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 11,
                      fontFamily: _fontFamily,
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.11,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            spacing: 10,
            children: [
              Image.asset(
                'assets/icons/menu.png',
                width: 24,
                height: 24,
                color: const Color(0xFF888888),
              ),

              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: Color(0xFF747474),
                  shape: BoxShape.circle,
                ),
                child: const LikeButton(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 価格エリア ──────────────────────────────────────────
  Widget _buildPrice(CoinData coin) {
    final isPositive = coin.changePercent >= 0;
    final changeColor = isPositive
        ? const Color(0xFFE8317B)
        : const Color(0xFF009B8D);
    final changeStr = isPositive
        ? '+${coin.changePercent.toStringAsFixed(2)} %'
        : '${coin.changePercent.toStringAsFixed(2)} %';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        spacing: 4,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            spacing: 2,
            children: [
              Text(
                _formatPrice(coin.price),
                style: const TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 30,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  '円',
                  style: TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 14,
                    fontFamily: _fontFamily,
                    fontWeight: FontWeight.w400,
                    height: 1,
                  ),
                ),
              ),
            ],
          ),
          Text(
            changeStr,
            style: TextStyle(
              color: changeColor,
              fontSize: 12,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  // ── 期間セレクター ──────────────────────────────────────
  Widget _buildTimePeriodSelector(CoinData coin) {
    const periods = ['時', '日', '週', '月', '年'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 34,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEEEE),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Row(
                children: List.generate(periods.length, (i) {
                  final isSelected = i == _selectedPeriod;
                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => setState(() => _selectedPeriod = i),
                      child: Container(
                        margin: const EdgeInsets.all(3),
                        decoration: isSelected
                            ? BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(999),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x18000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1),
                                  ),
                                ],
                              )
                            : null,
                        child: Center(
                          child: Text(
                            periods[i],
                            style: TextStyle(
                              color: isSelected
                                  ? const Color(0xFF333333)
                                  : const Color(0xFF999999),
                              fontSize: 12,
                              fontFamily: _fontFamily,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // ローソク足 / ラインチャート 切り替えボタン
          GestureDetector(
            onTap: _toggleChartType,
            child: Icon(
              _showCandlestick
                  ? Icons.show_chart
                  : Icons.candlestick_chart_outlined,
              size: 22,
              color: coin.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  // 価格フォーマット: 1234567 → "1,234,567"
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

// ── ラインチャート描画 ────────────────────────────────────
// 上昇: ピンク (#FFA0B9 → #ED1B8B)、下降: グリーン (#B3D3A7 → #268703)
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final double progress; // 0.0 - 1.0
  final bool isRising;
  final List<String> xLabels;

  const _LineChartPainter({
    required this.data,
    required this.progress,
    required this.isRising,
    required this.xLabels,
  });

  static const _risingStart = Color(0xFFFFA0B9);
  static const _risingEnd = Color(0xFFED1B8B);
  static const _fallingStart = Color(0xFFB3D3A7);
  static const _fallingEnd = Color(0xFF268703);

  static const double _leftMargin = 8;
  static const double _rightMargin = 52;
  static const double _topMargin = 8;
  static const double _bottomMargin = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - _leftMargin - _rightMargin;
    final chartHeight = size.height - _topMargin - _bottomMargin;

    final minVal = data.reduce(math.min);
    final maxVal = data.reduce(math.max);
    final range = maxVal - minVal == 0 ? 1.0 : maxVal - minVal;

    // 全ポイント計算
    final allPoints = List.generate(data.length, (i) {
      final x = _leftMargin + (i / (data.length - 1)) * chartWidth;
      final y = _topMargin + (1 - (data[i] - minVal) / range) * chartHeight;
      return Offset(x, y);
    });

    // progress分だけ切り取るためのクリップ
    final clipRight = _leftMargin + progress * chartWidth;
    canvas.save();
    canvas.clipRect(Rect.fromLTRB(0, 0, clipRight, size.height));

    // グラデーション塗りつぶし
    final fillPath = Path()..moveTo(allPoints.first.dx, allPoints.first.dy);
    for (final p in allPoints.skip(1)) {
      fillPath.lineTo(p.dx, p.dy);
    }
    fillPath.lineTo(allPoints.last.dx, _topMargin + chartHeight);
    fillPath.lineTo(allPoints.first.dx, _topMargin + chartHeight);
    fillPath.close();

    // トレンドに応じたライン色を決定
    final lineStart = isRising ? _risingStart : _fallingStart;
    final lineEnd = isRising ? _risingEnd : _fallingEnd;

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineEnd.withValues(alpha: 0.18),
            lineEnd.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, _topMargin, size.width, chartHeight)),
    );

    // チャートライン（左から右へのグラデーション）
    final linePath = Path()..moveTo(allPoints.first.dx, allPoints.first.dy);
    for (final p in allPoints.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [lineStart, lineEnd],
        ).createShader(
          Rect.fromLTWH(_leftMargin, 0, chartWidth, size.height),
        )
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round,
    );
    canvas.restore();

    // グリッド線 + Y軸ラベル
    _drawGridAndLabels(canvas, size, chartWidth, chartHeight, minVal, range);

    // X軸ラベル
    _drawXLabels(canvas, size, chartWidth);
  }

  void _drawGridAndLabels(
    Canvas canvas,
    Size size,
    double chartWidth,
    double chartHeight,
    double minVal,
    double range,
  ) {
    final gridPaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = 0.8;
    const labelStyle = TextStyle(
      color: Color(0xFF999999),
      fontSize: 10,
      fontFamily: _fontFamily,
    );

    final minY = data.reduce(math.min);
    final maxY = data.reduce(math.max);
    final step = (maxY - minY) / 3;
    final gridValues = [
      minY + step * 2.5,
      minY + step * 1.5,
      minY + step * 0.5,
    ];

    for (final yVal in gridValues) {
      final yPixel = _topMargin + (1 - (yVal - minVal) / range) * chartHeight;
      if (yPixel < _topMargin - 4 || yPixel > _topMargin + chartHeight + 4) {
        continue;
      }
      _drawDashedLine(
        canvas,
        Offset(_leftMargin, yPixel),
        Offset(_leftMargin + chartWidth, yPixel),
        gridPaint,
      );
      final label = _formatYLabel(yVal);
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(_leftMargin + chartWidth + 6, yPixel - tp.height / 2),
      );
    }
  }

  void _drawXLabels(Canvas canvas, Size size, double chartWidth) {
    const labelStyle = TextStyle(
      color: Color(0xFF999999),
      fontSize: 10,
      fontFamily: _fontFamily,
    );
    for (int i = 0; i < xLabels.length; i++) {
      final x = _leftMargin + (i / (xLabels.length - 1)) * chartWidth;
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x - tp.width / 2, size.height - _bottomMargin + 4),
      );
    }
  }

  String _formatYLabel(double val) {
    if (val >= 1000) {
      final thousands = val / 1000;
      return thousands == thousands.roundToDouble()
          ? '${thousands.toInt()}.000'
          : thousands.toStringAsFixed(3);
    }
    return val.toStringAsFixed(0);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length == 0) return;
    final ux = dx / length;
    final uy = dy / length;
    double p = 0;
    bool drawing = true;
    while (p < length) {
      final step = drawing ? dashWidth : dashSpace;
      final e = math.min(p + step, length);
      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + ux * p, start.dy + uy * p),
          Offset(start.dx + ux * e, start.dy + uy * e),
          paint,
        );
      }
      p = e;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) =>
      old.progress != progress ||
      old.isRising != isRising ||
      old.xLabels != xLabels;
}

// ── ローソク足チャート描画 ────────────────────────────────
class _CandlePainter extends CustomPainter {
  final List<OhlcData> data;
  final double progress;
  final List<String> xLabels;

  static const _upColor = Color(0xFF1F7EEA);
  static const _downColor = Color(0xFFEA3A3A);

  const _CandlePainter({
    required this.data,
    required this.progress,
    required this.xLabels,
  });

  static const double _leftMargin = 8;
  static const double _rightMargin = 52;
  static const double _topMargin = 8;
  static const double _bottomMargin = 24;

  @override
  void paint(Canvas canvas, Size size) {
    final chartWidth = size.width - _leftMargin - _rightMargin;
    final chartHeight = size.height - _topMargin - _bottomMargin;

    double minLow = double.infinity;
    double maxHigh = double.negativeInfinity;
    for (final d in data) {
      if (d.low < minLow) minLow = d.low;
      if (d.high > maxHigh) maxHigh = d.high;
    }
    final range = maxHigh - minLow == 0 ? 1.0 : maxHigh - minLow;

    // グリッドラインと Y軸ラベル
    final gridPaint = Paint()
      ..color = const Color(0xFFDDDDDD)
      ..strokeWidth = 0.8;
    const labelStyle = TextStyle(
      color: Color(0xFF999999),
      fontSize: 10,
      fontFamily: _fontFamily,
    );
    final step = (maxHigh - minLow) / 3;
    final gridValues = [
      minLow + step * 2.5,
      minLow + step * 1.5,
      minLow + step * 0.5,
    ];
    for (final yVal in gridValues) {
      final yPixel = _topMargin + (1 - (yVal - minLow) / range) * chartHeight;
      _drawDashedLine(
        canvas,
        Offset(_leftMargin, yPixel),
        Offset(_leftMargin + chartWidth, yPixel),
        gridPaint,
      );
      final label = _formatYLabel(yVal);
      final tp = TextPainter(
        text: TextSpan(text: label, style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(_leftMargin + chartWidth + 6, yPixel - tp.height / 2),
      );
    }

    // ローソク足描画（progressに応じて左から右に表示）
    final visibleCount = (data.length * progress).ceil().clamp(0, data.length);
    final candleWidth = chartWidth / data.length;
    final bodyWidth = (candleWidth * 0.55).clamp(4.0, 12.0);

    for (int i = 0; i < visibleCount; i++) {
      final d = data[i];
      final centerX = _leftMargin + (i + 0.5) * candleWidth;
      final yHigh = _topMargin + (1 - (d.high - minLow) / range) * chartHeight;
      final yLow = _topMargin + (1 - (d.low - minLow) / range) * chartHeight;
      final yOpen = _topMargin + (1 - (d.open - minLow) / range) * chartHeight;
      final yClose =
          _topMargin + (1 - (d.close - minLow) / range) * chartHeight;

      final isUp = d.close >= d.open;
      final color = isUp ? _upColor : _downColor;
      final paint = Paint()..color = color;

      // ヒゲ（上下）
      canvas.drawLine(
        Offset(centerX, yHigh),
        Offset(centerX, yLow),
        paint
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke,
      );

      // 胴体
      final bodyTop = math.min(yOpen, yClose);
      final bodyBottom = math.max(yOpen, yClose);
      canvas.drawRect(
        Rect.fromLTRB(
          centerX - bodyWidth / 2,
          bodyTop,
          centerX + bodyWidth / 2,
          math.max(bodyBottom, bodyTop + 2.0),
        ),
        paint..style = PaintingStyle.fill,
      );
    }

    // X軸ラベル
    for (int i = 0; i < xLabels.length; i++) {
      final x = _leftMargin + (i / (xLabels.length - 1)) * chartWidth;
      final tp = TextPainter(
        text: TextSpan(text: xLabels[i], style: labelStyle),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(x - tp.width / 2, size.height - _bottomMargin + 4),
      );
    }
  }

  String _formatYLabel(double val) {
    if (val >= 1000) {
      final thousands = val / 1000;
      return thousands == thousands.roundToDouble()
          ? '${thousands.toInt()}.000'
          : thousands.toStringAsFixed(3);
    }
    return val.toStringAsFixed(0);
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 4.0;
    const dashSpace = 3.0;
    final dx = end.dx - start.dx;
    final dy = end.dy - start.dy;
    final length = math.sqrt(dx * dx + dy * dy);
    if (length == 0) return;
    final ux = dx / length;
    final uy = dy / length;
    double p = 0;
    bool drawing = true;
    while (p < length) {
      final step = drawing ? dashWidth : dashSpace;
      final e = math.min(p + step, length);
      if (drawing) {
        canvas.drawLine(
          Offset(start.dx + ux * p, start.dy + uy * p),
          Offset(start.dx + ux * e, start.dy + uy * e),
          paint,
        );
      }
      p = e;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(_CandlePainter old) =>
      old.progress != progress || old.xLabels != xLabels;
}

class LikeButton extends StatefulWidget {
  const LikeButton({super.key});

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  bool _liked = false;
  late AnimationController _controller;
  late Animation<double> _springAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _springAnim = _controller.drive(Tween(begin: 0.0, end: 1.0));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _liked = !_liked);

    final spring = SpringDescription(mass: 1, stiffness: 180, damping: 12);

    _controller.animateWith(
      SpringSimulation(spring, _controller.value, _liked ? 1.0 : 0.0, 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggle,
      child: SizedBox(
        width: 28,
        height: 28,
        child: AnimatedBuilder(
          animation: _springAnim,
          builder: (context, _) {
            final t = _springAnim.value;
            return Stack(
              alignment: Alignment.center,
              children: [
                Transform.scale(
                  scale: (1.0 - t).clamp(0.0, 1.0),
                  child: const Icon(
                    Icons.favorite, // ← 変更
                    size: 20,
                    color: Color.fromARGB(255, 255, 255, 255), // 枠ハート（赤）
                  ),
                ),

                Transform.scale(
                  scale: t.clamp(0.0, 2.4),
                  child: const Icon(
                    Icons.favorite, // ← 変更
                    size: 20,
                    color: Color.fromARGB(255, 255, 208, 0), // 塗りハート（ちょいピンク）
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
