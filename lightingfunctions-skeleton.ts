import {initFileShaders, vec4, mat4, vec2, perspective, flatten, lookAt, rotateX, rotateY} from "./helperfunctions.js";


"use strict";
let gl:WebGLRenderingContext;
let program:WebGLProgram; //array of different shader programs

let vPosition:GLint;
let vTexCoord:GLint;
let time:WebGLUniformLocation;

let tick:number = 0.0;

let canvas:HTMLCanvasElement;

window.onload = function init() {

    canvas = document.getElementById("gl-canvas") as HTMLCanvasElement;
    gl = canvas.getContext('webgl2', {antialias:true}) as WebGLRenderingContext;
    if (!gl) {
        alert("WebGL isn't available");
    }


    program = initFileShaders(gl, "vshader-unlit.glsl", "fshader-unlit.glsl");

    gl.useProgram(program);
    gl.viewport(0, 0, gl.drawingBufferWidth, gl.drawingBufferHeight);

    time = gl.getUniformLocation(program, "time");

    makePoint();

    window.setInterval(update, 16);

    requestAnimationFrame(render);

};

function update(){
    tick += 0.01;
    requestAnimationFrame(render);
}

function makePoint(){
    let Points:any[] = [];
    Points.push(new vec4(-1.0,1.0,0,1));
    Points.push(new vec2(-1.0, 1.0));
    Points.push(new vec4(1.0, 1.0, 0, 1));
    Points.push(new vec2(1.0, 1.0));
    Points.push(new vec4(1.0, -1.0, 0, 1));
    Points.push(new vec2(1.0, -1.0));
    Points.push(new vec4(-1.0, -1.0, 0, 1));
    Points.push(new vec2(-1.0, -1.0));

    let bufferId:WebGLBuffer = gl.createBuffer();
    gl.bindBuffer(gl.ARRAY_BUFFER, bufferId);
    gl.bufferData(gl.ARRAY_BUFFER, flatten(Points), gl.STATIC_DRAW);

    vPosition = gl.getAttribLocation(program, "vPosition");
    vTexCoord = gl.getAttribLocation(program, "vTexCoord");

    gl.vertexAttribPointer(vPosition, 4, gl.FLOAT, false, 24, 0);
    gl.enableVertexAttribArray(vPosition);

    gl.vertexAttribPointer(vTexCoord, 2, gl.FLOAT, false, 24, 16)
    gl.enableVertexAttribArray(vTexCoord);
}

//draw a frame
function render(){
    gl.clear(gl.COLOR_BUFFER_BIT);
    gl.uniform1f(time, tick);

    gl.drawArrays(gl.TRIANGLE_FAN, 0, 4);
}