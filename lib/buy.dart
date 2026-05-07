import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'order_complete_dialog.dart';

const _fontFamily = 'Hiragino Kaku Gothic Pro';
const _hiraFont = TextStyle(fontFamily: _fontFamily);
const _kMaxFs = 56.0;
const _kMinFs = 28.0;
const _kBtcRate = 16845997.0;
const _kQuickAmounts = [1000, 3000, 5000, 10000, 30000, 50000];

class BuyPage extends StatefulWidget {
  const BuyPage({super.key});

  @override
  State<BuyPage> createState() => _BuyPageState();
}

class _BuyPageState extends State<BuyPage> with TickerProviderStateMixin {
  String _rawDigits = '';
  bool _showKeyboard = false;
  bool _skipConfirm = false;
  bool _usePoint = true;
  bool _isBtcMode = false;

  // ── Swap animation controller ──
  late AnimationController _swapCtrl;
  late Animation<double> _outSlide;
  late Animation<double> _inSlide;
  late Animation<double> _outFade;
  late Animation<double> _inFade;

  @override
  void initState() {
    super.initState();
    _swapCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _outSlide = Tween<double>(begin: 0.0, end: 0.6).animate(
      CurvedAnimation(
        parent: _swapCtrl,
        curve: const Interval(0.0, 0.8, curve: Curves.easeInOutCubic),
      ),
    );
    _outFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _swapCtrl,
        curve: const Interval(0.1, 0.7, curve: Curves.easeOut),
      ),
    );
    _inSlide = Tween<double>(begin: -0.6, end: 0.0).animate(
      CurvedAnimation(
        parent: _swapCtrl,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOutCubic),
      ),
    );
    _inFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _swapCtrl,
        curve: const Interval(0.3, 0.9, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _swapCtrl.dispose();
    super.dispose();
  }

  // ── Stored values for the crossfade ──
  String _prevMainText = '0';
  String _prevMainSuffix = 'JPY';
  String _prevSubText = '0 BTC';
  String _nextMainText = '0';
  String _nextMainSuffix = 'BTC';
  String _nextSubText = '0 JPY';
  bool _isAnimating = false;

  // ── Frozen layout metrics (locked at animation start) ──
  double _prevTargetFs = _kMaxFs;
  double _nextTargetFs = _kMaxFs;
  bool _frozenShouldPinRight = false;
  double _frozenCenterAlignX = 0.0;

  void _toggleMode() {
    // 1) Snapshot OUTGOING values (current mode, before flip)
    _prevMainText = _isBtcMode ? _btcDisplayValue : _formattedAmount;
    _prevMainSuffix = _isBtcMode ? 'BTC' : '円';
    _prevSubText = _isBtcMode ? '$_jpyFromBtc 円' : '$_btcFromJpy BTC';

    // 2) Flip mode
    _isBtcMode = !_isBtcMode;

    // 3) Snapshot INCOMING values (new mode, after flip)
    _nextMainText = _isBtcMode ? _btcDisplayValue : _formattedAmount;
    _nextMainSuffix = _isBtcMode ? 'BTC' : '円';
    _nextSubText = _isBtcMode ? '$_jpyFromBtc 円' : '$_btcFromJpy BTC';

    // 4) Freeze layout metrics so they stay constant during animation
    //    Use the LARGER of outgoing/incoming to avoid clipping either.
    final sw = MediaQuery.of(context).size.width;
    const btcIconWidth = 36.0;
    const gap = 16.0;
    const horizontalPadding = 16.0;
    final totalWidth = sw - horizontalPadding * 2;
    final maxAmountWidth = totalWidth - btcIconWidth - gap;

    final prevWidth = _measureTextWidth(
      _prevMainText,
      _prevMainSuffix,
      _kMaxFs,
    );
    final nextWidth = _measureTextWidth(
      _nextMainText,
      _nextMainSuffix,
      _kMaxFs,
    );

    if (prevWidth <= maxAmountWidth) {
      _prevTargetFs = _kMaxFs;
    } else {
      _prevTargetFs = (_kMaxFs * maxAmountWidth / prevWidth).clamp(
        _kMinFs,
        _kMaxFs,
      );
    }

    if (nextWidth <= maxAmountWidth) {
      _nextTargetFs = _kMaxFs;
    } else {
      _nextTargetFs = (_kMaxFs * maxAmountWidth / nextWidth).clamp(
        _kMinFs,
        _kMaxFs,
      );
    }

    final actualWidth = _measureTextWidth(
      _nextMainText,
      _nextMainSuffix,
      _nextTargetFs,
    );
    final centeredRightEdge = totalWidth / 2 + actualWidth / 2;
    _frozenShouldPinRight = centeredRightEdge > maxAmountWidth;
    final slack = maxAmountWidth - actualWidth;
    _frozenCenterAlignX = _rawDigits.isEmpty
        ? (btcIconWidth + gap) / (maxAmountWidth - 1)
        : slack > 1.0
        ? ((btcIconWidth + gap) / slack).clamp(-1.0, 1.0)
        : 0.0;

    // 5) Start animation & rebuild together – no gap frame
    _isAnimating = true;
    setState(() {});
    _swapCtrl.forward(from: 0).then((_) {
      if (mounted) setState(() => _isAnimating = false);
    });
  }

  // ── Getters ────────────────────────────────────────────

  String get _formattedAmount {
    if (_rawDigits.isEmpty) return '0';
    final n = int.tryParse(_rawDigits) ?? 0;
    if (n == 0) return '0';
    return NumberFormat('#,###').format(n);
  }

  String get _btcFromJpy {
    if (_rawDigits.isEmpty) return '0';
    final jpy = double.tryParse(_rawDigits) ?? 0.0;
    if (jpy == 0) return '0';
    final btc = jpy / _kBtcRate;
    return btc
        .toStringAsFixed(10)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String get _btcDisplayValue {
    if (_rawDigits.isEmpty || _rawDigits == '.') return '0';
    // 小数点以下の表示を考慮
    return _rawDigits;
  }

  String get _jpyFromBtc {
    if (_rawDigits.isEmpty || _rawDigits == '.') return '0';
    final btc = double.tryParse(_rawDigits) ?? 0.0;
    if (btc == 0) return '0';
    final jpy = (btc * _kBtcRate).toInt();
    return NumberFormat('#,###').format(jpy);
  }

  // 古い _commaSep は削除

  // ── Operations ────────────────────────────────────────
  void _quickAdd(int amount) {
    if (_isBtcMode) return;
    setState(() {
      final cur = int.tryParse(_rawDigits) ?? 0;
      _rawDigits = (cur + amount).toString();
    });
  }

  void _onKey(String key) {
    setState(() {
      if (key == '⌫') {
        if (_rawDigits.length <= 1) {
          _rawDigits = '';
        } else {
          _rawDigits = _rawDigits.substring(0, _rawDigits.length - 1);
        }
      } else if (key == '.') {
        if (_isBtcMode && !_rawDigits.contains('.')) {
          _rawDigits = _rawDigits.isEmpty ? '0.' : '$_rawDigits.';
        }
      } else {
        // 最大入力桁数の制限
        if (_rawDigits.replaceAll('.', '').length >= 10) return;

        if (_rawDigits == '0') {
          if (key != '0') _rawDigits = key;
        } else {
          _rawDigits += key;
        }
      }
    });
  }

  void _dismissKeyboard() {
    if (_showKeyboard) setState(() => _showKeyboard = false);
  }

  // ── Measure text width (for given text/suffix, not current state) ──
  double _measureTextWidth(String text, String suffix, double fs) {
    final amountTp = TextPainter(
      text: TextSpan(
        text: text,
        style: _hiraFont.copyWith(
          fontSize: fs,
          fontWeight: FontWeight.w600,
          letterSpacing: -2,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    final suffixTp = TextPainter(
      text: TextSpan(
        text: suffix,
        style: _hiraFont.copyWith(
          fontSize: fs * 0.36,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    return amountTp.width + 3.0 + suffixTp.width;
  }

  // Convenience: measure using current live state
  double _measureAmountWidth(double fs) {
    final displayText = _isBtcMode ? _btcDisplayValue : _formattedAmount;
    final suffixText = _isBtcMode ? 'BTC' : '円';
    return _measureTextWidth(displayText, suffixText, fs);
  }

  double _computeTargetFs(double availableWidth) {
    final totalAtMax = _measureAmountWidth(_kMaxFs);
    if (totalAtMax <= availableWidth) return _kMaxFs;
    return (_kMaxFs * availableWidth / totalAtMax).clamp(_kMinFs, _kMaxFs);
  }

  // ── build ────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    final routeAnim =
        ModalRoute.of(context)?.animation ?? const AlwaysStoppedAnimation(1.0);

    final sheetSlide = Tween<Offset>(
      begin: const Offset(0.0, 1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: routeAnim, curve: Curves.easeOutCubic));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: routeAnim,
            builder: (context, child) => GestureDetector(
              onTap: () {
                if (_showKeyboard) {
                  _dismissKeyboard();
                } else {
                  Navigator.pop(context);
                }
              },
              child: Container(
                color: Color.lerp(
                  Colors.transparent,
                  const Color(0x80000000),
                  routeAnim.value,
                ),
              ),
            ),
          ),
          SlideTransition(
            position: sheetSlide,
            child: Column(
              children: [
                GestureDetector(
                  onTap: () {
                    if (_showKeyboard) {
                      _dismissKeyboard();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: SizedBox(height: safeTop + 48),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _dismissKeyboard,
                    behavior: HitTestBehavior.translucent,
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(38),
                          topRight: Radius.circular(38),
                        ),
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: SingleChildScrollView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 16),
                                  _buildHeader(context),
                                  const SizedBox(height: 8),
                                  _buildRateRow(),
                                  const SizedBox(height: 16),
                                  _buildToggleTabs(),
                                  const SizedBox(height: 16),
                                  _buildAmountInputArea(sw),
                                  if (!_isBtcMode) ...[
                                    const SizedBox(height: 20),
                                    _buildQuickButtons(),
                                    const SizedBox(height: 16),
                                  ] else
                                    const SizedBox(height: 40),
                                  _buildPointCard(),
                                  const SizedBox(height: 8),
                                  _buildBalanceCard(),
                                  const SizedBox(height: 12),
                                  _buildSkipConfirmation(),
                                  const SizedBox(height: 12),
                                  _buildFooterNote(),
                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                          _buildBottomButton(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AbsorbPointer(
              absorbing: !_showKeyboard,
              child: AnimatedSlide(
                offset: _showKeyboard ? Offset.zero : const Offset(0, 1),
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                child: _buildKeyboardPanel(safeBottom),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────
  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Image.asset(
          'assets/icons/btc.png',
          width: 24,
          height: 24,
          errorBuilder: (context, error, stack) => const Icon(
            Icons.currency_bitcoin,
            color: Colors.orange,
            size: 24,
          ),
        ),
        Expanded(
          child: Text(
            'BTCを買う',
            textAlign: TextAlign.center,
            style: _hiraFont.copyWith(
              color: const Color(0xFF333333),
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1,
            ),
          ),
        ),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3F7),
              borderRadius: BorderRadius.circular(128),
            ),
            child: const Icon(Icons.close, size: 16, color: Color(0xFF333333)),
          ),
        ),
      ],
    );
  }

  Widget _buildRateRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'レート(参考)',
          style: _hiraFont.copyWith(
            color: const Color(0xFF4D4D4D),
            fontSize: 12,
            fontWeight: FontWeight.w300,
            letterSpacing: 0.12,
            height: 1,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          '16,845,997',
          style: _hiraFont.copyWith(
            color: const Color(0xFF222222),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.14,
            height: 1,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          'JPY',
          style: _hiraFont.copyWith(
            color: const Color(0xFF222222),
            fontSize: 12,
            fontWeight: FontWeight.w300,
            height: 1,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.help_outline, size: 13, color: Color(0xFF4D4D4D)),
      ],
    );
  }

  Widget _buildToggleTabs() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _tabButton('通常', true),
        const SizedBox(width: 8),
        _tabButton('条件付き', false),
      ],
    );
  }

  Widget _tabButton(String text, bool isActive) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFFF8FAFD) : const Color(0xFFF0F3F7),
        borderRadius: BorderRadius.circular(128),
      ),
      child: Center(
        child: Text(
          text,
          style: _hiraFont.copyWith(
            color: isActive ? const Color(0xFFBF0000) : const Color(0xFF4D4D4D),
            fontSize: 14,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w300,
            letterSpacing: 0.14,
            height: 1,
          ),
        ),
      ),
    );
  }

  // ── Amount input area with vertical swap animation ──────────────
  Widget _buildAmountInputArea(double sw) {
    const btcIconWidth = 36.0;
    const gap = 16.0;
    const horizontalPadding = 8.0;
    const amountToSubSpacing = 8.0;

    final totalWidth = sw - horizontalPadding * 2;
    final maxAmountWidth = totalWidth - btcIconWidth - gap;

    // When animating, use frozen values; otherwise compute live
    final double targetFs;
    final bool shouldPinRight;
    final double centerAlignX;

    if (_isAnimating) {
      targetFs = _nextTargetFs; // For live calculation, we'll use next as base
      shouldPinRight = _frozenShouldPinRight;
      centerAlignX = _frozenCenterAlignX;
    } else {
      targetFs = _computeTargetFs(maxAmountWidth);
      final actualWidth = _measureAmountWidth(targetFs);
      final centeredRightEdge = totalWidth / 2 + actualWidth / 2;
      shouldPinRight = centeredRightEdge > maxAmountWidth;
      final slack = maxAmountWidth - actualWidth;
      centerAlignX = _rawDigits.isEmpty
          ? (btcIconWidth + gap) / (maxAmountWidth - 1)
          : slack > 1.0
          ? ((btcIconWidth + gap) / slack).clamp(-1.0, 1.0)
          : 0.0;
    }

    const amountAreaHeight = _kMaxFs;
    final isEmpty = _rawDigits.isEmpty;
    final amountColor = isEmpty
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF1A1A1A);
    const subColor = Color(0xFF4D4D4D);
    const subFs = 13.0;

    return GestureDetector(
      onTap: () => setState(() => _showKeyboard = true),
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _swapCtrl,
        builder: (context, _) {
          if (!_isAnimating) {
            // ── Static Layout ──
            return Column(
              children: [
                SizedBox(
                  height: amountAreaHeight,
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: btcIconWidth + gap,
                            ),
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.center,
                              child: _AmountDisplay(
                                formatted: _isBtcMode
                                    ? _btcDisplayValue
                                    : _formattedAmount,
                                suffix: _isBtcMode ? 'BTC' : '円',
                                fontSize: targetFs,
                                color: amountColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Center(
                          child: _CurrencyToggleBadge(
                            isBtcMode: _isBtcMode,
                            onToggle: _toggleMode,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: amountToSubSpacing),
                SizedBox(
                  height: 20,
                  child: Text(
                    _isBtcMode ? '$_jpyFromBtc 円' : '$_btcFromJpy BTC',
                    textAlign: TextAlign.center,
                    style: _hiraFont.copyWith(
                      color: subColor,
                      fontSize: subFs,
                      fontWeight: FontWeight.w300,
                      height: 1,
                    ),
                  ),
                ),
              ],
            );
          }

          // ── Animating Layout: Unified Swap ──
          final t = _swapCtrl.value; // 0.0 to 1.0
          final centerToSubDist =
              amountAreaHeight / 2 + amountToSubSpacing + 10;

          // Outgoing (Main -> Sub)
          final outgoingFs = ui.lerpDouble(_prevTargetFs, subFs, t)!;
          final outgoingColor = Color.lerp(amountColor, subColor, t)!;
          final outgoingTop =
              (amountAreaHeight / 2 - outgoingFs / 2) + (t * centerToSubDist);

          // Incoming (Sub -> Main)
          final incomingFs = ui.lerpDouble(subFs, _nextTargetFs, t)!;
          final incomingColor = Color.lerp(subColor, amountColor, t)!;
          final incomingTop =
              (amountAreaHeight + amountToSubSpacing + 10 - incomingFs / 2) -
              (t * centerToSubDist);

          return SizedBox(
            height: amountAreaHeight + amountToSubSpacing + 20,
            child: Stack(
              children: [
                // Outgoing Text (Main -> Sub)
                Positioned(
                  left: 0,
                  right: 0,
                  top: outgoingTop,
                  child: Opacity(
                    opacity: _outFade.value,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: btcIconWidth + gap,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: _StaticAmountDisplay(
                            formatted: _prevMainText,
                            suffix: _prevMainSuffix,
                            fontSize: outgoingFs,
                            color: outgoingColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Incoming Text (Sub -> Main)
                Positioned(
                  left: 0,
                  right: 0,
                  top: incomingTop,
                  child: Opacity(
                    opacity: _inFade.value,
                    child: Align(
                      alignment: Alignment.center,
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: btcIconWidth + gap,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.center,
                          child: _StaticAmountDisplay(
                            formatted: _nextMainText,
                            suffix: _nextMainSuffix,
                            fontSize: incomingFs,
                            color: incomingColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Toggle Button
                Positioned(
                  right: 0,
                  top: 0,
                  height: amountAreaHeight,
                  child: Center(
                    child: _CurrencyToggleBadge(
                      isBtcMode: _isBtcMode,
                      onToggle: _toggleMode,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Static Display for Animation (Avoids internal digit animations) ──
  Widget _StaticAmountDisplay({
    required String formatted,
    required String suffix,
    required double fontSize,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          formatted,
          style: _hiraFont.copyWith(
            fontSize: fontSize,
            fontWeight: FontWeight.w600,
            letterSpacing: -2,
            color: color,
            height: 1,
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Text(
            suffix,
            style: _hiraFont.copyWith(
              fontSize: fontSize * 0.36,
              fontWeight: FontWeight.w300,
              color: color,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickButtons() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 6,
        crossAxisSpacing: 6,
        childAspectRatio: 3.2,
      ),
      itemCount: _kQuickAmounts.length,
      itemBuilder: (_, i) {
        final amount = _kQuickAmounts[i];
        return GestureDetector(
          onTap: () => _quickAdd(amount),
          child: Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F3F7),
              borderRadius: BorderRadius.circular(128),
            ),
            alignment: Alignment.center,
            child: Text(
              '+${NumberFormat('#,###').format(amount)}',
              style: _hiraFont.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w300,
                color: const Color(0xFF333333),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPointCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        spacing: 6,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                spacing: 4,
                children: [
                  Text(
                    'ポイント利用',
                    style: _hiraFont.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                      height: 1,
                    ),
                  ),
                  const Icon(
                    Icons.help_outline,
                    size: 14,
                    color: Color(0xFF4D4D4D),
                  ),
                ],
              ),
              Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: _usePoint,
                  onChanged: (v) => setState(() => _usePoint = v),
                  activeThumbColor: const Color(0xFF555555),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '投資可能ポイント',
                style: _hiraFont.copyWith(
                  color: const Color(0xFF4D4D4D),
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                ),
              ),
              Text(
                '10,000',
                style: _hiraFont.copyWith(
                  color: const Color(0xFFBF0000),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  height: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(128),
            ),
            child: const Center(
              child: Text(
                '¥',
                style: TextStyle(
                  color: Color(0xFFBF0000),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFamily: _fontFamily,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '円残高',
            style: _hiraFont.copyWith(
              color: const Color(0xFF4D4D4D),
              fontSize: 13,
              fontWeight: FontWeight.w300,
            ),
          ),
          const Spacer(),
          Text(
            '359,485',
            style: _hiraFont.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: const Color(0xFF333333),
              height: 1,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            '円',
            style: _hiraFont.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w300,
              color: const Color(0xFF4D4D4D),
            ),
          ),
          const SizedBox(width: 6),
          const Icon(
            Icons.arrow_forward_ios,
            size: 11,
            color: Color(0xFF4D4D4D),
          ),
        ],
      ),
    );
  }

  Widget _buildSkipConfirmation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          '確認を省略する',
          style: _hiraFont.copyWith(
            color: const Color(0xFF4D4D4D),
            fontSize: 13,
            fontWeight: FontWeight.w300,
          ),
        ),
        Transform.scale(
          scale: 0.75,
          child: Switch(
            value: _skipConfirm,
            onChanged: (v) => setState(() => _skipConfirm = v),
            activeThumbColor: const Color(0xFF555555),
          ),
        ),
      ],
    );
  }

  Widget _buildFooterNote() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '認定資金決済事業者協会による参考価格',
          style: _hiraFont.copyWith(
            color: const Color(0xFF4D4D4D),
            fontSize: 11,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(width: 4),
        const Icon(Icons.open_in_new, size: 12, color: Color(0xFF4D4D4D)),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBF0000),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          onPressed: () {
            showOrderCompleteDialog(context, onViewHistory: () {});
          },
          child: Text(
            '注文を確認',
            style: _hiraFont.copyWith(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeyboardPanel(double safeBottom) {
    final rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['.', '0', '⌫'],
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFD7DDE6),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(top: 8, bottom: safeBottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBF0000),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(128),
                  ),
                  elevation: 0,
                  padding: const EdgeInsets.all(12),
                ),
                onPressed: () {
                  setState(() => _showKeyboard = false);
                  showOrderCompleteDialog(context, onViewHistory: () {});
                },
                child: Text(
                  '注文を確認',
                  textAlign: TextAlign.center,
                  style: _hiraFont.copyWith(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 270,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
              child: Column(
                children: rows.map((row) {
                  return Expanded(
                    child: Row(
                      children: row.map((key) {
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(3),
                            child: _buildKey(key),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKey(String key) {
    // '.' は BTCモードのみ有効
    final isEnabled = key != '.' || _isBtcMode;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () => _onKey(key) : null,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            color: isEnabled
                ? Colors.white
                : Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isEnabled
                ? const [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 1,
                      offset: Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: key == '⌫'
                ? Icon(
                    Icons.backspace_outlined,
                    size: 20,
                    color: isEnabled
                        ? const Color(0xFF333333)
                        : const Color(0xFFBBBBBB),
                  )
                : Text(
                    key,
                    textAlign: TextAlign.center,
                    style: _hiraFont.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isEnabled
                          ? const Color(0xFF333333)
                          : const Color(0xFFBBBBBB),
                      height: 1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

// ── Animated Amount Display (Typed digit animation) ──────────────────
class _AmountDisplay extends StatefulWidget {
  final String formatted;
  final String suffix;
  final double fontSize;
  final Color color;

  const _AmountDisplay({
    required this.formatted,
    required this.suffix,
    required this.fontSize,
    required this.color,
  });

  @override
  State<_AmountDisplay> createState() => _AmountDisplayState();
}

class _AmountDisplayState extends State<_AmountDisplay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnim;
  late Animation<double> _fadeAnim;

  String _prevFormatted = '0';
  int _animCharIndex = -1;
  bool _isAdding = true;

  @override
  void initState() {
    super.initState();
    _prevFormatted = widget.formatted;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.8),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _fadeAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_AmountDisplay old) {
    super.didUpdateWidget(old);

    final curr = widget.formatted;
    final prev = _prevFormatted;

    if (curr != prev) {
      _isAdding = curr.length >= prev.length;
      _animCharIndex = curr.length - 1;

      _slideAnim = Tween<Offset>(
        begin: Offset(0, _isAdding ? 0.8 : -0.8),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

      _controller.forward(from: 0);
      _prevFormatted = curr;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chars = widget.formatted.characters.toList();

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        ...List.generate(chars.length, (i) {
          final ch = chars[i];
          final isAnimTarget = (i == _animCharIndex);

          // カンマ・ドットは静的
          if (ch == ',' || ch == '.') {
            return Text(
              ch,
              style: _hiraFont.copyWith(
                fontSize: widget.fontSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -2,
                color: widget.color,
                height: 1,
              ),
            );
          }

          if (isAnimTarget) {
            return ClipRect(
              child: SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: Text(
                    ch,
                    style: _hiraFont.copyWith(
                      fontSize: widget.fontSize,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -2,
                      color: widget.color,
                      height: 1,
                    ),
                  ),
                ),
              ),
            );
          }

          return Text(
            ch,
            style: _hiraFont.copyWith(
              fontSize: widget.fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: -2,
              color: widget.color,
              height: 1,
            ),
          );
        }),
        Padding(
          padding: const EdgeInsets.only(left: 3),
          child: Text(
            widget.suffix,
            style: _hiraFont.copyWith(
              fontSize: widget.fontSize * 0.36,
              fontWeight: FontWeight.w300,
              color: widget.color,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Currency Toggle Badge (3D Flip Animation) ──────────────────────
class _CurrencyToggleBadge extends StatefulWidget {
  final bool isBtcMode;
  final VoidCallback onToggle;

  const _CurrencyToggleBadge({required this.isBtcMode, required this.onToggle});

  @override
  State<_CurrencyToggleBadge> createState() => _CurrencyToggleBadgeState();
}

class _CurrencyToggleBadgeState extends State<_CurrencyToggleBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotateAnim;
  bool _localBtcMode = false;

  @override
  void initState() {
    super.initState();
    _localBtcMode = widget.isBtcMode;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 320),
      vsync: this,
    );
    _rotateAnim = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void didUpdateWidget(_CurrencyToggleBadge old) {
    super.didUpdateWidget(old);
    if (widget.isBtcMode != _localBtcMode) {
      // 親からの変更（クイックボタンなどでモードが変わる場合など）に同期
      setState(() => _localBtcMode = widget.isBtcMode);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0).then((_) {
      _controller.value = 0; // Reset to 0 so it's not upside down
      setState(() => _localBtcMode = !_localBtcMode);
      widget.onToggle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _rotateAnim,
            builder: (context, _) {
              return Transform.rotate(
                angle: _rotateAnim.value * 3.141592653589793, // 180度回転
                child: const Icon(
                  Icons.sync,
                  color: Color(0xFF333333),
                  size: 24,
                ),
              );
            },
          ),
          const SizedBox(height: 2),
          Text(
            _localBtcMode ? '円' : 'BTC',
            style: _hiraFont.copyWith(
              color: const Color(0xFF333333),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
