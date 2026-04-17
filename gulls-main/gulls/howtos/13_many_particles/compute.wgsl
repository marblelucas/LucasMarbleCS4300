struct Particle {
  pos: vec2f,
  vel: vec2f
};

@group(0) @binding(0) var<uniform> res:   vec2f;
@group(0) @binding(1) var<storage, read_write> state: array<Particle>;

fn cellindex( cell:vec3u ) -> u32 {
  let size = 8u;
  return cell.x + (cell.y * size) + (cell.z * size * size);
}

@compute
@workgroup_size(8,8)

fn cs(@builtin(global_invocation_id) cell:vec3u)  {
  let i = cellindex( cell );
  let p = state[ i ];
  var next = p.pos - (2. / res) * p.vel;
  if( next.x <= -1. ) { next.x += 2.; next.y = -1.05;}
  if( next.y >= 1. ) { next.y -= 2.; next.x = 1.05;}
  state[i].pos = next;
}
