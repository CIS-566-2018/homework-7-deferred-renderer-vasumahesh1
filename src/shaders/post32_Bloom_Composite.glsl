#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform float u_BloomBlend;

uniform sampler2D u_frame;
uniform sampler2D u_BloomBlur;

void main() {
  vec3 baseColor = texture(u_frame, fs_UV).rgb;
  vec3 bloomColor = texture(u_BloomBlur, fs_UV).rgb;

  vec3 finalColor = baseColor + bloomColor * u_BloomBlend;

  out_Col = vec4(finalColor, 1.0);
}