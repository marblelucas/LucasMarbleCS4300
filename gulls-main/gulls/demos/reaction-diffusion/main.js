import { default as seagulls } from '../../gulls.js'

const sg      = await seagulls.init(),
      frag    = await seagulls.import( './frag.wgsl' ),
      compute = await seagulls.import( './compute.wgsl' ),
      render  = seagulls.constants.vertex + frag,
      size    = (window.innerWidth * window.innerHeight),
      stateA   = new Float32Array( size ),
      stateB   = new Float32Array( size )

for( let x = 0; x < window.innerWidth; x++ ) {
  for (let y = 0; y < window.innerHeight; y++ ) {
    let i = y * window.innerWidth + x;
    stateA[ i ] = 1;
    stateB[ i ] = 0;
    if (x > window.innerWidth/2 - 100 && x < window.innerWidth/2 + 100 && y > window.innerHeight/2 - 100 && y < window.innerHeight/2 + 100) {
      stateB[ i ] = 1;
    }
  }
}

let diffA = sg.uniform(1.0);
let diffB = sg.uniform(0.5);
let feed = sg.uniform(0.055);
let kill = sg.uniform(0.062);
let style = sg.uniform(0.0);

const statebuffer1 = sg.buffer( stateA )
const statebuffer2 = sg.buffer( stateA )
const statebuffer3 = sg.buffer( stateB )
const statebuffer4 = sg.buffer( stateB )
const res = sg.uniform([ window.innerWidth, window.innerHeight ])

const aDiffuser = document.getElementById("DA");
aDiffuser.oninput = function() {diffA.value = this.value;};

const bDiffuser = document.getElementById("DB");
bDiffuser.oninput = function() {diffB.value = this.value;};

const feeder = document.getElementById("f");
feeder.oninput = function() {feed.value = this.value;};

const killer = document.getElementById("k");
killer.oninput = function() {kill.value = this.value;};

const mapper = document.getElementById("map");
mapper.oninput = function() {style.value = this.value;};

const renderPass = await sg.render({
  shader: render,
  data: [
    res,
    sg.pingpong( statebuffer1, statebuffer2 ),
    sg.pingpong( statebuffer3, statebuffer4 )
  ]
})

const computePass = sg.compute({
  shader: compute,
  data: [ 
    res, 
    sg.pingpong( statebuffer1, statebuffer2 ), 
    sg.pingpong( statebuffer3, statebuffer4 ),
    diffA,
    diffB,
    feed,
    kill,
    style
  ],
  dispatchCount:  [Math.round(seagulls.width / 8), Math.round(seagulls.height/8), 1],
})

sg.run( computePass, renderPass )
