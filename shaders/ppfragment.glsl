varying vec2 vUv;

uniform sampler2D tDiffuse;
uniform float uTime;
uniform vec2 uResolution;
uniform vec2 uMouse;
uniform vec3 uMouseSpeed;

float rand(vec2 co, float s){
    float PHI = 1.61803398874989484820459;
    return fract(tan(distance(co*PHI, co)*s)*co.x);
}

vec3 mod289(vec3 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 mod289(vec4 x) {
    return x - floor(x * (1.0 / 289.0)) * 289.0;
}

vec4 permute(vec4 x) {
    return mod289(((x*34.0)+1.0)*x);
}

vec4 taylorInvSqrt(vec4 r)
{
    return 1.79284291400159 - 0.85373472095314 * r;
}

float snoise(vec3 v)
{
    const vec2  C = vec2(1.0/6.0, 1.0/3.0) ;
    const vec4  D = vec4(0.0, 0.5, 1.0, 2.0);

    // First corner
    vec3 i  = floor(v + dot(v, C.yyy) );
    vec3 x0 =   v - i + dot(i, C.xxx) ;

    // Other corners
    vec3 g = step(x0.yzx, x0.xyz);
    vec3 l = 1.0 - g;
    vec3 i1 = min( g.xyz, l.zxy );
    vec3 i2 = max( g.xyz, l.zxy );

    //   x0 = x0 - 0.0 + 0.0 * C.xxx;
    //   x1 = x0 - i1  + 1.0 * C.xxx;
    //   x2 = x0 - i2  + 2.0 * C.xxx;
    //   x3 = x0 - 1.0 + 3.0 * C.xxx;
    vec3 x1 = x0 - i1 + C.xxx;
    vec3 x2 = x0 - i2 + C.yyy; // 2.0*C.x = 1/3 = C.y
    vec3 x3 = x0 - D.yyy;      // -1.0+3.0*C.x = -0.5 = -D.y

    // Permutations
    i = mod289(i);
    vec4 p = permute( permute( permute(
    i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
    + i.y + vec4(0.0, i1.y, i2.y, 1.0 ))
    + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));

    // Gradients: 7x7 points over a square, mapped onto an octahedron.
    // The ring size 17*17 = 289 is close to a multiple of 49 (49*6 = 294)
    float n_ = 0.142857142857; // 1.0/7.0
    vec3  ns = n_ * D.wyz - D.xzx;

    vec4 j = p - 49.0 * floor(p * ns.z * ns.z);  //  mod(p,7*7)

    vec4 x_ = floor(j * ns.z);
    vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)

    vec4 x = x_ *ns.x + ns.yyyy;
    vec4 y = y_ *ns.x + ns.yyyy;
    vec4 h = 1.0 - abs(x) - abs(y);

    vec4 b0 = vec4( x.xy, y.xy );
    vec4 b1 = vec4( x.zw, y.zw );

    //vec4 s0 = vec4(lessThan(b0,0.0))*2.0 - 1.0;
    //vec4 s1 = vec4(lessThan(b1,0.0))*2.0 - 1.0;
    vec4 s0 = floor(b0)*2.0 + 1.0;
    vec4 s1 = floor(b1)*2.0 + 1.0;
    vec4 sh = -step(h, vec4(0.0));

    vec4 a0 = b0.xzyw + s0.xzyw*sh.xxyy ;
    vec4 a1 = b1.xzyw + s1.xzyw*sh.zzww ;

    vec3 p0 = vec3(a0.xy,h.x);
    vec3 p1 = vec3(a0.zw,h.y);
    vec3 p2 = vec3(a1.xy,h.z);
    vec3 p3 = vec3(a1.zw,h.w);

    //Normalise gradients
    vec4 norm = taylorInvSqrt(vec4(dot(p0,p0), dot(p1,p1), dot(p2, p2), dot(p3,p3)));
    p0 *= norm.x;
    p1 *= norm.y;
    p2 *= norm.z;
    p3 *= norm.w;

    // Mix final noise value
    vec4 m = max(0.5 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
    m = m * m;
    return 105.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1),
    dot(p2,x2), dot(p3,x3) ) );
}

float sNoise(vec3 uv) {
    float n = 0.;

    int oct = 5;
    float freq[5] = float[](1., 2., 3., 5., 7.);
    float amp[5] = float[](1., .5, .25, .125, .075);

    float nf = 0.;

    for(int i = 0; i < oct; i++) {

        n += snoise(uv*freq[i])*amp[i];
        nf += amp[i];
    }

    return (n/nf);
}

float C( vec2 uv, vec2 pos, float rad, float blur ) {
    return smoothstep(rad, rad-blur, length(uv-pos));
}

void main(){
    vec2 lv = vUv;
    float t = uTime*0.1;

    lv.x += cos(vUv.y + uTime * 0.01);
    lv.y += - cos(uTime) * 0.01 - sin(uTime * .0001) * .01;

    vec2 cuv = vUv;
    cuv -= .5;
    cuv.x *= uResolution.x/uResolution.y;

    vec2 mo = uMouse.xy;

    vec2 rgbShift = vec2(0.01, 0.01)*uMouseSpeed.z*0.5;

    vec4 originalImage = texture2D(tDiffuse, vUv);
    vec4 originalImageRightShift = texture2D(tDiffuse, vUv - rgbShift);
    vec4 originalImageLeftShift = texture2D(tDiffuse, vUv + rgbShift);

    vec4 originalImageColor = vec4(originalImageLeftShift.r, originalImage.g, originalImageRightShift.b, originalImage.a);

    vec4 bwImage = originalImage;
    bwImage.rgb = vec3((originalImage.r + originalImage.g + originalImage.b)/9.);
    bwImage.a = originalImage.a;

    vec4 bwImageRightShift = originalImageRightShift;
    bwImageRightShift.rgb = vec3((originalImageRightShift.r + originalImageRightShift.g + originalImageRightShift.b)/9.);
    bwImageRightShift.a = originalImageRightShift.a;

    vec4 bwImageLeftShift = originalImageLeftShift;
    bwImageLeftShift.rgb = vec3((originalImageLeftShift.r + originalImageLeftShift.g + originalImageLeftShift.b)/9.);
    bwImageLeftShift.a = originalImageLeftShift.a;

    vec4 bwImageColor = vec4(bwImageLeftShift.r, bwImage.g, bwImageRightShift.b, bwImage.a);

    vec3 n = vec3(sNoise(vec3(lv*20., t)) + 0.5);
    vec3 m = vec3(C(cuv, (mo-0.025)+n.xy*0.05, 0.15, 0.01));

    vec4 finalImage = mix(bwImageColor, originalImageColor, m.x);


    vec3 noise = vec3(  rand(gl_FragCoord.xy, fract(uTime)+1.0)*0.12,
                        rand(gl_FragCoord.xy*20., fract(uTime)+1.0)*0.12,
                        rand(gl_FragCoord.xy*30., fract(uTime)+1.0)*0.12 );

    gl_FragColor = finalImage + vec4(noise, 1.);
}