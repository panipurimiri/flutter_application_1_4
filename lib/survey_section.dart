import 'package:flutter/material.dart';

/// Figmaデザインから変換したアンケート＆BTC情報セクション
/// main.dartのbody内に SurveySection() として配置してください

class SurveySection extends StatefulWidget {
  const SurveySection({super.key});

  @override
  State<SurveySection> createState() => _SurveySectionState();
}

class _SurveySectionState extends State<SurveySection>
    with TickerProviderStateMixin {
  // アンケート / 週間結果 の切り替え
  int _surveyTabIndex = 0;
  // BTCについて / ニュース の切り替え
  int _infoTabIndex = 0;

  // 投票済みかどうか / 投票した選択肢 (null=未投票, 0=攻め, 1=様子見)
  int? _votedIndex;

  // 棒グラフ用アニメーション
  late final AnimationController _barAnimController;
  late final Animation<double> _progressAnim;

  // 折れ線グラフ用アニメーション
  late final AnimationController _chartAnimController;
  late final Animation<double> _chartAnim;

  // 投票結果の割合（攻め: 24%, 様子見: 76%）
  static const _attackRatio = 0.24;
  static const _watchRatio = 0.76;

  // 週間データ（Figmaより）
  static const _weekLabels = ['9/23', '9/24', '9/25', '9/26', '9/27', '9/28', '9/29'];
  static const _attackData = [76, 80, 64, 88, 40, 22, 20];
  static const _watchData  = [24, 20, 36, 12, 60, 78, 80];

  @override
  void initState() {
    super.initState();
    _barAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnim = CurvedAnimation(
      parent: _barAnimController,
      curve: Curves.easeOut,
    );
    _chartAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _chartAnim = CurvedAnimation(
      parent: _chartAnimController,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _barAnimController.dispose();
    _chartAnimController.dispose();
    super.dispose();
  }

  void _onVote(int index) {
    if (_votedIndex != null) return;
    setState(() => _votedIndex = index);
    _barAnimController.forward(from: 0);
  }

  void _onSurveyTabTap(int index) {
    setState(() => _surveyTabIndex = index);
    if (index == 1) {
      _chartAnimController.forward(from: 0);
    }
  }

  // ---- デザイントークン（Figma準拠） ----
  static const _fontBody = Color(0xFF222222);
  static const _fontDisable = Color(0xFF555555);
  static const _primaryActive = Color(0xFFBF0000);
  static const _statusInfoBg = Color(0xFFE7F1FE);
  static const _statusInfoFont = Color(0xFF1F70E1);
  static const _statusSuccessBg = Color(0xFFE6F1E6);
  static const _statusSuccessFont = Color(0xFF047205);
  static const _tagRedBg = Color(0xFFFFE8E8);
  static const _tagBlueBg = Color(0xFFE7F1FE);
  static const _toggleBgMiddle = Color(0x99D2D6DC);
  static const _cardBgMiddle = Color(0x99FFFFFF); // white 60%

  static const _fontFamily = 'Hiragino Kaku Gothic Pro';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF4F6F9), Color(0xFFEEF0F4), Color(0xFFD3DAE4)],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ========== アンケートカード ==========
          _buildSurveyCard(),
          const SizedBox(height: 24),
          // ========== BTC情報セクション ==========
          _buildInfoSection(),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // アンケートカード
  // ───────────────────────────────────────
  Widget _buildSurveyCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBgMiddle,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          // タイトル
          const Text(
            '毎日更新！',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _fontBody,
              fontSize: 12,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w300,
              letterSpacing: 0.12,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'みんなの予想、今日の動向は？',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _fontBody,
              fontSize: 16,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),

          // タブ切り替え: アンケート / 週間結果
          _buildToggleTabs(
            labels: ['アンケート', '週間結果'],
            selectedIndex: _surveyTabIndex,
            onTap: _onSurveyTabTap,
          ),
          const SizedBox(height: 16),

          // 週間結果タブ
          if (_surveyTabIndex == 1) ...[
            _buildWeeklyChart(),
          ] else if (_votedIndex == null) ...[
            const Text(
              'どちらかを選んで結果を確認しよう',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _fontBody,
                fontSize: 12,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.12,
              ),
            ),
            const SizedBox(height: 16),
            _buildVoteButton(
              label: '攻め！追加するべき！',
              bgColor: _statusInfoBg,
              textColor: _statusInfoFont,
              onTap: () => _onVote(0),
            ),
            const SizedBox(height: 8),
            _buildVoteButton(
              label: 'とりあえず様子を見る',
              bgColor: _statusSuccessBg,
              textColor: _statusSuccessFont,
              onTap: () => _onVote(1),
            ),
          ] else ...[
            _buildResultBars(),
          ],
          const SizedBox(height: 16),

          // 注釈
          const Text(
            '結果は毎日0時から6時間毎に更新されます。',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _fontBody,
              fontSize: 10,
              fontFamily: _fontFamily,
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────
  // BTC情報セクション
  // ───────────────────────────────────────
  Widget _buildInfoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // タブ切り替え: BTCについて / ニュース
        _buildToggleTabs(
          labels: ['BTCについて', 'ニュース'],
          selectedIndex: _infoTabIndex,
          onTap: (i) => setState(() => _infoTabIndex = i),
        ),
        const SizedBox(height: 16),

        // コンテンツカード
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          decoration: BoxDecoration(
            color: _cardBgMiddle,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // BTC ヘッダー
              _buildCoinHeader(),
              const SizedBox(height: 16),

              // タグ
              Row(
                children: [
                  _buildTag('現物取引', _tagRedBg, _primaryActive),
                  const SizedBox(width: 8),
                  _buildTag('証拠金取引', _tagBlueBg, _statusInfoFont),
                ],
              ),
              const SizedBox(height: 16),

              // 説明文
              const Text(
                'ビットコイン\n'
                '(Bitcoin：BTC)現物取引｜証拠金取引\n'
                'ビットコインは2008年にサトシ・ナカモトを名乗る人物が論文'
                '「Bitcoin：A Peer-to-Peer Electronic Cash System'
                '（ビットコイン：P2P電子通貨システム）」を発表し、'
                'それに基づき2009年にサトシ・ナカモトが実装したと見られる'
                'プログラムがインターネット上で配布され、運用され始めました。'
                '発行者として特定の国や金融機関などが関わっておらず、'
                'ブロックチェーン技術によって管理されています。\n'
                '時を経て、2010年5月22日に1万ビットコインと2枚のピザが交換されました。'
                '5月22日を初めてビットコインが取引されました日として、'
                'ビットコイン・ピザ・デーと呼ばれています。'
                'ビットコインは世界で最初の暗号資産で、暗号資産の代名詞とも言えます。',
                style: TextStyle(
                  color: _fontBody,
                  fontSize: 16,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w300,
                  height: 1.6,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────
  // 共通: トグルタブ
  // ───────────────────────────────────────
  Widget _buildToggleTabs({
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int> onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(labels.length, (i) {
        final isSelected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onTap(i),
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            margin: EdgeInsets.only(right: i < labels.length - 1 ? 8 : 0),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white : _toggleBgMiddle,
              borderRadius: BorderRadius.circular(128),
            ),
            child: Text(
              labels[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isSelected ? _primaryActive : _fontDisable,
                fontSize: 14,
                fontFamily: _fontFamily,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w300,
                letterSpacing: 0.14,
              ),
            ),
          ),
        );
      }),
    );
  }

  // ───────────────────────────────────────
  // 共通: 投票ボタン
  // ───────────────────────────────────────
  Widget _buildVoteButton({
    required String label,
    required Color bgColor,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(128),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: textColor,
            fontSize: 16,
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────
  // 週間折れ線グラフ（アニメーション付き）
  // ───────────────────────────────────────
  Widget _buildWeeklyChart() {
    return AnimatedBuilder(
      animation: _chartAnim,
      builder: (context, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '直近1週間の結果を確認しよう',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _fontBody,
                fontSize: 12,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w300,
                letterSpacing: 0.12,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: CustomPaint(
                painter: LineChartPainter(
                  attackData: _attackData,
                  watchData: _watchData,
                  labels: _weekLabels,
                  progress: _chartAnim.value,
                  attackColor: _statusInfoFont,
                  watchColor: _statusSuccessFont,
                  fontFamily: _fontFamily,
                ),
                size: const Size(double.infinity, 160),
              ),
            ),
            const SizedBox(height: 8),
            // 凡例
            Row(
              children: [
                _buildLegendDot(_statusInfoFont),
                const SizedBox(width: 4),
                const Text('攻め！追加するべき！',
                    style: TextStyle(
                        color: _fontBody,
                        fontSize: 10,
                        fontFamily: _fontFamily,
                        fontWeight: FontWeight.w300)),
                const SizedBox(width: 12),
                _buildLegendDot(_statusSuccessFont),
                const SizedBox(width: 4),
                const Text('とりあえず様子を見る',
                    style: TextStyle(
                        color: _fontBody,
                        fontSize: 10,
                        fontFamily: _fontFamily,
                        fontWeight: FontWeight.w300)),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ───────────────────────────────────────
  // 投票結果バー（アニメーション付き）
  // ───────────────────────────────────────
  Widget _buildResultBars() {
    return AnimatedBuilder(
      animation: _progressAnim,
      builder: (context, _) {
        final t = _progressAnim.value;
        final attackPct = (_attackRatio * t * 100).round();
        final watchPct = (_watchRatio * t * 100).round();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSingleBar(
              label: '攻め！追加するべき！',
              labelColor: _statusInfoFont,
              barColor: _statusInfoFont,
              trackColor: _statusInfoBg,
              ratio: _attackRatio * t,
              percent: attackPct,
            ),
            const SizedBox(height: 16),
            _buildSingleBar(
              label: 'とりあえず様子を見る',
              labelColor: _statusSuccessFont,
              barColor: _statusSuccessFont,
              trackColor: _statusSuccessBg,
              ratio: _watchRatio * t,
              percent: watchPct,
            ),
          ],
        );
      },
    );
  }

  Widget _buildSingleBar({
    required String label,
    required Color labelColor,
    required Color barColor,
    required Color trackColor,
    required double ratio, // 0.0〜1.0
    required int percent,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelColor,
            fontSize: 12,
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final trackWidth = constraints.maxWidth;
                  final fillWidth = trackWidth * ratio;
                  return Container(
                    height: 18,
                    decoration: BoxDecoration(
                      color: trackColor,
                      borderRadius: BorderRadius.circular(128),
                    ),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Container(
                        width: fillWidth.clamp(0.0, trackWidth),
                        decoration: BoxDecoration(
                          color: barColor,
                          borderRadius: BorderRadius.circular(128),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 32,
              child: Text(
                '$percent%',
                style: const TextStyle(
                  color: _fontBody,
                  fontSize: 12,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.12,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ───────────────────────────────────────
  // BTCヘッダー（アイコン + 名前）
  // ───────────────────────────────────────
  Widget _buildCoinHeader() {
    return Row(
      children: [
        // BTCアイコン（仮画像 → 実際のアセットに差し替え）
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            image: DecorationImage(
              image: NetworkImage('https://placehold.co/24x24'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 4),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'BTC',
              style: TextStyle(
                color: _fontBody,
                fontSize: 16,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'ビットコイン',
              style: TextStyle(
                color: _fontBody,
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

  // ───────────────────────────────────────
  // 共通: タグ
  // ───────────────────────────────────────
  Widget _buildTag(String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontFamily: _fontFamily,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 折れ線グラフ CustomPainter
// ─────────────────────────────────────────────────────────────────────────────
class LineChartPainter extends CustomPainter {
  final List<int> attackData;
  final List<int> watchData;
  final List<String> labels;
  final double progress; // 0.0 → 1.0
  final Color attackColor;
  final Color watchColor;
  final String fontFamily;

  LineChartPainter({
    required this.attackData,
    required this.watchData,
    required this.labels,
    required this.progress,
    required this.attackColor,
    required this.watchColor,
    required this.fontFamily,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const labelHeight = 20.0;
    const labelTopPad = 16.0; // データラベル用の上余白
    final chartTop = labelTopPad;
    final chartBottom = size.height - labelHeight;
    final chartHeight = chartBottom - chartTop;
    final n = labels.length;
    final xStep = size.width / (n - 1);

    // Y軸: 0%〜100% を chartHeight にマッピング
    double yFor(int pct) =>
        chartBottom - (pct / 100.0) * chartHeight;

    // X座標
    double xFor(int i) => i * xStep;

    // アニメーション進行に応じて描画するポイント数を決定
    // progress=0→最初の点, progress=1→全点
    final totalSegments = n - 1;
    final drawn = progress * totalSegments; // 例: 2.7 → 2セグメント+70%

    // ---- 折れ線を描く ----
    void drawLine(List<int> data, Color color) {
      final paint = Paint()
        ..color = color
        ..strokeWidth = 2.0
        ..strokeCap = StrokeCap.round
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(xFor(0), yFor(data[0]));

      for (int i = 1; i < n; i++) {
        if (drawn < i - 1) break; // まだ到達していないセグメント
        final segProgress = (drawn - (i - 1)).clamp(0.0, 1.0);
        final x0 = xFor(i - 1);
        final y0 = yFor(data[i - 1]);
        final x1 = xFor(i);
        final y1 = yFor(data[i]);
        path.lineTo(x0 + (x1 - x0) * segProgress,
                    y0 + (y1 - y0) * segProgress);
      }

      canvas.drawPath(path, paint);

      // ---- データラベル（各点に到達したら表示） ----
      for (int i = 0; i < n; i++) {
        final pointProgress = (drawn - i + 1).clamp(0.0, 1.0);
        if (pointProgress <= 0) continue;

        final cx = xFor(i);
        final cy = yFor(data[i]);

        // 点（丸）
        canvas.drawCircle(Offset(cx, cy), 3.0,
            Paint()..color = color.withValues(alpha: pointProgress));

        // 数値ラベル（点の上）
        final tp = TextPainter(
          text: TextSpan(
            text: '${data[i]}\n%',
            style: TextStyle(
              color: const Color(0xFF4D4D4D).withValues(alpha: pointProgress),
              fontSize: 8,
              fontFamily: fontFamily,
              fontWeight: FontWeight.w300,
              height: 1.2,
            ),
          ),
          textAlign: TextAlign.center,
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas,
            Offset(cx - tp.width / 2, cy - tp.height - 4));
      }
    }

    drawLine(attackData, attackColor);
    drawLine(watchData, watchColor);

    // ---- X軸ラベル（日付） ----
    for (int i = 0; i < n; i++) {
      final labelProgress = ((drawn - i + 1) / 1.0).clamp(0.0, 1.0);
      final tp = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: TextStyle(
            color: const Color(0xFF222222).withValues(alpha: labelProgress),
            fontSize: 10,
            fontFamily: fontFamily,
            fontWeight: FontWeight.w300,
          ),
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(xFor(i) - tp.width / 2, chartBottom + 4));
    }
  }

  @override
  bool shouldRepaint(LineChartPainter old) => old.progress != progress;
}
