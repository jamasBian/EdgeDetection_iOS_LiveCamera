
uniform sampler2D u_TextureBaseRGB;
uniform highp float texelWidthOffset;
uniform highp float texelHeightOffset;

varying highp vec2 blurCoordinates[5];

void main()
{
    lowp vec4 sum = vec4(0.0);
    sum += texture2D(inputImageTexture, blurCoordinates[0]) * 0.111111;
    sum += texture2D(inputImageTexture, blurCoordinates[1]) * 0.222222;
    sum += texture2D(inputImageTexture, blurCoordinates[2]) * 0.222222;
    sum += texture2D(inputImageTexture, blurCoordinates[3]) * 0.222222;
    sum += texture2D(inputImageTexture, blurCoordinates[4]) * 0.222222;
    gl_FragColor = sum;
}
