#version 300 es
precision highp float;

uniform mat4 u_Model;
uniform mat4 u_ModelInvTr;  

uniform mat4 u_LightSpaceMatrix;

in vec4 vs_Pos;
out vec4 fs_Pos;

void main()
{
    fs_Pos = u_LightSpaceMatrix * vec4(vs_Pos.xyz, 1);
    gl_Position = fs_Pos;
}
