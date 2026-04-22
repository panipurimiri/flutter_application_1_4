import 'package:flutter/material.dart';
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

class _BuyPageState extends State<BuyPage> with SingleTickerProviderStateMixin {
  String _rawDigits = '';
  bool _showKeyboard = false;
  bool _skipConfirm = false;
  bool _usePoint = true;
  bool _isBtcMode = false;
  late AnimationController _switchAnim;
  late Animation<double> _iconSpin;

  @override
  void initState() {
    super.initState();
    _switchAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _iconSpin = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _switchAnim, curve: Curves.easeOutBack));
  }

  @override
  void dispose() {
    _switchAnim.dispose();
    super.dispose();
  }

  void _toggleMode() {
    setState(() {
      _isBtcMode = !_isBtcMode;
      _rawDigits = '';
    });
    _switchAnim.forward(from: 0);
  }

  // ── ゲッター ────────────────────────────────────────────

  String get _formattedAmount {
    if (_rawDigits.isEmpty) return '0';
    final n = int.tryParse(_rawDigits) ?? 0;
    return _commaSep(n);
  }

  String get _btcFromJpy {
    if (_rawDigits.isEmpty) return '0';
    final n = int.tryParse(_rawDigits) ?? 0;
    if (n == 0) return '0';
    final btc = n / _kBtcRate;
    return btc
        .toStringAsFixed(15)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }

  String get _btcDisplayValue {
    if (_rawDigits.isEmpty || _rawDigits == '.') return '0';
    return _rawDigits;
  }

  String get _jpyFromBtc {
    final btc = double.tryParse(_rawDigits) ?? 0;
    if (btc == 0) return '0';
    return _commaSep((btc * _kBtcRate).toInt());
  }

  String _commaSep(int n) {
    final s = n.toString();
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  // ── 操作 ────────────────────────────────────────────────
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
        if (_rawDigits.isNotEmpty) {
          _rawDigits = _rawDigits.substring(0, _rawDigits.length - 1);
        }
      } else if (key == '.') {
        if (_isBtcMode && !_rawDigits.contains('.')) {
          _rawDigits = _rawDigits.isEmpty ? '0.' : '$_rawDigits.';
        }
      } else {
        if (_rawDigits.replaceAll('.', '').length >= 12) return;
        if (_isBtcMode) {
          if (_rawDigits == '0') {
            _rawDigits = key;
          } else {
            _rawDigits += key;
          }
        } else {
          _rawDigits += key;
          while (_rawDigits.length > 1 && _rawDigits.startsWith('0')) {
            _rawDigits = _rawDigits.substring(1);
          }
        }
      }
    });
  }

  void _dismissKeyboard() {
    if (_showKeyboard) setState(() => _showKeyboard = false);
  }

  // ── 金額テキストの実幅を計測 ──────────────────────────────
  double _measureAmountWidth(double fs) {
    final displayText = _isBtcMode ? _btcDisplayValue : _formattedAmount;
    final suffixText = _isBtcMode ? 'BTC' : '円';
    final amountTp = TextPainter(
      text: TextSpan(
        text: displayText,
        style: _hiraFont.copyWith(
          fontSize: fs,
          fontWeight: FontWeight.w600,
          letterSpacing: -2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final suffixTp = TextPainter(
      text: TextSpan(
        text: suffixText,
        style: _hiraFont.copyWith(
          fontSize: fs * 0.36,
          fontWeight: FontWeight.w300,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    return amountTp.width + 3.0 + suffixTp.width;
  }

  double _computeTargetFs(double availableWidth) {
    final totalAtMax = _measureAmountWidth(_kMaxFs);
    if (totalAtMax <= availableWidth) return _kMaxFs;
    return (_kMaxFs * availableWidth / totalAtMax).clamp(_kMinFs, _kMaxFs);
  }

  // ── build ────────────────────────────────────────────────
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

  // ── ヘッダー ─────────────────────────────────────────────
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
          '円',
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

  // ── 金額入力エリア ──────────────────────────────────────
  //
  // 設計:
  // 配置領域は「左端〜トグル手前16px」で固定(幅 = maxAmountWidth)
  //  - 中央配置モード: Alignment.x を計算して画面全体の中央に見せる
  //  - 右端固定モード: Alignment.centerRight で右端に貼り付け
  //
  // オーバーフロー防止:
  // 金額コンテンツを FittedBox(scaleDown) で包むことで、
  // 最小フォントサイズ(_kMinFs)でも収まらない場合でも
  // 最終手段として物理的に縮小して必ず配置領域内に収める。
  //
  // 間隔:
  // 金額エリア高さは金額テキストのフォント高さ(fs * 1.0)に統一し、
  // その下に SizedBox(height: 8) で換算表示との間隔を確保する。
  Widget _buildAmountInputArea(double sw) {
    const btcIconWidth = 36.0;
    const gap = 16.0;
    const horizontalPadding = 16.0;
    const amountToSubSpacing = 8.0;

    final totalWidth = sw - horizontalPadding * 2;
    final maxAmountWidth = totalWidth - btcIconWidth - gap;

    final targetFs = _computeTargetFs(maxAmountWidth);
    final actualWidth = _measureAmountWidth(targetFs);

    // 中央配置時の右端位置 > maxAmountWidth なら右端固定モード
    final centeredRightEdge = totalWidth / 2 + actualWidth / 2;
    final shouldPinRight = centeredRightEdge > maxAmountWidth;

    // 中央配置モードの Alignment.x 計算
    // 入力が空の場合はモードに関わらず固定センター(ズレ防止)
    final slack = maxAmountWidth - actualWidth;
    final centerAlignX = _rawDigits.isEmpty
        ? (btcIconWidth + gap) / (maxAmountWidth - 1)
        : slack > 1.0
            ? ((btcIconWidth + gap) / slack).clamp(-1.0, 1.0)
            : 0.0;

    // 金額エリアの高さ = 最大フォントサイズの行高(height: 1 で描画)
    // これにより、どの fs でも同じベースラインで描画される
    const amountAreaHeight = _kMaxFs;

    final isEmpty = _rawDigits.isEmpty;
    final amountColor = isEmpty
        ? const Color(0xFFB0B0B0)
        : const Color(0xFF1A1A1A);

    return GestureDetector(
      onTap: () => setState(() => _showKeyboard = true),
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          SizedBox(
            height: amountAreaHeight,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // 金額表示(配置領域 = 左端〜トグル手前16px)
                Positioned.fill(
                  right: btcIconWidth + gap,
                  child: Align(
                    alignment: shouldPinRight
                        ? Alignment.centerRight
                        : Alignment(centerAlignX, 0),
                    // FittedBox で最終安全策: 最小フォントでも収まらない
                    // ケースでも物理的に縮小して必ず収める
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: shouldPinRight
                          ? Alignment.centerRight
                          : Alignment.center,
                      child: _buildAmountContent(targetFs, amountColor),
                    ),
                  ),
                ),

                // 切り替えボタン(右端固定)
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: _toggleMode,
                      behavior: HitTestBehavior.opaque,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RotationTransition(
                            turns: _iconSpin,
                            child: const Icon(
                              Icons.cached,
                              color: Color(0xFF333333),
                              size: 18,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _isBtcMode ? '円' : 'BTC',
                            style: _hiraFont.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF333333),
                              height: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: amountToSubSpacing),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position:
                    Tween<Offset>(
                      begin: const Offset(0, 0.4),
                      end: Offset.zero,
                    ).animate(
                      CurvedAnimation(parent: anim, curve: Curves.easeOutCubic),
                    ),
                child: child,
              ),
            ),
            child: Text(
              _isBtcMode ? '$_jpyFromBtc 円' : '$_btcFromJpy BTC',
              key: ValueKey(_isBtcMode),
              textAlign: TextAlign.center,
              style: _hiraFont.copyWith(
                color: const Color(0xFF4D4D4D),
                fontSize: 13,
                fontWeight: FontWeight.w300,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountContent(double targetFs, Color amountColor) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 420),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      layoutBuilder: (current, previous) => Stack(
        alignment: Alignment.center,
        children: [...previous, ?current],
      ),
      transitionBuilder: (child, anim) {
        final isIncoming = child.key == ValueKey(_isBtcMode);
        // 退場: 0→-90度（奥へ倒れる）、登場: 90→0度（奥から起き上がる）
        final angle = Tween<double>(
          begin: isIncoming ? 1.5708 : 0.0,   // π/2
          end:   isIncoming ? 0.0    : -1.5708,
        ).animate(anim);
        return AnimatedBuilder(
          animation: angle,
          child: child,
          builder: (_, w) {
            final v = angle.value;
            // 前半(退場)は非表示、後半(登場)は表示
            if (!isIncoming && v < -1.0) return const SizedBox.shrink();
            if (isIncoming  && v >  1.0) return const SizedBox.shrink();
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)   // perspective
                ..rotateX(v),
              child: w,
            );
          },
        );
      },
      child: TweenAnimationBuilder<double>(
        key: ValueKey(_isBtcMode),
        tween: Tween<double>(end: targetFs),
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOutCubic,
        builder: (context, fs, child) => Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              _isBtcMode ? _btcDisplayValue : _formattedAmount,
              style: _hiraFont.copyWith(
                fontSize: fs,
                fontWeight: FontWeight.w600,
                letterSpacing: -2,
                color: amountColor,
                height: 1,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 3),
              child: Text(
                _isBtcMode ? 'BTC' : '円',
                style: _hiraFont.copyWith(
                  fontSize: fs * 0.28,
                  fontWeight: FontWeight.w300,
                  color: amountColor,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
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
              '+${_commaSep(amount)}',
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
            showOrderCompleteDialog(
              context,
              onViewHistory: () {
                // TODO: 注文履歴画面への遷移処理
              },
            );
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
                  showOrderCompleteDialog(
                    context,
                    onViewHistory: () {
                      // TODO: 注文履歴画面への遷移処理
                    },
                  );
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
    return GestureDetector(
      onTap: () => _onKey(key),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x22000000),
              blurRadius: 1,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Center(
          child: key == '⌫'
              ? const Icon(
                  Icons.backspace_outlined,
                  size: 20,
                  color: Color(0xFF333333),
                )
              : Text(
                  key,
                  textAlign: TextAlign.center,
                  style: _hiraFont.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                    height: 1,
                  ),
                ),
        ),
      ),
    );
  }
}
