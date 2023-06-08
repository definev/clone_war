#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

layout(location = 0) out vec4 fragColor;
uniform float iTime;
uniform vec2 iResolution;

vec3 pallete(float t) {
    vec3 a = vec3(0.5, 0.5, 0.5);
    vec3 b = vec3(0.5, 0.5, 0.5);
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.0, 0.821, 0.559);
    return a + b * cos(6.28318 * (c * t + d));
}

void main() {
    vec2 uv = FlutterFragCoord().xy / iResolution * 2.0 - 1.0;

    if(iResolution.x > iResolution.y) {
        uv.x *= iResolution.x / iResolution.y;
    } else if(iResolution.x < iResolution.y) {
        uv.y *= iResolution.y / iResolution.x;
    }

    vec2 uv0 = uv;
    vec3 finalColor = vec3(0.0f);

    for(float i = 0.0; i < 4.0; i++) {

        uv = fract(uv * 1.5) - 0.5;

        float d = length(uv) * exp(-length(uv0));

        vec3 col = pallete(length(uv0) - i * .1 + iTime);

        d = sin(d * 8. + iTime) / 8.;
        d = abs(d);
        d = pow(0.01 / d, 1.2);

        finalColor += col * d;
    }

    fragColor = vec4(finalColor, 1.0f);
}