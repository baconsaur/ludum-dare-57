shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform vec4 target_color : source_color;
uniform vec4 replacement_color : source_color;
uniform float threshold = 0.1;

void fragment() {
	vec4 main_texture = texture(TEXTURE, UV);

    if (main_texture.a > 0.1 && distance(main_texture.rgb, target_color.rgb) < threshold) {
       	main_texture.rgb = replacement_color.rgb;
    }
    
    COLOR = main_texture;
}