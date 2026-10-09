package funkin.graphics.shaders;

import flixel.math.FlxMath;
import flixel.FlxBasic;
import flixel.addons.display.FlxRuntimeShader;
import openfl.Lib;
import haxe.macro.Type.TypedExpr;
import flixel.system.FlxAssets.FlxShader;
import openfl.filters.ShaderFilter;
import openfl.filters.BitmapFilter;

using StringTools;

class CabinetGlitchChrom extends FlxShader 
{
	@:isVar
	public var amount(get, set):Float = 0.;
	function get_amount()
	{
		return (AMT.value[0]);
	}
	function set_amount(v:Float)
	{
		AMT.value = [v, v];
		return v;
	}

	@:isVar
	public var speed(get, set):Float = 0.;
	function get_speed()
	{
		return (SPEED.value[0]);
	}
	function set_speed(v:Float)
	{
		SPEED.value = [v, v];
		return v;
	}

	@:glFragmentSource('
	#pragma header
	uniform float iTime;


	//2D (returns 0 - 1)
	float random2d(vec2 n) { 
		return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
	}

	float randomRange (in vec2 seed, in float min, in float max) {
			return min + random2d(seed) * (max - min);
	}


	//inputs
	uniform float AMT; //0 - 1 glitch amount
	uniform float SPEED; //0 - 1 speed
	
	void main()
	{
		
		float time = floor(iTime * SPEED * 60.0);    
		vec2 uv = openfl_TextureCoordv.xy;
		
		//copy orig
		vec4 outCol = flixel_texture2D(bitmap, uv);
		
		
		//do slight offset on one entire channel
		float maxColOffset = AMT/6.0;
		float rnd = random2d(vec2(time , 9545.0));
		vec2 colOffset = vec2(randomRange(vec2(time , 9545.0),-maxColOffset,maxColOffset), 
						randomRange(vec2(time , 7205.0),-maxColOffset,maxColOffset));
		if (rnd < 0.33){
			outCol.r = flixel_texture2D(bitmap, uv + colOffset).r;
		}
		else{
			outCol.b = flixel_texture2D(bitmap, uv + colOffset).b;  
		}
		
		gl_FragColor = outCol;
	}
	')

	public function new() {
		super();
		this.iTime.value = [1, 1];
		this.AMT.value = [0.05,0.05];
		this.SPEED.value = [0.6,0.6];
	}

	public function update(elapsed) {
		this.iTime.value[0] += elapsed;
	}
	
}

class Glitch2 extends FlxShader //me make into hardcode kay?
{


	@:isVar
	public var glitchy(get, set):Float = 0;

	function get_glitchy()
	{
		return (GLITCH.value[0]);
	}
	function set_glitchy(v:Float)
	{
		GLITCH.value = [v, v];
		return v;
	}
	
	@:glFragmentSource('
	#pragma header

	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    uniform float iTime;
	uniform float GLITCH;

	float sat( float t ) {
		return clamp( t, 0.0, 1.0 );
	}
	
	vec2 sat( vec2 t ) {
		return clamp( t, 0.0, 1.0 );
	}
	
	//remaps inteval [a;b] to [0;1]
	float remap  ( float t, float a, float b ) {
		return sat( (t - a) / (b - a) );
	}
	
	//note: t=[0;0.5;1], y=[0;1;0]
	float linterp( float t ) {
		return sat( 1.0 - abs( 2.0*t - 1.0 ) );
	}
	
	vec3 spectrum_offset( float t ) {
		vec3 ret;
		float lo = step(t,0.5);
		float hi = 1.0-lo;
		float w = linterp( remap( t, 1.0/6.0, 5.0/6.0 ) );
		float neg_w = 1.0-w;
		ret = vec3(lo,1.0,hi) * vec3(neg_w, w, neg_w);
		return pow( ret, vec3(1.0/2.2) );
	}
	
	//note: [0;1]
	float rand( vec2 n ) {
	  return fract(sin(dot(n.xy, vec2(12.9898, 78.233)))* 43758.5453);
	}
	
	//note: [-1;1]
	float srand( vec2 n ) {
		return rand(n) * 2.0 - 1.0;
	}
	
	float mytrunc( float x, float num_levels )
	{
		return floor(x*num_levels) / num_levels;
	}
	vec2 mytrunc( vec2 x, float num_levels )
	{
		return floor(x*num_levels) / num_levels;
	}
	
	void main()
	{
		vec2 uv = fragCoord.xy / openfl_TextureSize.xy;
		uv.y = uv.y;
		
		float time = mod(iTime*100.0, 32.0)/110.0;

		float gnm = sat( GLITCH );
		float rnd0 = rand( mytrunc( vec2(time, time), 6.0 ) );
		float r0 = sat((1.0-gnm)*0.7 + rnd0);
		float rnd1 = rand( vec2(mytrunc( uv.x, 10.0*r0 ), time) ); //horz
		//float r1 = 1.0f - sat( (1.0f-gnm)*0.5f + rnd1 );
		float r1 = 0.5 - 0.5 * gnm + rnd1;
		r1 = 1.0 - max( 0.0, ((r1<1.0) ? r1 : 0.9999999) ); //note: weird ass bug on old drivers
		float rnd2 = rand( vec2(mytrunc( uv.y, 40.0*r1 ), time) ); //vert
		float r2 = sat( rnd2 );
	
		float rnd3 = rand( vec2(mytrunc( uv.y, 10.0*r0 ), time) );
		float r3 = (1.0-sat(rnd3+0.8)) - 0.1;
	
		float pxrnd = rand( uv + time );
	
		float ofs = 0.05 * r2 * GLITCH * ( rnd0 > 0.5 ? 1.0 : -1.0 );
		ofs += 0.5 * pxrnd * ofs;
	
		uv.y += 0.1 * r3 * GLITCH;
	
		const int NUM_SAMPLES = 20;
		const float RCP_NUM_SAMPLES_F = 1.0 / float(NUM_SAMPLES);
		
		vec4 sum = vec4(0.0);
		vec3 wsum = vec3(0.0);
		for( int i=0; i<NUM_SAMPLES; ++i )
		{
			float t = float(i) * RCP_NUM_SAMPLES_F;
			uv.x = sat( uv.x + ofs * t );
			vec4 samplecol = texture2D( bitmap, uv,-10.);
			vec3 s = spectrum_offset( t );
			samplecol.rgb = samplecol.rgb * s;
			sum += samplecol;
			wsum += s;
		}
		sum.rgb /= wsum;
		sum.a *= RCP_NUM_SAMPLES_F;
	
		//gl_FragColor.a = sum.a;
		//gl_FragColor.rgb = sum.rgb; // * outcol0.a;
		gl_FragColor = sum;
	}
	
    ')
	public function new()
	{
		super();
		this.iTime.value = [1, 1];
		this.GLITCH.value = [0,0];
		// this.chromo.value = [0,0];
	}

	public function update(elapsed){
		this.iTime.value[0] += elapsed;
	}

}

class GlitchShader2 extends FlxShader
{

    @:isVar
	public var amount(get, set):Float = 0;

    function get_amount()
    {
        return (size.value[0]);
    }
    
    function set_amount(v:Float)
    {
        size.value = [v, v];
        return v;
    }


	@:glFragmentSource('
    #pragma header
    vec2 uv = openfl_TextureCoordv.xy;
    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;
    uniform float iTime;

    vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }
       uniform float size;
    float snoise(vec2 v){
      const vec4 C = vec4(0.211324865405187, 0.366025403784439,
               -0.577350269189626, 0.024390243902439);
      vec2 i  = floor(v + dot(v, C.yy) );
      vec2 x0 = v -   i + dot(i, C.xx);
      vec2 i1;
      i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
      vec4 x12 = x0.xyxy + C.xxzz;
      x12.xy -= i1;
      i = mod(i, 289.0);
      vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
      + i.x + vec3(0.0, i1.x, 1.0 ));
      vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
        dot(x12.zw,x12.zw)), 0.0);
      m = m*m ;
      m = m*m ;
      vec3 x = 2.0 * fract(p * C.www) - 1.0;
      vec3 h = abs(x) - 0.5;
      vec3 ox = floor(x + 0.5);
      vec3 a0 = x - ox;
      m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
      vec3 g;
      g.x  = a0.x  * x0.x  + h.x  * x0.y;
      g.yz = a0.yz * x12.xz + h.yz * x12.yw;
      return 130.0 * dot(m, g);
    }
    
    //	Simplex 3D Noise 
    //	by Ian McEwan, Ashima Arts
    
    vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
    vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
    
    float snoise(vec3 v){ 
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
    
      //  x0 = x0 - 0. + 0.0 * C 
      vec3 x1 = x0 - i1 + 1.0 * C.xxx;
      vec3 x2 = x0 - i2 + 2.0 * C.xxx;
      vec3 x3 = x0 - 1. + 3.0 * C.xxx;
    
    // Permutations
      i = mod(i, 289.0 ); 
      vec4 p = permute( permute( permute( 
                 i.z + vec4(0.0, i1.z, i2.z, 1.0 ))
               + i.y + vec4(0.0, i1.y, i2.y, 1.0 )) 
               + i.x + vec4(0.0, i1.x, i2.x, 1.0 ));
    
    // Gradients
    // ( N*N points uniformly over a square, mapped onto an octahedron.)
      float n_ = 1.0/7.0; // N=6
      vec3  ns = n_ * D.wyz - D.xzx;
    
      vec4 j = p - 49.0 * floor(p * ns.z *ns.z);  //  mod(p,N*N)
    
      vec4 x_ = floor(j * ns.z);
      vec4 y_ = floor(j - 7.0 * x_ );    // mod(j,N)
    
      vec4 x = x_ *ns.x + ns.yyyy;
      vec4 y = y_ *ns.x + ns.yyyy;
      vec4 h = 1.0 - abs(x) - abs(y);
    
      vec4 b0 = vec4( x.xy, y.xy );
      vec4 b1 = vec4( x.zw, y.zw );
    
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
      vec4 m = max(0.6 - vec4(dot(x0,x0), dot(x1,x1), dot(x2,x2), dot(x3,x3)), 0.0);
      m = m * m;
      return 42.0 * dot( m*m, vec4( dot(p0,x0), dot(p1,x1), 
                                    dot(p2,x2), dot(p3,x3) ) );
    }
    
    float rand(float n){return fract(sin(n) * 43758.5453123);}
    
    float noise(float p){
        float fl = floor(p);
      float fc = fract(p);
        return mix(rand(fl), rand(fl + 1.0), fc);
    }
    
    void main()
    {
        vec2 uv = fragCoord.xy / openfl_TextureSize.xy;
        //float n = 1.5;
        float n = noise(fragCoord.y + iTime);
        float sdist = snoise(vec2(0.0, uv.y * 8.0 + iTime * 2.0));
        uv.x += size * sdist * snoise(vec3(vec2(uv.x, floor(fragCoord.y / n) * n) + vec2(iTime * 4.4, iTime * 0.2), iTime * 0.4));
        vec2 uv_r = uv + size * 0.1 * sdist * snoise(vec3(vec2(uv.x, floor(fragCoord.y / n) * n) + vec2(iTime * 4.4, iTime * 0.2), iTime * 0.4));
        vec2 uv_b = uv - size * 0.05 * sdist * snoise(vec3(vec2(uv.x, floor(fragCoord.y / n) * n) + vec2(iTime * 4.4, iTime * 0.2), iTime * 0.4));
        vec4 r = flixel_texture2D(bitmap, uv_r);
        //vec4 g = flixel_texture2D(bitmap, uv);
        vec4 b = flixel_texture2D(bitmap, uv_b);

		vec4 col = flixel_texture2D(bitmap,uv);
		col.r = r.r;
		col.b = b.b;
		gl_FragColor = col;

        //gl_FragColor = vec4(r.r, g.g, b.b, 1.0);
    }')
	public function new()
	{
		super();
        this.iTime.value = [0.0];
        this.size.value = [0.05];

	}

    public function update(elapsed:Float) {
        this.iTime.value[0] += elapsed;
    }
}

class Fishlens extends FlxShader //me make into hardcode kay?
{
	@:isVar
	public var intensity(get, set):Float = 1;
	function get_intensity()
	{
		return (power.value[0]);
	}
	function set_intensity(v:Float)
	{
		power.value = [v, v];
		return v;
	}

	@:isVar
	public var chromatic(get, set):Float = 0;

	function get_chromatic()
	{
		return (chromo.value[0]);
	}
	function set_chromatic(v:Float)
	{
		chromo.value = [v, v];
		return v;
	}
	
	@:glFragmentSource('
	#pragma header
	vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;

	uniform float power;
	uniform float chromo;
	
	void main()
	{
		// uv (0 to 1)
		vec2 uv = fragCoord/openfl_TextureSize.xy;
		
		// uv (-1 to 1, 0 - center)
		uv.x = 2. * uv.x - 1.;
		uv.y = 2. * uv.y - 1.;
		
		float barrel_power = power; // increase for BIGGER EYE!
		float theta = atan(uv.y, uv.x);
		float radius = length(uv);
		radius = pow(radius, barrel_power);
		uv.x = radius * cos(theta);
		uv.y = radius * sin(theta);
		
		// uv (0 to 1)
		uv.x = 0.5 * (uv.x + 1.);
		uv.y = 0.5 * (uv.y + 1.);
	
		float chromo_x = chromo;
		float chromo_y = chromo;
		vec4 col = flixel_texture2D(bitmap,uv);
		col.r = flixel_texture2D(bitmap, vec2(uv.x - chromo_x*0.016, uv.y - chromo_y*0.009)).r;
		col.g = flixel_texture2D(bitmap, vec2(uv.x + chromo_x*0.0125, uv.y - chromo_y*0.004)).g;
		col.b = flixel_texture2D(bitmap, vec2(uv.x - chromo_x*0.0045, uv.y + chromo_y*0.0085)).b;
		gl_FragColor = col;
		
		// output
		//gl_FragColor = vec4(flixel_texture2D(bitmap, vec2(uv.x - chromo_x*0.016, uv.y - chromo_y*0.009)).r, flixel_texture2D(bitmap, vec2(uv.x + chromo_x*0.0125, uv.y - chromo_y*0.004)).g, flixel_texture2D(bitmap, vec2(uv.x - chromo_x*0.0045, uv.y + chromo_y*0.0085)).b, 1.0);;
	}
    ')
	public function new()
	{
		super();
		this.power.value = [1, 1];
		this.chromo.value = [0,0];
	}

}
class FollowedGlitch extends FlxShader 
{
	@:isVar
	public var squareAmount(get, set):Float = 0.;
	function get_squareAmount()
	{
		return (prob.value[0]);
	}
	function set_squareAmount(v:Float)
	{
		prob.value = [v, v];
		return v;
	}

	@:isVar
	public var glowAmount(get, set):Float = 0.;
	function get_glowAmount()
	{
		return (intensityChromatic.value[0]);
	}
	function set_glowAmount(v:Float)
	{
		intensityChromatic.value = [v, v];
		return v;
	}

	@:isVar
	public var iTime(get, set):Float = 0.;
	function get_iTime()
	{
		return (time.value[0]);
	}
	function set_iTime(v:Float)
	{
		time.value = [v, v];
		return v;
	}

	@:glFragmentSource('
	// https://www.shadertoy.com/view/XtyXzW

	#pragma header

	uniform float time;
	uniform float prob;
	uniform float intensityChromatic;
	
	int sampleCount = 50;

	float _round(float n) {
		return floor(n + .5);
	}

	vec2 _round(vec2 n) {
		return floor(n + .5);
	}

	vec3 tex2D(sampler2D _tex,vec2 _p)
	{
		vec3 col=texture2D(_tex,_p).xyz;
		if(.5<abs(_p.x-.5)){
			col=vec3(.1);
		}
		return col;
	}

	#define PI 3.14159265359
	#define PHI (1.618033988749895)

	// --------------------------------------------------------
	// Glitch core
	// --------------------------------------------------------

	float rand(vec2 co){
		return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
	}

	float glitchScale = .4;

	vec2 glitchCoord(vec2 p, vec2 gridSize) {
		vec2 coord = floor(p / gridSize) * gridSize;;
		coord += (gridSize / 2.);
		return coord;
	}

	struct GlitchSeed {
		vec2 seed;
		float prob;
	};
		
	float fBox2d(vec2 p, vec2 b) {
	vec2 d = abs(p) - b;
	return min(max(d.x, d.y), 0.0) + length(max(d, 0.0));
	}

	GlitchSeed glitchSeed(vec2 p, float speed) {
		float seedTime = floor(time * speed);
		vec2 seed = vec2(
			1. + mod(seedTime / 100., 100.),
			1. + mod(seedTime, 100.)
		) / 100.;
		seed += p; 
		return GlitchSeed(seed, prob);
	}

	float shouldApply(GlitchSeed seed) {
		return _round(
			mix( mix(rand(seed.seed), 1., seed.prob - .5),  0.,(1. - seed.prob) * .5));
	}

	// gamma again 
	float GAMMA = 1.;

	vec3 gamma(vec3 color, float g) {
		return pow(color, vec3(g));
	}

	// --------------------------------------------------------
	// Glitch effects
	// --------------------------------------------------------

	// Swap

	vec4 swapCoords(vec2 seed, vec2 groupSize, vec2 subGrid, vec2 blockSize) {
		vec2 rand2 = vec2(rand(seed), rand(seed+.1));
		vec2 range = subGrid - (blockSize - 1.);
		vec2 coord = floor(rand2 * range) / subGrid;
		vec2 bottomLeft = coord * groupSize;
		vec2 realBlockSize = (groupSize / subGrid) * blockSize;
		vec2 topRight = bottomLeft + realBlockSize;
		topRight -= groupSize / 2.;
		bottomLeft -= groupSize / 2.;
		return vec4(bottomLeft, topRight);
	}

	float isInBlock(vec2 pos, vec4 block) {
		vec2 a = sign(pos - block.xy);
		vec2 b = sign(block.zw - pos);
		return min(sign(a.x + a.y + b.x + b.y - 3.), 0.);
	}

	vec2 moveDiff(vec2 pos, vec4 swapA, vec4 swapB) {
		vec2 diff = swapB.xy - swapA.xy;
		return diff * isInBlock(pos, swapA);
	}

	void swapBlocks(inout vec2 xy, vec2 groupSize, vec2 subGrid, vec2 blockSize, vec2 seed, float apply) {
		
		vec2 groupOffset = glitchCoord(xy, groupSize);
		vec2 pos = xy - groupOffset;
		
		vec2 seedA = seed * groupOffset;
		vec2 seedB = seed * (groupOffset + .1);
		
		vec4 swapA = swapCoords(seedA, groupSize, subGrid, blockSize);
		vec4 swapB = swapCoords(seedB, groupSize, subGrid, blockSize);
		
		vec2 newPos = pos;
		newPos += moveDiff(pos, swapA, swapB) * apply;
		newPos += moveDiff(pos, swapB, swapA) * apply;
		pos = newPos;
		
		xy = pos + groupOffset;
	}


	// Static

	void staticNoise(inout vec2 p, vec2 groupSize, float grainSize, float contrast) {
		GlitchSeed seedA = glitchSeed(glitchCoord(p, groupSize), 5.);
		seedA.prob *= .5;
		if (shouldApply(seedA) == 1.) {
			GlitchSeed seedB = glitchSeed(glitchCoord(p, vec2(grainSize)), 5.);
			vec2 offset = vec2(rand(seedB.seed), rand(seedB.seed + .1));
			offset = _round(offset * 2. - 1.);
			offset *= contrast;
			p += offset;
		}
	}


	// Freeze time

	void freezeTime(vec2 p, inout float time, vec2 groupSize, float speed) {
		GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), speed);
		//seed.prob *= .5;
		if (shouldApply(seed) == 1.) {
			float frozenTime = floor(time * speed) / speed;
			time = frozenTime;
		}
	}


	// --------------------------------------------------------
	// Glitch compositions
	// --------------------------------------------------------

	void glitchSwap(inout vec2 p) {

		vec2 pp = p;
		
		float scale = glitchScale;
		float speed = 5.;
		
		vec2 groupSize;
		vec2 subGrid;
		vec2 blockSize;    
		GlitchSeed seed;
		float apply;
		
		groupSize = vec2(.6) * scale;
		subGrid = vec2(2);
		blockSize = vec2(1);

		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		apply = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);
		
		groupSize = vec2(.8) * scale;
		subGrid = vec2(3);
		blockSize = vec2(1);
		
		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		apply = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);

		groupSize = vec2(.2) * scale;
		subGrid = vec2(6);
		blockSize = vec2(1);
		
		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		float apply2 = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 1.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 2.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 3.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 4.), apply * apply2);
		swapBlocks(p, groupSize, subGrid, blockSize, (seed.seed + 5.), apply * apply2);
		
		groupSize = vec2(1.2, .2) * scale;
		subGrid = vec2(9,2);
		blockSize = vec2(3,1);
		
		seed = glitchSeed(glitchCoord(p, groupSize), speed);
		apply = shouldApply(seed);
		swapBlocks(p, groupSize, subGrid, blockSize, seed.seed, apply);
	}

	void glitchStatic(inout vec2 p) {
		staticNoise(p, vec2(.5, .25/2.) * glitchScale, .2 * glitchScale, 2.);
	}


	void glitchColor(vec2 p, inout vec3 color) {
		vec2 groupSize = vec2(.75,.125) * glitchScale;
		vec2 subGrid = vec2(0,6);
		float speed = 5.;
		GlitchSeed seed = glitchSeed(glitchCoord(p, groupSize), speed);
		seed.prob *= .3;
		if (shouldApply(seed) == 1.) 
			color = vec3(0, 0, 0);
	}

	vec4 transverseChromatic(vec2 p) {
		vec2 destCoord = p;
		vec2 direction = normalize(destCoord - 0.5); 
		vec2 velocity = direction * intensityChromatic * pow(length(destCoord - 0.5), 3.0);
		float inverseSampleCount = 1.0 / float(sampleCount); 
		
		//mat3x2 increments = mat3x2(velocity * 1.0 * inverseSampleCount, velocity * 2.0 * inverseSampleCount, velocity * 4.0 * inverseSampleCount);

		vec2 increment1 = vec2(velocity * 1.0 * inverseSampleCount);
		vec2 increment2 = vec2(velocity * 2.0 * inverseSampleCount);
		vec2 increment3 = vec2(velocity * 4.0 * inverseSampleCount);

		vec3 accumulator = vec3(0);
		//mat3x2 offsets = mat3x2(0); 
		vec2 offsets1 = vec2(0);
		vec2 offsets2 = vec2(0);
		vec2 offsets3 = vec2(0);


		for (int i = 0; i < sampleCount; i++) {
			accumulator.r += texture2D(bitmap, destCoord + offsets1).r; 
			accumulator.g += texture2D(bitmap, destCoord + offsets2).g; 
			accumulator.b += texture2D(bitmap, destCoord + offsets3).b; 
			offsets1 -= increment1;
			offsets2 -= increment2;
			offsets3 -= increment3;

			//offsets -= increments;
		}
		//vec2 uv = fragCoord/openfl_TextureSize.xy;
		vec4 newColor = vec4(accumulator / float(sampleCount), flixel_texture2D(bitmap,(openfl_TextureCoordv*openfl_TextureSize)/openfl_TextureSize.xy).a);
		return newColor;
	}

	void main() {
		vec2 p = openfl_TextureCoordv.xy;
		vec4 color = texture2D(bitmap, p);
		
		glitchSwap(p);
		glitchStatic(p);

		color = transverseChromatic(p);
		glitchColor(p, color.rgb);
		gl_FragColor = color;
	}
')
	public function new()
	{
		super();
		intensityChromatic.value = [0,0];
		iTime = 0.1;
	}

	public function update(elapsed) {
        iTime += elapsed;
    }

}

class MosiacShader extends FlxShader //kay so i dont know if theres a convenient way to tween runtimeshader values? so im making the mosaic shader a class /data todo? make class and shit built around runtimer shaders to tween em
{
	@:isVar
	public var pixelSize(get, set):Float = 1;

	function get_pixelSize()
	{
		return (pixel.value[0] + pixel.value[1])/2;
	}
	function set_pixelSize(v:Float)
	{
		pixel.value = [v, v];
		return v;
	}
	
	@:glFragmentSource('
        #pragma header

        uniform vec2 pixel;
		void main()
		{
            vec2 size = openfl_TextureSize.xy / pixel;
            gl_FragColor = flixel_texture2D(bitmap, floor(openfl_TextureCoordv.xy * size) / size);
        }
    ')
	public function new()
	{
		super();
		pixel.value = [1, 1];
	}

}

class GlitchShaderA extends FlxShader //https://www.shadertoy.com/view/MscGzl
{

    @:isVar
	public var glitchEffect(get, set):Float = 0;

	function get_glitchEffect()
	{
		return (glitchAmount.value[0]);
	}

	function set_glitchEffect(v:Float)
	{
		glitchAmount.value = [v, v];
		return v;
	}

	@:glFragmentSource('
    #pragma header

    vec2 fragCoord = openfl_TextureCoordv*openfl_TextureSize;

    uniform float glitchAmount;
    uniform float iTime;

    vec4 posterize(vec4 color, float numColors)
    {
        return floor(color * numColors - 0.5) / numColors;
    }

    vec2 quantize(vec2 v, float steps)
    {
        return floor(v * steps) / steps;
    }

    float dist(vec2 a, vec2 b)
    {
        return sqrt(pow(b.x - a.x, 2.0) + pow(b.y - a.y, 2.0));
    }

    void main()
    {   
	    vec2 uv = fragCoord.xy / openfl_TextureSize.xy;
        float amount = pow(glitchAmount, 2.0);
        vec2 pixel = 1.0 / openfl_TextureSize.xy;    
        vec4 color = flixel_texture2D(bitmap, uv);
        float t = mod(mod(iTime, amount * 100.0 * (amount - 0.5)) * 109.0, 1.0);
        vec4 postColor = posterize(color, 16.0);
        vec4 a = posterize(flixel_texture2D(bitmap, quantize(uv, 64.0 * t) + pixel * (postColor.rb - vec2(.5)) * 100.0), 5.0).rbga;
        vec4 b = posterize(flixel_texture2D(bitmap, quantize(uv, 32.0 - t) + pixel * (postColor.rg - vec2(.5)) * 1000.0), 4.0).gbra;
        vec4 c = posterize(flixel_texture2D(bitmap, quantize(uv, 16.0 + t) + pixel * (postColor.rg - vec2(.5)) * 20.0), 16.0).bgra;
        gl_FragColor = mix(flixel_texture2D(bitmap, 
        uv + amount * (quantize((a * t - b + c - (t + t / 2.0) / 10.0).rg, 16.0) - vec2(.5)) * pixel * 100.0),
        (a + b + c) / 3.0, (0.5 - (dot(color, postColor) - 1.5)) * amount);
    }
    
    
    ')
	public function new()
	{
		super();
        this.iTime.value = [0.0];
        this.glitchAmount.value = [0,0];
	}
    public function update(elapsed) {
        this.iTime.value[0] += elapsed;
    }
	
}



class RuntimeShaderHelper extends FlxBasic { //tween values and ig itime?


	// public function new() {
	// 	super();
	// }




	// override public function update(elapsed:Float){
	// 	super.update(elapsed);


	// }




}