precision highp float;
uniform sampler2D u_TextureBaseRGB;
uniform sampler2D u_BackgroundTextureRGB;
varying vec2 v_TextureCoordinate;


void main()
{
    highp float blurredInput = texture2D(u_TextureBaseRGB, vec2(v_TextureCoordinate.x ,1.0 - v_TextureCoordinate.y )).r;
    highp float localLuminance = texture2D(u_BackgroundTextureRGB, vec2(v_TextureCoordinate.x , v_TextureCoordinate.y )).r;
    highp float thresholdResult = step(blurredInput - 0.04, localLuminance);
    
    gl_FragColor = vec4(vec3(thresholdResult), 1.0);
}

