varying vec2 vUv;
varying vec3 vPosition;
varying vec3 vModPosition;
varying vec3 vNormal;
varying vec3 vFixNormal;
varying vec3 eyeVector;
varying vec3 vCenter;

uniform float uTime;
uniform vec2 uResolution;
uniform sampler2D uImage;

void main() {

    float width = 1.8;

    vec3 afwidth = fwidth(vCenter.xyz);
    vec3 edge3 = smoothstep((width - 1.) * afwidth, width * afwidth, vCenter.xyz);

    float edge = 1. - min(min(edge3.x, edge3.y), edge3.z);

    if ( edge < 0.4 ) discard;

    vec3 col = mix(vec3(0.), vec3(1.), edge);

    gl_FragColor = vec4(col, edge);
}
