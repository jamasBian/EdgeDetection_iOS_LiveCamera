precision mediump float;
attribute vec4 a_TexturePosition; // 1
attribute vec2 a_TextureCoordinate; // New
varying vec2 v_TextureCoordinate; // New






void main(void) { // 4
    gl_Position = a_TexturePosition; // 6
    v_TextureCoordinate = a_TextureCoordinate;
}
