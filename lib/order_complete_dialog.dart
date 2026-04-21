import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

void showOrderCompleteDialog(
  BuildContext context, {
  required VoidCallback onViewHistory,
}) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'dismiss',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 250),
    transitionBuilder: (ctx, anim, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
      child: ScaleTransition(
        scale: Tween(
          begin: 0.92,
          end: 1.0,
        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
        child: child,
      ),
    ),
    pageBuilder: (ctx, anim2, anim3) => const Material(
      type: MaterialType.transparency,
      child: _OrderCompleteDialog(),
    ),
  ).then((_) => null);
}

class _OrderCompleteDialog extends StatefulWidget {
  const _OrderCompleteDialog();

  @override
  State<_OrderCompleteDialog> createState() => _OrderCompleteDialogState();
}

class _OrderCompleteDialogState extends State<_OrderCompleteDialog> {
  late VideoPlayerController _video;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _video = VideoPlayerController.asset('assets/mp4/success.mp4')
      ..initialize().then((_) {
        if (mounted) {
          setState(() => _ready = true);
          _video.play();
        }
      });
  }

  @override
  void dispose() {
    _video.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 311,
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        clipBehavior: Clip.antiAlias,
        decoration: ShapeDecoration(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(32),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Video + title ─────────────────────────────────────
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: _ready ? VideoPlayer(_video) : const SizedBox.shrink(),
                ),
                Transform.translate(
                  offset: const Offset(0, -24), // 上に24px移動
                  child: const Text(
                    '注文完了',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFF222222),
                      fontSize: 18,
                      fontFamily: 'Hiragino Kaku Gothic Pro',
                      fontWeight: FontWeight.w600,
                      height: 1.20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 0),

            // ── Buttons ───────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 閉じる
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 123.5,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF2F5FA),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(128),
                      ),
                    ),
                    child: const Text(
                      '閉じる',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF333333),
                        fontSize: 16,
                        fontFamily: 'Hiragino Kaku Gothic Pro',
                        fontWeight: FontWeight.w300,
                        height: 1,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 16),

                // 注文履歴へ
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop();
                    // TODO: 注文履歴画面への遷移
                  },
                  child: Container(
                    width: 123.5,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFBF0000),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(128),
                      ),
                    ),
                    child: const Text(
                      '注文履歴へ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontFamily: 'Hiragino Kaku Gothic Pro',
                        fontWeight: FontWeight.w300,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
