import 'package:flutter/material.dart';
import 'dart:math' as math;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sliding Doors demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyWidget(),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Sliding Doors'),
              Expanded(
                child: Stack(
                  fit: StackFit.expand,
                  children: const [
                    Background(),
                    DoorFrame(),
                    SlidingDoorFrame(
                      door: Door(
                        doorColor: Colors.amber,
                      ),
                    ),
                    SlidingDoorFrame(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Background extends StatelessWidget {
  const Background({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.lightBlue,
            Colors.lightBlue.shade200,
          ],
          transform: const GradientRotation(math.pi / 2),
        ),
      ),
    );
  }
}

class DoorFrame extends StatelessWidget {
  const DoorFrame({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.orange.shade600,
          width: 4,
        ),
      ),
    );
  }
}

class SlidingDoorFrame extends StatefulWidget {
  const SlidingDoorFrame({
    Key? key,
    this.door = const Door(),
  }) : super(key: key);

  final Widget door;

  @override
  State<SlidingDoorFrame> createState() => _SlidingDoorFrameState();
}

class _SlidingDoorFrameState extends State<SlidingDoorFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  late double _halfWidth;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
  }

  // implementing drag and fling
  // https://www.youtube.com/watch?v=oDRPpkzb0aQ&t=1256s
  void _onDragUpdate(DragUpdateDetails details) {
    if (details.primaryDelta == null) return;

    final delta = details.primaryDelta! / _halfWidth;
    animationController.value += delta;
    debugPrint(delta.toString());
  }

  void _onDragEnd(DragEndDetails details) {
    double kMinFlingVelocity = 365.0;
    double dragvelocity = details.velocity.pixelsPerSecond.dx.abs();
    if (dragvelocity >= kMinFlingVelocity) {
      double visualVelocity =
          details.velocity.pixelsPerSecond.dx / (_halfWidth * 2);
      animationController.fling(velocity: visualVelocity);
    } else {
      if (animationController.value < 0.5) {
        animationController.reverse();
      } else {
        animationController.forward();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        _halfWidth = constraints.maxWidth / 2;

        return Stack(
          children: [
            AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                double translateXValue = animationController.value * _halfWidth;

                return Transform.translate(
                  offset: Offset(translateXValue, 0),
                  child: child,
                );
              },
              child: GestureDetector(
                onHorizontalDragUpdate: _onDragUpdate,
                onHorizontalDragEnd: _onDragEnd,
                child: SizedBox(
                  width: _halfWidth,
                  height: double.infinity,
                  child: widget.door,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}

class Door extends StatelessWidget {
  const Door({
    super.key,
    this.doorColor = Colors.orange,
    this.opacity = 0.8,
  });

  final MaterialColor doorColor;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: doorColor,
          width: 8,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: List.generate(
                10,
                ((index) => Expanded(
                      child: Row(
                        children: List.generate(
                          3,
                          ((index) => Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: doorColor,
                                        width: 2,
                                      ),
                                    ),
                                    child: ColoredBox(
                                      color: Colors.white.withOpacity(
                                        opacity,
                                      ),
                                    ),
                                  ),
                                ),
                              )),
                        ).toList(),
                      ),
                    )),
              ).toList(),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: doorColor,
                    width: 8,
                  ),
                ),
              ),
              child: ColoredBox(
                color: doorColor.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
