#version 460 core

#include <flutter/runtime_effect.glsl>

precision highp float;

layout(location = 0) out vec4 fragColor;

uniform sampler2D image;

uniform vec2 resolution;
uniform vec4 container;
uniform float cornerRadius;
uniform float cylinderDx;
uniform float cylinderRadius;

const float PI = 3.1415926535897;
const vec4 TRANSPARENT = vec4(0, 0, 0, 0);

bool inRect(vec2 p, vec4 rect) {
  bool inRect = p.x >= rect.x && p.x <= rect.z && p.y >= rect.y && p.y <= rect.w;
  if(!inRect) {
    return false;
  }

  // Top left corner
  if(p.x < rect.x + cornerRadius && p.y < rect.y + cornerRadius) {
    return length(p - vec2(rect.x + cornerRadius, rect.y + cornerRadius)) < cornerRadius;
  }
  // // Top right corner
  if(p.x > rect.z - cornerRadius && p.y < rect.y + cornerRadius) {
    return length(p - vec2(rect.z - cornerRadius, rect.y + cornerRadius)) < cornerRadius;
  }
  // Bottom left corner
  if(p.x < rect.x + cornerRadius && p.y > rect.w - cornerRadius) {
    return length(p - vec2(rect.x + cornerRadius, rect.w - cornerRadius)) < cornerRadius;
  }
  // Bottom right corner
  if(p.x > rect.z - cornerRadius && p.y > rect.w - cornerRadius) {
    return length(p - vec2(rect.z - cornerRadius, rect.w - cornerRadius)) < cornerRadius;
  }

  return true;
}

vec2 toUV(vec2 p) {
  return p / resolution.xy;
}

vec4 backgroundColor(vec4 color) {
  return mix(color, vec4(255) / 255, 0.4);
}

float project(float py, float from, float to) {
  float yScaleFactor = py / from;
  return yScaleFactor * to + (from - to) / 2;
}

float saturate(float val) {
  if(val < 0)
    return 0;
  if(val > 1)
    return 1;
  return val;
}

void main() {
  vec2 xy = FlutterFragCoord().xy;
  if(xy.x > container.z) {
    fragColor = TRANSPARENT;
    return;
  }

  vec2 rectSize = vec2(container.z - container.x, container.w - container.y);

  float distance = xy.x - cylinderDx;

  if(distance > cylinderRadius) {
    fragColor = TRANSPARENT;
    if(inRect(xy, container)) {
      fragColor.a = mix(0.5, 0, (distance - cylinderRadius) / cylinderRadius);
    }
  } else if(distance > 0) {
    float theta = asin(distance / cylinderRadius);

    float dx2 = cylinderDx + cylinderRadius * (PI - theta);
    float scaledDy2 = rectSize.y + theta / PI * (resolution.y - rectSize.y);
    float dy2 = project(xy.y, resolution.y, scaledDy2);
    vec2 p2 = vec2(dx2, dy2);

    if(inRect(p2, container)) {
      fragColor = backgroundColor(texture(image, toUV(p2)));
      return;
    }

    float dx1 = cylinderDx + cylinderRadius * theta;
    float scaledDy1 = rectSize.y + (PI - theta) / PI * (resolution.y - rectSize.y);
    float dy1 = project(xy.y, resolution.y, scaledDy1);
    vec2 p1 = vec2(dx1, dy1);

    if(inRect(p1, container)) {
      fragColor = texture(image, toUV(p1));
      fragColor.rgb *= pow(saturate((cylinderRadius - distance) / cylinderRadius), 0.2);
      return;
    }

    if(inRect(xy, container)) {
      fragColor = TRANSPARENT;
      fragColor.a = 0.5;
      return;
    }

    fragColor = TRANSPARENT;
  } else {
    float yScaleFactor = xy.y / resolution.y;
    float newY = container.y + yScaleFactor * rectSize.y;
    float d2 = abs(distance) + PI * cylinderRadius;
    vec2 p2 = vec2(cylinderDx + d2, newY);

    if(inRect(p2, container)) {
      fragColor = backgroundColor(texture(image, toUV(p2)));
      return;
    }

    if(inRect(xy, container)) {
      fragColor = texture(image, toUV(xy));
      return;
    }

    fragColor = TRANSPARENT;
  }
}
