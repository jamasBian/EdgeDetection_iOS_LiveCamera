
attribute vec4 a_TexturePosition;
attribute vec2 a_TextureCoordinate;

uniform float texelWidthOffset;
uniform float texelHeightOffset;

varying vec2 blurCoordinates[5];

void main()
{
    gl_Position = a_TexturePosition;
    
    vec2 singleStepOffset = vec2(texelWidthOffset, texelHeightOffset);
    blurCoordinates[0] = a_TextureCoordinate.xy;
    blurCoordinates[1] = a_TextureCoordinate.xy + singleStepOffset * 1.500000;
    blurCoordinates[2] = a_TextureCoordinate.xy - singleStepOffset * 1.500000;
    blurCoordinates[3] = a_TextureCoordinate.xy + singleStepOffset * 3.500000;
    blurCoordinates[4] = a_TextureCoordinate.xy - singleStepOffset * 3.500000;
}
