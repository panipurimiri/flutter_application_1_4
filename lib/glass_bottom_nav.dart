import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:liquid_glass_renderer/liquid_glass_renderer.dart';

const _kFont = 'Hiragino Kaku Gothic Pro';
const _kBrandRed = Color(0xFFE60012);
const _kInactive = Color(0x8C000000);
const _kBarH = 58.0;
const _kRadius = 30.0;
const _kIndicatorRadius = 64.0;
const _kIndicatorInset = 4.0;
const _kActiveScale = 1.08;

// Active indicator tint: #939393 at 13% opacity.
const _kIndicatorTint = Color(0x21939393);

class GlassNavItem {
  final String asset;
  final String label;
  const GlassNavItem({required this.asset, required this.label});
}

// ── Public widget ──────────────────────────────────────────────────────────

class LiquidGlassBottomNav extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final List<GlassNavItem> items;
  final double bottomPadding;

  const LiquidGlassBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
    required this.items,
    this.bottomPadding = 0,
  });

  @override
  State<LiquidGlassBottomNav> createState() => _State();
}

class _State extends State<LiquidGlassBottomNav>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pos;
  late Animation<double> _stretch;
  int _prev = 0;
  int _cur = 0;
  late List<double> _tapScales;

  // Maps tab index → Alignment.x (-1 … 1)
  double _xAlignOf(int i) {
    final n = widget.items.length;
    if (n <= 1) return 0;
    return (i / (n - 1)) * 2 - 1;
  }

  @override
  void initState() {
    super.initState();
    _cur = widget.selectedIndex;
    _prev = widget.selectedIndex;
    _tapScales = List.filled(widget.items.length, 1.0);

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    // Start complete so indicator is at the correct position immediately
    _ctrl.value = 1.0;

    _pos = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _stretch = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.08), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.08, end: 1.0), weight: 50),
    ]).animate(_ctrl);
  }

  @override
  void didUpdateWidget(LiquidGlassBottomNav old) {
    super.didUpdateWidget(old);
    if (old.selectedIndex != widget.selectedIndex) {
      _prev = _cur;
      _cur = widget.selectedIndex;
      if (MediaQuery.of(context).disableAnimations) {
        _ctrl.value = 1.0;
      } else {
        _ctrl.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTap(int i) {
    if (i != _cur) {
      HapticFeedback.selectionClick();
      setState(() => _tapScales[i] = 0.95);
      Future.delayed(const Duration(milliseconds: 180), () {
        if (mounted) setState(() => _tapScales[i] = 1.0);
      });
    }
    widget.onTap(i);
  }

  Color _colorOf(int i) {
    if (_prev == _cur) return i == _cur ? _kBrandRed : _kInactive;
    if (i == _cur) return Color.lerp(_kInactive, _kBrandRed, _pos.value)!;
    if (i == _prev) return Color.lerp(_kBrandRed, _kInactive, _pos.value)!;
    return _kInactive;
  }

  // Scale for active-tab emphasis, animated with _pos.
  double _scaleOf(int i) {
    if (_prev == _cur) return i == _cur ? _kActiveScale : 1.0;
    if (i == _cur) {
      return 1.0 + (_kActiveScale - 1.0) * _pos.value;
    }
    if (i == _prev) {
      return 1.0 + (_kActiveScale - 1.0) * (1.0 - _pos.value);
    }
    return 1.0;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    final highContrast = MediaQuery.of(context).highContrast;

    final glassSettings = LiquidGlassSettings(
      refractiveIndex: 1.20,
      thickness: 20,
      blur: 12,
      saturation: 1.3,
      lightIntensity: isDark ? 0.8 : 1.2,
      ambientStrength: isDark ? 0.25 : 0.4,
      lightAngle: math.pi / 4,
      glassColor: isDark ? const Color(0x331C1C1E) : const Color(0x33FFFFFF),
    );

    return RepaintBoundary(
      child: Padding(
        padding: EdgeInsets.only(
          left: 14,
          right: 14,
          bottom: widget.bottomPadding + 10,
        ),
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (context, child) {
            final fromX = _xAlignOf(_prev);
            final toX = _xAlignOf(_cur);
            final xAlign = fromX + (toX - fromX) * _pos.value;
            final stretch = _stretch.value;

            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_kRadius),
                boxShadow: [
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, isDark ? 0.40 : 0.12),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: Color.fromRGBO(0, 0, 0, isDark ? 0.20 : 0.06),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: highContrast
                  ? _fallback(isDark)
                  : LiquidGlassLayer(
                      settings: glassSettings,
                      child: SizedBox(
                        height: _kBarH,
                        child: Stack(
                          children: [
                            // ── Glass bar (only the bar body is glass) ──
                            // Indicator is rendered as a flat color pill
                            // on top, so no bulging refraction happens at
                            // its edges.
                            LiquidGlass.grouped(
                              shape: const LiquidRoundedSuperellipse(
                                borderRadius: _kRadius,
                              ),
                              child: const SizedBox(
                                width: double.infinity,
                                height: _kBarH,
                              ),
                            ),

                            // ── Flat color pill indicator ───────────────
                            Positioned.fill(
                              left: _kIndicatorInset,
                              right: _kIndicatorInset,
                              top: _kIndicatorInset,
                              bottom: _kIndicatorInset,
                              child: IgnorePointer(
                                child: FractionallySizedBox(
                                  widthFactor: stretch / widget.items.length,
                                  alignment: Alignment(xAlign, 0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: _kIndicatorTint,
                                      borderRadius: BorderRadius.circular(
                                        _kIndicatorRadius,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            // ── Tab items (on top of glass) ─────────────
                            Row(
                              children: List.generate(
                                widget.items.length,
                                (i) => _buildTabItem(i),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabItem(int i) {
    final c = _colorOf(i);
    final activeScale = _scaleOf(i);
    return Expanded(
      child: GestureDetector(
        onTap: () => _onTap(i),
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _tapScales[i],
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: SizedBox(
            height: _kBarH,
            child: Transform.scale(
              scale: activeScale,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    widget.items[i].asset,
                    width: 22,
                    height: 22,
                    colorFilter: ColorFilter.mode(c, BlendMode.srcIn),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.items[i].label,
                    style: TextStyle(
                      fontFamily: _kFont,
                      fontSize: 10,
                      fontWeight: i == _cur ? FontWeight.w600 : FontWeight.w400,
                      color: c,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── High-contrast fallback (no blur shader) ─────────────────────────────
  Widget _fallback(bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(_kRadius),
      child: Container(
        height: _kBarH,
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        child: Row(
          children: List.generate(widget.items.length, (i) => _buildTabItem(i)),
        ),
      ),
    );
  }
}
