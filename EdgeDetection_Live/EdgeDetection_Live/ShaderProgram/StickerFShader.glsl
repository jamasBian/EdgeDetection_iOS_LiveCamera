

precision mediump float;

varying vec2 v_TextureCoordinate;
uniform sampler2D u_TextureBaseRGB;

void main(void) {
    vec4 srcColor = texture2D(u_TextureBaseRGB, vec2(v_TextureCoordinate.x , v_TextureCoordinate.y ));
    if (srcColor.a > 0.0) {
        srcColor.r /= srcColor.a; srcColor.g /= srcColor.a; srcColor.b /= srcColor.a;
        
    }
    gl_FragColor = srcColor;//vec4(0.7);
}
