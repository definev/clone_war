#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

layout(location = 0) out vec4 fragColor;

uniform sampler2D image;

uniform vec2 resolution;
uniform vec4 container;
uniform float progress;
uniform float cornerRadius;
uniform float cylinderRadius;

const float shadow = 0.3;
const float PI = 3.1415926535897932384626433832795;
const vec4 TRANSPARENT = vec4(0);
const vec4 BACKGROUND = vec4(0.3, 0.5, 0.1, 1.0);

vec2 rectSize = vec2((container.z - container.x) / 2, (container.w - container.y) / 2);
vec2 center = vec2(container.x + rectSize.x, container.y + rectSize.y);

// Credit: https://www.shadertoy.com/view/NtVSW1
float sdRoundRect(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  return min(max(q.x, q.y), 0.0) + length(max(q, 0.0)) - r;
}

bool inRect(vec2 p) {
  float disRect = sdRoundRect(p - center, rectSize, cornerRadius);
  return disRect <= 0.0;
}

float project(float p, float from, float to) {
  return p / from * to + (from - to) / 2;
}

vec4 backgroundColor(vec2 p) {
  return mix(texture(image, p / resolution.xy), BACKGROUND, 0.3);
}

void main() {
  vec2 xy = FlutterFragCoord().xy;

  vec2 fullRectSize = vec2(container.z - container.x, container.w - container.y);
  float cylinderDy = container.y + fullRectSize.y * (1 - progress);

  float distance = xy.y - cylinderDy;

  if(distance > cylinderRadius) {
    fragColor = TRANSPARENT;
    if(inRect(xy)) {
      fragColor.a = mix(shadow, 0, (distance - cylinderRadius) / cylinderRadius);
    }
  } else if(distance > 0) {
    float theta = asin(distance / cylinderRadius);

    float dy2 = cylinderDy + cylinderRadius * (PI - theta);
    float scaledDx2 = fullRectSize.x + theta / PI * (resolution.x - fullRectSize.x);
    float dx2 = project(xy.x, resolution.x, scaledDx2);
    vec2 p2 = vec2(dx2, dy2);

    if(inRect(p2)) {
      fragColor = backgroundColor(p2);
      return;
    }

    float dy1 = cylinderDy + cylinderRadius * theta;
    float scaledDx1 = fullRectSize.x + (PI - theta) / PI * (resolution.x - fullRectSize.x);
    float dx1 = project(xy.x, resolution.x, scaledDx1);
    vec2 p1 = vec2(dx1, dy1);

    if(inRect(p1)) {
      fragColor = texture(image, p1 / resolution.xy);
      fragColor.rgb *= pow(clamp((cylinderRadius - distance) / cylinderRadius, 0.0, 1.0), 0.1);
      return;
    }

    if(inRect(xy)) {
      fragColor = TRANSPARENT;
      fragColor.a = shadow;
      return;
    }

    fragColor = TRANSPARENT;
  } else {
    float absDistance = abs(distance);
    float dy2 = cylinderDy + absDistance + PI * cylinderRadius;
    float dx2 = project(xy.x, resolution.x, fullRectSize.x);
    vec2 p2 = vec2(dx2, dy2);

    if(inRect(p2)) {
      fragColor = backgroundColor(p2);
      return;
    }

    if(inRect(xy)) {
      fragColor = texture(image, xy / resolution.xy);
      return;
    }

    fragColor = TRANSPARENT;
  }
}
