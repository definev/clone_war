import 'dart:math';

import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class RiveoPageCurlView extends StatefulWidget {
  const RiveoPageCurlView({super.key});

  @override
  State<RiveoPageCurlView> createState() => _RiveoPageCurlViewState();
}

class _RiveoPageCurlViewState extends State<RiveoPageCurlView> {
  @override
  Widget build(BuildContext context) {
    return Theme(
      data: FlexColorScheme.light().toTheme,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Riveo Page Curl'),
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: RiveoCard(),
            ),
            ColoredBox(
              color: Colors.yellow,
              child: SizedBox.square(dimension: 150),
            ),
          ],
        ),
      ),
    );
  }
}

class RiveoCard extends StatefulWidget {
  const RiveoCard({
    super.key,
  });

  @override
  State<RiveoCard> createState() => _RiveoCardState();
}

class _RiveoCardState extends State<RiveoCard> with SingleTickerProviderStateMixin {
  double radius = 20;
  final padding = const EdgeInsets.symmetric(
    horizontal: 20,
    vertical: 10,
  );
  Rect getRect(double width, double height) =>
      Rect.fromLTRB(padding.left, padding.top, width - padding.right, height - padding.bottom);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              margin: padding,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(radius),
                color: Colors.red,
              ),
            ),
          ),
          Positioned.fill(
            child: ShaderBuilder(
              assetKey: 'shaders/riveo_page_curl.frag',
              (context, shader, child) {
                return child! //
                    .animate(
                      onPlay: (controller) => controller.loop(reverse: true),
                    )
                    .custom(
                      duration: 2.5.seconds,
                      builder: (context, value, child) {
                        return AnimatedSampler(
                          (image, size, canvas) {
                            final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
                            final rect = getRect(
                                image.width.toDouble() / devicePixelRatio, image.height.toDouble() / devicePixelRatio);

                            shader
                              ..setImageSampler(0, image)
                              // Size
                              ..setFloat(0, image.width.toDouble() / devicePixelRatio)
                              ..setFloat(1, image.height.toDouble() / devicePixelRatio)
                              // Container
                              ..setFloat(2, rect.left)
                              ..setFloat(3, rect.top)
                              ..setFloat(4, rect.right)
                              ..setFloat(5, rect.bottom)
                              // Radius
                              ..setFloat(6, radius)
                              // Cylinder dx
                              ..setFloat(7, rect.left + rect.right * (1 - value))
                              // Cylinder radius
                              ..setFloat(8, image.width.toDouble() / devicePixelRatio / pi);

                            canvas
                              ..save()
                              ..drawRect(
                                Offset.zero & size,
                                Paint()..shader = shader,
                              )
                              ..restore();
                          },
                          child: child,
                        );
                      },
                    );
              },
              child: Padding(
                padding: padding,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber, Colors.redAccent],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    image: DecorationImage(
                        image: NetworkImage(
                            'https://expertphotography.b-cdn.net/wp-content/uploads/2022/05/Landscape-Photography-Sophie-Turner.jpg'),
                        fit: BoxFit.cover),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
