import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      home: const MyFigmaScreen(),
    );
  }
}

class MyFigmaScreen extends StatelessWidget {
  const MyFigmaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 金額表示 1
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '123,456,789',
                    style: TextStyle(
                      fontSize: 52,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF222222),
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '円',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: screenWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '現在の市場をもとにした想定価格です。実際の予想価格は変動する可能性があります。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF222222),
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '0.000936490544794',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF4D4D4D),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'BTC',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF4D4D4D),
                    ),
                  ),
                ],
              ), //1

              // 金額表示 2
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '123,456,789',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 52,
                      color: const Color(0xFF222222),
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '円',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: screenWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '現在の市場をもとにした想定価格です。実際の予想価格は変動する可能性があります。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: const Color(0xFF222222),
                      height: 1.5,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '0.000936490544794',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF4D4D4D),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'BTC',
                    style: TextStyle(
                      fontSize: 10,
                      color: const Color(0xFF4D4D4D),
                    ),
                  ),
                ],
              ), //2

              // 金額表示 3
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '123,456,789',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 52,
                      color: const Color(0xFF222222),
                      height: 1,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Text(
                      '円',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: const Color(0xFF222222),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: screenWidth,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    '現在の市場をもとにした想定価格です。実際の予想価格は変動する可能性があります。',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      color: const Color(0xFF4D4D4D),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '0.000936490544794',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: const Color(0xFF4D4D4D),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'BTC',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                      color: const Color(0xFF4D4D4D),
                    ),
                  ),
                ],
              ), //3
            ],
          ),
        ),
      ),
    );
  }
}