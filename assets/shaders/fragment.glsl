#version 300 es
precision highp float;
precision highp int;
out vec4 outColor;

#define PI 3.14159265359
//Common
uniform float time;
uniform vec2 resolution;
uniform int scene;
uniform float alpha;
uniform float oldTV;
uniform float interfereFrequency;
uniform float interfereAmplitude;
uniform float interfereToggle;
uniform float interfereTime;
uniform float interfereTrail;
uniform vec3 interfereColor;

//Logo
uniform float logoWaves;
uniform float logoSpeed;
uniform float logoAmplitude;
uniform sampler2D logo;
uniform vec2 logoPosition;

//Scope
uniform float scopeFrequency;
uniform float scopeAmplitude;
uniform float scopeSpeed;
uniform float scopeTrail;
uniform vec3 scopeColor;

//Logo and scope
uniform float scopeAndLogo;

//Raymarching camera
uniform vec3 rayCameraPosition;
uniform vec3 rayCameraLookAt;
uniform vec3 lightPosition;
uniform float rayMaxSteps;
uniform float rayThreshold;

//Skulls 
uniform sampler2D gallo;
uniform sampler2D prevFrame;

//scene 1
uniform float scene1Rotation;
uniform float scene1Detail;
uniform vec2 scene1Modifier;

//scene 2
uniform float scene2Fractal;
uniform float scene2Torus;
uniform vec3 scene2Position;
uniform float scene2Union;

//scene 3
uniform vec3 scene3Rotation;

//scene 4
uniform vec3 scene4BulbPosition;
uniform vec3 scene4BulbRotation;
uniform vec2 scene4BulbDetail;
uniform float scene4BulbBorder;
//scene 5
uniform vec4 scene5Detail;

//scene 6
uniform float scene6Rotation;
uniform float scene6Balls;

uniform vec4 bulb;
uniform vec4 box;

uniform sampler2D bogdan;

struct Hit {
    vec3 normal;
    bool normalPresent;
    vec3 path;
    vec3 mutilatedPath;
    float steps;
    float dist;
    float shadow;
    float last;
    float centerDist;
    int id;
};

struct March {
    float dist;
    float centerDist;
    vec3 mutilatedPath;
    int id;
};

struct ShadeParameters {
    vec3 baseColor;
    vec3 ambientColor;
    float ambientStrength;
    vec3 diffuseColor;
    float diffuseStrength;
    vec3 specularColor;
    float specularStrength;
    float specularHardness;
    float shadowHardness;
    float fogDistance;
    vec3 color1;
    vec3 color2;
    vec3 color3;

};


 ShadeParameters shadeParameters[8] = ShadeParameters[8](
     //tunnel scene 1
    ShadeParameters(vec3(0.1, 0.2, 0.5),
    vec3(0.5, 0.5, 0.5), 5.5,
    vec3(0.5, 0.5, 0.5), 5.07,
    vec3(1.0, 1.0, 1.0), 2.00, 32.0,
    0.0, 0.0,
    vec3(42.0 / 255.0, 60.0 / 255.0, 36.0 / 255.0), vec3(3.0 / 255.0, 0.0 / 255.0, 39.0 / 255.0), vec3(0.1, 0.2, 0.5)),
    //Donut scene 2
    ShadeParameters(vec3(0.3, 0.8, 0.5),
    vec3(0.5, 0.5, 0.5), 1.5,
    vec3(0.5, 0.5, 0.5), 10.2,
    vec3(1.0, 1.0, 1.0), 10.3, 64.0,
    1.0, 0.0,
    vec3(0.3, 0.8, 0.5), vec3(0.1, 0.2, 0.5), vec3(0.1, 0.2, 0.5)),
    //Mengel scene 3
    ShadeParameters(vec3(0.9, 0.2, 0.9),
    vec3(0.5, 0.5, 0.5), 5.5,
    vec3(0.5, 0.5, 0.5), 5.07,
    vec3(1.0, 1.0, 1.0), 0.03, 32.0,
    0.0, 0.0,
    vec3(0.1, 0.2, 0.9), vec3(0.1, 0.2, 0.1), vec3(0.1, 0.2, 0.5)),
    //Sponge scene 4
    ShadeParameters(vec3(0.2, 0.8, 0.2),
    vec3(0.5, 0.5, 0.5), 1.5,
    vec3(0.5, 0.5, 0.5), 1.007,
    vec3(1.0, 1.0, 1.0), 1.3,32.0,
    1.0, 0.0,
    vec3(0.2, 0.8, 0.2), vec3(0.1, 0.2, 0.5), vec3(0.1, 0.2, 0.5)),
    //Mandelcube scene 5
    ShadeParameters(vec3(0.0, 0.5, 0.5),
    vec3(0.5, 0.5, 0.5), 2.5,
    vec3(0.0, 1.0, 0.0), 0.0,
    vec3(1.0, 1.0, 1.0), 1.0, 2.0,
    0.0, 0.0,
    vec3(0.1, 0.1, 0.5), vec3(0.1, 0.2, 0.5), vec3(0.1, 0.2, 0.5)),
    //Bouncing balls scene 6
    ShadeParameters(vec3(0.1, 0.5, 0.3),
    vec3(0.5, 0.5, 0.5), 0.5,
    vec3(0.5, 0.5, 0.5), 1.3,
    vec3(1.0, 1.0, 1.0), 1.0, 32.0,
    50.0, 70.0,
    vec3(0.9, 0.5, 0.3), vec3(0.1, 0.2, 0.5), vec3(0.9, 0.9, 0.5)),
     //textured cube scene 7
    ShadeParameters(vec3(0.1, 0.0, 0.8),
    vec3(0.5, 0.5, 0.5), 0.5,
    vec3(0.5, 0.0, 0.0), 1.3,
    vec3(1.0, 1.0, 1.0), 10.0, 32.0,
    1.0, 0.0,
    vec3(0.1, 0.1, 0.8), vec3(0.1, 0.2, 0.5), vec3(0.1, 0.2, 0.5)),
    //logo scene 8
    ShadeParameters(vec3(0.1, 0.0, 0.8),
    vec3(0.5, 0.5, 0.5), 2.5,
    vec3(0.5, 0.5, 0.5), 5.3,
    vec3(1.0, 1.0, 1.0), 1.0, 32.0,
    1.0, 0.0,
    vec3(0.1, 0.1, 0.8), vec3(0.1, 0.2, 0.5), vec3(0.1, 0.2, 0.5))
); 

//Source http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
float opSmoothUnion( float d1, float d2, float k ) {
    float h = clamp( 0.5 + 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) - k*h*(1.0-h);
}

float opSmoothSubtraction( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2+d1)/k, 0.0, 1.0 );
    return mix( d2, -d1, h ) + k*h*(1.0-h);
}

float opSmoothIntersection( float d1, float d2, float k ) {
    float h = clamp( 0.5 - 0.5*(d2-d1)/k, 0.0, 1.0 );
    return mix( d2, d1, h ) + k*h*(1.0-h);
}

vec3 opTwist(vec3 p, float angle)
{
    float c = cos(angle * p.y);
    float s = sin(angle * p.y);
    mat2 m = mat2(c, -s, s, c);
    vec3 q = vec3(m * p.zx, p.y);
    return q;
}

vec3 opBend(vec3 p, float angle)
{
    float c = cos(angle * p.y);
    float s = sin(angle * p.y);
    mat2 m = mat2(c, -s, s, c);
    vec3 q = vec3(m * p.xy, p.z);
    return q;
}

float opRound(float p, float rad)
{
    return p - rad;
}

//Distance functions to creat primitives to 3D world
//Source http://www.iquilezles.org/www/articles/distfunctions/distfunctions.htm
float sdPlane(vec3 p, vec3 pos, vec4 n)
{
  // n must be normalized
    vec3 p1 = vec3(p) + pos;
    return dot(p1, n.xyz) + n.w;
}

float sdSphere(vec3 p, vec3 pos, float radius)
{
    vec3 p1 = vec3(p) + pos;
    return length(p1) - radius;
}

float sdEllipsoid(vec3 p, vec3 pos, vec3 r)
{
    vec3 p1 = p + pos;
    float k0 = length(p1 / r);
    float k1 = length(p1 / (r * r));
    return k0 * (k0 - 1.0) / k1;
}

float sdBox(vec3 p, vec3 pos, vec3 b)
{   
    vec3 p1 = vec3(p) + pos;
    vec3 d = abs(p1) - b;
    return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdTorus(vec3 p, vec3 pos, vec2 t)
{   
    vec3 p1 = vec3(p) + pos;
    vec2 q = vec2(length(p1.xz)-t.x,p1.y);
    return length(q)-t.y;
}

float sdCylinder(vec3 p, vec3 pos, vec3 c )
{
    vec3 p1 = p + pos;
    return length(p1.xz - c.xy) - c.z;
}

float sdRoundCone( in vec3 p, vec3 pos,in float r1, float r2, float h)
{    
    vec3 p1 = vec3(p) + pos;
    vec2 q = vec2( length(p1.xz), p1.y );
    
    float b = (r1-r2)/h;
    float a = sqrt(1.0-b*b);
    float k = dot(q,vec2(-b,a));
    
    if( k < 0.0 ) return length(q) - r1;
    if( k > a*h ) return length(q-vec2(0.0,h)) - r2;
        
    return dot(q, vec2(a,b) ) - r1;
}

float sdCapsule( vec3 p, vec3 pos, vec3 a, vec3 b, float r)
{   
    vec3 p1 = vec3(p) + pos;
    vec3 pa = p1 - a, ba = b - a;
    float h = clamp( dot(pa,ba)/dot(ba,ba), 0.0, 1.0 );
    return length( pa - ba*h ) - r;
}

float sdHexPrism(vec3 p, vec3 pos, vec2 h)
{
    vec3 p1 = p + pos;
    vec3 q = abs(p1);
    return max(q.z-h.y,max((q.x*0.866025+q.y*0.5),q.y)-h.x);
}

float sdFractal(vec3 p, vec3 pos, vec3 size, int iter)
{
    vec3 p1 = p + pos;
    float r;
    float scale = size.x;
    float offset = size.y;
    int n = 0;
    for(int i = 0; i < iter; i++) {
        if(p1.x + p1.y < 0.0) p1.xy = -p1.yx; // fold 1
        if(p1.x + p1.z < 0.0) p1.xz = -p1.zx; // fold 2
        if(p1.y + p1.z < 0.0) p1.zy = -p1.yz; // fold 3 
        p1 = p1 * scale - offset * (scale - 1.0);
        n++;
    }

    return (length(p1)) * pow(scale, -float(n));
}

float sdMandleBox(vec3 path, vec3 pos, float size, float scale, float minrad, float limit, float c)
{
    const int Iterations = 14;
    const float FoldingLimit = 20.0;

    vec4 scalev = vec4(size) / minrad;
    float AbsScalem1 = abs(scale - 1.0);
    float AbsScaleRaisedTo1mIters = pow(abs(scale), float(1 - Iterations));
   vec4 p = vec4(path, 1.0), p0 = p;  // p.w is the distance estimate
   
   for (int i=0; i<Iterations; i++)
   {
      p.xyz = clamp(p.xyz, -limit, limit) * c - p.xyz;
      float r2 = dot(p.xyz, p.xyz);
      p *= clamp(max(minrad / r2, minrad), 0.19, 4.0);
      p = p * scalev + p0;
      if (r2>FoldingLimit) break;
   }
   return ((length(p.xyz) - AbsScalem1) / p.w - AbsScaleRaisedTo1mIters);
}

float sdMandlebulb(vec3 p, vec3 pos, float pwr, float dis, float bail, int it) {
    vec3 z = p + pos;
 
    float dr = 1.0;
    float r = 0.0;
    float power = pwr + dis;
    for (int i = 0; i < it; i++) {
        r = length(z);
        if (r > bail) break;
        
        // convert to polar coordinates
        float theta = acos(z.z/r);
        float phi = atan(z.y,z.x);
        dr =  pow(r, power - 1.0) * power * dr + 1.0;
        
        // scale and rotate the point
        float zr = pow(r, power);
        theta = theta*power;
        phi = phi*power;
        
        // convert back to cartesian coordinates
        z = zr*vec3(sin(theta)*cos(phi), sin(phi)*sin(theta), cos(theta));
        
        z += (p + pos);
    }
    return (0.5 * log(r) * r / dr);
}

float displacement(vec3 p, vec3 m)
{
    return sin(m.x*p.x)*sin(m.y*p.y)*sin(m.z*p.z);
}

float impulse(float x, float k)
{
    float h = k * x;
    return h * exp(1.0 - h);
}


float sinc(float x, float k)
{
    float a = PI * k * x - 1.0;
    return sin(a) / a;
}

float hash(vec3 p)  // replace this by something better
{
    p  = 50.0*fract( p*0.3183099 + vec3(0.71,0.113,0.419));
    return -1.0+2.0*fract( p.x*p.y*p.z*(p.x+p.y+p.z) );
}


float fbm(vec3 p, int octaves) {
    vec3 p1 = p;
    float h = 0.0, a = 1.0;    
    for (int i = 0; i < octaves; ++i) {
        h += 1.0-abs(a * hash(p1)); // ridged perlin noise
        a *= 0.45; p1 *= 2.02;
    }        
    return h;
}

float sinusoidalPlasma(in vec3 p, float t, vec3 a, float c){

    return sin(p.x + t * a.x) * cos(p.y + t * a.y) * sin(p.z + t * a.z) * c;
}

vec3 rotX(vec3 p, float a)
{
    float s = sin(a);
    float c = cos(a);
    return vec3(
        p.x,
        c*p.y-s*p.z,
        s*p.y+c*p.z
    );
}

vec3 rotY(vec3 p, float a)
{
    float s = sin(a);
    float c = cos(a);
    return vec3(
        c*p.x+s*p.z,
        p.y,
        -s*p.x+c*p.z
    );
}
 

vec3 rotZ(vec3 p, float a)
{
    float s = sin(a);
    float c = cos(a);
    return vec3(
        c*p.x-s*p.y,
        s*p.x+c*p.y,
        p.z
    );
}

vec3 repeat(vec3 p, vec3 c) {
    vec3 path1 = mod(p, c) - 0.5 * c;
    return path1;
}

float sdCross(vec3 path, vec3 pos, vec3 l, vec3 t) {
    vec3 p1 = path + pos;
    float d1 = sdBox(p1, vec3(0.0), vec3(t.x, t.y, l.z));
    float d2 = sdBox(p1, vec3(0.0), vec3(l.x, t.y, t.z));
    float d3 = sdBox(p1, vec3(0.0), vec3(t.x, l.y, t.z));
    return min(d1, min(d2, d3));
}


float sdMenger(vec3 path, vec3 pos, int depth, float factor) {
    vec3 p1 = path + pos;

    float b = sdBox(p1, vec3(0.0), vec3(1.0, 1.0, 1.0));
    float s = 1.0;
    for(int i = 0; i < depth; i++) {
        
        vec3 a = mod(p1 * s, 2.0) - 1.0;
        s *= factor;
        
        vec3 r = 1.0 - factor * abs(a);
        float c = sdCross(r, vec3(0.0), vec3(6.0, 6.0, 6.0), vec3(1.0, 1.0, 1.0)) / s;
        b = max(b, c);
    }
    return b;
}

// KIRJAIN FUNKTIOT
// LETTER FUNCTIONS IN ALPHAPETIC ORDER
// p = path, pos = position of lettter, r = rotation (not used), s = scale (not used)
/*
float letterA(vec3 p, vec3 pos, vec3 r, float s) {
    float h1 = sdBox(rotY((p + pos), -0.3), vec3(0.0), vec3(0.05, 0.0, 1.0));
    float h2 = opRound(h1, 0.5);
    float h3 = sdBox(rotY((p + pos - vec3(0.7, 0.0, 0.0)), 0.3), vec3(0.0), vec3(0.05, 0.0, 1.0));
    float h4 = opRound(h3, 0.5);
    return opSmoothUnion(h2, h4, 0.1);
}
 
float letterC(vec3 p, vec3 pos, vec3 r, float s) {
    float torus = sdTorus(p, pos, vec2(1.0, 0.5));
    float box = sdBox(p, pos - vec3(1.0, 0.0, 0.0), vec3(0.5, 0.5, 0.3));
    float cletter = opSmoothSubtraction(box, torus, 0.3);
    return cletter;
}
 
float letterD(vec3 p, vec3 pos, vec3 r, float s) {
    float d1 = sdBox(p, pos + vec3(0.5, 0.0, 0.0), vec3(0.05, 0.0, 1.0));
    float d2 = opRound(d1, 0.5);
    float torus2 = sdTorus(p, pos, vec2(1.0, 0.5));
    float box2 = sdBox(p, pos + vec3(1.5, 0.0, 0.0), vec3(0.9, 1.0, 1.5));
    float cletter2 = opSmoothSubtraction(box2, torus2, 0.2);    
    return opSmoothUnion(cletter2, d2, 0.1);
}
 
float letterE(vec3 p, vec3 pos, vec3 r, float s) {
    float e3 = sdBox(p, pos, vec3(0.05, 0.0, 1.0));
    float e4 = opRound(e3, 0.5);
    float e5 = sdBox(p, pos - vec3(0.6, 0.0, 1.0), vec3(0.5, 0.0, 0.0));
    float e6 = opRound(e5, 0.5);
    float e7 = opSmoothUnion(e4, e6, 0.1);
    float e8 = sdBox(p, pos - vec3(0.6, 0.0, 0.0), vec3(0.5, 0.0, 0.0));
    float e9 = opRound(e8, 0.5);
    float e10 = opSmoothUnion(e7, e9, 0.1);
    float e11 = sdBox(p, pos - vec3(0.6, 0.0, -1.0), vec3(0.5, 0.0, 0.0));
    float e12 = opRound(e11, 0.5);
    return opSmoothUnion(e10, e12, 0.1);
}
 
float letterF(vec3 p, vec3 pos, vec3 r, float s) {
    float l1 = sdBox(p, pos, vec3(0.05, 0.0, 1.0));
    float l2 = opRound(l1, 0.5);
    float l3 = sdBox(p, pos - vec3(0.75, 0.0, 1.0), vec3(0.5, 0.0, 0.0));
    float l4 = opRound(l3, 0.5);
    float l5 = sdBox(p, pos - vec3(0.75, 0.0, 0.0), vec3(0.3, 0.0, 0.0));
    float l6 = opRound(l5, 0.5);
    float l7 = opSmoothUnion(l2, l4, 0.1);
   
    return opSmoothUnion(l6, l7, 0.1);
}
// G needs fixing
float letterG(vec3 p, vec3 pos, vec3 r, float s) {
    float torus = sdTorus(p, pos, vec2(1.0, 0.5));
    float box = sdBox(p, pos - vec3(1.0, 0.0, 1.0), vec3(0.7, 0.7, 0.7));
    float cletter = opSmoothSubtraction(box, torus, 0.3);
    float g1 = sdBox(p, pos - vec3(0.7, 0.0, 0.0), vec3(0.3, 0.0, 0.0));
    float g2 = opRound(g1, 0.5);
    float g3 = opSmoothUnion(cletter, g2, 0.1);
    return g3;
}
 
float letterH(vec3 p, vec3 pos, vec3 r, float s) {
    float h1 = sdBox(p, pos, vec3(0.05, 0.0, 1.0));
    float h2 = opRound(h1, 0.5);
    float h3 = sdBox(p, pos - vec3(1.5, 0.0, 0.0), vec3(0.05, 0.0, 1.0));
    float h4 = opRound(h3, 0.5);
    float h5 = sdBox(p, pos - vec3(0.75, 0.0, 0.0), vec3(0.5, 0.0, 0.0));
    float h6 = opRound(h5, 0.5);
    float h7 = opSmoothUnion(h6, h4, 0.1);
    float h8 = opSmoothUnion(h2, h7, 0.1);
    return h8;
}
 
float letterI(vec3 p, vec3 pos, vec3 r, float s) {          
    float h1 = sdBox(p, pos, vec3(0.05, 0.0, 1.0));
    return opRound(h1, 0.5);
}
 
float letterJ(vec3 p, vec3 pos, vec3 r, float s) {
    float d3 = sdBox(p, pos + vec3(-1.0, 0.0, -0.3), vec3(0.05, 0.0, 0.6));
    float d4 = opRound(d3, 0.5);
    float torus2 = sdTorus(p, pos, vec2(1.0, 0.5));
    float box2 = sdBox(p, pos + vec3(-1.5, 0.0, 1.4), vec3(2.0, 1.0, 1.5));
    float cletter2 = opSmoothIntersection(box2, torus2, 0.2);
    return opSmoothUnion(cletter2, d4, 0.1);
    //return cletter2;
}
 
float letterL(vec3 p, vec3 pos, vec3 r, float s) {    
    float l1 = sdBox(p, pos, vec3(0.05, 0.0, 1.0));
    float l2 = opRound(l1, 0.5);
    float l3 = sdBox(p, pos - vec3(0.75, 0.0, -1.0), vec3(0.5, 0.0, 0.0));
    float l4 = opRound(l3, 0.5);
    return opSmoothUnion(l2, l4, 0.1);
}
 
float letterM(vec3 p, vec3 pos, vec3 r, float s) {          
    float h1 = sdBox(rotY((p + pos), -0.3), vec3(0.0), vec3(0.05, 0.0, 1.0));
    float h2 = opRound(h1, 0.5);
    float h3 = sdBox(rotY((p + pos - vec3(0.7, 0.0, 0.0)), 0.3), vec3(0.0), vec3(0.05, 0.0, 1.0));
    float h4 = opRound(h3, 0.5);
    float h5 = sdBox(rotY((p + pos - vec3(1.4, 0.0, 0.0)), -0.3), vec3(0.0), vec3(0.05, 0.0, 1.0));
    float h6 = opRound(h5, 0.5);
    float h7 = sdBox(rotY((p + pos - vec3(2.1, 0.0, 0.0)), 0.3), vec3(0.0), vec3(0.05, 0.0, 1.0));
    float h8 = opRound(h7, 0.5);
    float first = opSmoothUnion(h2, h4, 0.1);
    float second = opSmoothUnion(first, h6, 0.1);
    float third = opSmoothUnion(second, h8, 0.1);
    return third;
}
 
float letterN(vec3 p, vec3 pos, vec3 r, float s) {
    float h1 = sdBox(p, pos, vec3(0.05, 0.0, 1.0));
    float h2 = opRound(h1, 0.5);
    float h3 = sdBox(rotY((p + pos - vec3(0.7, 0.0, 0.0)), 0.5), vec3(0.0), vec3(0.05, 0.0, 1.0));
    float h4 = opRound(h3, 0.5);
    float h5 = sdBox(p, pos - vec3(1.4, 0.0, 0.0), vec3(0.05, 0.0, 1.0));
    float h6 = opRound(h5, 0.5);
    float first = opSmoothUnion(h2, h4, 0.1);
    float second = opSmoothUnion(first, h6, 0.1);
    return second;
}
 
float letterO(vec3 p, vec3 pos, vec3 r, float s) {
    return sdTorus(p, pos, vec2(1.0, 0.5));
}
// Ugly R
float letterR(vec3 p, vec3 pos, vec3 r, float s) {
    float l1 = sdBox(p, pos, vec3(0.05, 0.0, 1.0));
    float l2 = opRound(l1, 0.5);
    float rr = sdTorus(p, pos - vec3(0.45, 0.0, 0.5), vec2(0.5, 0.5));
    float P = opSmoothUnion(l2, rr, 0.1);
    float l3 = sdBox(rotY(p + pos - vec3(0.6, 0.0, -0.6), -0.8), vec3(0.0), vec3(0.5, 0.0, 0.0));
    float l4 = opRound(l3, 0.5);
    return opSmoothUnion(P, l4, 0.1);
}
 
float letterS(vec3 p, vec3 pos, vec3 r, float s) {
    float s1 = sdTorus(p, pos - vec3(0.0, 0.0, 0.5), vec2(0.5, 0.5));
    float box1 = sdBox(p, pos - vec3(0.6, 0.0, 0.2), vec3(0.5, 0.5, 0.5));
    float s2 = sdTorus(p, pos - vec3(0.0, 0.0, -0.5), vec2(0.5, 0.5));
    float box2 = sdBox(p, pos - vec3(-0.6, 0.0, -0.2), vec3(0.5, 0.5, 0.5));
    float first = opSmoothSubtraction(box1, s1, 0.3);
    float second = opSmoothSubtraction(box2, s2, 0.3);
    return opSmoothUnion(first, second, 0.1);
}
 
float letterT(vec3 p, vec3 pos, vec3 r, float s) {
    float l1 = sdBox(p, pos, vec3(0.05, 0.0, 1.0));
    float l2 = opRound(l1, 0.5);
    float l3 = sdBox(p, pos - vec3(0.0, 0.0, 1.0), vec3(0.8, 0.0, 0.0));
    float l4 = opRound(l3, 0.5);
    return opSmoothUnion(l2, l4, 0.1);
}
 
float letterU(vec3 p, vec3 pos, vec3 r, float s) {
    float d1 = sdBox(p, pos + vec3(1.0, 0.0, -0.3), vec3(0.05, 0.0, 0.6));
    float d2 = opRound(d1, 0.5);
    float d3 = sdBox(p, pos + vec3(-1.0, 0.0, -0.3), vec3(0.05, 0.0, 0.6));
    float d4 = opRound(d3, 0.5);
    float torus2 = sdTorus(p, pos, vec2(1.0, 0.5));
    float box2 = sdBox(p, pos + vec3(0.0, 0.0, -1.4), vec3(2.0, 1.0, 1.5));
    float cletter2 = opSmoothSubtraction(box2, torus2, 0.2);
    float cletter3 = opSmoothUnion(cletter2, d2, 0.1);
    return opSmoothUnion(cletter3, d4, 0.1);
}
 
float letterW(vec3 p, vec3 pos, vec3 r, float s) {
    float h1 = sdBox(rotY((p + pos), 0.3), vec3(0.0), vec3(0.05, 0.0, 1.0));
    float h2 = opRound(h1, 0.5);
    float h3 = sdBox(rotY((p + pos - vec3(0.7, 0.0, 0.0)), -0.3), vec3(0.0), vec3(0.05, 0.0, 1.0));
    float h4 = opRound(h3, 0.5);
    float h5 = sdBox(rotY((p + pos - vec3(1.4, 0.0, 0.0)), 0.3), vec3(0.0), vec3(0.05, 0.0, 1.0));
    float h6 = opRound(h5, 0.5);
    float h7 = sdBox(rotY((p + pos - vec3(2.1, 0.0, 0.0)), -0.3), vec3(0.0), vec3(0.05, 0.0, 1.0));
    float h8 = opRound(h7, 0.5);
    float first = opSmoothUnion(h2, h4, 0.1);
    float second = opSmoothUnion(first, h6, 0.1);
    float third = opSmoothUnion(second, h8, 0.1);
    return third;
}
 
float letterX(vec3 p, vec3 pos, vec3 r, float s) {
    float h1 = sdBox(rotY((p + pos), -0.7), vec3(0.0), vec3(0.05, 0.0, 1.2));
    float h2 = opRound(h1, 0.5);
    float h3 = sdBox(rotY((p + pos), 0.7), vec3(0.0), vec3(0.05, 0.0, 1.2));
    float h4 = opRound(h3, 0.5);
    float first = opSmoothUnion(h2, h4, 0.1);
    return first;
}
*/
March scenes(vec3 path)
{  
    if(scene == 1) {
        //Ready
        float displace = sinusoidalPlasma(path, time / 5.5, vec3(0.2),  0.25);

        vec3 path1 = repeat(path, vec3(8.2, 0.0, 0.0));
        vec3 pathr1 = rotX(path1, scene1Rotation);   
        float d1 = sdSphere(pathr1, vec3(0.0, 0.0, 0.0), scene1Detail);
        float d4 = sdMandleBox(pathr1, vec3(0.0), 1.2, 1.8, scene1Modifier.x, 1.0, 1.56);
        float d14 = opSmoothSubtraction(d1, d4, 0.5);
        
        vec3 path2 = repeat(path, vec3(5.0, 0.0, 0.0));
        vec3 pathr2 = rotX(path2, -time / 5.5);
        vec3 wallPath = pathr2 / 2.0;
        float d2 = sdCylinder(rotZ(wallPath, 1.5708), vec3(0.0, 0.0, 0.0), vec3(0.0, 0.0, 3.0)) * 3.0;
        float d6 = sdMandleBox(wallPath, vec3(0.0), 1.2, 1.7, scene1Modifier.y, 1.0, 1.96) * 2.0;
        float d26 = opSmoothSubtraction(d2, d6, 2.5);
        float complete = min(d26, d14);
        float id = step(d26, complete);
        return March(complete, 1.0, path, int(id));
    }
    else if(scene == 2) {
        //this will do
        float complete = 0.0;
        vec3 position = scene2Position;
        float displace = sinusoidalPlasma(path, time, vec3(0.2), 0.05);
        float torus = sdTorus(rotX(path + position, scene2Torus), position, vec2(1.5, 0.5));
  
        float fractal = sdFractal(rotZ(path + position, scene2Fractal), position, vec3(2.0, 3.0, 0.0), 5);

        complete = opSmoothUnion(fractal, torus, scene2Union);
        float id = step(fractal - torus, complete);
        return March(complete, length(path - position), path, int(id));
    }

    else if(scene == 3) {
        //might be some use, menger
        float displace = sinusoidalPlasma(path, time / 5.0, vec3(0.1), 0.9);
        float displace2 = sinusoidalPlasma(path, 2.7, vec3(1.0), 0.03);
        float complete = 0.0;
        vec3 position = vec3(0.0);
        vec3 pathrot = rotZ(rotY(rotX(path, scene3Rotation.x), scene3Rotation.y), scene3Rotation.z);

        float m1 = sdMenger(pathrot, vec3(0.0), 2, 3.0);
        vec3 pathr = repeat(path, vec3(6.0, 2.0, 4.0));
        float m2 = sdMenger(pathr, position, 2, 6.0);
  
        complete =  min(m2 , m1);
        float id = step(m2, complete);
   
        return March(complete, length(path - position), path, int(id));
    }
    else if(scene == 4) {
        //sponge
        float complete = 0.0;
        float d4 = sdMandlebulb(rotZ(rotY(rotX(path + scene4BulbPosition, scene4BulbRotation.x), scene4BulbRotation.y), scene4BulbRotation.z), scene4BulbPosition, scene4BulbDetail.x, scene4BulbDetail.y, 2.0, 20);

        complete = d4;
        return March(complete, abs(length(path - scene4BulbPosition)), path, 0);

    }
    else if(scene == 5) {
        vec3 pathr = rotY(rotX(path, time / 4.0), time / 3.0);
        float d4 = sdMandleBox(pathr, vec3(0.0), 1.0, scene5Detail.x, scene5Detail.y, scene5Detail.z, scene5Detail.w);
        float d5 = sdSphere(path, vec3(0.0, 0.0, 0.0), 1.0);
        float complete = opSmoothSubtraction(d5, d4, 1.0);
        //float d4 = sdMandleBox(path, vec3(0.0), 1.2, 1.8, 0.109, 1.0, 1.56);
        return March(complete, 1.0, pathr, 0);
    }
    else if(scene == 6) {
        float complete = 1000.0;
        const float balls = 15.0;
        const float radius = 2.2;
        const vec3 ballRadius = vec3(0.3, 0.3, 0.3);
        const float freq = 0.5;
        const float height = 2.5;
        float inc = (2.0 * PI / balls);
        float t = time / 1.0;
        float ballsDist = 1000.0;
        for(float i = 1.0; i <= balls; i++) {
            vec3 ballRadius1 = ballRadius;
            float v = scene6Balls - (i * (inc * freq));
  
            float ballDir = (cos(v) * sin(v)) / abs(sin(v));
            float ballY = (-abs(sin(v)) - (ballRadius.y / 2.0)) * height;
            float mal = sinc(sin(v) * 0.5, 22.9) * 0.2;
            if(ballDir > 0.0) {
                ballRadius1.xz += mal;
                ballRadius1.y -= mal;
            }
 
           
            vec3 ballPos = vec3(radius * cos(inc * i),
            ballY,
            radius * sin(inc * i));
            float d = sdEllipsoid(path, ballPos, ballRadius1);
           
            ballsDist = min(d, ballsDist);
        }
        vec3 rpath = rotZ(rotX(path + vec3(0.0, -1.7, 0.0), scene6Rotation), scene6Rotation);
        float ground = sdBox(path, vec3(0.0), vec3(10.0, 0.0, 10.0));
        float cube = sdBox(rpath, vec3(0.0), vec3(1.0));
        complete = min(ballsDist, complete);
        complete = min(ground, complete);
        complete = min(complete, cube);
        
        float id = step(ground, complete);

        if(complete == cube) {
            id = 2.0;
        }
        return March(complete, 1.0, rpath, int(id));
    }
    else if(int(scene) == 7) {
        float complete = 0.0;
        vec3 rpath = rotZ(rotX(path, time / 5.0), time / 2.2);
  
        float cd = sdBox(rpath, vec3(0.0), vec3(2.0));
        return March(cd, 1.0, rpath, 0);

    }
    /*
    else if(int(scene) == 11) {
        float dist;
 
        dist = letterC(path, vec3(1.0, 0.0, 0.0), vec3(0.0), 0.0);
        dist = min(dist, letterO(path, vec3(-2.5, 0.0, 0.0), vec3(0.0), 0.0));
        dist = min(dist, letterD(path, vec3(-5.5, 0.0, 0.0), vec3(0.0), 0.0));
        dist = min(dist, letterE(path, vec3(-8.0, 0.0, 0.0), vec3(0.0), 0.0));
       
        dist = min(dist, letterH(path, vec3(8.0, 0.0, 4.0), vec3(0.0), 0.0));
        dist = min(dist, letterE(path, vec3(5.0, 0.0, 4.0), vec3(0.0), 0.0));
        dist = min(dist, letterL(path, vec3(2.5, 0.0, 4.0), vec3(0.0), 0.0));
        dist = min(dist, letterG(path, vec3(-1.0, 0.0, 4.0), vec3(0.0), 0.0));
        dist = min(dist, letterR(path, vec3(-3.0, 0.0, 4.0), vec3(0.0), 0.0));
        dist = min(dist, letterI(path, vec3(-5.5, 0.0, 4.0), vec3(0.0), 0.0));
        dist = min(dist, letterM(path, vec3(-7.5, 0.0, 4.0), vec3(0.0), 0.0));
        dist = min(dist, letterA(path, vec3(-11.5, 0.0, 4.0), vec3(0.0), 0.0));
       
        dist = min(dist, letterC(path, vec3(2.0, 0.0, 8.0), vec3(0.0), 0.0));
        dist = min(dist, letterO(path, vec3(-1.25, 0.0, 8.0), vec3(0.0), 0.0));
        dist = min(dist, letterL(path, vec3(-3.7, 0.0, 8.0), vec3(0.0), 0.0));
        dist = min(dist, letterH(path, vec3(-6.2, 0.0, 8.0), vec3(0.0), 0.0));
        dist = min(dist, letterO(path, vec3(-10.25, 0.0, 8.0), vec3(0.0), 0.0));
       
        dist = min(dist, letterG(path, vec3(0.0, 0.0, 12.0), vec3(0.0), 0.0));
        dist = min(dist, letterF(path, vec3(-2.5, 0.0, 12.0), vec3(0.0), 0.0));
        dist = min(dist, letterX(path, vec3(-6.0, 0.0, 12.0), vec3(0.0), 0.0));
       
        dist = min(dist, letterW(path, vec3(4.0, 0.0, 16.0), vec3(0.0), 0.0));
        dist = min(dist, letterA(path, vec3(0.0, 0.0, 16.0), vec3(0.0), 0.0));
        dist = min(dist, letterR(path, vec3(-2.5, 0.0, 16.0), vec3(0.0), 0.0));
        dist = min(dist, letterT(path, vec3(-5.5, 0.0, 16.0), vec3(0.0), 0.0));
        dist = min(dist, letterT(path, vec3(-8.5, 0.0, 16.0), vec3(0.0), 0.0));
        dist = min(dist, letterI(path, vec3(-11.1, 0.0, 16.0), vec3(0.0), 0.0));
       
        dist = min(dist, letterM(path, vec3(3.0, 0.0, 20.0), vec3(0.0), 0.0));
        dist = min(dist, letterU(path, vec3(-1.5, 0.0, 20.0), vec3(0.0), 0.0));
        dist = min(dist, letterS(path, vec3(-4.8, 0.0, 20.0), vec3(0.0), 0.0));
        dist = min(dist, letterI(path, vec3(-7.0, 0.0, 20.0), vec3(0.0), 0.0));
        dist = min(dist, letterC(path, vec3(-10.0, 0.0, 20.0), vec3(0.0), 0.0));
       
        dist = min(dist, letterM(path, vec3(10.0, 0.0, 24.0), vec3(0.0), 0.0));
        dist = min(dist, letterA(path, vec3(6.0, 0.0, 24.0), vec3(0.0), 0.0));
        dist = min(dist, letterJ(path, vec3(3.5, 0.0, 24.0), vec3(0.0), 0.0));
        dist = min(dist, letterA(path, vec3(1.0, 0.0, 24.0), vec3(0.0), 0.0));
        dist = min(dist, letterN(path, vec3(-1.0, 0.0, 24.0), vec3(0.0), 0.0));
        dist = min(dist, letterI(path, vec3(-4.0, 0.0, 24.0), vec3(0.0), 0.0));
        dist = min(dist, letterE(path, vec3(-6.0, 0.0, 24.0), vec3(0.0), 0.0));
        dist = min(dist, letterM(path, vec3(-9.0, 0.0, 24.0), vec3(0.0), 0.0));
        dist = min(dist, letterI(path, vec3(-13.0, 0.0, 24.0), vec3(0.0), 0.0));
       
        vec3 position = vec3(0.0, 0.0, 0.0);
 
        float id = 0.0;
        return March(dist, length(path - position), path, int(id));
    }
    */
}


Hit raymarch(vec3 rayOrigin, vec3 rayDirection, bool normals) {
   
    const vec3 eps = vec3(0.001, 0.00, 0.0);

    Hit h;
    h.normalPresent = normals;
    h.steps = 0.0;

    for(float i = 0.0; i <= rayMaxSteps; i++) {
        h.path = rayOrigin + rayDirection * h.dist;
        March m = scenes(h.path);
        h.id = m.id;
        h.steps += 1.0;
        h.last = m.dist;
        h.centerDist = m.centerDist;
        if(m.dist < rayThreshold) {
            if(normals == true) {
                h.normal = normalize(vec3(
                    scenes(h.path + eps.xyy).dist - scenes(h.path - eps.xyy).dist,
                    scenes(h.path + eps.yxy).dist - scenes(h.path - eps.yxy).dist,
                    scenes(h.path + eps.yyx).dist - scenes(h.path - eps.yyx).dist
                ));
            }
            break;
        }
        h.dist += m.dist;

    }
    
    return h;
}

vec3 background(vec2 uv, Hit hit, vec3 eye) {
    vec2 p = uv;
  
    return vec3(0.0);
}

vec3 ambient(vec3 color, float strength) {
    return color * strength;
} 

vec3 diffuse(vec3 normal, vec3 hit, vec3 pos, vec3 color, float strength) {
    vec3 lightDir = normalize(pos - hit);
    float diff = max(dot(normal, lightDir), 0.0);
    vec3 diffuse = diff * color * strength;
    return diffuse;
}

vec3 specular(vec3 normal, vec3 eye, vec3 hit, vec3 pos, vec3 color, float strength, float power) {
    vec3 lightDir = normalize(pos - hit);
    vec3 viewDir = normalize(eye - hit);
    vec3 halfwayDir = normalize(lightDir + viewDir);

    float spec = pow(max(dot(normal, halfwayDir), 0.0), power);
    vec3 specular = strength * spec * color;
    return specular;
} 

//maybe implement distance, so further objects are not shadowed
float shadows(vec3 hitPos, vec3 lightDir, float mint, float maxt, float k) {
    float res = 1.0;
  
    for(float t = mint; t < maxt;) {
        vec3 path = hitPos + lightDir * t;
        float h = scenes(path).dist;
        if(h < 0.001) {
            return 0.0;
        }
        res = min(res, k * h / t);
        t += h;
    }
    return res;
}

vec2 planarMapping(vec3 p) {
    vec3 p1 = normalize(p);
    vec2 r = vec2(0.0);
    if(abs(p1.x) == 1.0) {
        r = vec2((p1.z + 1.0) / 2.0, (p1.y + 1.0) / 2.0);
    }
    else if(abs(p1.y) == 1.0) {
        r = vec2((p1.x + 1.0) / 2.0, (p1.z + 1.0) / 2.0);
    }
    else {
        r = vec2((p1.x + 1.0) / 2.0, (p1.y + 1.0) / 2.0);
    }
    return r;
}
vec2 planarMapping2(vec3 p) {
    vec3 p1 = normalize(p);
    return vec2(p1.x, p1.y);
}

vec2 sphericalMapping(vec3 p) {
    float r = sqrt(pow(p.x, 2.0) + pow(p.y, 2.0) + pow(p.z, 2.0));
    float i = acos(r);
    float a = atan(p.x / p.y);
    return vec2(i, a);
} 

vec2 cylindiricalMapping(vec3 p) {
    return vec2(atan(p.y / p.x), p.z);
}

vec3 processColor(Hit h, vec3 rd, vec3 eye, vec2 uv, vec3 lightPos)
{
    if(h.steps >= rayMaxSteps) {
        //We did not hit anything
        return vec3(0.0, 0.0, 0.0);
    }
    vec3 result = vec3(0.0);
    ShadeParameters sp = shadeParameters[scene - 1];
    vec3 c = sp.color1;
    
    if(scene == 6 && h.id == 2 || scene == 7) {
        c = texture(bogdan, planarMapping(h.path) * 0.2).rgb;
    }
    if(scene == 1 && h.id == 1) {
        c = sp.color2;
    }
    if(scene == 3 && h.id == 1) {
        c = sp.color2;
    }

    if(scene == 2) {
        if(h.id == 1) {
            c = sp.color1;
        }
        else {
             c = sp.color2;
        }
       
    }
     
    if(scene == 4) {
        c += (1.0 - smoothstep(scene4BulbBorder, 1.0, h.centerDist)) * sp.color2;
    }

    vec3 res = (1.0 - smoothstep(0.0, rayMaxSteps, float(h.steps))) * c;
    
    vec3 fog = vec3(0);
    if(sp.fogDistance > 0.0)  {
        fog = vec3(smoothstep(0.0, sp.fogDistance, h.dist));
    }
    vec3 lights = ambient(sp.ambientColor, sp.ambientStrength);
    if(h.normalPresent == true) { 
        vec3 diffuse = diffuse(h.normal, h.path, lightPos, sp.diffuseColor, sp.diffuseStrength);
        vec3 specular = specular(h.normal, eye, h.path, lightPos, sp.specularColor, sp.specularStrength, sp.specularHardness);
        float shadow = 1.0;
        if(sp.shadowHardness > 0.0) {
            shadow = shadows(h.path, normalize(h.path + lightPos), 0.01, rayMaxSteps, sp.shadowHardness);
        }
        lights += diffuse;
        lights += specular;
        result = lights * res * vec3(shadow);
    }
    else {
        result = res * lights;
    }
        
    float gamma = 2.2;
    vec3 correct = pow(result + fog, vec3(1.0 / gamma));
    return vec3(correct);
}

float plot(vec2 st, float pct, float trail){
  return  smoothstep( pct, pct, st.y) -
          smoothstep( pct, pct+trail, st.y);
}

vec3 drawLogo() {
    //allon paikoitus
    vec2 cPos = -1.00 + 2.00 * gl_FragCoord.xy / resolution.xy;
    cPos.x += logoPosition.x;
    cPos.y += logoPosition.y;
    //en tajua mitä tää tekee
    float cLength = length(cPos);
    
    //aaltomäärät, aallon "korkeus" ja aallon nopeus
    float amplitude = sinc(abs(sin(time)), 2.0) * logoAmplitude;
    
    //aallon muodostus (+teksturointi)
    vec2 uv = gl_FragCoord.xy/resolution.xy+(cPos/cLength)*cos(cLength*logoWaves-time*logoSpeed)*amplitude;    
    vec3 col = texture(logo,uv).xyz;
    return col;
}

vec3 drawScope() {
    vec2 st = gl_FragCoord.xy/resolution;

    //aallon muodostus
    float y = sin(st.x*scopeFrequency+(fract(time*scopeSpeed)*PI*2.0))/scopeAmplitude + 1.0;

    vec3 color = vec3(y);
    float pct = plot(st, y / 2.0, scopeTrail);
    color = color * pct * scopeColor;
    return color;
}

vec3 interfere() {
    vec2 st = gl_FragCoord.xy / resolution;

    //aallon muodostus
    float y = sin(st.x * interfereFrequency + (fract(interfereTime) * PI * 2.0)) / interfereAmplitude;

    vec3 color = vec3(y);
    float pct = plot(st, y, interfereTrail);
    color = color * pct * interfereColor;
    return color;
}

vec3 drawSkulls() {
    vec2 cPos = gl_FragCoord.xy / resolution.xy;
    vec3 col = vec3(0.0);

    // kallon vatkuttelua pitkin näyttämöä
    vec2 uv = vec2(cPos.x+0.02*sin(time*2.0), cPos.y+0.05*(sin(time)));
 
    col = texture(gallo,uv).xyz;

    //varjot erotellaan, punainen kanava menee ajan mukaan
    if (col.x < 0.3) {
        col = vec3(col.r*1.0*abs(sin(time)),col.g, col.b);
    };
    
    //näköjään luodaan varjoja... :O
    vec3 prevCol = vec3(
        texture(prevFrame,(uv-0.1*sin(time))).x*1.0,
        texture(prevFrame,(uv-0.1*cos(time))).x*0.9,
        texture(prevFrame,(uv-0.1*sin(-time))).x*2.0);
    //col = col + (prevCol*10.3);
    return col;
}

vec3 drawMarching() {
    float aspectRatio = resolution.y / resolution.x;
    vec2 uv = (gl_FragCoord.xy / resolution) - 0.5;
    
    uv.x /= aspectRatio;
    float fov = 1.0;
    
    vec3 cPos = rayCameraPosition;;
    vec3 cDir = rayCameraLookAt;
    
    vec3 forward = normalize(cDir - cPos); 
    vec3 right = normalize(vec3(forward.z, 0.0, -forward.x)); 
    vec3 up = normalize(cross(forward, right)); 
    
    vec3 rd = normalize(forward + fov * uv.x * right + fov * uv.y * up);
    
    vec3 ro = vec3(cPos);
    int s = int(scene);
    bool needNormals = true;
    if(s == 1 || s == 4) {
        needNormals = false;
    }
    Hit tt = raymarch(ro, rd, needNormals);
    return processColor(tt, rd, ro, uv, lightPosition); 
}
 
void main(void)
{
    int s = int(scene);
    vec2 uv = (gl_FragCoord.xy / resolution);
    float st = hash(vec3(uv + vec2(time * 2.1), 6.0)) * oldTV;
    vec3 o = vec3(0.0);
    if(s == 8) {
        o = drawLogo();
        if(scopeAndLogo >= 1.0) {
            o *= drawScope();
        }
    }
    else if(s == 9) {
        o = drawScope();
        if(scopeAndLogo >= 1.0) {
            o *= drawLogo();
        }
    }
    else if(s == 10) {
        o = drawSkulls();
    }
    else {
        o = drawMarching();
        if(interfereToggle >= 1.0) {
            o *= interfere();
        } 
    }
    o += st;
    outColor = vec4(o, alpha);

}
