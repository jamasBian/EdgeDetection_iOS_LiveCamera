
precision highp float;

varying vec2 v_TextureCoordinate;

uniform sampler2D u_TextureBaseRGB;

const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);

void main()
{
    lowp vec4 textureColor = texture2D(u_TextureBaseRGB, vec2(1.0 - v_TextureCoordinate.x, v_TextureCoordinate.y));
    float luminance = dot(textureColor.rgb, W);
    
    gl_FragColor = vec4(vec3(luminance), textureColor.a);
}
