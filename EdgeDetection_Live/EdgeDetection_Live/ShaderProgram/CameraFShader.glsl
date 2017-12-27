
precision mediump float;

varying vec2 v_TextureCoordinate;
uniform sampler2D u_TextureBaseRGB;

void main(void) {
    vec4 t1 = texture2D(u_TextureBaseRGB, vec2(1.0 - v_TextureCoordinate.x, v_TextureCoordinate.y));

    gl_FragColor = vec4(t1.b, t1.g, t1.r, t1.a);
}

//varying vec2 v_TextureCoordinate;
//uniform sampler2D u_TextureBaseRGB;
//const highp vec3 W = vec3(0.2125, 0.7154, 0.0721);
//void main(void) {
//    vec4 textureColor = texture2D(u_TextureBaseRGB, vec2(1.0 - v_TextureCoordinate.x, v_TextureCoordinate.y));
//    float luminance = dot(textureColor.rgb, W);
//
//    gl_FragColor = vec4(vec3(luminance), textureColor.a);
//}

