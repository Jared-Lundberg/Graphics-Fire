import { initFileShaders, vec4, vec2, flatten } from "./helperfunctions.js";
"use strict";
let gl;
let program; //array of different shader programs
let vPosition;
let vTexCoord;
let time;
let flameType;
let tick = 0.0;
let flame = 0;
let canvas;
window.onload = function init() {
    canvas = document.getElementById("gl-canvas");
    gl = canvas.getContext('webgl2', { antialias: true });
    if (!gl) {
        alert("WebGL isn't available");
    }
    program = initFileShaders(gl, "vshader.glsl", "fshader.glsl");
    gl.useProgram(program);
    gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);
    time = gl.getUniformLocation(program, "time");
    flameType = gl.getUniformLocation(program, "flame");
    window.addEventListener("keydown", function (event) {
        switch (event.key) {
            case "t":
                if (flame == 1) {
                    flame = 0;
                }
                else {
                    flame = 1;
                }
                break;
        }
    });
    makePoint();
    window.setInterval(update, 16);
    requestAnimationFrame(render);
};
function update() {
    tick += 0.01;
    requestAnimationFrame(render);
}
function makePoint() {
    let Points = [];
    Points.push(new vec4(-1.0, 1.0, 0, 1));
    Points.push(new vec2(-1.0, 1.0));
    Points.push(new vec4(1.0, 1.0, 0, 1));
    Points.push(new vec2(1.0, 1.0));
    Points.push(new vec4(1.0, -1.0, 0, 1));
    Points.push(new vec2(1.0, -1.0));
    Points.push(new vec4(-1.0, -1.0, 0, 1));
    Points.push(new vec2(-1.0, -1.0));
    let bufferId = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, bufferId);
    gl.bufferData(gl.ARRAY_BUFFER, flatten(Points), gl.STATIC_DRAW);
    vPosition = gl.getAttribLocation(program, "vPosition");
    vTexCoord = gl.getAttribLocation(program, "vTexCoord");
    gl.vertexAttribPointer(vPosition, 4, gl.FLOAT, false, 24, 0);
    gl.enableVertexAttribArray(vPosition);
    gl.vertexAttribPointer(vTexCoord, 2, gl.FLOAT, false, 24, 16);
    gl.enableVertexAttribArray(vTexCoord);
}
//draw a frame
function render() {
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.uniform1f(time, tick);
    gl.uniform1f(flameType, flame);
    gl.drawArrays(gl.TRIANGLE_FAN, 0, 4);
}
//# sourceMappingURL=mainfunctions.js.map