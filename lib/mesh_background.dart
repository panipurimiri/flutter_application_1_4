import 'dart:math';
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:mesh/mesh.dart';

// ── 銘柄別カラーパレット ──────────────────────────────────
// BTC（ページ0 / 先頭・デフォルト）
const _btcC1 = Color(0xFFFBCE98);
const _btcC2 = Color(0xFFFAB96A);
const _btcC3 = Color(0xFFF7931A);
const _btcC4 = Color(0xFFCA7815);
const _btcC5 = Color(0xFFA76311);

// BAT（ページ1）
const _batC1 = Color(0xFFF4A9A9);
const _batC2 = Color(0xFFF08384);
const _batC3 = Color(0xFFE84142);
const _batC4 = Color(0xFFBE3536);
const _batC5 = Color(0xFF9D2C2C);

// BCH（ページ2）
const _bchC1 = Color(0xFF90E3CC);
const _bchC2 = Color(0xFF5FD6B5);
const _bchC3 = Color(0xFF0AC18E);
const _bchC4 = Color(0xFF089E74);
const _bchC5 = Color(0xFF068360);

// XRP（ページ3 / 右端）
const _xrpC1 = Color(0xFFA0A5AC);
const _xrpC2 = Color(0xFF767D88);
const _xrpC3 = Color(0xFF2D3748);
const _xrpC4 = Color(0xFF242D3B);
const _xrpC5 = Color(0xFF1E2530);

// ── メッシュ色配置パターン [c1,c2,c3,c3,c3,c2,c5,c4,c4] ──
List<Color> _buildMesh(
  Color c1,
  Color c2,
  Color c3,
  Color c4,
  Color c5,
) =>
    [c1, c2, c3, c3, c3, c2, c5, c4, c4];

final _btcMesh = _buildMesh(_btcC1, _btcC2, _btcC3, _btcC4, _btcC5);
final _batMesh = _buildMesh(_batC1, _batC2, _batC3, _batC4, _batC5);
final _bchMesh = _buildMesh(_bchC1, _bchC2, _bchC3, _bchC4, _bchC5);
final _xrpMesh = _buildMesh(_xrpC1, _xrpC2, _xrpC3, _xrpC4, _xrpC5);

// ── HSL補間ヘルパー ──────────────────────────────────────
Color _lerpHSL(Color a, Color b, double t) {
  final hslA = HSLColor.fromColor(a);
  final hslB = HSLColor.fromColor(b);

  // 色相は最短経路で補間
  double hueA = hslA.hue;
  double hueB = hslB.hue;
  double hueDiff = hueB - hueA;
  if (hueDiff > 180) hueDiff -= 360;
  if (hueDiff < -180) hueDiff += 360;
  double hue = (hueA + hueDiff * t) % 360;
  if (hue < 0) hue += 360;

  // 彩度：遷移中に下がりすぎないようガード（最小値の85%以下にしない）
  final satMin = min(hslA.saturation, hslB.saturation);
  final saturation = lerpDouble(hslA.saturation, hslB.saturation, t)!
      .clamp(satMin * 0.85, 1.0);

  // 明度：始点と終点の範囲内にガード
  final ltMin = min(hslA.lightness, hslB.lightness);
  final ltMax = max(hslA.lightness, hslB.lightness);
  final lightness =
      lerpDouble(hslA.lightness, hslB.lightness, t)!.clamp(ltMin, ltMax);

  return HSLColor.fromAHSL(1.0, hue, saturation, lightness).toColor();
}

// ── 9色を個別にHSL補間 ───────────────────────────────────
List<Color> _interpolateMesh(List<Color> from, List<Color> to, double t) =>
    List.generate(9, (i) => _lerpHSL(from[i], to[i], t));

/// PageController.page（0.0〜3.0）からメッシュ色リストを返す
///   page 0 = BTC, page 1 = BAT, page 2 = BCH, page 3 = XRP
List<Color> meshColorsForPage(double page) {
  if (page <= 0.0) return _btcMesh;
  if (page >= 3.0) return _xrpMesh;
  if (page <= 1.0) {
    return _interpolateMesh(_btcMesh, _batMesh, page);
  } else if (page <= 2.0) {
    return _interpolateMesh(_batMesh, _bchMesh, page - 1.0);
  } else {
    return _interpolateMesh(_bchMesh, _xrpMesh, page - 2.0);
  }
}

// ── MeshBackground ウィジェット ──────────────────────────
/// PageController をそのまま渡すと、スワイプに完全同期して
/// OMeshGradient の色がリアルタイムで変化する。
class MeshBackground extends StatelessWidget {
  final PageController pageController;

  const MeshBackground({super.key, required this.pageController});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pageController,
      builder: (context, _) {
        final page =
            pageController.hasClients ? (pageController.page ?? 1.0) : 1.0;
        final colors = meshColorsForPage(page);
        return _MeshView(colors: colors);
      },
    );
  }
}

class _MeshView extends StatelessWidget {
  final List<Color> colors;

  const _MeshView({required this.colors});

  @override
  Widget build(BuildContext context) {
    return OMeshGradient(
      mesh: OMeshRect(
        width: 3,
        height: 3,
        backgroundColor: colors[4],
        fallbackColor: colors[4],
        vertices: [
          (-0.08, -0.05).v, (0.52, -0.08).v, (1.08, 0.02).v,
          (-0.12, 0.42).v, (0.60, 0.42).v, (1.10, 0.45).v,
          (-0.05, 1.08).v, (0.48, 1.02).v, (1.05, 1.05).v,
        ],
        colors: colors,
      ),
    );
  }
}
