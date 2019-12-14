#version 300 es

precision mediump float;

uniform float time;
uniform float flame;
in vec2 fTexCoord;
out vec4  fColor;

vec2 rand2(vec2 point )
{
    point = vec2( dot(point,vec2(127.1,311.7)),
    dot(point,vec2(269.5,183.3)) );
    return -1.0 + 2.0*fract(sin(point)*43758.5453123);
}


float pnoise(vec2 point )
{
    float K1 = 0.366025404; // (sqrt(3)-1)/2;
    float K2 = 0.211324865; // (3-sqrt(3))/6;

    vec2 i = floor( point + (point.x+point.y)*K1 );

    vec2 a = point - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0);
    vec2 b = a - o + K2;
    vec2 c = a - 1.0 + 2.0*K2;

    vec3 h = max( 0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );

    vec3 n = h*h*h*h*vec3( dot(a,rand2(i+0.0)), dot(b,rand2(i+o)), dot(c,rand2(i+1.0)));

    return dot( n, vec3(70.0) );
}

//Adjusts the x value of the texture
vec2 turbulence(vec2 uv){
    float strength = .04;
    float start = -0.25;
    if(flame == 1.0){
        strength = .05;
        start = -0.85;
    }
    if(uv.y < start){
        return uv;
    }if(uv.y >= start  && uv.y <= 0.0){
        float modifier = 1.0;
        if(int(uv.y * 1000.0) % 2 == 1){
            modifier = -1.0;
        }
        float perc = (uv.y - start) / (0.0 - start);
        float minPerc = ((sin(uv.x/10.0-time*10.0 + uv.y*10.0 * (sin(uv.x*20.0 + time*.5)*.3+1.0))+1.0)*0.0) * (1.0 - perc);
        float maxPerc = ((sin(uv.x/10.0-time*10.0 + uv.y*10.0 * (sin(uv.x*20.0 + time*.5)*.3+1.0))+1.0)* strength * modifier) * perc;
        uv.x += minPerc + maxPerc;
        return uv;
    }
    uv.x += (sin(uv.x/10.0-time*10.0 + uv.y*10.0 * (sin(uv.x*20.0 + time*.5)*.3+1.0))+1.0)* strength;
    return uv;
}



//This helps chill out perlin noise.  Otherwise it is very sparatic. It also adjusts flame flicker i.e. min flame size and size of flicker
float flameModifier(vec2 uv)
{
    float f;
    mat2 m = mat2( 1.7,  1.2, -1.2,  1.7 );
    f  = 0.500*pnoise( uv );
    uv = m*uv;
    f += 0.2500*pnoise( uv );
    uv = m*uv;
    f += 0.1250*pnoise( uv );
    uv = m*uv;
    f += 0.0625*pnoise( uv );
    uv = m*uv;
    //Adjust these to change size and flicker of flame
    if(flame == 0.0){
        f = .6 + .1*f;
    }else{
        f = .5 + .6*f;
    }

    return f;
}


void main()
{
    if(flame == 0.0){
        vec2 uv = turbulence(fTexCoord);
        vec2 q = uv;
        q.x *= 0.5;
        //Makes the flame more round
        q.y *= 1.0;
        q = q - 0.5;

        //Adjusts the strength of the flame
        float strength = floor(q.x+1.0);
        //Make the flame slower or faster
        float T3 = max(2.0, 1.25*strength)*time;
        //Adjusting the location of the flame
        q.x = mod(q.x, 1.)-0.5;
        q.y += .8;
        float n = flameModifier(strength*q - vec2(1, T3));
        //Adjust width and length of flame
        float c = 1.0 - 17.0 * pow(max(0.0, length(q*vec2(1.8+q.y*1.5, .75)) - n * max(0.0, q.y+.15)), 1.0);
        float c1 = n * c * (1.5-pow(2.0*uv.y, 4.0));
        //Forces this color to be between 0 and 1
        c1=clamp(c1, 0.0, 1.0);

        //Color of flame
        vec3 col = vec3(1.5*c1, 1.5*c1*c1*c1, c1*c1*c1*c1*c1*c1);
        float a = c * (1.3-pow(uv.y, 3.0));

        fColor = vec4(mix(vec3(0.), col, a), 1.0);

    }if(flame == 1.0){
        vec2 uv = turbulence(fTexCoord);
        vec2 q = uv;
        q.x *= 0.5;
        q.y *= 1.3;
        q.x -= 0.5;
        float strength = floor(q.x+3.0);
        float T3 = max(3.,2.25*strength)*time;
        q.x = mod(q.x,1.)-0.5;
        q.y += 0.55;
        float n = flameModifier(strength*q - vec2(0,T3));
        float c = 1.0 - 8. * pow( max( 0., length(q*vec2(1.8+q.y*1.5,.95) ) - n * max( 0.0, q.y+.95 ) ),1.9 );
        float c1 = n * c * (1.5-pow(1.00*uv.y,4.));
        c1=clamp(c1,0.,1.);

        vec3 col = vec3(1.5*c1, 1.5*c1*c1*c1, c1*c1*c1*c1*c1*c1);

        float a = c * (1.-pow(uv.y,3.));
        fColor = vec4( mix(vec3(0.),col,a), 1.0);
    }
}
//vec2 tex = fTexCoord;
//vec2 uv = turbulence(fTexCoord);
//vec2 q = uv;
//q.x *= 1.5;
////Makes the flame more round
//q.y *= 0.5;
//q = q - 0.5;
//
////Adjusts the strength of the flame
//float strength = floor(q.x+18.0);
////Make the flame slower or faster
//float T3 = max(2.0, 1.0*strength)*time;
////Adjusting the location of the flame
//q.x = mod(q.x, 1.)-0.5;
//q.y += 1.3;
//float n = flameModifier(strength*q - vec2(1, T3));
////Adjust width and length of flame
//float c = 1.0 - 17.0 * pow(max(0.0, length(q*vec2(1.8+q.y*2.5, .75)) - n * max(0.0, q.y+1.15)), 2.0);
//float c1 = n * c * (1.5-pow(2.0*uv.y, 4.0));
////Forces this color to be between 0 and 1
//c1=clamp(c1, 0.0, 1.0);
//
////Color of flame
//vec3 col = vec3(1.5*c1, 1.5*c1*c1*c1, c1*c1*c1*c1*c1*c1);
//float a = c * (1.3-pow(tex.y, 3.0));
//
//fColor = vec4(mix(vec3(0.), col, a), 1.0);

