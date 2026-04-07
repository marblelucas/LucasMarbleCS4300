import { default as gulls } from '../../gulls.js'
import { default as Video    } from '../../helpers/video.js'
import { default as Mouse } from '../../helpers/mouse.js'
import { default as Audio } from '../../helpers/audio.js'
//http://127.0.0.1:8080/howtos/9_video_feedback/
const sg     = await gulls.init(),
      frag   = await gulls.import( './frag.wgsl' ),
      shader = gulls.constants.vertex + frag

await Video.init()
Mouse.init()

const back = new Float32Array( gulls.width * gulls.height * 4 )
const feedback_t = sg.texture( back ) 
const mouse = sg.uniform( Mouse.values )
let time = sg.uniform(0)
let animate = sg.uniform(0);
let shift = sg.uniform(1/3);
let invert = sg.uniform(1/2);
let intensity = sg.uniform(0);

const animateButton = document.getElementById("noiseAnimation");
animateButton.onclick = function() { animate.value = (animate.value + 1) % 2 };

const shifter = document.getElementById("shift");
shifter.oninput = function() {shift.value = this.value;};

const inverter = document.getElementById("invert");
inverter.oninput = function() {invert.value = this.value;};

const intensifier = document.getElementById("intensity");
intensifier.oninput = function() {intensity.value = this.value;};

const render = await sg.render({
  shader,
  data:[
    sg.uniform([ sg.width, sg.height ]),
    mouse,
    time,
    animate,
    shift,
    invert,
    intensity,
    sg.sampler(),
    feedback_t,
    sg.video( Video.element )
  ],
  onframe() {mouse.value = Mouse.values, time.value += 0.01},
  copy: feedback_t
})

sg.run( render )
