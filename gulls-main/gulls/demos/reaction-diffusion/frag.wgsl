@group(0) @binding(0) var<uniform> res:   vec2f;
@group(0) @binding(1) var<storage> stateA: array<f32>;
@group(0) @binding(3) var<storage> stateB: array<f32>;

@fragment 
fn fs( @builtin(position) pos : vec4f ) -> @location(0) vec4f {
  let idx : u32 = u32( floor(pos.y) * res.x + floor(pos.x) );
  let v = stateA[ idx ];
  let w = stateB[ idx ];
  return vec4f( w/2, v, 0, 1.);
}
