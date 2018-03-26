import Texture from './Texture';
import {gl} from '../../globals';
import ShaderProgram, {Shader} from './ShaderProgram';
import Drawable from './Drawable';
import Square from '../../geometry/Square';
import {vec2, vec3, vec4, mat4} from 'gl-matrix';

class PostProcess extends ShaderProgram {
	static screenQuad: Square = undefined; // Quadrangle onto which we draw the frame texture of the last render pass
	unifFrame: WebGLUniformLocation; // The handle of a sampler2D in our shader which samples the texture drawn to the quad
	name: string;

	unifLightPos: WebGLUniformLocation;
	unifDimensions: WebGLUniformLocation;

	dof_unifBlend: WebGLUniformLocation;
	dof_unifFocalLength: WebGLUniformLocation;

	gb_target0: WebGLUniformLocation;
	gb_target1: WebGLUniformLocation;
	gb_target2: WebGLUniformLocation;

	constructor(fragProg: Shader, tag: string = "default") {
		super([new Shader(gl.VERTEX_SHADER, require('../../shaders/screenspace-vert.glsl')),
			fragProg]);

		this.unifLightPos = gl.getUniformLocation(this.prog, "u_LightPos");
		this.unifDimensions = gl.getUniformLocation(this.prog, "u_Dimensions");
		this.unifFrame = gl.getUniformLocation(this.prog, "u_frame");
		this.gb_target0 = gl.getUniformLocation(this.prog, "u_gb0");
		this.gb_target1 = gl.getUniformLocation(this.prog, "u_gb1");
		this.gb_target2 = gl.getUniformLocation(this.prog, "u_gb2");

		this.dof_unifBlend = gl.getUniformLocation(this.prog, "u_DOF_Blend");
		this.dof_unifFocalLength = gl.getUniformLocation(this.prog, "u_DOF_Focal");

		this.use();
		this.name = tag;

		// bind texture unit 0 to this location
		gl.uniform1i(this.unifFrame, 0); // gl.TEXTURE0
		if (PostProcess.screenQuad === undefined) {
			PostProcess.screenQuad = new Square(vec3.fromValues(0, 0, 0));
			PostProcess.screenQuad.create();
		}
	}

	setLightPosition(light: vec3) {
    this.use();
    if (this.unifLightPos !== -1) {
      gl.uniform3fv(this.unifLightPos, light);
    }
  }

  setGBufferTarget0(buffer: number) {
    this.use();
    if (this.gb_target0 !== -1) {
      gl.uniform1i(this.gb_target0, buffer);
    }
  }

  setGBufferTarget1(buffer: number) {
    this.use();
    if (this.gb_target1 !== -1) {
      gl.uniform1i(this.gb_target1, buffer);
    }
  }

  setGBufferTarget2(buffer: number) {
    this.use();
    if (this.gb_target2 !== -1) {
      gl.uniform1i(this.gb_target2, buffer);
    }
  }

  setScreenSize(x:number, y:number) {
  	this.use();
    if (this.unifDimensions !== -1) {
      gl.uniform2i(this.unifDimensions, x, y);
    }
  }

  setPassParams_DOF(params: any) {
  	this.use();
    if (this.dof_unifBlend !== -1) {
      gl.uniform1f(this.dof_unifBlend, params.blend);
    }

    if (this.dof_unifFocalLength !== -1) {
      gl.uniform1f(this.dof_unifFocalLength, params.focalLength);
    }
  }

	draw() {
		super.draw(PostProcess.screenQuad);
	}

	getName() : string { return this.name; }

}

export default PostProcess;
