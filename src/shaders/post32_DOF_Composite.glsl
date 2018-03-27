#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_frame;
uniform sampler2D u_gb0; // Near Blur
uniform sampler2D u_gb1; // Far Blur

vec4 blend(vec4 color1, vec4 color2) {
  // if (color2.w > 0.5) {
  //   return 2.0 * color1 * color2;
  // } else {
  //   return 1.0 - 2.0 * (1.0 - color1) * (1.0 - color2);
  // }
  if (color2.a > 0.0) {
    return color2 * 0.25 * color2.a;
  }

  return color1;
  // return color1 * color2;
}

void main() {
  vec4 baseColor = texture(u_frame, fs_UV);
  vec4 nearBlurColor = texture(u_gb0, fs_UV);
  vec4 farBlurColor = texture(u_gb1, fs_UV);

  vec4 finalColor;

  finalColor = blend(baseColor, nearBlurColor);
  finalColor = blend(finalColor, farBlurColor);

  // finalColor = baseColor * 0.8 + nearBlurColor * 0.2 + farBlurColor * 0.2;
  out_Col = vec4(finalColor.xyz, 1.0);
}