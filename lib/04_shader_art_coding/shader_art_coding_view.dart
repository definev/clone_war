import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_shaders/flutter_shaders.dart';

class ShaderArtCodingView extends StatelessWidget {
  const ShaderArtCodingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ShaderPlayground();
  }
}

class _ShaderPlayground extends StatefulWidget {
  const _ShaderPlayground();

  @override
  State<_ShaderPlayground> createState() => _ShaderPlaygroundState();
}

class _ShaderPlaygroundState extends State<_ShaderPlayground> {
  var iTime = 0.0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(
      1.6.ms,
      (timer) => setState(() => iTime += 0.008),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ShaderBuilder(
      (context, shader, child) => AnimatedSampler(
        (image, size, canvas) {
          shader //
            ..setFloat(0, iTime)
            ..setFloat(1, size.width)
            ..setFloat(2, size.height);
          canvas
            ..save()
            ..drawPaint(Paint()..shader = shader)
            ..restore();
        },
        child: const SizedBox.expand(),
      ),
      assetKey: 'shaders/04/shader_art_coding.frag',
    );
  }
}
