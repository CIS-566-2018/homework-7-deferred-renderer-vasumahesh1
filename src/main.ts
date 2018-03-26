import {vec3, vec4} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Square from './geometry/Square';
import Mesh from './geometry/Mesh';
import OpenGLRenderer from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import {readTextFile} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import Texture from './rendering/gl/Texture';
import SpotLight from './lights/SpotLight';

// Define an object with application parameters and button callbacks
// const controls = {
//   // Extra credit: Add interactivity
// };

let square: Square;
let shouldCapture: boolean = false;

let controls = {
  saveImage: saveImage,
  dof: {
    focalLength: 10,
    blend: 1.0
  },
  tonemap: {
    enabled: true
  },
  bloom: {
    enabled: true,
    blend: 1.0
  }
};

let obj0: string;
let mesh0: Mesh;
let mesh1: Mesh;
let mesh2: Mesh;

let tex0: Texture;
let lights: Array<SpotLight> = [];

let meshes: Array<string> = [
  '../resources/obj/car_1.obj',
  '../resources/obj/car_2.obj',
  '../resources/obj/car_3.obj',
  '../resources/obj/bus.obj',
  '../resources/obj/road.obj'
];

let textures: any = [
  ['../resources/textures/car_1.png', '../resources/textures/car_1_emissive.png'],
  ['../resources/textures/car_2.png', '../resources/textures/car_2_emissive.png'],
  ['../resources/textures/car_3.png', '../resources/textures/car_2_emissive.png'],
  ['../resources/textures/bus.png', '../resources/textures/default_emissive.png'],
  ['../resources/textures/road.png', '../resources/textures/default_emissive.png']
];

let sceneOBJs: Array<string> = [];
let sceneMeshes: Array<Mesh> = [];
let sceneTextures: Array<Array<Texture>> = [];

var timer = {
  deltaTime: 0.0,
  startTime: 0.0,
  currentTime: 0.0,
  updateTime: function() {
    var t = Date.now();
    t = (t - timer.startTime) * 0.001;
    timer.deltaTime = t - timer.currentTime;
    timer.currentTime = t;
  },
}


function loadOBJText() {
  obj0 = readTextFile('../resources/obj/wahoo.obj');

  for (var itr = 0; itr < meshes.length; ++itr) {
    sceneOBJs.push(readTextFile(meshes[itr]));
  }
}

function createLights() {
  let targetSpotLight = new SpotLight();
  targetSpotLight.ambient = vec4.fromValues(0.07, 0.07, 0.07, 1);
  targetSpotLight.diffuse = vec4.fromValues(9.6, 8.9, 6.2, 1);
  targetSpotLight.specular = vec4.fromValues(0, 0, 0, 1);

  targetSpotLight.position = vec3.fromValues(1.8, -0.5, 1.3);
  // targetSpotLight.position = vec3.fromValues(0, 0, 0);
  targetSpotLight.range = 10;
  targetSpotLight.contrib = 2.0;

  targetSpotLight.direction = vec3.fromValues(1, 0, 0);
  vec3.normalize(targetSpotLight.direction, targetSpotLight.direction);
  targetSpotLight.kSpot = 16;

  targetSpotLight.attn = vec3.fromValues(1, 0, 0.25);

  lights.push(targetSpotLight);

  targetSpotLight = new SpotLight();
  targetSpotLight.ambient = vec4.fromValues(0.07, 0.07, 0.07, 1);
  targetSpotLight.diffuse = vec4.fromValues(9.6, 8.9, 6.2, 1);
  targetSpotLight.specular = vec4.fromValues(0, 0, 0, 1);

  targetSpotLight.position = vec3.fromValues(1.8, -0.5, 2.6);
  // targetSpotLight.position = vec3.fromValues(0, 0, 0);
  targetSpotLight.range = 10;
  targetSpotLight.contrib = 2.0;

  targetSpotLight.direction = vec3.fromValues(1, 0, 0);
  vec3.normalize(targetSpotLight.direction, targetSpotLight.direction);
  targetSpotLight.kSpot = 16;
  targetSpotLight.attn = vec3.fromValues(1, 0, 0.25);

  lights.push(targetSpotLight);
}

function loadScene() {
  square && square.destroy();
  mesh0 && mesh0.destroy();

  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();

  mesh0 = new Mesh(obj0, vec3.fromValues(0, 0, 0));
  mesh0.create();

  mesh1 = new Mesh(obj0, vec3.fromValues(-10, 0, -10));
  mesh1.create();

  mesh2 = new Mesh(obj0, vec3.fromValues(10, 0, 10));
  mesh2.create();

  createLights();

  for (var itr = 0; itr < sceneOBJs.length; ++itr) {   
    let mesh = new Mesh(sceneOBJs[itr], vec3.fromValues(0, 0, 0));
    mesh.create();

    sceneMeshes.push(mesh);
  }

  for (var itr = 0; itr < textures.length; ++itr) {
    let tex1 = new Texture(textures[itr][0]);
    let tex2 = new Texture(textures[itr][1]);
    sceneTextures.push([tex1, tex2]);
  }

  tex0 = new Texture('../resources/textures/wahoo.bmp')
}

function saveImage() {
  shouldCapture = true;
}

function downloadImage() {
  // Dump the canvas contents to a file.
  var canvas = <HTMLCanvasElement>document.getElementById("canvas");
  canvas.toBlob(function(blob) {
    var link = document.createElement("a");
    link.download = "image.png";

    link.href = URL.createObjectURL(blob);
    console.log(blob);

    link.click();

  }, 'image/png');
}


function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // Add controls to the gui
  const gui = new DAT.GUI();
  gui.add(controls, 'saveImage').name('Save Image');

  var group;

  group = gui.addFolder('Depth of Field');
  group.add(controls.dof, 'blend', 0, 1.0).step(0.05).name('Blend Amount').listen();
  group.add(controls.dof, 'focalLength', 0, 100.0).step(0.5).name('Focal Length').listen();

  group = gui.addFolder('Tonemap');
  group.add(controls.tonemap, 'enabled').name('Enabled').listen();

  group = gui.addFolder('Bloom');
  group.add(controls.bloom, 'blend', 0, 1.0).step(0.05).name('Blend Amount').listen();
  group.add(controls.bloom, 'enabled').name('Enabled').listen();

  // get canvas and webgl context
  const canvas = <HTMLCanvasElement> document.getElementById('canvas');
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 25), vec3.fromValues(0, 0, 0));

  const renderer = new OpenGLRenderer(canvas);
  renderer.setClearColor(0, 0, 0, 1);
  gl.enable(gl.DEPTH_TEST);

  const standardDeferred = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/standard-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/standard-frag.glsl')),
    ]);

  standardDeferred.setupTexUnits(["tex_Color", "emi_Color"]);

  renderer.deferredShader.setSpotLights(lights);

  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    timer.updateTime();
    renderer.updateTime(timer.deltaTime, timer.currentTime);

    // standardDeferred.bindTexToUnit("tex_Color", tex0, 0);

    renderer.deferredShader.setLightPosition(vec3.fromValues(15, 15, 15));

    renderer.clear();
    renderer.clearGB();

    // TODO: pass any arguments you may need for shader passes
    // forward render mesh info into gbuffers
    // renderer.renderToGBuffer(camera, standardDeferred, [mesh0, mesh1, mesh2]);
    renderer.renderToGBuffer(camera, standardDeferred, sceneMeshes, sceneTextures);
    // render from gbuffers into 32-bit color buffer
    renderer.renderFromGBuffer(camera);
    // apply 32-bit post and tonemap from 32-bit color to 8-bit color
    // renderer.renderPostProcessHDR();
    // // apply 8-bit post and draw
    // renderer.renderPostProcessLDR();

    renderer.renderPass_Bloom(controls.bloom);
    // renderer.renderPass_DOF(camera, controls.dof);
    renderer.renderPass_ToneMapping(controls.tonemap);
    
    renderer.renderPass_Present(camera);

    stats.end();

    if (shouldCapture) {
      downloadImage();
      shouldCapture = false;
    }

    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();

  // Start the render loop
  tick();
}


function setup() {
  timer.startTime = Date.now();
  loadOBJText();
  main();
}

setup();
