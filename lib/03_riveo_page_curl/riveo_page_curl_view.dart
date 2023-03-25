import 'dart:ui';

import 'package:clone_war/03_riveo_page_curl/riveo_card.dart';
import 'package:clone_war/resources/resources.dart';
import 'package:flextras/flextras.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class Challenge3PageData {
  const Challenge3PageData({
    required this.title,
    required this.image,
    required this.color,
  });

  final String title;
  final String image;
  final Color color;

  static final values = [
    const Challenge3PageData(
      title: 'Artificial nature',
      image: Challenge3Images.artificialNature,
      color: Color(0xFFD39DF9),
    ),
    const Challenge3PageData(
      title: 'Cyber globalism',
      image: Challenge3Images.cyberGlobalism,
      color: Color(0xFF53C2EB),
    ),
    const Challenge3PageData(
      title: 'Modern future',
      image: Challenge3Images.modernFuture,
      color: Color(0xFFEABD40),
    ),
  ];
}

class RiveoPageCurlView extends StatefulWidget {
  const RiveoPageCurlView({super.key});

  @override
  State<RiveoPageCurlView> createState() => _RiveoPageCurlViewState();
}

class _RiveoPageCurlViewState extends State<RiveoPageCurlView> {
  int currentPage = 0;

  double bendValue = 0.0;

  @override
  Widget build(BuildContext context) {
    final pageData = Challenge3PageData.values[currentPage];

    final titles = pageData.title.split(' ');
    const fontSize = 56.0;

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedContainer(
              duration: 500.ms,
              curve: Curves.easeInOutCubicEmphasized,
              decoration: BoxDecoration(
                color: pageData.color,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
                      child: StoryProgressBar(currentPage),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      PaddedColumn(
                        padding: const EdgeInsets.only(
                          top: 40,
                          left: 25,
                        ),
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            titles[0],
                            style: Theme.of(context) //
                                .textTheme
                                .labelSmall!
                                .copyWith(
                              fontSize: fontSize,
                              height: 1,
                              fontVariations: [
                                const FontVariation('wght', 300),
                              ],
                            ),
                          ),
                          SizedBox(height: 10 - 5 * bendValue),
                          SizedBox(
                            height: fontSize + 20,
                            child: Text(
                              titles[1],
                              style: Theme.of(context) //
                                  .textTheme
                                  .labelSmall!
                                  .copyWith(
                                fontSize: fontSize + 20 * bendValue,
                                height: 0.8 + 0.2 * bendValue,
                                color: Color.lerp(pageData.color, Colors.white, 0.6 + 0.4 * bendValue),
                                fontVariations: [
                                  FontVariation('wght', 300 + bendValue * 300),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Expanded(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxHeight: 610),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 5),
                              child: RiveoCard(
                                onVerticalDrag: (value) => setState(() => bendValue = value),
                                onHorizontalSwipe: (value) {
                                  switch (value) {
                                    case AxisDirection.left:
                                      setState(() {
                                        currentPage = (currentPage - 1) % Challenge3PageData.values.length;
                                      });
                                      break;
                                    case AxisDirection.right:
                                      setState(() {
                                        currentPage = (currentPage + 1) % Challenge3PageData.values.length;
                                      });
                                      break;
                                    default:
                                  }
                                },
                                hiddenChild: ColoredBox(color: pageData.color),
                                child: _buildSplashImage(pageData.image),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                      .animate(key: ValueKey(pageData.image)) //
                      .fadeIn(
                        duration: 500.ms,
                        curve: Curves.easeInOutCubicEmphasized,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSplashImage(String image) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.5,
          color: Colors.black87,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Image.asset(
        image,
        fit: BoxFit.cover,
      ),
    );
  }
}

class StoryProgressBar extends StatelessWidget {
  const StoryProgressBar(this.currentPage, {super.key});

  final int currentPage;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 9.0;
        final maxWidth = constraints.maxWidth - gap * 2;
        return SeparatedRow(
          separatorBuilder: () => const SizedBox(width: gap),
          children: [
            for (int i = 0; i < 3; i++)
              TweenAnimationBuilder<double>(
                tween: Tween<double>(
                  begin: 1,
                  end: currentPage == i ? 2 : 1,
                ),
                curve: Curves.easeInOutCubicEmphasized,
                duration: 300.ms,
                builder: (context, value, child) {
                  return SizedBox(
                    width: maxWidth / 4 * value,
                    height: 6,
                    child: child,
                  );
                },
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: i <= currentPage ? Colors.white : Colors.white24,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
