#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform vec3 uColorA;
uniform vec3 uColorB;
uniform float uProgress;

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    float noise = fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
    float t = uProgress + noise * 0.05 * (1.0 - uProgress);
    vec3 color = mix(uColorA, uColorB, t);
    fragColor = vec4(color, 1.0);
}
