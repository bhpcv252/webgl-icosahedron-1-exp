import ppVertexShader from './../shaders/ppvertex.glsl';
import ppFragmentShader from './../shaders/ppfragment.glsl';

import * as THREE from 'three';

const customPassShader = {

    uniforms: {

        tDiffuse: { value: null },
        uTime: { value: 0. },
        uResolution: { value: new THREE.Vector2(0, 0) },
        uMouse: { value: new THREE.Vector2(0, 0) },
        uMouseSpeed: {
            value: new THREE.Vector3(0,0,0)
        },
    },

    vertexShader: ppVertexShader,

    fragmentShader: ppFragmentShader

};

export { customPassShader };