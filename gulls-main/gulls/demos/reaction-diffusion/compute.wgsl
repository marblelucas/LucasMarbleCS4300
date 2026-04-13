@group(0) @binding(0) var<uniform> res: vec2f;
@group(0) @binding(1) var<storage> stateinA: array<f32>;
@group(0) @binding(2) var<storage, read_write> stateoutA: array<f32>;
@group(0) @binding(3) var<storage> stateinB: array<f32>;
@group(0) @binding(4) var<storage, read_write> stateoutB: array<f32>;
@group(0) @binding(5) var<uniform> dA: f32;
@group(0) @binding(6) var<uniform> dB: f32;
@group(0) @binding(7) var<uniform> feeder: f32;
@group(0) @binding(8) var<uniform> killer: f32;
@group(0) @binding(9) var<uniform> styler: f32;

fn index( x:i32, y:i32 ) -> u32 {
  let _res = vec2i(res);
  return u32( (y % _res.y) * _res.x + ( x % _res.x ) );
}

@compute
@workgroup_size(8,8)
fn cs( @builtin(global_invocation_id) _cell:vec3u ) {
  let cell = vec3i(_cell);

  let DiffA = dA;
  let DiffB = dB;
  let feed = feeder;
  let kill = killer - styler*(killer*f32(cell.x)*0.00007+killer*f32(cell.y)*0.00007);
  let time = 1.1;

  let i = index(cell.x, cell.y);
  let LaplaceA = stateinA[index(cell.x + 1, cell.y)] * 0.2 +
                 stateinA[index(cell.x, cell.y - 1)] * 0.2 +
                 stateinA[index(cell.x - 1, cell.y)] * 0.2 +
                 stateinA[index(cell.x, cell.y + 1)] * 0.2 +
                 stateinA[index(cell.x + 1, cell.y + 1)] * 0.05 +
                 stateinA[index(cell.x - 1, cell.y + 1)] * 0.05 +
                 stateinA[index(cell.x + 1, cell.y - 1)] * 0.05 +
                 stateinA[index(cell.x - 1, cell.y - 1)] * 0.05 - 
                 stateinA[index(cell.x, cell.y)];
                 
  let LaplaceB = stateinB[index(cell.x + 1, cell.y)] * 0.2 +
                 stateinB[index(cell.x, cell.y - 1)] * 0.2 +
                 stateinB[index(cell.x - 1, cell.y)] * 0.2 +
                 stateinB[index(cell.x, cell.y + 1)] * 0.2 +
                 stateinB[index(cell.x + 1, cell.y + 1)] * 0.05 +
                 stateinB[index(cell.x - 1, cell.y + 1)] * 0.05 +
                 stateinB[index(cell.x + 1, cell.y - 1)] * 0.05 +
                 stateinB[index(cell.x - 1, cell.y - 1)] * 0.05 - 
                 stateinB[index(cell.x, cell.y)];

  stateoutA[i] = stateinA[i] + (DiffA*LaplaceA - stateinA[i]*stateinB[i]*stateinB[i] + feed*(1 - stateinA[i]))*time;
  stateoutB[i] = stateinB[i] + (DiffB*LaplaceB + stateinA[i]*stateinB[i]*stateinB[i] - (kill + feed)*stateinB[i])*time;
}
