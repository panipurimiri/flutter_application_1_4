import 'package:flutter/material.dart';

/// Figmaデザインから変換したアンケート＆BTC情報セクション
/// main.dartのbody内に SurveySection() として配置してください

class SurveySection extends StatefulWidget {
  const SurveySection({super.key});

  @override
  State<SurveySection> createState() => _SurveySectionState();
}

class _SurveySectionState extends State<SurveySection> {
  // アンケート / 週間結果 の切り替え
  int _surveyTabIndex = 0;
  // BTCについて / ニュース の切り替え
  int _infoTabIndex = 0;

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
            onTap: (i) => setState(() => _surveyTabIndex = i),
          ),
          const SizedBox(height: 16),

          // 説明テキスト
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

          // 投票ボタン
          _buildVoteButton(
            label: '攻め！追加するべき！',
            bgColor: _statusInfoBg,
            textColor: _statusInfoFont,
            onTap: () {},
          ),
          const SizedBox(height: 8),
          _buildVoteButton(
            label: 'とりあえず様子を見る',
            bgColor: _statusSuccessBg,
            textColor: _statusSuccessFont,
            onTap: () {},
          ),
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
