#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb3;

uniform sampler2D u_frame;

void main() {
  vec4 gb3 = texture(u_gb3, fs_UV);
  out_Col = gb3;
}