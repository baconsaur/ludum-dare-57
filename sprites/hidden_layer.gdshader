    shader_type canvas_item;

    uniform vec4 tint_color : source_color;
    uniform vec4 mask_color : source_color;
	uniform bool is_active = false;

    void fragment() {
		vec4 main_texture = texture(TEXTURE, UV);
		
		if (is_active && distance(main_texture.rgb, mask_color.rgb) > 0.1) {
        	COLOR.rgb = tint_color.rgb;
		}
    }