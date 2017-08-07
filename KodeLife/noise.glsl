#version 150

// I think I grabbed the base noise function from https://github.com/keijiro/ShaderSketches - cred to him

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


float fade(float x) { return x * x * x * (x * (x * 6 - 15) + 10); }

float phash(float p)
{
    // Just a noise function. (sufficiently complex enough that it appears to be noise)
    p = fract(7.8233139 * p);
    p = ((2384.2345 * p - 1324.3438) * p + 3884.2243) * p - 4921.2354;
    return fract(p) * 2 - 1;
}

float noise(float p)
{
// In this context, p is a scale/biased value derived from the screen x pos.
// So we get the integer and fractional components of p
    float ip = floor(p);
    float fp = fract(p);

    // phash returns a single grayscale value 
    float d0 = phash(ip    ) *  fp;
// d1 guaranteed to = d0 at the end point
    float d1 = phash(ip + 1) * (fp - 1);
    // I think the fade function is a quintic (5??) interpolation?
    // so it ends up forming a gradient.
    
    return mix(d0, d1, fade(fp));
}

void main(void)
{
    float p = gl_FragCoord.x * 10 / resolution.x;
    
    p += time * 2 - 10;
    float p2 = gl_FragCoord.y * 20/resolution.y;
    p2 += sin(3*time)*1- 10;
    vec4 col = vec4(noise(p) / 2 + 0.5);
    vec4 col2 = vec4(noise(p2) / 2 + 0.5);
    fragColor = col;


}
