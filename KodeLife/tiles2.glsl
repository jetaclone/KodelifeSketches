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

float rand(vec2 n) { 
    return fract(sin(dot(n, vec2(12.9898, 4.1414))) * 43758.5453);
}

float loopTime(float timeToUse, float modulus, float offset, float scale) {
    return scale*(timeToUse/modulus - floor(timeToUse/modulus)) + offset;
}

float pingpongTime(float timeToUse, float modulus, float offset, float scale) {
    float side = fract(timeToUse/modulus) > 0.5 ? 1 : 0;
    return loopTime(timeToUse, modulus, offset, scale);
}

void main()
{
    //inData.v_position - is in [-1..1] space
    vec2 pos = inData.v_position.xy;
    //pos.x = (pos.x*resolution.x)/resolution.y;

// How many tiles do I want?
    float ar = resolution.x/resolution.y;
    float xTiles = 7*ar;
    float yTiles = 7;

    // Split up the space based on the random value found at the middle of each tile
    vec2 midPt = floor(inData.v_position.xy*vec2(xTiles, yTiles));
    float timeToUse = time - 10;
    float timeCutoff = loopTime(timeToUse, 5, -5, 10);

    vec4 boxCol = vec4(rand(midPt));
    //timeCutoff = 0;
    // This is essentially the alpha for each box.
    boxCol = clamp(boxCol + timeCutoff + -midPt.x/5, 0.0, 1.0);
    
    fragColor = boxCol;

// Now, what we need to do is decide what we want to draw in each box. Can do a black box with white outline?
   // Or white box with black outline?

    // black with white outline    
    // the coordinates of each box within its midpoint
    vec2 coordsInBox = fract(inData.v_position.xy*vec2(xTiles, yTiles));
    float xBorder = (1 - smoothstep(0.01, 0.03, coordsInBox.x)) + smoothstep(0.97, 0.99, coordsInBox.x);
    float yBorder = (1 - smoothstep(0.01, 0.03, coordsInBox.y)) + smoothstep(0.97, 0.99, coordsInBox.y);
    float border = clamp(xBorder+yBorder, 0.0, 1.0);
    // swap colour? Yeah it looks nicer with the black outlines.
    border = 1 - border;
    fragColor = boxCol*vec4(border);
}
