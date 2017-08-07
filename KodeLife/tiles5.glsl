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
    float xTiles = 5*ar;
    float yTiles = 5;

    // Split up the space based on the random value found at the middle of each tile
    vec2 midPt = floor(inData.v_position.xy*vec2(xTiles, yTiles));
    float timeToUse = time - 10;
    float timeCutoff = loopTime(timeToUse, 6, -4, 8);
    //timeCutoff = 0;
    float randVal = rand(midPt);
    //timeCutoff = 0;
    // This is essentially the alpha for each box.
    float boxAlpha = clamp(randVal + timeCutoff + -midPt.x/10, 0.0, 1.0);
    
    fragColor = vec4(boxAlpha);

// Try out another boxAlpha setting using the reverse?
    float boxAlpha2 = clamp(randVal - timeCutoff + 3+ midPt.x/10, 0.0, 1.0);
if (timeCutoff > 1) boxAlpha =boxAlpha2;
// Now, what we need to do is decide what we want to draw in each box. Can do a black box with white outline?
   // Or white box with black outline?

    // black with white outline    
    // the coordinates of each box within its midpoint
// I also want to do some sort of "fake" 3D effect where the tiles scale in according to their progression.

    vec2 coordsInBox = fract(inData.v_position.xy*vec2(xTiles, yTiles));
// Ok this probably means scaling the coordsInBox according to boxCol.
// Curves would be nice
    float boxScale = clamp(mix(1.5, 1.0, boxAlpha*2), 1.0, 5.0); 
    // But say I only want to scale the right side of the box (from the centre)
    // and scale the top and bottom only on the right side.
    // so we have to scale our coordinates by the coordinates in the box?
    boxScale = mix(boxScale, 1.0, 1 - coordsInBox.x);
    coordsInBox = (coordsInBox-0.5)*boxScale + 0.5;
    coordsInBox.x = coordsInBox.x + mix(0.0, 0, boxAlpha);
    vec2 borders = (1 - smoothstep(0.01, 0.03, coordsInBox)) + smoothstep(0.97, 0.99, coordsInBox);
 
    float border = clamp(borders.x+borders.y, 0.0, 1.0);
    // swap colour? Yeah it looks nicer with the black outlines.
    border = 1 - border;
    fragColor = boxAlpha*vec4(border);
}
