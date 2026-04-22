import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

const _fontFamily = 'Hiragino Kaku Gothic Pro';

// ══════════════════════════════════════════════════════════════
//  AccountPanel
//
//  ・ShaderMask + RadialGradient でソフトエッジの円形展開
//  ・BackdropFilter 二重でリキッドグラス（ホーム画面が透ける）
//  ・閉じるとき origin に吸い込まれ、呼び出し元でバウンス
//  ・全 Text に decoration: TextDecoration.none を明示
// ══════════════════════════════════════════════════════════════

class AccountPanel {
  static Future<void> show(BuildContext context, GlobalKey avatarKey) {
    final RenderBox box =
        avatarKey.currentContext!.findRenderObject() as RenderBox;
    final Offset pos = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final Offset center = pos + Offset(size.width / 2, size.height / 2);

    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 600),
        reverseTransitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => _PanelOverlay(origin: center),
        transitionsBuilder: (_, a, __, child) => child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
class _PanelOverlay extends StatefulWidget {
  final Offset origin;
  const _PanelOverlay({required this.origin});
  @override
  State<_PanelOverlay> createState() => _PanelOverlayState();
}

class _PanelOverlayState extends State<_PanelOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _masterCtrl;
  late final AnimationController _contentCtrl;

  late final Animation<double> _reveal; // 0→1 ソフト円展開
  late final Animation<double> _bgBlur; // 全画面背景ブラー
  late final Animation<double> _bgDim; // 全画面暗幕
  late final Animation<double> _cFade; // コンテンツ不透明度
  late final Animation<double> _cSlide; // コンテンツ Yオフセット

  bool _closing = false;

  @override
  void initState() {
    super.initState();

    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 580),
    );

    // 円形展開 — easeOutQuart でスプリング的な減速
    _reveal = CurvedAnimation(
      parent: _masterCtrl,
      curve: const Interval(0.0, 0.88, curve: Curves.easeOutQuart),
    );

    // 背景ブラー（展開に伴う全体ブラー）
    _bgBlur = Tween<double>(begin: 0, end: 16).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    // 背景暗幕
    _bgDim = Tween<double>(begin: 0, end: 0.12).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    // コンテンツ
    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _cFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);
    _cSlide = Tween<double>(begin: 12, end: 0).animate(
      CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOutCubic),
    );

    _open();
  }

  Future<void> _open() async {
    _masterCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 280));
    if (mounted) _contentCtrl.forward();
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    _contentCtrl.reverse();
    await Future.delayed(const Duration(milliseconds: 120));
    await _masterCtrl.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screen = MediaQuery.of(context).size;
    final maxR = _maxRadius(screen, widget.origin);

    return AnimatedBuilder(
      animation: Listenable.merge([_masterCtrl, _contentCtrl]),
      builder: (context, _) {
        final revealVal = _reveal.value;
        // 現在の展開半径（フェザー領域を含む）
        final currentR = maxR * revealVal;
        // フェザー幅（展開中はリッチに、完了近くで縮小）
        final feather = 80.0 * (1.0 - revealVal).clamp(0.0, 1.0) + 20.0;

        return Stack(
          children: [
            // ── ① 全画面背景ブラー＋暗幕 ──────────────────────
            if (_bgBlur.value > 0.3)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: _bgBlur.value,
                    sigmaY: _bgBlur.value,
                  ),
                  child: Container(
                    color: Colors.black.withValues(alpha: _bgDim.value),
                  ),
                ),
              ),

            // ── ② リキッドグラスパネル（ソフトエッジ展開）──────
            Positioned.fill(
              child: _SoftCircleReveal(
                center: widget.origin,
                radius: currentR,
                feather: feather,
                child: Stack(
                  children: [
                    // 強ブラー + 半透明グラデ → ホーム画面が透ける
                    BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              const Color(0xFFF4F6F9).withValues(alpha: 0.62),
                              const Color(0xFFEEF0F4).withValues(alpha: 0.55),
                              const Color(0xFFD3DAE4).withValues(alpha: 0.48),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // コンテンツ
                    SafeArea(child: _buildContent()),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ── コンテンツ ─────────────────────────────────────────────
  Widget _buildContent() {
    return FadeTransition(
      opacity: _cFade,
      child: AnimatedBuilder(
        animation: _cSlide,
        builder: (ctx, child) =>
            Transform.translate(offset: Offset(0, _cSlide.value), child: child),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),

              // ✕ ボタン
              GestureDetector(
                onTap: _close,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.45),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close,
                    size: 20,
                    color: Color(0xFF444444),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // アカウント
              const Text(
                'アカウント',
                style: TextStyle(
                  color: Color(0xFF222222),
                  fontSize: 22,
                  fontFamily: _fontFamily,
                  fontWeight: FontWeight.w600,
                  height: 1,
                  decoration: TextDecoration.none,
                ),
              ),

              const SizedBox(height: 16),

              // ユーザー行
              Row(
                children: [
                  // TR アバター — ホーム画面と同じピンクグラデーション
                  Container(
                    width: 48,
                    height: 48,
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
                        fontSize: 16,
                        fontFamily: _fontFamily,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'ラクテンタロウ',
                      style: TextStyle(
                        color: Color(0xFF222222),
                        fontSize: 16,
                        fontFamily: _fontFamily,
                        fontWeight: FontWeight.w600,
                        height: 1,
                        decoration: TextDecoration.none,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // クイック設定カード
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.60),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _qItem(Icons.settings_outlined, 'アプリ\n設定'),
                    _qItem(Icons.wallpaper_outlined, '壁紙'),
                    _qItem(Icons.manage_accounts_outlined, 'アカウント\n設定'),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // メニューカード
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.60),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _menuRow(Icons.info_outline, 'アプリ情報'),
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    _menuRow(Icons.logout_outlined, 'ログアウト'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _qItem(IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.60),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 24, color: const Color(0xFF444444)),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF222222),
            fontSize: 12,
            fontFamily: _fontFamily,
            fontWeight: FontWeight.w600,
            height: 1.2,
            letterSpacing: 0.12,
            decoration: TextDecoration.none,
          ),
        ),
      ],
    );
  }

  Widget _menuRow(IconData icon, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 24, color: const Color(0xFF444444)),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFF222222),
                fontSize: 14,
                fontFamily: _fontFamily,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: 0.14,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const Icon(Icons.chevron_right, size: 16, color: Color(0xFF888888)),
        ],
      ),
    );
  }

  double _maxRadius(Size s, Offset o) {
    double m = 0;
    for (final c in [
      Offset.zero,
      Offset(s.width, 0),
      Offset(0, s.height),
      Offset(s.width, s.height),
    ]) {
      final d = (c - o).distance;
      if (d > m) m = d;
    }
    return m;
  }
}

// ══════════════════════════════════════════════════════════════
//  _SoftCircleReveal — ShaderMask でフェザードエッジの円形表示
//
//  RadialGradient を使い、半径内は不透明、エッジでフェードアウト。
//  ClipPath と違い境界がぼやけて「ほわっ」と広がる。
// ══════════════════════════════════════════════════════════════
class _SoftCircleReveal extends StatelessWidget {
  final Offset center;
  final double radius;
  final double feather; // フェザー幅（px）
  final Widget child;

  const _SoftCircleReveal({
    required this.center,
    required this.radius,
    required this.feather,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (radius <= 0) return const SizedBox.shrink();

    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (Rect bounds) {
        // フェザー内のストップ比率
        final innerR = (radius - feather).clamp(0.0, radius);
        final innerStop = innerR / radius;

        return RadialGradient(
          center: Alignment(
            // Alignment: -1..1 の座標系に変換
            (center.dx / bounds.width) * 2 - 1,
            (center.dy / bounds.height) * 2 - 1,
          ),
          radius: radius / bounds.shortestSide,
          colors: const [
            Colors.white, // 中心：完全不透明
            Colors.white, // innerStop まで不透明を維持
            Colors.transparent, // エッジ：完全透明
          ],
          stops: [0.0, innerStop.clamp(0.0, 0.99), 1.0],
        ).createShader(bounds);
      },
      child: child,
    );
  }
}
