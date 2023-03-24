import 'package:clone_war/03_riveo_page_curl/riveo_card.dart';
import 'package:clone_war/resources/resources.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
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

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: FlexColorScheme.dark().toTheme,
      child: Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedContainer(
                duration: 300.ms,
                curve: Curves.easeInOutCubic,
                decoration: BoxDecoration(
                  color: Challenge3PageData.values[currentPage].color,
                ),
              ),
            ),
            SafeArea(
              top: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(),
                  ElevatedButton(
                    onPressed: () => setState(() {
                      currentPage = (currentPage + 1) % Challenge3PageData.values.length;
                    }),
                    child: const Text('Next'),
                  ),
                  AspectRatio(
                    aspectRatio: 119 / 175,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: RiveoCard(
                        hiddenChild: const ColoredBox(
                          color: Colors.red,
                        ),
                        child: _buildSplashImage(Challenge3PageData.values[currentPage].image) //
                            .animate(key: ValueKey(currentPage))
                            .fadeIn(
                              duration: 300.ms,
                              curve: Curves.easeInOutCubic,
                            )
                            .custom(
                              duration: 300.ms,
                              curve: Curves.easeInOutCubic,
                              begin: 1,
                              end: 0,
                              builder: (context, value, child) => Stack(
                                children: [
                                  Positioned.fill(
                                    child: Opacity(
                                      opacity: value,
                                      child: _buildSplashImage(
                                        Challenge3PageData
                                            .values[currentPage - 1 < 0
                                                ? Challenge3PageData.values.length - 1
                                                : currentPage - 1]
                                            .image,
                                      ),
                                    ),
                                  ),
                                  Positioned.fill(child: child),
                                ],
                              ),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSplashImage(String image) {
    return DecoratedBox(
      position: DecorationPosition.foreground,
      decoration: BoxDecoration(
        border: Border.all(width: 2, color: Colors.white, strokeAlign: BorderSide.strokeAlignInside),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Image.asset(
        image,
        fit: BoxFit.cover,
      ),
    );
  }
}
