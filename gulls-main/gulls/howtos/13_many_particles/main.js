import { default as gulls } from '../../gulls.js'

const sg = await gulls.init(),
      render_shader  = await gulls.import( './render.wgsl' ),
      compute_shader = await gulls.import( './compute.wgsl' )

const NUM_PARTICLES = 2048, 
      NUM_PROPERTIES = 4, 
      state = new Float32Array( NUM_PARTICLES * NUM_PROPERTIES )

for( let i = 0; i < NUM_PARTICLES * NUM_PROPERTIES; i+= NUM_PROPERTIES ) {
  state[ i ] = -1 + Math.random() * 2
  state[ i + 1 ] = -1 + Math.random() * 2
  state[ i + 2 ] = Math.random() * 0.5
  state[ i + 3 ] = -(Math.random() * 0.5)
}

const state_b = sg.buffer( state ),
      frame_u = sg.uniform( 0 ),
      res_u   = sg.uniform([ sg.width, sg.height ]), 
      ratio   = sg.uniform( 0.2 )

const shifter = document.getElementById("shift");
shifter.oninput = function() {ratio.value = this.value;};

const render = await sg.render({
  shader: render_shader,
  data: [
    frame_u,
    res_u,
    ratio,
    state_b
  ],
  onframe() { frame_u.value++ },
  count: NUM_PARTICLES,
  blend: true
})


const dc = Math.ceil( NUM_PARTICLES / 64 )

const compute = sg.compute({
  shader: compute_shader,
  data:[
    res_u,
    state_b,
  ],
  dispatchCount: [ dc, dc, 1 ] 

})

sg.run( compute, render )
