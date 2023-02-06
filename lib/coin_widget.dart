import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CoinWidget extends StatefulWidget {
  const CoinWidget({super.key});

  @override
  State<CoinWidget> createState() => _CoinWidgetState();
}

class _CoinWidgetState extends State<CoinWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> animation;

  String _result = 'Flip the coin';
  bool _disableTouch = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    animation = Tween<double>(begin: 0, end: 1).animate(controller);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void _flipCoin() async {
    if (_disableTouch) return;

    setState(() {
      _disableTouch = true;
    });

    controller.reset();
    int value = await _getRandomNumber();
    await controller.forward().whenComplete(() async {
      setState(() {
        _disableTouch = false;
        _result = value == 0 ? 'Heads' : 'Tails';
      });
    });
  }

  // Gets a random number from random.org to decide the result of the coin flip
  Future<int> _getRandomNumber() async {
    final response = await http.get(Uri.parse(
        'https://www.random.org/integers/?num=1&min=0&max=1&col=1&base=10&format=plain&rnd=new'));
    if (response.statusCode == 200) {
      return int.parse(response.body.trim());
    } else {
      throw Exception('Failed to get random number');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _flipCoin,
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(4 * pi * animation.value),
              child: child,
            );
          },
          child: Container(
            width: 200,
            height: 200,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.yellow,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
            child: Center(
              child: Text(
                _result,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.black87,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
