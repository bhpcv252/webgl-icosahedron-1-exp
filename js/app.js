import '../sass/style.scss';

import * as THREE from 'three';
import { EffectComposer } from 'three/examples/jsm/postprocessing/EffectComposer';
import { RenderPass } from 'three/examples/jsm/postprocessing/RenderPass';
import { ShaderPass } from 'three/examples/jsm/postprocessing/ShaderPass';
import { customPassShader } from './postprocessing';
import fShader from './../shaders/fragment.glsl';
import fEdgesShader from './../shaders/fragmentEdges.glsl';
import fPointsShader from './../shaders/fragmentPoints.glsl';
import vShader from './../shaders/vertex.glsl';

import image from './../images/1.png';

let mouseSpeed = new THREE.Vector3(0,0, 0);
let mousePosition = new THREE.Vector3(0,0, 0);

const canvasContainer = document.querySelector(".container");

const mouse = new THREE.Vector2();

const renderer = new THREE.WebGLRenderer({
    antialias: true
});
canvasContainer.appendChild(renderer.domElement);

const camera = new THREE.PerspectiveCamera(45, 1, 0.1, 10);
camera.position.set(0, 0, 4);
camera.lookAt(0, 0, 0);

const scene = new THREE.Scene();
const group = new THREE.Group();

const resolution = new THREE.Vector2();

const geometry = new THREE.IcosahedronGeometry( 1, 1);

const materialCover = new THREE.ShaderMaterial({
    extensions: {
        derivatives: "#extension GL_OES_standard_derivatives : enable",
    },
    uniforms: {
        uTime: {
            type: 'f',
            value: 0.
        },
        uResolution: {
            type: 'v2',
            value: resolution
        },
        uImage: {
            type: 't',
            value: new THREE.TextureLoader().load(image)
        },
        uMouseSpeed: {
            type: 'v3',
            value: mouseSpeed
        }
    },
    fragmentShader: fShader,
    vertexShader: vShader,
    //wireframe: true
});

const ico =  new THREE.Mesh(geometry, materialCover);
ico.position.set(0, 0, 0);

group.add(ico);

const icoBorder = new THREE.IcosahedronBufferGeometry(1, 1);
const vectors = [
    new THREE.Vector3( 1, 0, 0 ),
    new THREE.Vector3( 0, 1, 0 ),
    new THREE.Vector3( 0, 0, 1 )
];
const position = icoBorder.attributes.position;
const centers = new Float32Array(position.count * 3);

for(let i = 0, l = position.count; i < l; i++) {
    vectors[ i % 3 ].toArray(centers, i * 3);
}
icoBorder.setAttribute('aCenter', new THREE.BufferAttribute(centers, 3));

const materialBorder = new THREE.ShaderMaterial({
    extensions: {
        derivatives: "#extension GL_OES_standard_derivatives : enable",
    },
    uniforms: {
        uTime: {
            type: 'f',
            value: 0.
        },
        uResolution: {
            type: 'v2',
            value: resolution
        },
        uImage: {
            type: 't',
            value: new THREE.TextureLoader().load(image)
        },
        uMouseSpeed: {
            type: 'v3',
            value: mouseSpeed
        }
    },
    fragmentShader: fEdgesShader,
    vertexShader: vShader,
    alphaToCoverage: true
});

const icoEdge =  new THREE.Mesh(icoBorder, materialBorder);
icoEdge.position.set(0, 0, 0);
icoEdge.scale.set(1.001, 1.001, 1.001);

group.add(icoEdge);

scene.add(group);

const composer = new EffectComposer( renderer );

const renderPass = new RenderPass(scene, camera);
composer.addPass(renderPass);

const customPass = new ShaderPass(customPassShader);
customPass.renderToScreen = true;
composer.addPass(customPass);


/*const light = new THREE.DirectionalLight(0xffffff, 1);
light.position.set(-1, 2, 4);
scene.add(light);*/

let then = 0;
requestAnimationFrame(animate);
function animate(now) {
    now *= .001;
    const deltaTime = now - then;
    then = now;

    mousePosition.x += mouseSpeed.x;
    mousePosition.y += mouseSpeed.y;
    mousePosition.z += mouseSpeed.z;
    mouseSpeed.x *= 0.97;
    mouseSpeed.y *= 0.97;
    mouseSpeed.z *= 0.97;

    if(resizeCanvas(renderer)) {
        const canvas = renderer.domElement;
        camera.aspect = canvas.clientWidth / canvas.clientHeight;
        camera.updateProjectionMatrix();
        composer.setSize(canvas.width, canvas.height);
    }

    materialCover.uniforms.uTime.value = now;
    materialCover.uniforms.uResolution.value = resolution;
    materialCover.uniforms.uMouseSpeed.value = mouseSpeed;

    materialBorder.uniforms.uTime.value = now;
    materialBorder.uniforms.uResolution.value = resolution;
    materialBorder.uniforms.uMouseSpeed.value = mouseSpeed;

    customPass.uniforms.uTime.value = now;
    customPass.uniforms.uResolution.value = resolution;
    customPass.uniforms.uMouse.value = mouse;
    customPass.uniforms.uMouseSpeed.value = mouseSpeed;


    group.rotation.set(now*0.1 + mousePosition.y*0.1, now*0.1 + mousePosition.x*0.1, 0);
    //renderer.render(scene, camera);
    composer.render(deltaTime);

    requestAnimationFrame(animate);
}

function resizeCanvas(renderer) {
    const canvas = renderer.domElement;
    const pixelRatio = window.devicePixelRatio;
    const width = canvas.clientWidth * pixelRatio | 0;
    const height = canvas.clientHeight * pixelRatio | 0;
    const needResize = canvas.width !== width || canvas.height !== height;
    if(needResize) {
        renderer.setSize(width, height, false);
        resolution.set(width, height);
    }
    return needResize;
}

window.addEventListener( 'mousemove', onMouseMove, false );

const lastMousePos = new THREE.Vector2(0,0);
function onMouseMove( event ) {
    mouseSpeed.x += (event.clientX - lastMousePos.x) * 0.002;
    mouseSpeed.y += (event.clientY - lastMousePos.y) * 0.002;
    mouseSpeed.z += Math.sqrt(((event.clientX - lastMousePos.x)**2) + ((event.clientY - lastMousePos.y)**2)) * 0.002;
    lastMousePos.x = event.clientX;
    lastMousePos.y = event.clientY;

    mouse.x = ( event.clientX / window.innerWidth ) - 0.5;
    mouse.x *= resolution.x/resolution.y;
    mouse.y = - ( event.clientY / window.innerHeight ) + 0.5;
}
