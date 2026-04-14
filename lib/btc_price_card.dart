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
// [0] XRP / [1] BTC (初期表示) / [2] ETH
final List<CoinData> kCoins = [
  // ─── 0: XRP ─────────────────────────────────────────
  CoinData(
    symbol: 'XRP',
    name: 'リップル',
    symbolChar: 'X',
    primaryColor: const Color(0xFF346AA9),
    accentColor: const Color(0xFF5090CC),
    price: 7834,
    changePercent: 2.10,
    lineData: const [
      7400,
      7450,
      7420,
      7480,
      7500,
      7550,
      7520,
      7580,
      7600,
      7650,
      7620,
      7680,
      7700,
      7750,
      7720,
      7780,
      7800,
      7850,
      7820,
      7880,
      7900,
      7850,
      7820,
      7834,
    ],
    candleData: const [
      OhlcData(open: 7400, high: 7520, low: 7350, close: 7450),
      OhlcData(open: 7450, high: 7560, low: 7400, close: 7520),
      OhlcData(open: 7520, high: 7620, low: 7480, close: 7580),
      OhlcData(open: 7580, high: 7690, low: 7550, close: 7650),
      OhlcData(open: 7650, high: 7780, low: 7620, close: 7720),
      OhlcData(open: 7720, high: 7820, low: 7680, close: 7780),
      OhlcData(open: 7780, high: 7900, low: 7750, close: 7850),
      OhlcData(open: 7850, high: 7960, low: 7820, close: 7900),
      OhlcData(open: 7900, high: 7980, low: 7830, close: 7850),
      OhlcData(open: 7850, high: 7920, low: 7790, close: 7820),
      OhlcData(open: 7820, high: 7880, low: 7780, close: 7840),
      OhlcData(open: 7840, high: 7870, low: 7800, close: 7834),
    ],
  ),
  // ─── 1: BTC ─────────────────────────────────────────
  CoinData(
    symbol: 'BTC',
    name: 'ビットコイン',
    symbolChar: '₿',
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
  CoinData(
    symbol: 'ETH',
    name: 'イーサリアム',
    symbolChar: 'Ξ',
    primaryColor: const Color(0xFF627EEA),
    accentColor: const Color(0xFF8FA4F0),
    price: 285430,
    changePercent: -1.23,
    lineData: const [
      290000,
      289000,
      287500,
      286000,
      284500,
      283000,
      282000,
      281500,
      281000,
      280500,
      281000,
      282000,
      283500,
      285000,
      286500,
      285500,
      284500,
      285000,
      286000,
      285500,
      285000,
      284500,
      285000,
      285430,
    ],
    candleData: const [
      OhlcData(open: 290000, high: 291000, low: 288000, close: 289000),
      OhlcData(open: 289000, high: 289500, low: 286000, close: 286500),
      OhlcData(open: 286500, high: 287500, low: 283500, close: 284000),
      OhlcData(open: 284000, high: 285000, low: 281500, close: 282000),
      OhlcData(open: 282000, high: 283000, low: 280200, close: 281000),
      OhlcData(open: 281000, high: 283500, low: 280500, close: 283000),
      OhlcData(open: 283000, high: 286000, low: 282500, close: 285500),
      OhlcData(open: 285500, high: 287000, low: 284000, close: 285000),
      OhlcData(open: 285000, high: 286500, low: 284000, close: 285500),
      OhlcData(open: 285500, high: 286500, low: 284000, close: 284500),
      OhlcData(open: 284500, high: 286000, low: 284000, close: 285200),
      OhlcData(open: 285200, high: 286200, low: 284800, close: 285430),
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
      height: 470,
      padding: const EdgeInsets.symmetric(horizontal: 0),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x6BF1F1F1), blurRadius: 16),
          BoxShadow(color: Color(0x99FFFFFF), blurRadius: 14),
          BoxShadow(
            color: Color(0x3F000000),
            blurRadius: 4,
            offset: Offset(0, 4),
          ),
        ],
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
                          return CustomPaint(
                            painter: _LineChartPainter(
                              data: coin.lineData,
                              progress: _chartProgress.value,
                              lineColor: coin.primaryColor,
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
              // コインアイコン（グラデーション丸）
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [coin.accentColor, coin.primaryColor],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    coin.symbolChar,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
class _LineChartPainter extends CustomPainter {
  final List<double> data;
  final double progress; // 0.0 - 1.0
  final Color lineColor;
  final List<String> xLabels;

  const _LineChartPainter({
    required this.data,
    required this.progress,
    required this.lineColor,
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

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            lineColor.withValues(alpha: 0.15),
            lineColor.withValues(alpha: 0.0),
          ],
        ).createShader(Rect.fromLTWH(0, _topMargin, size.width, chartHeight)),
    );

    // チャートライン
    final linePath = Path()..moveTo(allPoints.first.dx, allPoints.first.dy);
    for (final p in allPoints.skip(1)) {
      linePath.lineTo(p.dx, p.dy);
    }
    canvas.drawPath(
      linePath,
      Paint()
        ..color = lineColor
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
      old.lineColor != lineColor ||
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
