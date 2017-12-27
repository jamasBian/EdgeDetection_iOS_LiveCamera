
precision mediump float;

varying vec2 v_TextureCoordinate;
uniform sampler2D u_TextureBaseRGB;

void main(void) {
    vec4 t1 = texture2D(u_TextureBaseRGB, vec2(1.0 - v_TextureCoordinate.x, v_TextureCoordinate.y));

    gl_FragColor = vec4(t1.b, t1.g, t1.r, t1.a);
}

