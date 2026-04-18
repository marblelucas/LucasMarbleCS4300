struct VertexInput {
  @location(0) pos: vec2f,
  @builtin(instance_index) instance: u32,
};

struct VertexOutput {
  @builtin(position) pos: vec4f,
  @location(0) @interpolate(flat) instance: u32,
  @location(1) uv: vec2f,
};

struct Particle {
  pos: vec2f,
  speed: f32
};

@group(0) @binding(0) var<uniform> frame: f32;
@group(0) @binding(1) var<uniform> res:   vec2f;
@group(0) @binding(2) var<uniform> ratio: f32;
@group(0) @binding(3) var<storage> state: array<Particle>;

fn random (st: vec2f) -> f32 {
    return fract(sin(dot(st.xy,
                         vec2(23.3464,71.4587)))
                 * 37581.9748463);
}

@vertex 
fn vs( input: VertexInput ) ->  VertexOutput {
  let aspect = res.y / res.x;
  let p = state[ input.instance ];
  let size = input.pos * 0.1*random(vec2f(f32( input.instance )));
  //return vec4f( p.pos.x + size.x * aspect, p.pos.y + size.y, 0., 1.); 
  var out = VertexOutput();
  out.pos = vec4f( p.pos.x + size.x * aspect, p.pos.y + size.y, 0., 1.);
  out.instance = input.instance;
  out.uv = input.pos;
  return out;
}

@fragment 
fn fs( input: VertexOutput ) -> @location(0) vec4f {;
  let color = random(vec2f(3.14159*f32( input.instance )));
  var red = 0.;
  var blue = 0.;
  if (color < ratio){
    red = 0.7;
  }
  else {
    blue = 0.55;
  }
  if (length(input.uv) > 1.){
    discard;
  }
  var alpha = 0.;
  if (abs(input.uv.x) < 0.1 || abs(input.uv.y) < 0.1 || abs(input.uv.x) + 4*abs(input.uv.y) < 1. || 4*abs(input.uv.x) + abs(input.uv.y) < 1.){
    alpha = 0.2*(1. - length(input.uv));
  }
//
  return vec4f( red, 0, blue , .4*(1. - length(input.uv)) + alpha);
}
