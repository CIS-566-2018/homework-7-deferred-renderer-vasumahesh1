#version 300 es
precision highp float;

#define EPS 0.0001
#define PI 3.1415962

in vec2 fs_UV;
out vec4 out_Col;

uniform sampler2D u_gb0;
uniform sampler2D u_gb1;
uniform sampler2D u_gb2;

uniform float u_Time;

uniform vec3 u_LightPos;

uniform mat4 u_View;
uniform vec4 u_CamPos;


vec4 calculateLighting(vec4 inputColor, vec3 normal) {
  float alpha = inputColor.a;
  
  // Initialize outputs.
  vec4 ambient = vec4(0.0f, 0.0f, 0.0f, 0.0f);
  vec4 diffuse = vec4(0.0f, 0.0f, 0.0f, 0.0f);
  vec4 spec    = vec4(0.0f, 0.0f, 0.0f, 0.0f);

  // The vector from the surface to the light.
  vec3 lightVec = normalize(u_LightPos); // Directional Light
  
  // Ambient term.
  ambient = vec4(vec3(0.2), 1);

  // Add diffuse and specular term
  float diffuseTerm = dot(lightVec, normal);

  if( diffuseTerm > 0.0f ) {
    vec3 v         = reflect(-lightVec, normal);
    float specFactor = pow(max(dot(v, normalize(vec3(u_CamPos))), 0.0f), 128.0);
          
    diffuse = diffuseTerm * vec4(1.0); // TODO: pass light color
    spec    = specFactor * vec4(1.0); // TODO: pass light color
  }

  vec4 totalLightContrib = diffuse + spec + ambient;

  inputColor = inputColor * totalLightContrib;
  // inputColor = (inputColor * diffuse) + spec + ambient;

  inputColor.a = alpha;

  return inputColor;
}

void main() { 
	// read from GBuffers

  vec4 gb0 = texture(u_gb0, fs_UV);
  vec4 gb1 = texture(u_gb1, fs_UV);
	vec4 gb2 = texture(u_gb2, fs_UV);

  vec3 normal = gb0.xyz;
  float cameraDepth = gb0.w;

	vec4 diffuseColor = gb2;
  vec4 worldPosition = gb1;

  vec4 finalColor = calculateLighting(diffuseColor, normal);

	out_Col = finalColor;
}