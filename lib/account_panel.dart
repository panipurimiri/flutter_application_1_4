import 'dart:ui';
import 'package:flutter/material.dart';

const _fontFamily = 'Hiragino Kaku Gothic Pro';

class AccountPanel {
  static Future<void> show(BuildContext context, GlobalKey avatarKey) {
    final RenderBox? box =
        avatarKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return Future.value();

    final Offset pos = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final Offset center = pos + Offset(size.width / 2, size.height / 2);

    return Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 500),
        reverseTransitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (ctx, a1, a2) => _PanelOverlay(
          origin: center,
          initialSize: size,
        ),
        transitionsBuilder: (ctx, a, a2, child) => child,
      ),
    );
  }
}

class _PanelOverlay extends StatefulWidget {
  final Offset origin;
  final Size initialSize;
  const _PanelOverlay({required this.origin, required this.initialSize});
  @override
  State<_PanelOverlay> createState() => _PanelOverlayState();
}

class _PanelOverlayState extends State<_PanelOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _masterCtrl;
  late final AnimationController _contentCtrl;

  late final Animation<double> _anim;
  late final Animation<double> _bgBlur;
  late final Animation<double> _bgDim;
  late final Animation<double> _cFade;

  bool _closing = false;

  @override
  void initState() {
    super.initState();

    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _anim = CurvedAnimation(
      parent: _masterCtrl,
      curve: Curves.fastLinearToSlowEaseIn,
    );

    _bgBlur = Tween<double>(begin: 0, end: 30).animate(_anim);
    _bgDim = Tween<double>(begin: 0, end: 0.25).animate(_anim);

    _contentCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _cFade = CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut);

    _open();
  }

  Future<void> _open() async {
    _masterCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 180));
    if (mounted) _contentCtrl.forward();
  }

  Future<void> _close() async {
    if (_closing) return;
    _closing = true;
    _contentCtrl.reverse();
    await Future.delayed(const Duration(milliseconds: 50));
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

    return AnimatedBuilder(
      animation: Listenable.merge([_masterCtrl, _contentCtrl]),
      builder: (context, _) {
        final t = _anim.value;

        // アイコン位置から全画面への枠のモーフィング
        final left = lerpDouble(widget.origin.dx - (widget.initialSize.width / 2), 0, t)!;
        final top = lerpDouble(widget.origin.dy - (widget.initialSize.height / 2), 0, t)!;
        final width = lerpDouble(widget.initialSize.width, screen.width, t)!;
        final height = lerpDouble(widget.initialSize.height, screen.height, t)!;
        final radius = lerpDouble(widget.initialSize.width / 2, 0, t)!;

        // 透明度の段階的変化 (0%で0.3、50%で0.6、100%で1.0)
        double currentAlpha;
        if (t < 0.5) {
          currentAlpha = lerpDouble(0.3, 0.6, t * 2)!;
        } else {
          currentAlpha = lerpDouble(0.6, 1.0, (t - 0.5) * 2)!;
        }

        return Stack(
          children: [
            // ① 背景（強力ブラー） フッター部分も完全に覆う（Z-Index最上位）
            if (t > 0.01)
              Positioned.fill(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: _bgBlur.value, sigmaY: _bgBlur.value),
                  child: Container(
                    color: Colors.black.withValues(alpha: _bgDim.value),
                  ),
                ),
              ),

            // ② パネル本体
            Positioned(
              left: left,
              top: top,
              width: width,
              height: height,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(radius),
                child: OverflowBox(
                  alignment: Alignment.topLeft,
                  minWidth: screen.width,
                  maxWidth: screen.width,
                  minHeight: screen.height,
                  maxHeight: screen.height,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          const Color(0xFFF8FAFC).withValues(alpha: currentAlpha),
                          const Color(0xFFF1F5F9).withValues(alpha: currentAlpha),
                          const Color(0xFFE2E8F0).withValues(alpha: currentAlpha),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        Opacity(
                          opacity: _cFade.value,
                          child: SafeArea(child: _buildContent()),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),
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
              child: const Icon(Icons.close, size: 20, color: Color(0xFF444444)),
            ),
          ),
          const SizedBox(height: 12),
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
          Row(
            children: [
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
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
}
