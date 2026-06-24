shader_type canvas_item;

instance
uniform float y_threshold: hint_range(0.0, 1.0, 0.001) = 1.;

int[2] get_size_pixels(vec2 texture_pixel_size) {
	vec2 pixels = trunc((1. / texture_pixel_size) / 3.);
	return int[] (int(pixels.x), int(pixels.y));
}

int get_pixel_y(float y, vec2 texture_pixel_size) {
	int pixels = get_size_pixels(texture_pixel_size)[1]; //int(trunc(1. / texture_pixel_size.y));
	int p = int(trunc(y * float(pixels)));
	return p;
}

void fragment() {
	vec3 col = COLOR.rgb;
	
	float yt = y_threshold;
	vec2 uv = UV * 3.; 
	uv = fract(uv);
	if (get_pixel_y(uv.y, TEXTURE_PIXEL_SIZE) >= get_pixel_y(yt, TEXTURE_PIXEL_SIZE)) {
		vec3 mono = vec3(col.g);
		col = mono;
	}
	
	COLOR.rgb = col;
}