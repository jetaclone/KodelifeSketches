#version 150

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;
uniform vec3 spectrum;
uniform sampler2D texture0;
uniform sampler2D texture1;
uniform sampler2D texture2;
uniform sampler2D texture3;
uniform sampler2D prevFrame;

in VertexData
{
    vec4 v_position;
    vec3 v_normal;
    vec2 v_texcoord;
} inData;

out vec4 fragColor;



void main()
{
    vec2 pos = inData.v_position.xy;
    pos.x = (pos.x*resolution.x)/resolution.y;
    vec2 pos2 = -pos;
    pos = (pos+0.01*time);
    pos2 = (pos2+0.01*time);
    

    vec2 tile = vec2(10, 10);
    float dist = pow(distance(vec2(0.5, 0.5), fract(pos*tile)), mix(3, 4, 0.5 + 0.5*sin(time*3)));
    float dist2 = pow(distance(vec2(0.5, 0.5), fract(pos2*tile + vec2(0.5, 0.5))), mix(3, 4, 0.5 + 0.5*sin(time*3+2)));
    
    dist = 2*dist+3*dist2;
    if (dist < 0.15) dist = 0;

    fragColor = vec4(dist, dist, dist, 1);


}
