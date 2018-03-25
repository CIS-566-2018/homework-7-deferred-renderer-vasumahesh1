#version 300 es
precision highp float;

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb0;

uniform float u_DOF_Blend;
uniform float u_DOF_Focal;
uniform sampler2D u_frame;
uniform ivec2 u_Dimensions;

const float blurclamp = 3.0;  // max blur amount
const float bias = 0.6; //aperture - bigger values for shallower depth of field

const int FILTER_SIZE = 11;
const float BLUR_MATRIX[121] = float[](
    0.006849, 0.007239, 0.007559, 0.007795, 0.007941, 0.00799, 0.007941,
    0.007795, 0.007559, 0.007239, 0.006849, 0.007239, 0.007653, 0.00799,
    0.00824, 0.008394, 0.008446, 0.008394, 0.00824, 0.00799, 0.007653, 0.007239,
    0.007559, 0.00799, 0.008342, 0.008604, 0.008764, 0.008819, 0.008764,
    0.008604, 0.008342, 0.00799, 0.007559, 0.007795, 0.00824, 0.008604,
    0.008873, 0.009039, 0.009095, 0.009039, 0.008873, 0.008604, 0.00824,
    0.007795, 0.007941, 0.008394, 0.008764, 0.009039, 0.009208, 0.009265,
    0.009208, 0.009039, 0.008764, 0.008394, 0.007941, 0.00799, 0.008446,
    0.008819, 0.009095, 0.009265, 0.009322, 0.009265, 0.009095, 0.008819,
    0.008446, 0.00799, 0.007941, 0.008394, 0.008764, 0.009039, 0.009208,
    0.009265, 0.009208, 0.009039, 0.008764, 0.008394, 0.007941, 0.007795,
    0.00824, 0.008604, 0.008873, 0.009039, 0.009095, 0.009039, 0.008873,
    0.008604, 0.00824, 0.007795, 0.007559, 0.00799, 0.008342, 0.008604,
    0.008764, 0.008819, 0.008764, 0.008604, 0.008342, 0.00799, 0.007559,
    0.007239, 0.007653, 0.00799, 0.00824, 0.008394, 0.008446, 0.008394, 0.00824,
    0.00799, 0.007653, 0.007239, 0.006849, 0.007239, 0.007559, 0.007795,
    0.007941, 0.00799, 0.007941, 0.007795, 0.007559, 0.007239, 0.006849);

vec3 getColor(float x, float y) {
  float posX = x / (float(u_Dimensions.x) - 1.0);
  float posY = y / (float(u_Dimensions.y) - 1.0);

  vec4 col = texture(u_frame, vec2(posX, posY));
  return col.xyz;
}

void main() {
  // int halfSize = FILTER_SIZE / 2;

  // vec2 coords = gl_FragCoord.xy - float(halfSize);

  // vec4 gb0 = texture(u_gb0, coords);
  // float depth = gb0.w;

  // float amount = abs(u_DOF_Focal - depth);

  // vec3 val = vec3(0, 0, 0);

  // for (int i = 0; i < FILTER_SIZE; i++) {
  //   float x = coords.x + float(i);

  //   for (int j = 0; j < FILTER_SIZE; j++) {
  //     float y = coords.y + float(j);

  //     int key = j + (FILTER_SIZE * i);

  //     float filterValue = BLUR_MATRIX[key];
  //     float filterBase = 0.0;

  //     if (i == halfSize && j == halfSize) {
  //       filterBase = 1.0;
  //     }

  //     filterValue = mix(filterBase, filterValue, amount);

  //     val += filterValue * getColor(x, y);
  //   }
  // }

  // out_Col = vec4(val, 1.0f);

  float aspectratio = float(u_Dimensions.x) / float(u_Dimensions.y);
  vec2 aspectcorrect = vec2(1.0, aspectratio);

  float posX = gl_FragCoord.x / (float(u_Dimensions.x) - 1.0);
  float posY = gl_FragCoord.y / (float(u_Dimensions.y) - 1.0);
  vec2 coords = vec2(posX, posY);
 
  vec4 depth1 = texture(u_gb0, coords);

  float focus = 10.0;// u_DOF_Focal;

  float factor = (depth1.w - focus);
   
  vec2 dofblur = vec2(clamp(factor * bias, -blurclamp, blurclamp));

  vec4 col = vec4(0.0);
 
  col += texture(u_frame, coords);
  col += texture(u_frame, coords + (vec2( 0.0,0.4 )*aspectcorrect) * dofblur);
  col += texture(u_frame, coords + (vec2( 0.15,0.37 )*aspectcorrect) * dofblur);
  col += texture(u_frame, coords + (vec2( 0.29,0.29 )*aspectcorrect) * dofblur);
  col += texture(u_frame, coords + (vec2( -0.37,0.15 )*aspectcorrect) * dofblur);       
  col += texture(u_frame, coords + (vec2( 0.4,0.0 )*aspectcorrect) * dofblur);   
  col += texture(u_frame, coords + (vec2( 0.37,-0.15 )*aspectcorrect) * dofblur);       
  col += texture(u_frame, coords + (vec2( 0.29,-0.29 )*aspectcorrect) * dofblur);       
  col += texture(u_frame, coords + (vec2( -0.15,-0.37 )*aspectcorrect) * dofblur);
  col += texture(u_frame, coords + (vec2( 0.0,-0.4 )*aspectcorrect) * dofblur); 
  col += texture(u_frame, coords + (vec2( -0.15,0.37 )*aspectcorrect) * dofblur);
  col += texture(u_frame, coords + (vec2( -0.29,0.29 )*aspectcorrect) * dofblur);
  col += texture(u_frame, coords + (vec2( 0.37,0.15 )*aspectcorrect) * dofblur); 
  col += texture(u_frame, coords + (vec2( -0.4,0.0 )*aspectcorrect) * dofblur); 
  col += texture(u_frame, coords + (vec2( -0.37,-0.15 )*aspectcorrect) * dofblur);       
  col += texture(u_frame, coords + (vec2( -0.29,-0.29 )*aspectcorrect) * dofblur);       
  col += texture(u_frame, coords + (vec2( 0.15,-0.37 )*aspectcorrect) * dofblur);
 
  col += texture(u_frame, coords + (vec2( 0.15,0.37 )*aspectcorrect) * dofblur*0.9);
  col += texture(u_frame, coords + (vec2( -0.37,0.15 )*aspectcorrect) * dofblur*0.9);           
  col += texture(u_frame, coords + (vec2( 0.37,-0.15 )*aspectcorrect) * dofblur*0.9);           
  col += texture(u_frame, coords + (vec2( -0.15,-0.37 )*aspectcorrect) * dofblur*0.9);
  col += texture(u_frame, coords + (vec2( -0.15,0.37 )*aspectcorrect) * dofblur*0.9);
  col += texture(u_frame, coords + (vec2( 0.37,0.15 )*aspectcorrect) * dofblur*0.9);            
  col += texture(u_frame, coords + (vec2( -0.37,-0.15 )*aspectcorrect) * dofblur*0.9);   
  col += texture(u_frame, coords + (vec2( 0.15,-0.37 )*aspectcorrect) * dofblur*0.9);   
 
  col += texture(u_frame, coords + (vec2( 0.29,0.29 )*aspectcorrect) * dofblur*0.7);
  col += texture(u_frame, coords + (vec2( 0.4,0.0 )*aspectcorrect) * dofblur*0.7);       
  col += texture(u_frame, coords + (vec2( 0.29,-0.29 )*aspectcorrect) * dofblur*0.7);   
  col += texture(u_frame, coords + (vec2( 0.0,-0.4 )*aspectcorrect) * dofblur*0.7);     
  col += texture(u_frame, coords + (vec2( -0.29,0.29 )*aspectcorrect) * dofblur*0.7);
  col += texture(u_frame, coords + (vec2( -0.4,0.0 )*aspectcorrect) * dofblur*0.7);     
  col += texture(u_frame, coords + (vec2( -0.29,-0.29 )*aspectcorrect) * dofblur*0.7);   
  col += texture(u_frame, coords + (vec2( 0.0,0.4 )*aspectcorrect) * dofblur*0.7);
                   
  col += texture(u_frame, coords + (vec2( 0.29,0.29 )*aspectcorrect) * dofblur*0.4);
  col += texture(u_frame, coords + (vec2( 0.4,0.0 )*aspectcorrect) * dofblur*0.4);       
  col += texture(u_frame, coords + (vec2( 0.29,-0.29 )*aspectcorrect) * dofblur*0.4);   
  col += texture(u_frame, coords + (vec2( 0.0,-0.4 )*aspectcorrect) * dofblur*0.4);     
  col += texture(u_frame, coords + (vec2( -0.29,0.29 )*aspectcorrect) * dofblur*0.4);
  col += texture(u_frame, coords + (vec2( -0.4,0.0 )*aspectcorrect) * dofblur*0.4);     
  col += texture(u_frame, coords + (vec2( -0.29,-0.29 )*aspectcorrect) * dofblur*0.4);   
  col += texture(u_frame, coords + (vec2( 0.0,0.4 )*aspectcorrect) * dofblur*0.4);       
                 
  out_Col = col/41.0;
  out_Col.a = 1.0;
}