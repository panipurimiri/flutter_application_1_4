import 'package:flutter/material.dart';

const _hiraFont = TextStyle(fontFamily: 'Hiragino Sans');

class BuyPage extends StatelessWidget {
  const BuyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFF757575),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 60),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildHeader(context),
                            const SizedBox(height: 24),
                            _buildPriceSection(),
                            const SizedBox(height: 32),
                            _buildToggleButtons(),
                            const SizedBox(height: 40),
                            _buildAmountInputArea(screenWidth),
                            const SizedBox(height: 40),
                            _buildPointCard(),
                            const SizedBox(height: 12),
                            _buildBalanceCard(),
                            const SizedBox(height: 20),
                            _buildSkipConfirmation(),
                            const SizedBox(height: 100),
                          ],
                        ),
                      ),
                    ),
                    _buildBottomButton(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Text(
          'BTCを買う',
          style: _hiraFont.copyWith(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.black54),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: Image.network(
            'https://upload.wikimedia.org/wikipedia/commons/thumb/4/46/Bitcoin.svg/64px-Bitcoin.svg.png',
            width: 32,
            height: 32,
            errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.currency_bitcoin, color: Colors.orange),
          ),
        ),
      ],
    );
  }

  Widget _buildPriceSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'レート（参考） ',
          style: _hiraFont.copyWith(color: Colors.grey, fontSize: 13),
        ),
        Text(
          '16,845,997',
          style: _hiraFont.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        Text(
          ' 円 ',
          style: _hiraFont.copyWith(fontSize: 13),
        ),
        const Icon(Icons.help_outline, size: 16, color: Colors.grey),
      ],
    );
  }

  Widget _buildToggleButtons() {
    return Row(
      children: [
        _tabButton("通常", true),
        const SizedBox(width: 8),
        _tabButton("条件付き", false),
      ],
    );
  }

  Widget _tabButton(String text, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isActive
            ? const Color(0xFFF8FAFD)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: _hiraFont.copyWith(
          color: isActive ? const Color(0xFFBF0000) : Colors.grey,
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildAmountInputArea(double screenWidth) {
    return Column(
      children: [
        SizedBox(
          width: screenWidth * 0.9,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '1,234,567',
                  style: _hiraFont.copyWith(
                    fontSize: screenWidth * 0.138,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12, left: 4),
                  child: Text(
                    '円',
                    style: _hiraFont.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  children: [
                    const Icon(Icons.cached, color: Colors.black87),
                    Text(
                      'BTC',
                      style: _hiraFont.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        Text(
          '0.000936490544794 BTC',
          style: _hiraFont.copyWith(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildPointCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'ポイント利用 ',
                    style: _hiraFont.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const Icon(Icons.help_outline, size: 16, color: Colors.grey),
                ],
              ),
              Switch(
                value: true,
                onChanged: (v) {},
                activeThumbColor: const Color(0xFF555555),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '投資可能ポイント',
                style: _hiraFont.copyWith(color: Colors.grey),
              ),
              Text(
                '10,000',
                style: _hiraFont.copyWith(
                  color: const Color(0xFFBF0000),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const Icon(Icons.currency_yen, color: Color(0xFFBF0000), size: 20),
          const SizedBox(width: 8),
          Text(
            '円残高',
            style: _hiraFont.copyWith(color: Colors.grey),
          ),
          const Spacer(),
          Text(
            '359,485',
            style: _hiraFont.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text('円', style: _hiraFont.copyWith()),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
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
          style: _hiraFont.copyWith(color: Colors.black87, fontSize: 14),
        ),
        Switch(
          value: false,
          onChanged: (v) {},
          activeThumbColor: const Color(0xFF555555),
        ),
      ],
    );
  }

  Widget _buildBottomButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).padding.bottom + 20,
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFBF0000),
            shape: const StadiumBorder(),
            elevation: 0,
          ),
          onPressed: () {},
          child: Text(
            '注文を確認',
            style: _hiraFont.copyWith(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}