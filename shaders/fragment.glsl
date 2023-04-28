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
uniform vec3 uMouseSpeed;

float rand(vec2 co, float s){
    float PHI = 1.61803398874989484820459;
    return fract(tan(distance(co*PHI, co)*s)*co.x);
}

vec2 H12(float s) {
    float x = rand(vec2(243.234,63.834), s);
    float y = rand(vec2(53.1434,13.1234), s);
    return vec2(x, y);
}

void main() {
    vec2 uv = gl_FragCoord.xy/uResolution;
    vec3 x = dFdx(vFixNormal);
    vec3 y = dFdy(vFixNormal);
    vec3 norm = normalize(cross(x, y));
    float diff = dot(norm, vec3(0., 0., 2.));

    float fres = pow(dot(eyeVector, norm), 3.);

    vec2 rand = H12(floor(diff));

    rand = smoothstep(0.3, 0.35, rand);

    float eta = (1. - 0.2*uMouseSpeed.z*rand.x) - 0.09;

    vec3 refracted = refract(eyeVector, norm, eta);
    uv = uv * 0.9 + refracted.xy;

    vec4 image = texture(uImage, uv);
    gl_FragColor = image * vec4(fres);
}
