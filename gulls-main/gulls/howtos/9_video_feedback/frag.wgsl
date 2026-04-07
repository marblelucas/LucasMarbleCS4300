@group(0) @binding(0) var<uniform> resolution: vec2f;
@group(0) @binding(1) var<uniform> mouse: vec3f;
@group(0) @binding(2) var<uniform> time: f32;
@group(0) @binding(3) var<uniform> animate: f32;
@group(0) @binding(4) var<uniform> shifter: f32;
@group(0) @binding(5) var<uniform> inverter: f32;
@group(0) @binding(6) var<uniform> intensity: f32;
@group(0) @binding(7) var videoSampler:   sampler;
@group(0) @binding(8) var backBuffer:     texture_2d<f32>;
@group(1) @binding(0) var videoBuffer:    texture_external;

//The random and noise functions were taken from the book of shaders, and have been modified slightly.

// 2D Random
fn random (st: vec2f) -> f32 {
    return fract(sin(dot(st.xy,
                         vec2(23.3464,71.4587)))
                 * 37581.9748463);
}

// 2D Noise based on Morgan McGuire @morgan3d
// https://www.shadertoy.com/view/4dS3Wd
fn noise (st: vec2f) -> f32 {
    let i = floor(st);
    let f = fract(st);

    // Four corners in 2D of a tile
    let a = random(i);
    let b = random(i + vec2(1.0, 0.0));
    let c = random(i + vec2(0.0, 1.0));
    let d = random(i + vec2(1.0, 1.0));

    // Smooth Interpolation

    // Cubic Hermine Curve.  Same as SmoothStep()
    let u = f*f*(3.0-2.0*f);
    // u = smoothstep(0.,1.,f);

    // Mix 4 coorners percentages
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  var p = pos.xy / resolution;

  var noise = fract(noise(p*1000.0) + animate*random(floor(p/0.001)*0.001*time));

  var xsplit = shifter;
  var shift = 0;

  var ysplit = inverter;
  var invert = false;
  
  if (p.x % xsplit < xsplit / 3){
    p.y = (p.y + 1./3.) % 1;
    shift = 1;
  }
  else if (p.x % xsplit < 2 * xsplit / 3){
    p.y = (p.y + 2./3.) % 1;
    shift = -1;
  }

  if (p.y % ysplit < ysplit / 2){
    p.x = 1 - p.x;
    p.y = 1 - p.y;
    invert = true;
  }

  let video = textureSampleBaseClampToEdge( videoBuffer, videoSampler, p );

  //let fb = textureSample( backBuffer, videoSampler, p );

  var out = video;
  let one = 1;

  if (shift == 1){
    var temp = out[0];
    out[0] = out[1];
    out[1] = out[2];
    out[2] = temp;
  }

  else if (shift == -1){
    var temp = out[0];
    out[0] = out[2];
    out[2] = out[1];
    out[1] = temp;
  }

  if (invert){
    out[0] = 1 - out[0];
    out[1] = 1 - out[1];
    out[2] = 1 - out[2]; 
  }

  out[0] += out[0] * (mouse[1] * 2 - 1);
  out[1] += out[1] * (mouse[1] * 2 - 1);
  out[2] += out[2] * (mouse[1] * 2 - 1);

  let finale = mix(out.rgb, vec3f(noise), intensity);

  return vec4f( finale, 1. );
}

