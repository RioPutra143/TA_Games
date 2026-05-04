shader_type canvas_item;

// Mengambil tekstur layar di belakang ColorRect
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform float lod: hint_range(0.0, 5) = 0.0;

void fragment(){
    // Mengambil warna dari layar dengan tingkat blur (lod)
    vec4 blur_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, lod);
    
    // Pakai ini agar warna asli node ColorRect tidak ikut campur
    COLOR = blur_color;
}